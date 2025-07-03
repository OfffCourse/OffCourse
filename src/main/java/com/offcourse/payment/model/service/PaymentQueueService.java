package com.offcourse.payment.model.service;

import com.offcourse.course.model.dto.CourseViewResponse;
import com.offcourse.redis.model.dto.Queue;
import com.offcourse.redis.model.dto.QueueStatus;
import com.offcourse.redis.model.dto.QueueType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentQueueService {

    private final StringRedisTemplate stringRedisTemplate;

    // Redis Key 상수 - 결제 전용
    private static final String PAYMENT_QUEUE_KEY = "queue:payment:waiting:";
    private static final String PAYMENT_ACTIVE_KEY = "queue:payment:active:";
    private static final String PAYMENT_SESSION_KEY = "queue:payment:session:";
    private static final String PAYMENT_ACTIVITY_KEY = "queue:payment:activity:";
    private static final String PAYMENT_INFO_KEY = "queue:payment:info:";
    private static final String PAYMENT_LOCK_KEY = "queue:payment:lock:";

    @Value("${queue.payment-timeout:600}")
    private int paymentTimeout;

    /**
     * 결제 접근 시도 (동시 접근 제어)
     * 여유 자리가 있으면 결제 진행, 없으면 대기열 진입
     */
    public Queue attemptPaymentAccess(String sessionId, Long courseSeq, Long memberSeq,
                                      BigDecimal paymentPrice, CourseViewResponse course) {
        String lockKey = PAYMENT_LOCK_KEY + "access:" + courseSeq;
        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 10, TimeUnit.SECONDS);

        if (Boolean.FALSE.equals(lockAcquired)) {
            log.warn("결제 접근 락 획득 실패 - 세션: {}, 강의: {}", sessionId, courseSeq);
            // 락 실패 시 잠시 대기 후 대기열 진입
            try {
                Thread.sleep(200);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return enterPaymentQueue(sessionId, courseSeq, memberSeq, paymentPrice);
        }

        try {
            // 1. 이미 결제 진행 중인지 확인
            String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
            String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;
            Boolean isAlreadyActive = stringRedisTemplate.opsForSet().isMember(paymentActiveKey, sessionId);

            if (Boolean.TRUE.equals(isAlreadyActive)) {
                // 이미 결제 진행 중
                log.debug("이미 결제 진행 중인 사용자: {}", sessionId);
                updatePaymentActivity(sessionId);
                return Queue.createAllowedQueue(sessionId, QueueType.PAYMENT);
            }

            // 2. 이미 대기열에 있는지 확인
            Double queueScore = stringRedisTemplate.opsForZSet().score(paymentQueueKey, sessionId);
            if (queueScore != null) {
                log.debug("이미 대기열에 있는 사용자 재접근: {}", sessionId);
                updatePaymentActivity(sessionId);
                return getCurrentPaymentStatus(sessionId, courseSeq);
            }

            // 3. 정확한 여유 자리 계산 (동시성 고려)
            int currentEnrolled = course.getCourseCurrentSize(); // DB에서 가져온 현재 등록자 수
            int maxCapacity = course.getCourseSize(); // 강의 정원

            // 현재 결제 진행 중인 사람 수
            Long paymentActiveCount = stringRedisTemplate.opsForSet().size(paymentActiveKey);
            int activePayments = paymentActiveCount != null ? paymentActiveCount.intValue() : 0;

            // 실제 사용 가능한 자리 = 정원 - 현재 등록된 사용자 - 결제 진행 중인 사용자
            int availableSlots = maxCapacity - currentEnrolled - activePayments;

            log.info("결제 접근 시도 - 강의: {}, 정원: {}, 등록: {}, 결제중: {}, 여유: {}",
                    courseSeq, maxCapacity, currentEnrolled, activePayments, availableSlots);

            // 4. 여유 자리가 있으면 바로 결제 진행 허용
            if (availableSlots > 0) {
                // Redis에 결제 진행 상태 추가
                Long addResult = stringRedisTemplate.opsForSet().add(paymentActiveKey, sessionId);
                if (addResult != null && addResult > 0) {
                    // 결제 진행 상태 만료 시간 설정 (결제 제한 시간과 동일)
                    stringRedisTemplate.expire(paymentActiveKey, paymentTimeout, TimeUnit.SECONDS);
                    // 성공적으로 추가됨
                    startPaymentSession(sessionId, courseSeq);
                    savePaymentInfo(sessionId, courseSeq, memberSeq, paymentPrice,course);

                    log.info("결제 진행 허용 (바로 진입) - 세션: {}, 강의: {}, 남은 자리: {}",
                            sessionId, courseSeq, availableSlots - 1);

                    return Queue.builder()
                            .sessionId(sessionId)
                            .status(QueueStatus.ALLOW)
                            .queueType(QueueType.PAYMENT)
                            .position(0L)
                            .estimatedWaitTime(0L)
                            .courseSeq(courseSeq)
                            .memberSeq(memberSeq)
                            .paymentPrice(paymentPrice)
                            .courseName(course.getCourseName())
                            .courseCurrentSize(course.getCourseCurrentSize())
                            .courseMaxSize(course.getCourseSize())
                            .message("결제를 진행하실 수 있습니다.")
                            .timestamp(LocalDateTime.now())
                            .build();
                } else {
                    // 추가 실패 (이미 있거나 동시성 이슈)
                    log.warn("결제 진행 상태 추가 실패 (동시성 이슈) - 세션: {}", sessionId);
                    return enterPaymentQueue(sessionId, courseSeq, memberSeq, paymentPrice);
                }
            } else {
                // 5. 여유 자리 없음 - 대기열 진입
                log.info("여유 자리 없음으로 대기열 진입 - 세션: {}, 강의: {}", sessionId, courseSeq);
                return enterPaymentQueue(sessionId, courseSeq, memberSeq, paymentPrice);
            }
        } finally {
            // 락 해제
            stringRedisTemplate.delete(lockKey);
        }
    }

    /**
     * 결제 대기열 진입
     */
    public Queue enterPaymentQueue(String sessionId, Long courseSeq, Long memberSeq, BigDecimal paymentPrice) {
        String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;
        String lockKey = PAYMENT_LOCK_KEY + sessionId;
        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 5, TimeUnit.SECONDS);

        if (Boolean.FALSE.equals(lockAcquired)) {
            log.warn("결제 대기열 락 획득 실패 - 세션: {}", sessionId);
            return getCurrentPaymentStatus(sessionId, courseSeq);
        }

        try {
            // 1. 이미 대기열에 있는지 확인
            Double score = stringRedisTemplate.opsForZSet().score(paymentQueueKey, sessionId);
            if (score != null) {
                Long position = getPaymentPosition(sessionId, courseSeq);
                updatePaymentActivity(sessionId);

                return Queue.builder()
                        .status(QueueStatus.WAITING)
                        .queueType(QueueType.PAYMENT)
                        .sessionId(sessionId)
                        .courseSeq(courseSeq)
                        .memberSeq(memberSeq)
                        .paymentPrice(paymentPrice)
                        .position(position)
                        .estimatedWaitTime(calculatePaymentWaitTime(position))
                        .message("결제 대기열에 등록되었습니다.")
                        .timestamp(LocalDateTime.now())
                        .build();
            }

            // 2. 새로 대기열에 추가
            long currentTime = System.currentTimeMillis();
            stringRedisTemplate.opsForZSet().add(paymentQueueKey, sessionId, currentTime);

            // 3. 결제 정보 저장 및 활동 업데이트
            savePaymentInfo(sessionId, courseSeq, memberSeq, paymentPrice);
            updatePaymentActivity(sessionId);

            Long position = getPaymentPosition(sessionId, courseSeq);
            log.info("결제 대기열 진입 완료 - 세션: {}, 강의: {}, 순번: {}", sessionId, courseSeq, position);

            return Queue.builder()
                    .status(QueueStatus.WAITING)
                    .queueType(QueueType.PAYMENT)
                    .sessionId(sessionId)
                    .courseSeq(courseSeq)
                    .memberSeq(memberSeq)
                    .paymentPrice(paymentPrice)
                    .position(position)
                    .estimatedWaitTime(calculatePaymentWaitTime(position))
                    .message("결제 대기열에 등록되었습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();

        } finally {
            stringRedisTemplate.delete(lockKey);
        }
    }

    /**
     * 결제 대기열 상태 확인
     */
    public Queue getCurrentPaymentStatus(String sessionId, Long courseSeq) {
        try {
            String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
            String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;

            // 1. 결제 진행 중인지 확인
            Boolean isActive = stringRedisTemplate.opsForSet().isMember(paymentActiveKey, sessionId);

            if (Boolean.TRUE.equals(isActive)) {
                updatePaymentActivity(sessionId);
                log.debug("결제 진행 중 상태 확인 - 세션: {}", sessionId);

                return Queue.builder()
                        .status(QueueStatus.ALLOW)
                        .queueType(QueueType.PAYMENT)
                        .sessionId(sessionId)
                        .position(0L)
                        .estimatedWaitTime(0L)
                        .courseSeq(courseSeq)
                        .message("결제를 진행하실 수 있습니다.")
                        .timestamp(LocalDateTime.now())
                        .build();
            }

            // 2. 대기열에 있는지 확인
            Double score = stringRedisTemplate.opsForZSet().score(paymentQueueKey, sessionId);

            if (score != null) {
                Long position = getPaymentPosition(sessionId, courseSeq);
                updatePaymentActivity(sessionId);

                log.debug("대기열 상태 확인 - 세션: {}, 순번: {}", sessionId, position);

                return Queue.builder()
                        .status(QueueStatus.WAITING)
                        .queueType(QueueType.PAYMENT)
                        .sessionId(sessionId)
                        .position(position != null && position > 0 ? position : 1L)
                        .estimatedWaitTime(calculatePaymentWaitTime(position))
                        .courseSeq(courseSeq)
                        .message("결제 대기열에서 대기 중입니다.")
                        .timestamp(LocalDateTime.now())
                        .build();
            }

            // 3. 어디에도 없으면 신규 접근 가능 상태
            log.debug("결제 관련 상태 없음 (신규 사용자) - 세션: {}", sessionId);
            return Queue.builder()
                    .status(QueueStatus.ALLOW)
                    .queueType(QueueType.PAYMENT)
                    .sessionId(sessionId)
                    .position(0L)
                    .estimatedWaitTime(0L)
                    .courseSeq(courseSeq)
                    .message("결제를 진행하실 수 있습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();

        } catch (Exception e) {
            log.error("결제 상태 확인 중 오류 - 세션: {}", sessionId, e);
            return Queue.builder()
                    .status(QueueStatus.WAITING)
                    .queueType(QueueType.PAYMENT)
                    .sessionId(sessionId)
                    .position(99L)
                    .estimatedWaitTime(0L)
                    .courseSeq(courseSeq)
                    .message("상태 확인 중 오류가 발생했습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }
    }

    /**
     * 결제 세션 시작 (결제 폼 진입 시)
     */
    public void startPaymentSession(String sessionId, Long courseSeq) {
        String paymentSessionKey = PAYMENT_SESSION_KEY + sessionId;
        Map<String, String> sessionInfo = Map.of(
                "courseSeq", courseSeq.toString(),
                "startTime", String.valueOf(System.currentTimeMillis()),
                "status", "PAYMENT_IN_PROGRESS"
        );

        stringRedisTemplate.opsForHash().putAll(paymentSessionKey, sessionInfo);
        stringRedisTemplate.expire(paymentSessionKey, paymentTimeout, TimeUnit.SECONDS);

        updatePaymentActivity(sessionId);
        log.info("결제 세션 시작 - 세션: {}, 강의: {}", sessionId, courseSeq);
    }

    /**
     * 결제 활동 업데이트 (하트비트)
     */
    public void updatePaymentActivity(String sessionId) {
        String activityKey = PAYMENT_ACTIVITY_KEY + sessionId;
        stringRedisTemplate.opsForValue().set(
                activityKey,
                String.valueOf(System.currentTimeMillis()),
                paymentTimeout,
                TimeUnit.SECONDS
        );
        log.debug("결제 활동 업데이트 - 세션: {}", sessionId);
    }

    /**
     * 결제 세션 완료 (결제 성공 시에만 호출)
     * 자연스러운 페이지 이탈이나 하트비트 실패는 스케줄러가 처리
     */
    public void completePaymentSession(String sessionId) {
        try {
            // 1. 세션 정보에서 강의 번호 가져오기
            String paymentSessionKey = PAYMENT_SESSION_KEY + sessionId;
            String courseSeqStr = (String) stringRedisTemplate.opsForHash().get(paymentSessionKey, "courseSeq");

            if (courseSeqStr != null) {
                Long courseSeq = Long.parseLong(courseSeqStr);
                String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
                String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;

                // 2. 결제 진행 상태에서 제거
                Long removeCount = stringRedisTemplate.opsForSet().remove(paymentActiveKey, sessionId);
                boolean wasActive = removeCount != null && removeCount > 0;

                // 3. 대기열에서도 제거 (혹시 있다면)
                stringRedisTemplate.opsForZSet().remove(paymentQueueKey, sessionId);

                // 4. 모든 결제 관련 정보 삭제
                cleanupSessionData(sessionId);

                if (wasActive) {
                    log.info("결제 완료로 세션 정리 - 세션: {}, 강의: {}", sessionId, courseSeq);

                    // 5. 동기적으로 즉시 다음 사용자 처리
                    boolean processed = processNextPaymentUser(courseSeq);
                    if (processed) {
                        log.info("결제 완료 후 다음 사용자 활성화 완료 - 강의: {}", courseSeq);
                    } else {
                        log.debug("결제 완료 후 처리할 다음 사용자 없음 - 강의: {}", courseSeq);
                    }
                }
            }

            log.info("결제 세션 완료 - 세션: {}", sessionId);

        } catch (Exception e) {
            log.error("결제 세션 완료 처리 중 오류 - 세션: {}", sessionId, e);
        }
    }

    /**
     * 결제 대기열에서 제거 (취소, 타임아웃 등)
     */
    public boolean leavePaymentQueue(String sessionId) {
        try {
            // 1. 세션 정보에서 강의 번호 가져오기
            String paymentSessionKey = PAYMENT_SESSION_KEY + sessionId;
            String courseSeqStr = (String) stringRedisTemplate.opsForHash().get(paymentSessionKey, "courseSeq");

            boolean removed = false;

            if (courseSeqStr != null) {
                Long courseSeq = Long.parseLong(courseSeqStr);
                String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
                String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;

                // 2. 결제 진행 상태에서 제거
                Long activeRemoveCount = stringRedisTemplate.opsForSet().remove(paymentActiveKey, sessionId);
                boolean wasActive = activeRemoveCount != null && activeRemoveCount > 0;

                // 3. 대기열에서 제거
                Long queueRemoveCount = stringRedisTemplate.opsForZSet().remove(paymentQueueKey, sessionId);
                boolean wasWaiting = queueRemoveCount != null && queueRemoveCount > 0;

                removed = wasActive || wasWaiting;

                if (removed) {
                    log.info("결제 관련 상태에서 제거됨 - 세션: {}, 강의: {}, 진행중: {}, 대기중: {}",
                            sessionId, courseSeq, wasActive, wasWaiting);

                    // 4. 자리가 생겼으므로 동기적으로 즉시 다음 사용자 처리
                    if (wasActive) {
                        boolean processed = processNextPaymentUser(courseSeq);
                        if (processed) {
                            log.info("사용자 이탈 후 다음 사용자 활성화 완료 - 강의: {}", courseSeq);
                        } else {
                            log.debug("사용자 이탈 후 처리할 다음 사용자 없음 - 강의: {}", courseSeq);
                        }
                    }
                }
            }

            // 5. 결제 관련 정보 정리
            cleanupSessionData(sessionId);

            return removed;

        } catch (Exception e) {
            log.error("결제 대기열 제거 중 오류 - 세션: {}", sessionId, e);
            return false;
        }
    }

    /**
     * 결제 대기열 처리 (스케줄러에서 호출)
     */
    public void processPaymentQueues() {
        try {
            Set<String> paymentQueueKeys = stringRedisTemplate.keys(PAYMENT_QUEUE_KEY + "*");

            if (paymentQueueKeys == null || paymentQueueKeys.isEmpty()) {
                return;
            }

            for (String queueKey : paymentQueueKeys) {
                try {
                    String courseSeqStr = queueKey.replace(PAYMENT_QUEUE_KEY, "");
                    if (courseSeqStr.matches("\\d+")) {
                        Long courseSeq = Long.parseLong(courseSeqStr);
                        processNextPaymentUser(courseSeq);
                    }
                } catch (NumberFormatException  e) {
                    log.warn("잘못된 강의 번호 형식: {}", queueKey);
                }
            }
        }catch (Exception e) {
            log.warn("결제 대기열 처리 중 오류: {}", e.getMessage());
        }
    }

    /**
     * 다음 결제 사용자 처리 (여유 자리 확인 후 활성화)
     */
    private boolean processNextPaymentUser(Long courseSeq) {
        String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;
        String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
        String lockKey = PAYMENT_LOCK_KEY + "process:" + courseSeq;

        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 10, TimeUnit.SECONDS);
        if (Boolean.FALSE.equals(lockAcquired)) {
            log.debug("다음 결제 사용자 처리 락 실패 - 강의: {}", courseSeq);
            return false;
        }

        try {
            // 1. 대기열 첫 번째 사용자 확인
            Set<String> nextUsers = stringRedisTemplate.opsForZSet().range(paymentQueueKey, 0, 0);
            if (nextUsers == null || nextUsers.isEmpty()) {
                log.debug("결제 대기열에 대기자 없음 - 강의: {}", courseSeq);
                return false;
            }

            String nextSessionId = nextUsers.iterator().next();
            log.info("다음 결제 사용자 처리 시작 - 세션: {}, 강의: {}", nextSessionId, courseSeq);

            // 2. 현재 결제 진행 중인 사람 수 확인
            Long paymentActiveCount = stringRedisTemplate.opsForSet().size(paymentActiveKey);
            int activePayments = paymentActiveCount != null ? paymentActiveCount.intValue() : 0;

            // 3. 결제 정보에서 강의 정보 조회
            String infoKey = PAYMENT_INFO_KEY + nextSessionId;
            Map<Object, Object> paymentInfo = stringRedisTemplate.opsForHash().entries(infoKey);

            if (paymentInfo.isEmpty()) {
                log.warn("결제 정보를 찾을 수 없음 - 세션: {}, 대기열에서 제거", nextSessionId);
                stringRedisTemplate.opsForZSet().remove(paymentQueueKey, nextSessionId);
                cleanupSessionData(nextSessionId);
                return processNextPaymentUser(courseSeq); // 다음 사용자 재시도
            }

            String courseSizeStr = (String) paymentInfo.get("courseSize");
            String currentSizeStr = (String) paymentInfo.get("courseCurrentSize");

            if (courseSizeStr == null) {
                log.warn("강의 정원 정보 없음 - 세션: {}, 대기열에서 제거", nextSessionId);
                stringRedisTemplate.opsForZSet().remove(paymentQueueKey, nextSessionId);
                cleanupSessionData(nextSessionId);
                return processNextPaymentUser(courseSeq);
            }

            int maxCapacity = Integer.parseInt(courseSizeStr);
            int currentEnrolled = currentSizeStr != null ? Integer.parseInt(currentSizeStr) : 0;

            // 1. 실제 여유 자리 계산
            int actualAvailableSlots = maxCapacity - currentEnrolled - activePayments;

            log.info("대기열 처리 분석 - 강의: {}, 정원: {}, 등록: {}, 결제중: {}, 실제여유: {}",
                    courseSeq, maxCapacity, currentEnrolled, activePayments, actualAvailableSlots);

            // 2. 여유 자리가 없으면 처리하지 않음
            if (actualAvailableSlots <= 0) {
                log.info("실제 여유 자리 없음 - 강의: {}, 필요: 1자리, 여유: {}자리", courseSeq, actualAvailableSlots);
                return false;
            }

            // 3. 해당 사용자가 활성 상태인지 확인
            String activityKey = PAYMENT_ACTIVITY_KEY + nextSessionId;
            String lastActivity = stringRedisTemplate.opsForValue().get(activityKey);

            boolean isActiveUser = true;
            if (lastActivity != null) {
                try {
                    long lastTime = Long.parseLong(lastActivity);
                    long inactiveTime = (System.currentTimeMillis() - lastTime) / 1000;
                    // 10분 이내 활동한 사용자만 처리
                    isActiveUser = inactiveTime < paymentTimeout;

                    log.debug("사용자 활동 체크 - 세션: {}, 마지막활동: {}초전, 활성: {}",
                            nextSessionId, inactiveTime, isActiveUser);
                } catch (NumberFormatException e) {
                    log.warn("결제 활동 시간 파싱 오류: {} - 활성 사용자로 처리", nextSessionId);
                    isActiveUser = true; // 파싱 오류 시 활성으로 처리
                }
            } else {
                log.debug("활동 기록 없음 - 세션: {} - 활성 사용자로 처리", nextSessionId);
                isActiveUser = true; // 활동 기록이 없어도 활성으로 처리
            }

            if (isActiveUser) {
                // 4. 원자적으로 대기열에서 제거하고 결제 진행 상태로 이동
                Long removed = stringRedisTemplate.opsForZSet().remove(paymentQueueKey, nextSessionId);
                if (removed != null && removed > 0) {
                    // 5. 활성 사용자 추가 후 검증
                    Long addResult = stringRedisTemplate.opsForSet().add(paymentActiveKey, nextSessionId);
                    if (addResult != null && addResult > 0) {
                        // 성공적으로 추가됨
                        stringRedisTemplate.expire(paymentActiveKey, paymentTimeout, TimeUnit.SECONDS);
                        // 결제 세션 시작
                        startPaymentSession(nextSessionId, courseSeq);
                        // 활동 업데이트
                        updatePaymentActivity(nextSessionId);

                        log.info("다음 결제 사용자 활성화 성공 - 세션: {}, 강의: {}, 여유자리: {}",
                                nextSessionId, courseSeq, actualAvailableSlots - 1);
                        return true;
                    } else {
                        // 활성 사용자 추가 실패시 다시 대기열에 추가
                        log.warn("활성 사용자 추가 실패, 대기열로 복구 - 세션: {}", nextSessionId);
                        long currentTime = System.currentTimeMillis();
                        stringRedisTemplate.opsForZSet().add(paymentQueueKey, nextSessionId, currentTime);
                        return false;
                    }
                } else {
                    log.warn("대기열에서 제거 실패 - 세션: {} (이미 제거됨?)", nextSessionId);
                    return false;
                }
            } else {
                // 6. 비활성 사용자는 제거하고 다음 사용자 처리
                log.info("비활성 결제 대기 사용자 제거: {} ({}초 비활성)", nextSessionId,
                        lastActivity != null ? (System.currentTimeMillis() - Long.parseLong(lastActivity)) / 1000 : "기록없음");
                stringRedisTemplate.opsForZSet().remove(paymentQueueKey, nextSessionId);
                cleanupSessionData(nextSessionId);

                // 재귀적으로 다음 사용자 처리
                return processNextPaymentUser(courseSeq);
            }
        } catch (Exception e) {
            log.error("다음 결제 사용자 처리 중 오류 - 강의: {}", courseSeq, e);
            return false;
        } finally {
            stringRedisTemplate.delete(lockKey);
        }
    }

    /**
     * 결제 정보 저장
     */
    private void savePaymentInfo(String sessionId, Long courseSeq, Long memberSeq, BigDecimal paymentPrice) {
        String infoKey = PAYMENT_INFO_KEY + sessionId;
        Map<String, String> paymentInfo = Map.of(
                "courseSeq", courseSeq.toString(),
                "memberSeq", memberSeq.toString(),
                "paymentPrice", paymentPrice.toString(),
                "timestamp", String.valueOf(System.currentTimeMillis())
        );

        stringRedisTemplate.opsForHash().putAll(infoKey, paymentInfo);
        stringRedisTemplate.expire(infoKey, paymentTimeout * 2, TimeUnit.SECONDS);
    }

    private void savePaymentInfo(String sessionId, Long courseSeq, Long memberSeq, BigDecimal paymentPrice, CourseViewResponse course) {
        String infoKey = PAYMENT_INFO_KEY + sessionId;
        Map<String, String> paymentInfo = Map.of(
                "courseSeq", courseSeq.toString(),
                "memberSeq", memberSeq.toString(),
                "paymentPrice", paymentPrice.toString(),
                "courseSize", String.valueOf(course.getCourseSize()), // 강의 정원 저장
                "courseCurrentSize", String.valueOf(course.getCourseCurrentSize()), // 현재 등록자 수 저장
                "timestamp", String.valueOf(System.currentTimeMillis())
        );

        stringRedisTemplate.opsForHash().putAll(infoKey, paymentInfo);
        stringRedisTemplate.expire(infoKey, paymentTimeout * 2, TimeUnit.SECONDS);
    }

    /**
     * 세션 데이터 정리
     */
    private void cleanupSessionData(String sessionId) {
        stringRedisTemplate.delete(PAYMENT_SESSION_KEY + sessionId);
        stringRedisTemplate.delete(PAYMENT_ACTIVITY_KEY + sessionId);
        stringRedisTemplate.delete(PAYMENT_INFO_KEY + sessionId);
    }

    /**
     * 결제 사용자를 대기열로 이동 (heartbeat 실패, 시간 초과 등)
     */
    public void movePaymentUserToQueue(String sessionId, Long courseSeq) {
        String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
        String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;
        String lockKey = PAYMENT_LOCK_KEY + "move:" + sessionId;

        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 10, TimeUnit.SECONDS);
        if (Boolean.FALSE.equals(lockAcquired)) {
            log.warn("대기열 이동 락 실패 - 세션: {}", sessionId);
            return;
        }

        try {
            // 먼저 기존 대기열에 있는지 확인하고 score 가져오기
            Double existingScore = stringRedisTemplate.opsForZSet().score(paymentQueueKey, sessionId);

            // 결제 진행 상태에서 제거
            Long removeCount = stringRedisTemplate.opsForSet().remove(paymentActiveKey, sessionId);
            boolean wasActive = removeCount != null && removeCount > 0;

            if (wasActive) {
//                long priorityTime = System.currentTimeMillis();
//                stringRedisTemplate.opsForZSet().add(paymentQueueKey, sessionId, priorityTime);
                updatePaymentActivity(sessionId);

                log.info("결제 진행자를 대기열로 이동 완료 - 세션: {}, 강의: {}",
                        sessionId, courseSeq);

                // 다음 사용자 처리
                processNextPaymentUser(courseSeq);
            } else {
                // 대기열에 없으면 새로 추가
                Double score = stringRedisTemplate.opsForZSet().score(paymentQueueKey, sessionId);
                if (score == null) {
                    long currentTime = System.currentTimeMillis();
                    stringRedisTemplate.opsForZSet().add(paymentQueueKey, sessionId, currentTime);
                    updatePaymentActivity(sessionId);
                    log.info("대기열에 새로 추가 - 세션: {}, 강의: {}", sessionId, courseSeq);
                }
            }
        } catch (Exception e) {
            log.error("결제 사용자 대기열 이동 중 오류 - 세션: {}, 강의: {}", sessionId, courseSeq, e);
        } finally {
            stringRedisTemplate.delete(lockKey);
        }
    }

    /**
     * 대기열 순번 조회
     */
    private Long getPaymentPosition(String sessionId, Long courseSeq) {
        try {
            String queueKey = PAYMENT_QUEUE_KEY + courseSeq;
            Long rank = stringRedisTemplate.opsForZSet().rank(queueKey, sessionId);
            if (rank != null) {
                Long position = rank + 1;
                log.debug("대기열 순번 조회 - 세션: {}, 순번: {}", sessionId, position);
                return position;
            } else {
                log.warn("대기열에서 세션을 찾을 수 없음 - 세션: {}", sessionId);
                return null;
            }
        } catch (Exception e) {
            log.error("대기열 순번 조회 오류 - 세션: {}", sessionId, e);
            return 1L; // 기본값
        }
    }

    private Long calculatePaymentWaitTime(Long position) {
        if (position == null || position <= 0) return 0L;
        return position * 120; // 결제 대기열: 2분씩
    }

    /**
     * 결제 대기열 시스템 상태 조회
     */
    public Map<String, Object> getPaymentSystemStatus() {
        Map<String, Object> status = new HashMap<>();
        try {
            // 전체 결제 대기열 통계
            Set<String> paymentQueueKeys = stringRedisTemplate.keys(PAYMENT_QUEUE_KEY + "*");
            Set<String> paymentActiveKeys = stringRedisTemplate.keys(PAYMENT_ACTIVE_KEY + "*");

            long totalPaymentWaiting = 0;
            long totalPaymentActive = 0;

            if (paymentQueueKeys != null) {
                for (String key : paymentQueueKeys) {
                    if (key.matches(".*\\d+$")) { // 숫자로 끝나는 키만
                        Long count = stringRedisTemplate.opsForZSet().zCard(key);
                        if (count != null) totalPaymentWaiting += count;
                    }
                }
            }

            if (paymentActiveKeys != null) {
                for (String key : paymentActiveKeys) {
                    if (key.matches(".*\\d+$")) { // 숫자로 끝나는 키만
                        Long count = stringRedisTemplate.opsForSet().size(key);
                        if (count != null) totalPaymentActive += count;
                    }
                }
            }

            status.put("paymentWaitingCount", totalPaymentWaiting);
            status.put("paymentActiveCount", totalPaymentActive);
            status.put("paymentTimeout", paymentTimeout);
        } catch (Exception e) {
            log.error("결제 시스템 상태 조회 중 오류", e);
            status.put("error", e.getMessage());
        }
        return status;
    }

    /**
     * 특정 강의의 결제 대기열 상태
     */
    public int getActivePaymentUsersCount(Long courseSeq) {
        String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
        Long count = stringRedisTemplate.opsForSet().size(paymentActiveKey);
        return count != null ? count.intValue() : 0;
    }

    public int getPaymentQueueCount(Long courseSeq) {
        String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;
        Long count = stringRedisTemplate.opsForZSet().zCard(paymentQueueKey);
        return count != null ? count.intValue() : 0;
    }

    /**
     * 세션 전환 (로그인 시)
     */
    public boolean transferPaymentSession(String oldSessionId, String newSessionId) {
        // 결제 세션 정보 확인
        String sessionKey = PAYMENT_SESSION_KEY + oldSessionId;
        String courseSeqStr = (String) stringRedisTemplate.opsForHash().get(sessionKey, "courseSeq");

        if (courseSeqStr == null) {
            return false;
        }

        try {
            Long courseSeq = Long.parseLong(courseSeqStr);
            String paymentActiveKey = PAYMENT_ACTIVE_KEY + courseSeq;
            String paymentQueueKey = PAYMENT_QUEUE_KEY + courseSeq;
            boolean transferred = false;

            // 결제 진행 중 사용자 전환
            if (Boolean.TRUE.equals(stringRedisTemplate.opsForSet().isMember(paymentActiveKey, oldSessionId))) {
                stringRedisTemplate.opsForSet().remove(paymentActiveKey, oldSessionId);
                stringRedisTemplate.opsForSet().add(paymentActiveKey, newSessionId);
                transferred = true;
                log.info("결제 진행 사용자 세션 전환 - 강의: {}, 이전: {}, 새로운: {}",
                        courseSeq, oldSessionId, newSessionId);
            }

            // 결제 대기열 사용자 전환
            Double paymentScore = stringRedisTemplate.opsForZSet().score(paymentQueueKey, oldSessionId);
            if (paymentScore != null) {
                stringRedisTemplate.opsForZSet().remove(paymentQueueKey, oldSessionId);
                stringRedisTemplate.opsForZSet().add(paymentQueueKey, newSessionId, paymentScore);
                transferred = true;
                log.info("결제 대기열 사용자 세션 전환 - 강의: {}, 이전: {}, 새로운: {}, 점수: {}",
                        courseSeq, oldSessionId, newSessionId, paymentScore);
            }

            // 결제 관련 데이터 전환
            if (transferred) {
                transferPaymentData(oldSessionId, newSessionId);
            }

            return transferred;

        } catch (Exception e) {
            log.error("결제 세션 전환 중 오류 - 이전: {}, 새로운: {}", oldSessionId, newSessionId, e);
            return false;
        }
    }

    private void transferPaymentData(String oldSessionId, String newSessionId) {
        try {
            // 1. 결제 세션 정보 전환
            String oldSessionKey = PAYMENT_SESSION_KEY + oldSessionId;
            String newSessionKey = PAYMENT_SESSION_KEY + newSessionId;

            Map<Object, Object> sessionInfo = stringRedisTemplate.opsForHash().entries(oldSessionKey);
            if (!sessionInfo.isEmpty()) {
                stringRedisTemplate.opsForHash().putAll(newSessionKey, sessionInfo);
                stringRedisTemplate.expire(newSessionKey, paymentTimeout, TimeUnit.SECONDS);
                stringRedisTemplate.delete(oldSessionKey);
            }

            // 2. 결제 활동 정보 전환
            String oldActivityKey = PAYMENT_ACTIVITY_KEY + oldSessionId;
            String newActivityKey = PAYMENT_ACTIVITY_KEY + newSessionId;

            String lastActivity = stringRedisTemplate.opsForValue().get(oldActivityKey);
            if (lastActivity != null) {
                stringRedisTemplate.opsForValue().set(newActivityKey, lastActivity, paymentTimeout, TimeUnit.SECONDS);
                stringRedisTemplate.delete(oldActivityKey);
            }

            // 3. 결제 정보 전환
            String oldInfoKey = PAYMENT_INFO_KEY + oldSessionId;
            String newInfoKey = PAYMENT_INFO_KEY + newSessionId;

            Map<Object, Object> paymentInfo = stringRedisTemplate.opsForHash().entries(oldInfoKey);
            if (!paymentInfo.isEmpty()) {
                stringRedisTemplate.opsForHash().putAll(newInfoKey, paymentInfo);
                stringRedisTemplate.expire(newInfoKey, paymentTimeout * 2, TimeUnit.SECONDS);
                stringRedisTemplate.delete(oldInfoKey);
            }

        } catch (Exception e) {
            log.error("결제 데이터 전환 중 오류 - 이전: {}, 새로운: {}", oldSessionId, newSessionId, e);
        }
    }
}