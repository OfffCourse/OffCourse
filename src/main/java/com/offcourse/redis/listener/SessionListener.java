/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 24.
  Time: 오전 9:40
*/
package com.offcourse.redis.listener;

import com.offcourse.payment.model.service.PaymentQueueService;
import com.offcourse.redis.model.service.QueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.EventListener;
import org.springframework.session.events.SessionCreatedEvent;
import org.springframework.session.events.SessionDeletedEvent;
import org.springframework.session.events.SessionDestroyedEvent;
import org.springframework.session.events.SessionExpiredEvent;
import org.springframework.stereotype.Component;

/**
 * Spring Session 이벤트 리스너
 * 세션 생성, 종료, 만료 이벤트를 처리하여 대기열 시스템과 연동
 */
@Component
@Slf4j
public class SessionListener {

    private QueueService queueService;
    private PaymentQueueService paymentQueueService;

    // Lazy 로딩으로 순환 참조 및 빈 찾기 문제 해결
    @Autowired
    @Lazy
    public void setQueueService(QueueService queueService) {
        this.queueService = queueService;
    }

    @Autowired
    @Lazy
    public void setPaymentQueueService(PaymentQueueService paymentQueueService) {
        this.paymentQueueService = paymentQueueService;
    }

    /**
     * 세션 생성 이벤트 처리
     */
    @EventListener
    public void handleSessionCreated(SessionCreatedEvent event) {
        try {
            String sessionId = event.getSessionId();
            log.debug("새 세션 생성: {}", sessionId);

        } catch (Exception e) {
            log.error("세션 생성 이벤트 처리 중 오류: {}", e.getMessage(), e);
        }
    }

    /**
     * 세션 종료 이벤트 처리 (일반적인 세션 종료)
     */
    @EventListener
    public void handleSessionDestroyed(SessionDestroyedEvent event) {
        handleSessionEnd(event.getSessionId(), "DESTROYED", "일반 종료");
    }

    /**
     * 세션 삭제 이벤트 처리 (명시적 삭제)
     */
    @EventListener
    public void handleSessionDeleted(SessionDeletedEvent event) {
        handleSessionEnd(event.getSessionId(), "DELETED", "명시적 삭제");
    }

    /**
     * 세션 만료 이벤트 처리 (타임아웃으로 인한 만료)
     */
    @EventListener
    public void handleSessionExpired(SessionExpiredEvent event) {
        try {
            String sessionId = event.getSessionId();

            if (sessionId != null && !sessionId.isEmpty()) {
                log.info("세션 만료 감지: {} (타임아웃)", sessionId);

                // 세션 만료 시에는 사용자가 다시 접속할 가능성이 있으므로
                // 완전히 제거하지 않고 강제 대기열 진입으로 처리
                try {
                    queueService.forceAddToQueue(sessionId, "SESSION_EXPIRED");
                    log.info("만료된 세션 {} 대기열로 이동 처리 완료", sessionId);
                } catch (Exception queueError) {
                    log.warn("만료된 세션 {} 대기열 처리 실패: {}", sessionId, queueError.getMessage());

                    // 대기열 처리 실패 시 완전 제거
                    try {
                        boolean removed = queueService.leaveQueue(sessionId);
                        boolean paymentRemoved = paymentQueueService.leavePaymentQueue(sessionId);

                        if (removed || paymentRemoved) {
                            log.info("만료된 세션 {} 강제 제거 완료", sessionId);
                        }
                    } catch (Exception removeError) {
                        log.error("만료된 세션 {} 강제 제거 실패: {}", sessionId, removeError.getMessage());
                    }
                }

            } else {
                log.warn("SessionExpiredEvent에서 세션 ID를 가져올 수 없음");
            }
        } catch (Exception e) {
            log.error("세션 만료 처리 중 오류 발생 - SessionId: {}, Error: {}",
                    event.getSessionId(), e.getMessage(), e);
        }
    }

    /**
     * 공통 세션 종료 처리
     */
    private void handleSessionEnd(String sessionId, String eventType, String description) {
        try {
            if (sessionId != null && !sessionId.isEmpty()) {
                log.info("세션 종료 감지: {} ({})", sessionId, description);

                // 일반 대기열에서 제거 시도
                boolean removedFromGeneral = false;
                boolean removedFromPayment = false;

                try {
                    removedFromGeneral = queueService.leaveQueue(sessionId);
                } catch (Exception generalError) {
                    log.warn("일반 대기열에서 세션 {} 제거 실패: {}", sessionId, generalError.getMessage());
                }

                // 결제 대기열에서 제거 시도
                try {
                    removedFromPayment = paymentQueueService.leavePaymentQueue(sessionId);
                } catch (Exception paymentError) {
                    log.warn("결제 대기열에서 세션 {} 제거 실패: {}", sessionId, paymentError.getMessage());
                }

                // 결과 로깅
                if (removedFromGeneral || removedFromPayment) {
                    log.info("세션 {} 대기열에서 제거 완료 - 일반: {}, 결제: {}",
                            sessionId, removedFromGeneral, removedFromPayment);
                } else {
                    log.debug("세션 {} 대기열에 없었음 (이미 처리됨)", sessionId);
                }

            } else {
                log.warn("{}에서 세션 ID를 가져올 수 없음", eventType);
            }
        } catch (Exception e) {
            log.error("세션 종료 처리 중 오류 발생 - SessionId: {}, EventType: {}, Error: {}",
                    sessionId, eventType, e.getMessage(), e);
        }
    }
}