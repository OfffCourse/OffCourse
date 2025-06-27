package com.offcourse.security;

import com.offcourse.redis.model.service.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 로그아웃 시 대기열 처리를 위한 커스텀 로그아웃 핸들러
 * Spring Security의 기본 로그아웃 처리 전에 실행되어 대기열에서 사용자를 제거합니다.
 */
@Component
@Slf4j
public class CustomLogoutHandler implements LogoutHandler {

    private QueueService queueService;

    // Lazy 로딩으로 순환 참조 및 빈 찾기 문제 해결
    @Autowired
    @Lazy
    public void setQueueService(QueueService queueService) {
        this.queueService = queueService;
    }

    @Override
    public void logout(HttpServletRequest request, HttpServletResponse response,
                       Authentication authentication) {
        HttpSession session = request.getSession(false);

        if (session != null) {
            String sessionId = session.getId();
            log.info("로그아웃 처리 시작 - 세션: {}", sessionId);

            try {
                // 세션이 무효화되기 전에 대기열에서 제거
                boolean removed = queueService.leaveQueue(sessionId);

                if (removed) {
                    log.info("로그아웃으로 인한 대기열 제거 완료 - 세션: {}", sessionId);
                } else {
                    log.debug("로그아웃 사용자가 대기열에 없음 - 세션: {}", sessionId);
                }
            } catch (Exception e) {
                log.error("로그아웃 시 대기열 처리 오류 - 세션: {}", sessionId, e);
            }
        }
    }
}