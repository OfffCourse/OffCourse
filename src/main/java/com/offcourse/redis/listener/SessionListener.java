/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 24.
  Time: 오전 9:40
*/
package com.offcourse.redis.listener;

import com.offcourse.redis.model.service.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationListener;
import org.springframework.session.events.SessionDestroyedEvent;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class SessionListener implements ApplicationListener<SessionDestroyedEvent> {

    private final QueueService queueService;

    @Override
    public void onApplicationEvent(SessionDestroyedEvent event) {
        try {
            String sessionId = event.getSessionId();

            if (sessionId != null && !sessionId.isEmpty()) {
                log.info("Spring Session 종료 감지: {}", sessionId);
                boolean removed = queueService.leaveQueue(sessionId);
                log.debug("세션 {} 정리 완료 (제거됨: {})", sessionId, removed);
            } else {
                log.warn("SessionDestroyedEvent에서 세션 ID를 가져올 수 없음");
            }
        } catch (Exception e) {
            log.error("세션 종료 처리 중 오류 발생: {}", e.getMessage(), e);
        }
    }
}