package com.offcourse.redis.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.offcourse.redis.model.dto.Queue;
import com.offcourse.redis.model.service.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

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
            "/static",
            "/resources",
            "/favicon.ico",
            "/error"
    );

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {

        String requestURI = request.getRequestURI();

        if (isExcludedPath(requestURI)) {
            return true;
        }

        String sessionId = getSessionId(request);
        if (sessionId == null) {
            log.warn("세션 ID를 가져올 수 없음 - URI: {}", requestURI);
            response.sendRedirect(request.getContextPath() + "/queue");
            return false;
        }
    try{
        // 대기열 상태 확인
        Queue queueStatus = queueService.enterQueue(sessionId);

        if (!queueStatus.isAccessAllowed()) {
            if (isAjaxRequest(request)) {
                return handleAjaxRequest(response, queueStatus);
            } else {
                response.sendRedirect(request.getContextPath() + "/queue");
                return false;
            }
        }

        // 접근 허용 - 활동 시간 업데이트
        queueService.updateUserActivity(sessionId);
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
     * 세션 ID 안전하게 가져오기
     */
    private String getSessionId(HttpServletRequest request) {
        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                return session.getId();
            }

            // 세션이 없으면 새로 생성
            session = request.getSession(true);
            return session.getId();

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