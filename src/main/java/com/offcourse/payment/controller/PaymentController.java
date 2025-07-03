package com.offcourse.payment.controller;

import com.offcourse.config.PortOneConfig;
import com.offcourse.course.model.dto.CourseViewResponse;
import com.offcourse.course.model.service.CourseService;
import com.offcourse.enrollment.model.dto.Enrollment;
import com.offcourse.enrollment.model.service.EnrollmentService;
import com.offcourse.payment.model.dto.PaymentHistory;
import com.offcourse.payment.model.service.PaymentQueueService;
import com.offcourse.payment.model.service.PaymentService;
import com.offcourse.payment.util.PortOneApiUtil;
import com.offcourse.redis.model.dto.Queue;
import com.offcourse.redis.model.dto.QueueStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;
    private final PortOneConfig portOneConfig;
    private final PortOneApiUtil portOneApiUtil;
    private final CourseService courseService;
    private final EnrollmentService enrollmentService;
    private final PaymentQueueService paymentQueueService;

    // [결제 폼 화면]
    @GetMapping("/form")
    public String showPaymentForm(
            @RequestParam Long courseSeq,
            @RequestParam Long memberSeq,
            @RequestParam BigDecimal paymentPrice,
            HttpSession session,
            Model model
    ) {
        String sessionId = session.getId();

        try {
            log.info("결제 페이지 접근 시도 - 세션: {}, 강의: {}, 회원: {}, 금액: {}",
                    sessionId, courseSeq, memberSeq, paymentPrice);

            CourseViewResponse course = courseService.getCourseBySeq(courseSeq);
            if (course == null) {
                log.warn("존재하지 않는 강의 요청 - CourseSeq: {}, SessionId: {}", courseSeq, sessionId);
                model.addAttribute("error", "존재하지 않는 강의입니다.");
                return "redirect:/course/list";
            }

            // 동시 접근 제어를 통한 결제 진입 시도
            Queue accessResult = paymentQueueService.attemptPaymentAccess(sessionId, courseSeq, memberSeq, paymentPrice, course);

            log.info("결제 접근 결과 - 세션: {}, 강의: {}, 상태: {}, 순번: {}",
                    sessionId, courseSeq, accessResult.getStatus(), accessResult.getPosition());

            if (accessResult.getStatus() == QueueStatus.ALLOW) {
                // 결제 진행 가능 - 최종 정원 재확인
                CourseViewResponse latestCourse = courseService.getCourseBySeq(courseSeq);
                if (latestCourse.getCourseCurrentSize() >= latestCourse.getCourseSize()) {
                    log.warn("결제 페이지 진입 중 정원 마감 발생 - 세션: {}, 강의: {}, 현재인원: {}/{}",
                            sessionId, courseSeq, latestCourse.getCourseCurrentSize(), latestCourse.getCourseSize());

                    // 대기열로 강제 이동
                    paymentQueueService.movePaymentUserToQueue(sessionId, courseSeq);
                    Queue waitingResult = paymentQueueService.enterPaymentQueue(sessionId, courseSeq, memberSeq, paymentPrice);
                    return buildPaymentFormModel(model, latestCourse, courseSeq, memberSeq, paymentPrice);
                }

                // 결제 폼으로 이동
                log.info("결제 페이지 진입 허용 - 세션: {}, 강의: {}", sessionId, courseSeq);
                return buildPaymentFormModel(model, latestCourse, courseSeq, memberSeq, paymentPrice);
            } else {
                // 대기열로 이동
                log.info("결제 대기열 진입 - 세션: {}, 강의: {}, 순번: {}",
                        sessionId, courseSeq, accessResult.getPosition());
                return buildPaymentQueueModel(model, accessResult, sessionId, course, courseSeq, memberSeq, paymentPrice);
            }
        } catch (Exception e) {
            log.error("결제 폼 처리 중 오류 - CourseSeq: {}, SessionId: {}", courseSeq, sessionId, e);
            model.addAttribute("error", "결제 처리 중 오류가 발생했습니다.");
            return "redirect:/course/view?courseSeq=" + courseSeq;
        }
    }
