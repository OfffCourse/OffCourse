package com.offcourse.redis.controller;

import com.offcourse.redis.model.dto.Queue;
import com.offcourse.redis.model.service.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.Map;

@Controller
@RequestMapping("/queue")
@RequiredArgsConstructor
@Slf4j
public class QueueController {

    private final QueueService queueService;

    /**
     * 대기열 페이지
     */
    @GetMapping
    public String queue(HttpSession session, Model model) {
        String sessionId = session.getId();

        try {
            Queue response = queueService.enterQueue(sessionId);

            model.addAttribute("queue", response);
            model.addAttribute("sessionId", sessionId);

            if (response.isAccessAllowed()) {
                log.debug("사용자 {} 이미 접근 허용됨, 메인으로 리다이렉트", sessionId);
                return "redirect:/";
            } else {
                return "common/queue";
            }
        } catch (Exception e) {
            log.error("대기열 페이지 처리 중 오류 - SessionId: {}", sessionId, e);
            model.addAttribute("error", "시스템 오류가 발생했습니다.");
            return "common/queue";
        }
    }

    @GetMapping("/status")
    @ResponseBody
    public Queue getQueueStatus(HttpSession session) {
        String sessionId = session.getId();
        try{
//            Queue status = queueService.getQueueStatus(sessionId);
            Queue status = queueService.enterQueue(sessionId);
            log.debug("대기열 상태 조회 - 세션: {}, 상태: {}, 순번: {}",
                    sessionId, status.getStatus(), status.getPosition());
            return status;
        }catch (Exception e){
            log.error("대기열 상태 조회 중 오류 - SessionId: {}", sessionId, e);
            return Queue.builder()
                    .sessionId(sessionId)
                    .message("상태 조회 중 오류가 발생했습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }
    }

    @PostMapping("/complete")
    public String completeService(HttpSession session) {
        String sessionId = session.getId();
        try {
            queueService.completeService(sessionId);
            log.info("사용자 {} 서비스 완료 처리", sessionId);
        } catch (Exception e) {
            log.error("서비스 완료 처리 중 오류 - SessionId: {}", sessionId, e);
        }

        return "redirect:/";
    }

    /**
     * 탭 닫기 감지
     */
    @PostMapping("/leave")
    @ResponseBody
    public ResponseEntity<String> leaveQueue(HttpSession session) {
        String sessionId = session.getId();

        try {
            log.info("사용자 페이지 이탈 감지: {}", sessionId);
            boolean removed = queueService.leaveQueue(sessionId);

            if (removed) {
                log.info("페이지 이탈로 인한 대기열 제거: {}", sessionId);
                return ResponseEntity.ok("removed");
            } else {
                return ResponseEntity.ok("not_found");
            }
        } catch (Exception e) {
            log.error("페이지 이탈 처리 중 오류 - SessionId: {}", sessionId, e);
            return ResponseEntity.ok("error");
        }
    }

    /**
     * Heartbeat 엔드포인트 - 활성 사용자 세션 연장
     */
    @PostMapping("/heartbeat")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> heartbeat(HttpSession session) {
        String sessionId = session.getId();

        try {
            // 사용자 활동 업데이트 (세션 시간 연장)
            queueService.updateUserActivity(sessionId);

            // 현재 대기열 상태도 함께 반환
            Queue status = queueService.enterQueue(sessionId);

            log.debug("Heartbeat 수신 - 세션: {}, 상태: {}", sessionId, status.getStatus());

            return ResponseEntity.ok(Map.of(
                    "status", "alive",
                    "sessionId", sessionId,
                    "queueStatus", status.getStatus().name(),
                    "position", status.getPosition() != null ? status.getPosition() : 0,
                    "timestamp", LocalDateTime.now()
            ));

        } catch (Exception e) {
            log.error("Heartbeat 처리 중 오류 - SessionId: {}", sessionId, e);
            return ResponseEntity.ok(Map.of(
                    "status", "error",
                    "message", "heartbeat failed",
                    "timestamp", LocalDateTime.now()
            ));
        }
    }

    /**
     * 강제 대기열 진입 (heartbeat 실패, 관리자 액션 등)
     */
    @GetMapping("/insert")
    public String forceEnterQueue(HttpSession session, Model model,
                                  @RequestParam(value = "reason", defaultValue = "SESSION_EXPIRED") String reason) {
        String sessionId = session.getId();

        try {
            log.info("강제 대기열 진입 요청 - 세션: {}, 사유: {}", sessionId, reason);

            // 강제로 대기열에 추가
            Queue response = queueService.forceAddToQueue(sessionId, reason);

            model.addAttribute("queue", response);
            model.addAttribute("sessionId", sessionId);
            model.addAttribute("forceEntry", true); // 강제 진입 플래그
            model.addAttribute("entryReason", getReasonMessage(reason)); // 진입 사유 메시지

            log.info("강제 대기열 진입 완료 - 세션: {}, 순번: {}", sessionId, response.getPosition());

            return "common/queue";

        } catch (Exception e) {
            log.error("강제 대기열 진입 중 오류 - SessionId: {}", sessionId, e);
            model.addAttribute("error", "대기열 진입 중 오류가 발생했습니다.");
            return "common/queue";
        }
    }

    /**
     * 진입 사유별 메시지 반환
     */
    private String getReasonMessage(String reason) {
        switch (reason) {
            case "HEARTBEAT_FAILED":
                return "네트워크 연결 문제로 인해 대기열로 이동되었습니다.";
            case "SESSION_EXPIRED":
                return "세션이 만료되어 대기열로 이동되었습니다.";
            case "ADMIN_ACTION":
                return "관리자에 의해 대기열로 이동되었습니다.";
            case "SYSTEM_ERROR":
                return "시스템 오류로 인해 대기열로 이동되었습니다.";
            default:
                return "대기열로 이동되었습니다.";
        }
    }

    /**
     * 관리자용 - 사용자 조회
     */
    @GetMapping("/admin/status")
    @ResponseBody
    public Map<String, Object> getSystemStatus() {
        try {
            return queueService.getSystemStatus();
        } catch (Exception e) {
            log.error("시스템 상태 조회 중 오류", e);
            return Map.of(
                    "error", true,
                    "message", "시스템 상태 조회 중 오류가 발생했습니다.",
                    "timestamp", LocalDateTime.now()
            );
        }
    }

    /**
     * 관리자용 - 사용자 강제 제거
     */
    @PostMapping("/admin/remove")
    @ResponseBody
    public Map<String, Object> forceRemoveUser(@RequestParam String targetSessionId) {
        try {
            boolean success = queueService.leaveQueue(targetSessionId);
            log.info("관리자 사용자 제거 - 대상: {}, 결과: {}", targetSessionId, success);

            return Map.of(
                    "success", success,
                    "message", success ? "사용자가 제거되었습니다." : "해당 사용자를 찾을 수 없습니다.",
                    "targetSessionId", targetSessionId,
                    "timestamp", LocalDateTime.now()
            );
        }catch (Exception e){
            log.error("사용자 제거 중 오류 - Target: {}", targetSessionId, e);
            return Map.of(
                    "success", false,
                    "message", "사용자 제거 중 오류: " + e.getMessage()
            );
        }
    }

    /**
     * 관리자용 - 비활성 사용자 수동 정리
     */
    @PostMapping("/admin/cleanup")
    @ResponseBody
    public Map<String, Object> manualCleanup() {
        try {
            queueService.cleanupInactiveUsers();
            log.info("수동 정리 실행");
            return Map.of(
                    "success", true,
                    "message", "비활성 사용자 정리가 완료되었습니다.",
                    "timestamp", LocalDateTime.now()
            );
        } catch (Exception e) {
            log.error("수동 정리 중 오류", e);
            return Map.of(
                    "success", false,
                    "message", "정리 중 오류: " + e.getMessage()
            );
        }
    }

    /**
     * 관리자용 - 수동 대기열 처리
     */
    @PostMapping("/admin/process")
    @ResponseBody
    public Map<String, Object> manualProcessQueue() {
        try {
            queueService.processWaitingQueue();
            return Map.of(
                    "success", true,
                    "message", "대기열 처리가 완료되었습니다.",
                    "timestamp", LocalDateTime.now()
            );
        } catch (Exception e) {
            log.error("수동 대기열 처리 중 오류", e);
            return Map.of(
                    "success", false,
                    "message", "처리 중 오류: " + e.getMessage()
            );
        }
    }

    /**
     * 전체 대기열 초기화
     */
    @PostMapping("/admin/clear")
    @ResponseBody
    public Map<String, Object> clearAllQueue() {
        try {
            Map<String, Object> result = queueService.clearAllQueue();
            log.warn("관리자에 의한 전체 대기열 초기화 실행");
            return result;
        } catch (Exception e) {
            log.error("대기열 초기화 중 오류", e);
            return Map.of(
                    "success", false,
                    "message", "대기열 초기화 중 오류: " + e.getMessage(),
                    "timestamp", LocalDateTime.now()
            );
        }
    }

    @GetMapping("/all")
    public String getAllRedisData() {
        Map<String, Object> all = queueService.getAllRedisData();
        log.debug("레디스의 모든 키와 밸류 값: {}", all);
        return "common/queue";
    }


}