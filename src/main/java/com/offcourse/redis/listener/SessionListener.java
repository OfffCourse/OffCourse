/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 24.
  Time: 오전 9:40
*/
package com.offcourse.redis.listener;

import com.offcourse.redis.model.service.QueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.context.event.EventListener;
import org.springframework.session.events.SessionCreatedEvent;
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

    // Lazy 로딩으로 순환 참조 및 빈 찾기 문제 해결
    @Autowired
    @Lazy
    public void setQueueService(QueueService queueService) {
        this.queueService = queueService;
    }

    /**
     * 세션 생성 이벤트 처리
     */
    @EventListener
    public void handleSessionCreated(SessionCreatedEvent event) {
        try {
            String sessionId = event.getSessionId();
            log.debug("새 세션 생성: {}", sessionId);

            // 필요한 경우 세션 생성 시 초기화 작업 수행
            // 예: 사용자 통계, 초기 세션 속성 설정 등

        } catch (Exception e) {
            log.error("세션 생성 이벤트 처리 중 오류: {}", e.getMessage(), e);
        }
    }

    /**
     * 세션 종료 이벤트 처리 (일반적인 세션 종료)
     */
    @EventListener
    public void handleSessionDestroyed(SessionDestroyedEvent event) {
        try {
            String sessionId = event.getSessionId();

            if (sessionId != null && !sessionId.isEmpty()) {
                log.info("세션 종료 감지: {} (일반 종료)", sessionId);

                boolean removed = queueService.leaveQueue(sessionId);

                if (removed) {
                    log.info("세션 {} 대기열에서 제거 완료", sessionId);
                } else {
                    log.debug("세션 {} 대기열에 없었음 (이미 처리됨)", sessionId);
                }

            } else {
                log.warn("SessionDestroyedEvent에서 세션 ID를 가져올 수 없음");
            }
        } catch (Exception e) {
            log.error("세션 종료 처리 중 오류 발생 - SessionId: {}, Error: {}",
                    event.getSessionId(), e.getMessage(), e);
        }
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

                // 세션 만료로 인한 대기열 제거
                // 강제 진입으로 처리하여 약간의 우선권 부여
                queueService.forceAddToQueue(sessionId, "SESSION_EXPIRED");

            } else {
                log.warn("SessionExpiredEvent에서 세션 ID를 가져올 수 없음");
            }
        } catch (Exception e) {
            log.error("세션 만료 처리 중 오류 발생 - SessionId: {}, Error: {}",
                    event.getSessionId(), e.getMessage(), e);
        }
    }
}