//
    // [결제]
    @PostMapping("/process")
    public String processPayment(@RequestParam String impUid,
                                 @RequestParam String orderId,
                                 @RequestParam Long courseSeq,
                                 @RequestParam Long memberSeq,
                                 @RequestParam BigDecimal paymentPrice,
                                 HttpSession session,
                                 RedirectAttributes ra) {
        String sessionId = session.getId();
        try {
            // 1. 결제 정보 검증
            Map<String, Object> paymentInfo = portOneApiUtil.getPaymentInfo(impUid);
            String status = (String) paymentInfo.get("status");
            BigDecimal paidAmount = new BigDecimal(paymentInfo.get("amount").toString());
            // 2. 금액 및 상태 확인
            if (!"paid".equals(status) || paymentPrice.compareTo(paidAmount) != 0) {
                ra.addFlashAttribute("msg", "결제 검증 실패: 결제 금액 또는 상태 불일치");
                return "redirect:/payment/fail";
            }
            // 3. DB 저장
            paymentService.processEnrollmentPayment(courseSeq, memberSeq, paymentPrice, orderId, impUid);
            // 4. 결제 성공 시에만 세션 완료
            paymentQueueService.completePaymentSession(sessionId);
            ra.addFlashAttribute("msg", "결제가 완료되었습니다.");
            return "redirect:/mypage/student";
        } catch (Exception e) {
            log.error("결제 처리 중 오류 - CourseSeq: {}, SessionId: {}", courseSeq, sessionId, e);

            // 시스템 오류 시에만 세션 정리
            if (isSystemError(e)) {
                paymentQueueService.completePaymentSession(sessionId);
                ra.addFlashAttribute("msg", "시스템 오류가 발생했습니다.");
                return "redirect:/course/view?courseSeq=" + courseSeq;
            }

            // 일반 오류는 재시도 가능하도록 세션 유지
            ra.addFlashAttribute("msg", "결제 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
            return "redirect:/payment/form?courseSeq=" + courseSeq + "&memberSeq=" + memberSeq + "&paymentPrice=" + paymentPrice;
        }
    }

    // [환불 폼 화면]
    @GetMapping("/refund-form")
    public String showRefundForm(@RequestParam Long enrSeq,
                                 Model model) {
        PaymentHistory ph = paymentService.findPaymentHistoryByEnrSeq(enrSeq);
        Enrollment enrollment = enrollmentService.selectEnrollmentBySeq(enrSeq);
        CourseViewResponse course = courseService.getCourseBySeq(enrollment.getCourseSeq());
        model.addAttribute("paymentSeq", ph.getPaymentSeq());
        model.addAttribute("enrSeq", enrSeq);
        model.addAttribute("impUid", ph.getPaymentImpUid()); // 수정: paymentImpUid 사용
        model.addAttribute("amount", ph.getPaymentPrice());
        model.addAttribute("course", course);
        return "payment/refundForm";
    }

    // [환불]
    @PostMapping("/refund")
    public String refundPayment(@RequestParam Long paymentSeq,
                                @RequestParam Long enrSeq,
                                @RequestParam String impUid,
                                @RequestParam BigDecimal amount,
                                @RequestParam String reason,
                                RedirectAttributes ra) {
        try {
            // 1. 포트원 환불 API 호출
            portOneApiUtil.cancelPayment(impUid, amount, reason);
            // 2. DB 상태 변경 (환불 완료 처리)
            paymentService.refundPayment(paymentSeq, enrSeq, reason);
            ra.addFlashAttribute("msg", "환불이 완료되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "환불 처리 중 오류: " + e.getMessage());
        }
        return "redirect:/mypage/student";
    }

    // [결제 대기열 페이지]
    @GetMapping("/queue")
    public String showPaymentQueue(
            @RequestParam Long courseSeq,
            @RequestParam Long memberSeq,
            @RequestParam BigDecimal paymentPrice,
            @RequestParam(required = false) String reason,
            HttpSession session,
            Model model
    ) {
        String sessionId = session.getId();

        try {
            log.info("결제 대기열 페이지 접근 - 세션: {}, 강의: {}, 사유: {}", sessionId, courseSeq, reason);

            CourseViewResponse course = courseService.getCourseBySeq(courseSeq);
            if (course == null) {
                log.warn("존재하지 않는 강의 요청 - CourseSeq: {}", courseSeq);
                return "redirect:/course/list";
            }

            // 현재 결제 대기열 상태 확인
            Queue queueStatus = paymentQueueService.getCurrentPaymentStatus(sessionId, courseSeq);

            // 만약 허용 상태라면 결제 페이지로 리다이렉트
            if (queueStatus.getStatus() == QueueStatus.ALLOW) {
                log.info("결제 대기열에서 허용 상태로 변경됨 - 세션: {}", sessionId);
                return "redirect:/payment/form?courseSeq=" + courseSeq +
                        "&memberSeq=" + memberSeq + "&paymentPrice=" + paymentPrice;
            }

            return buildPaymentQueueModel(model, queueStatus, sessionId, course, courseSeq, memberSeq, paymentPrice);

        } catch (Exception e) {
            log.error("결제 대기열 페이지 처리 중 오류 - SessionId: {}", sessionId, e);
            model.addAttribute("error", "결제 대기열 처리 중 오류가 발생했습니다.");
            return buildPaymentQueueModel(model, null, sessionId, null, courseSeq, memberSeq, paymentPrice);
        }
    }

    // ====================== 통합된 AJAX 엔드포인트 ======================

    /**
     * [통합 상태 조회] - 결제 페이지와 대기열 페이지 모두에서 사용
     * 기존의 /status와 /queue/status를 통합
     */
    @GetMapping("/status")
    @ResponseBody
    public Map<String, Object> getPaymentStatus(
            @RequestParam Long courseSeq,
            @RequestParam(required = false, defaultValue = "false") boolean isQueuePage,
            HttpSession session
    ) {
        String sessionId = session.getId();

        try {
            // 1. 강의 정보 조회 (DB 기준)
            CourseViewResponse course = courseService.getCourseBySeq(courseSeq);
            if (course == null) {
                return Map.of(
                        "canProceed", false,
                        "error", "강의 정보를 찾을 수 없습니다.",
                        "timestamp", System.currentTimeMillis()
                );
            }

            // 2. 현재 세션의 결제 상태 확인
            Queue sessionStatus = paymentQueueService.getCurrentPaymentStatus(sessionId, courseSeq);

            // 3. 실시간 결제 관련 인원 수 계산
            int currentEnrolled = course.getCourseCurrentSize(); // DB 등록자 수
            int maxCapacity = course.getCourseSize(); // 정원
            int activePaymentUsers = paymentQueueService.getActivePaymentUsersCount(courseSeq); // Redis 결제 진행자
            int waitingPaymentUsers = paymentQueueService.getPaymentQueueCount(courseSeq); // Redis 대기자

            // 4. 총 점유 인원 및 실제 사용 가능한 자리 계산
            int totalOccupied = currentEnrolled + activePaymentUsers;
            int actualAvailableSlots = maxCapacity - totalOccupied;

            // 5. 세션 기준 결제 진행 가능 여부 판단
            boolean sessionCanProceed = false;
            String sessionStatusStr = "UNKNOWN";
            Long sessionPosition = 0L;

            if (sessionStatus != null) {
                sessionStatusStr = sessionStatus.getStatus().name();
                sessionPosition = sessionStatus.getPosition() != null ? sessionStatus.getPosition() : 0L;

                // 이미 결제 진행 중인 세션은 계속 진행 가능
                if (sessionStatus.getStatus() == QueueStatus.ALLOW) {
                    sessionCanProceed = true;
                }
                // 대기열에 있으면 진행 불가
                else if (sessionStatus.getStatus() == QueueStatus.WAITING) {
                    sessionCanProceed = false;
                }
            } else {
                // 세션 상태가 없으면 여유 자리 기준으로 판단
                sessionCanProceed = actualAvailableSlots > 0;
            }

            // 6. 결제 세션 활동 업데이트 (결제 진행 중인 경우에만)
            if (sessionCanProceed && sessionStatus != null && sessionStatus.getStatus() == QueueStatus.ALLOW) {
                paymentQueueService.updatePaymentActivity(sessionId);
            }

            log.debug("결제 상태 체크 - 세션: {}, 강의: {}, 세션상태: {}, 진행가능: {}, 등록: {}/{}, 결제중: {}, 총점유: {}/{}, 실제여유: {}",
                    sessionId, courseSeq, sessionStatusStr, sessionCanProceed,
                    currentEnrolled, maxCapacity, activePaymentUsers,
                    totalOccupied, maxCapacity, actualAvailableSlots);

            Map<String, Object> result = new HashMap<>();

            // 기본 정보
            result.put("canProceed", sessionCanProceed);
            result.put("currentSize", currentEnrolled);
            result.put("maxSize", maxCapacity);
            result.put("activePaymentUsers", activePaymentUsers);
            result.put("waitingPaymentUsers", waitingPaymentUsers);
            result.put("totalOccupied", totalOccupied);
            result.put("availableSlots", Math.max(0, actualAvailableSlots));
            result.put("courseName", course.getCourseName() != null ? course.getCourseName() : "");
            result.put("sessionStatus", sessionStatusStr);
            result.put("sessionPosition", sessionPosition);
            result.put("timestamp", System.currentTimeMillis());

            // 대기열 페이지용 추가 정보
            if (isQueuePage && sessionStatus != null) {
                result.put("status", sessionStatus.getStatus().name());
                result.put("position", sessionPosition);
                result.put("estimatedWaitTime", sessionStatus.getEstimatedWaitTime());
                result.put("queueType", sessionStatus.getQueueType() != null ? sessionStatus.getQueueType().name() : "PAYMENT");
                result.put("courseSeq", courseSeq);
                result.put("memberSeq", sessionStatus.getMemberSeq());
                result.put("paymentPrice", sessionStatus.getPaymentPrice());
                result.put("courseCurrentSize", currentEnrolled);
                result.put("courseMaxSize", maxCapacity);
            }

            String message;
            if (sessionCanProceed) {
                message = "결제 진행 가능";
            } else if (sessionStatusStr.equals("WAITING")) {
                message = String.format("대기열에서 대기 중 (순번: %d)", sessionPosition);
            } else if (totalOccupied >= maxCapacity) {
                message = String.format("정원 초과 (총 %d/%d명)", totalOccupied, maxCapacity);
            } else {
                message = "수강 인원 마감";
            }
            result.put("message", message);

            return result;

        } catch (Exception e) {
            log.error("결제 상태 체크 중 오류 - CourseSeq: {}, SessionId: {}", courseSeq, sessionId, e);
            return Map.of(
                    "canProceed", false,
                    "error", "상태 확인 중 오류가 발생했습니다.",
                    "timestamp", System.currentTimeMillis()
            );
        }
    }

    /**
     * [통합 하트비트] - 결제 페이지와 대기열 페이지 모두에서 사용
     * 기존의 /heartbeat와 /queue/heartbeat를 통합
     */
    @PostMapping("/heartbeat")
    @ResponseBody
    public Map<String, Object> paymentHeartbeat(
            @RequestParam Long courseSeq,
            @RequestParam(required = false, defaultValue = "false") boolean isQueuePage,
            HttpSession session
    ) {
        String sessionId = session.getId();

        try {
            // 1. 결제 세션 활동 업데이트
            paymentQueueService.updatePaymentActivity(sessionId);

            // 2. 현재 결제 상태 확인 (세션 기준)
            Queue currentStatus = paymentQueueService.getCurrentPaymentStatus(sessionId, courseSeq);

            // 3. 강의 정보 및 실시간 인원 체크
            CourseViewResponse course = courseService.getCourseBySeq(courseSeq);
            int currentEnrolled = course.getCourseCurrentSize();
            int maxCapacity = course.getCourseSize();
            int activePaymentUsers = paymentQueueService.getActivePaymentUsersCount(courseSeq);
            int waitingPaymentUsers = paymentQueueService.getPaymentQueueCount(courseSeq);

            // 4. 총 점유 인원 및 실제 여유 자리 계산
            int totalOccupied = currentEnrolled + activePaymentUsers;
            int actualAvailableSlots = maxCapacity - totalOccupied;
            boolean hasCapacity = actualAvailableSlots > 0;

            log.debug("하트비트 - 세션: {}, 강의: {}, 세션상태: {}, 등록: {}/{}, 결제중: {}, 총점유: {}/{}, 실제여유: {}",
                    sessionId, courseSeq, currentStatus.getStatus(), currentEnrolled, maxCapacity,
                    activePaymentUsers, totalOccupied, maxCapacity, actualAvailableSlots);

            Map<String, Object> response = new HashMap<>();

            // 5. 상태별 처리
            if (currentStatus.getStatus() == QueueStatus.ALLOW) {
                // 결제 진행 중인 사용자
                response.put("status", "alive");
                response.put("canProceed", true);
                response.put("queueStatus", "ALLOW");
                response.put("currentSize", currentEnrolled);
                response.put("maxSize", maxCapacity);
                response.put("hasCapacity", hasCapacity);
                response.put("activePaymentUsers", activePaymentUsers);
                response.put("waitingPaymentUsers", waitingPaymentUsers);
                response.put("totalOccupied", totalOccupied);
                response.put("paymentStatus", currentStatus.getStatus().name());
                response.put("position", 0);
                response.put("actualAvailableSlots", actualAvailableSlots);
                response.put("timestamp", System.currentTimeMillis());

                // 경고: 정원 초과 상태 감지
                if (totalOccupied > maxCapacity) {
                    log.warn("정원 초과 상태에서 결제 진행 중 - 세션: {}, 총점유: {}/{}",
                            sessionId, totalOccupied, maxCapacity);
                    response.put("warning", "정원 초과 상태입니다. 신속히 결제를 완료해주세요.");
                }

            } else if (currentStatus.getStatus() == QueueStatus.WAITING) {
                // 대기열에 있는 사용자
                response.put("status", "alive");
                response.put("canProceed", false);
                response.put("queueStatus", "WAITING");
                response.put("currentSize", currentEnrolled);
                response.put("maxSize", maxCapacity);
                response.put("hasCapacity", hasCapacity);
                response.put("activePaymentUsers", activePaymentUsers);
                response.put("waitingPaymentUsers", waitingPaymentUsers);
                response.put("totalOccupied", totalOccupied);
                response.put("paymentStatus", currentStatus.getStatus().name());
                response.put("position", currentStatus.getPosition() != null ? currentStatus.getPosition() : 1);
                response.put("estimatedWaitTime", currentStatus.getEstimatedWaitTime());
                response.put("actualAvailableSlots", actualAvailableSlots);
                response.put("timestamp", System.currentTimeMillis());

                // 정원이 가득 찬 경우 메시지 추가
                if (actualAvailableSlots <= 0) {
                    response.put("message", String.format("정원 초과로 대기 중 (총 %d/%d명)", totalOccupied, maxCapacity));
                }

            } else {
                // 알 수 없는 상태 - 대기열로 이동 권장
                log.warn("알 수 없는 결제 상태 - 세션: {}, 상태: {}", sessionId, currentStatus.getStatus());

                response.put("status", "redirect_to_queue");
                response.put("message", "세션 상태가 불명확하여 대기열로 이동합니다.");
                response.put("currentSize", currentEnrolled);
                response.put("maxSize", maxCapacity);
                response.put("activePaymentUsers", activePaymentUsers);
                response.put("totalOccupied", totalOccupied);
                response.put("reason", "UNKNOWN_STATUS");
            }

            return response;

        } catch (Exception e) {
            log.error("하트비트 처리 중 오류 - SessionId: {}", sessionId, e);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "error");
            response.put("message", "하트비트 처리 중 오류가 발생했습니다.");
            response.put("timestamp", System.currentTimeMillis());

            return response;
        }
    }

    // [결제 취소/이탈]
    @PostMapping("/leave")
    @ResponseBody
    public Map<String, Object> leavePayment(HttpSession session) {
        String sessionId = session.getId();
        log.info("결제 페이지 이탈 신호 - 세션: {}", sessionId);

        try {
            // 결제 대기열에서 사용자 제거
            boolean removed = paymentQueueService.leavePaymentQueue(sessionId);

            if (removed) {
                log.info("결제 대기열에서 사용자 제거 완료 - 세션: {}", sessionId);

                return Map.of(
                        "success", true,
                        "message", "결제 대기열에서 제거됨",
                        "removed", true,
                        "action", "queue_left",
                        "timestamp", System.currentTimeMillis()
                );
            } else {
                log.debug("결제 대기열에서 제거할 사용자 없음 - 세션: {}", sessionId);

                return Map.of(
                        "success", true,
                        "message", "이탈 신호 기록됨",
                        "removed", false,
                        "action", "signal_recorded",
                        "timestamp", System.currentTimeMillis()
                );
            }
        } catch (Exception e) {
            log.error("결제 이탈 처리 중 오류 - 세션: {}", sessionId, e);
            return Map.of(
                    "success", false,
                    "message", "이탈 처리 중 오류 발생",
                    "error", e.getMessage(),
                    "timestamp", System.currentTimeMillis()
            );
        }
    }

    /**
     * 결제 진행 상태에서 대기열로 강제 이동
     */
    @PostMapping("/moveToQueue")
    @ResponseBody
    public Map<String, Object> moveToQueue(
            @RequestParam Long courseSeq,
            @RequestParam(required = false) String reason,
            HttpSession session) {

        String sessionId = session.getId();

        try {
            log.info("결제 진행 상태에서 대기열로 이동 - 세션: {}, 강의: {}, 사유: {}",
                    sessionId, courseSeq, reason);
            // 1. 강의 정보 확인
            CourseViewResponse course = courseService.getCourseBySeq(courseSeq);
            if (course == null) {
                return Map.of(
                        "success", false,
                        "message", "존재하지 않는 강의입니다.",
                        "timestamp", System.currentTimeMillis()
                );
            }

            // 2. 결제 진행 상태에서 대기열로 이동
            paymentQueueService.movePaymentUserToQueue(sessionId, courseSeq);

            // 3. 이동 후 대기열 정보 조회
            int waitingPaymentUsers = paymentQueueService.getPaymentQueueCount(courseSeq);
            int activePaymentUsers = paymentQueueService.getActivePaymentUsersCount(courseSeq);

            return Map.of(
                    "success", true,
                    "message", "대기열로 이동 완료",
                    "reason", reason != null ? reason : "UNKNOWN",
                    "courseSeq", courseSeq,
                    "courseName", course.getCourseName(),
                    "currentSize", course.getCourseCurrentSize(),
                    "maxSize", course.getCourseSize(),
                    "waitingPaymentUsers", waitingPaymentUsers,
                    "activePaymentUsers", activePaymentUsers,
                    "timestamp", System.currentTimeMillis()
            );

        } catch (Exception e) {
            log.error("대기열 이동 처리 중 오류 - 세션: {}, 강의: {}", sessionId, courseSeq, e);

            // 에러가 발생해도 세션 정리는 시도
            try {
                paymentQueueService.leavePaymentQueue(sessionId);
            } catch (Exception cleanupError) {
                log.warn("세션 정리 중 추가 오류 - 세션: {}", sessionId, cleanupError);
            }

            return Map.of(
                    "success", false,
                    "message", "대기열 이동 중 오류 발생",
                    "error", e.getMessage(),
                    "reason", reason != null ? reason : "ERROR",
                    "timestamp", System.currentTimeMillis()
            );
        }
    }

    // ==================== Helper 메서드 ====================

    private String buildPaymentFormModel(Model model, CourseViewResponse course,
                                         Long courseSeq, Long memberSeq, BigDecimal paymentPrice) {
        // 실시간 결제 관련 인원 수 조회
        int activePaymentUsers = paymentQueueService.getActivePaymentUsersCount(courseSeq);
        int waitingPaymentUsers = paymentQueueService.getPaymentQueueCount(courseSeq);

        model.addAttribute("course", course);
        model.addAttribute("courseSeq", courseSeq);
        model.addAttribute("memberSeq", memberSeq);
        model.addAttribute("paymentPrice", paymentPrice);
        model.addAttribute("orderId", "OFFCOURSE_ORDER_ID_" + System.currentTimeMillis());
        model.addAttribute("impCode", portOneConfig.getImpCode());
        // 실시간 인원 정보 추가
        model.addAttribute("activePaymentUsers", activePaymentUsers);
        model.addAttribute("waitingPaymentUsers", waitingPaymentUsers);

        return "payment/paymentForm";
    }

    private String buildPaymentQueueModel(Model model, Queue queueStatus, String sessionId,
                                          CourseViewResponse course, Long courseSeq, Long memberSeq, BigDecimal paymentPrice) {
        model.addAttribute("queue", queueStatus);
        model.addAttribute("sessionId", sessionId);
        model.addAttribute("courseSeq", courseSeq);
        model.addAttribute("memberSeq", memberSeq);
        model.addAttribute("paymentPrice", paymentPrice);
        model.addAttribute("course", course);

        // 강제 진입인지 확인
        if (queueStatus != null && queueStatus.getMessage() != null) {
            boolean isForceEntry = queueStatus.getMessage().contains("이동되었습니다") ||
                    queueStatus.getMessage().contains("마감되어");
            model.addAttribute("forceEntry", isForceEntry);
        }

        return "payment/paymentQueue"; // 새로운 결제 대기열 전용 JSP
    }

    private boolean isSystemError(Exception e) {
        // 시스템 레벨 오류 판단 로직
        return e.getCause() instanceof SQLException ||
                e instanceof DataAccessException ||
                e.getMessage().contains("Connection") ||
                e.getMessage().contains("Timeout");
    }
}