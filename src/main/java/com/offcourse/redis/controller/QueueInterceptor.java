package com.offcourse.redis.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.offcourse.redis.model.dto.Queue;
import com.offcourse.redis.model.service.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

@Component
@RequiredArgsConstructor
@Slf4j
public class QueueInterceptor implements HandlerInterceptor {

    private final QueueService queueService;

    private static final Set<String> EXCLUDED_PATHS = Set.of(
            "/queue",
            "/error",
            "/mail",
            "/email",
            "/api",
            "/notification",
            "/login",
            "/logout",
            "/member"
    );

    // 대기열 체크는 하되 활동 업데이트는 하지 않을 경로들 (AJAX 요청 등)
    private static final Set<String> CHECK_ONLY_PATHS = Set.of(
            "/queue/status",
            "/queue/admin",
            "/queue/heartbeat",
            "/payment/heartbeat",
            "/payment/status"
    );

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {

        String requestURI = request.getRequestURI();

        // 제외 경로 체크
        if (isExcludedPath(requestURI)) {
            return true;
        }

        HttpSession session = request.getSession(false);
        String sessionId = getSessionId(request, session);

        if (sessionId == null) {
            log.warn("세션 ID를 가져올 수 없음 - URI: {}", requestURI);
            response.sendRedirect(request.getContextPath() + "/queue");
            return false;
        }

        try {
            // 세션 전환 감지 및 처리 (로그인 시)
            handleSessionTransition(request, sessionId);

            // 대기열 상태 확인
            Queue queueStatus = queueService.enterQueue(sessionId);

            if (!queueStatus.isAccessAllowed()) {
                log.info("대기열 접근 제한 - 세션: {}, URI: {}, 상태: {}, 순번: {}",
                        sessionId, requestURI, queueStatus.getStatus(), queueStatus.getPosition());

                if (isAjaxRequest(request)) {
                    return handleAjaxRequest(response, queueStatus);
                } else {
                    // 일반 요청은 대기열 페이지로 리다이렉트
                    response.sendRedirect(request.getContextPath() + "/queue");
                    return false;
                }
            }

            return true;
        } catch (Exception e) {
            log.error("대기열 처리 중 오류 - SessionId: {}, URI: {}", sessionId, requestURI, e);
            // 오류 발생 시 기본적으로 접근 허용 (서비스 중단 방지)
            return true;
        }
    }

    private boolean isExcludedPath(String requestURI) {
        return EXCLUDED_PATHS.stream().anyMatch(requestURI::startsWith);
    }

    /**
     * 세션 전환 감지 및 처리 (로그인 시 사용)
     */
    private void handleSessionTransition(HttpServletRequest request, String currentSessionId) {
        try {
            // 이전 세션 ID가 있는지 확인 (쿠키에서)
            String oldSessionId = getOldSessionId(request);

            if (oldSessionId != null && !oldSessionId.equals(currentSessionId)) {
                log.info("세션 전환 감지 - 이전: {}, 현재: {}", oldSessionId, currentSessionId);

                // 대기열 세션 정보 이전
                boolean transferred = queueService.transferQueueSession(oldSessionId, currentSessionId);

                if (transferred) {
                    log.info("대기열 세션 전환 완료 - 이전: {}, 현재: {}", oldSessionId, currentSessionId);
                } else {
                    log.debug("전환할 대기열 정보 없음 - 이전: {}, 현재: {}", oldSessionId, currentSessionId);
                }
            }
        } catch (Exception e) {
            log.warn("세션 전환 처리 중 오류 - 현재 세션: {}", currentSessionId, e);
        }
    }

    /**
     * 이전 세션 ID 가져오기
     */
    private String getOldSessionId(HttpServletRequest request) {
        // 쿠키에서 이전 세션 ID 찾기
        if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if ("OLD_SESSION_ID".equals(cookie.getName())) {
                    String value = cookie.getValue();
                    if (value != null && !value.isEmpty()) {
                        return value;
                    }
                }
            }
        }

        return null;
    }

    /**
     * 세션 ID 안전하게 가져오기
     */
    private String getSessionId(HttpServletRequest request, HttpSession session) {
        try {
            // 기존 세션이 있으면 사용
            if (session != null && !session.isNew()) {
                return session.getId();
            }

            // 세션이 없거나 새 세션이면 생성
            HttpSession newSession = request.getSession(true);
            String sessionId = newSession.getId();

            log.debug("새 세션 생성 - SessionId: {}", sessionId);
            return sessionId;

        } catch (Exception e) {
            log.error("세션 ID 가져오기 실패", e);
            return null;
        }
    }

    /**
     * AJAX 요청 확인
     */
    private boolean isAjaxRequest(HttpServletRequest request) {
        String xRequestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equals(xRequestedWith) ||
                (request.getHeader("Accept") != null &&
                        request.getHeader("Accept").contains("application/json"));
    }

    /**
     * AJAX 요청에 대한 JSON 응답 처리
     */
    private boolean handleAjaxRequest(HttpServletResponse response, Queue queueStatus)
            throws IOException {

        response.setStatus(queueStatus.getHttpStatus());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            ObjectMapper mapper = new ObjectMapper();
            String jsonResponse = mapper.writeValueAsString(queueStatus);
            response.getWriter().write(jsonResponse);
            response.getWriter().flush();

            log.debug("AJAX 대기열 응답 전송 - 상태: {}, 순번: {}",
                    queueStatus.getStatus(), queueStatus.getPosition());

        } catch (Exception e) {
            log.error("AJAX 응답 생성 실패", e);
        }
        return false;
    }
}