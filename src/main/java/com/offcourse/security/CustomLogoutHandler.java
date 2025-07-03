package com.offcourse.security;

import com.offcourse.payment.model.service.PaymentQueueService;
import com.offcourse.redis.model.service.QueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.LogoutHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.Cookie;
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

    @Override
    public void logout(HttpServletRequest request, HttpServletResponse response,
                       Authentication authentication) {
        HttpSession session = request.getSession(false);

        if (session != null) {
            String sessionId = session.getId();
            log.info("로그아웃 처리 시작 - 세션: {}", sessionId);

            try {

                if (authentication != null) {
                    log.info("로그아웃 처리: {} (세션: {})", authentication.getName(), sessionId);
                } else {
                    log.info("로그아웃 처리 (세션: {})", sessionId);
                }

                // 대기열에서 제거
                cleanupQueueInfo(sessionId);

                // 쿠키 정리
                cleanupCookies(request, response);

            } catch (Exception e) {
                log.error("로그아웃 시 대기열 처리 오류 - 세션: {}", sessionId, e);
            }
        }
    }

    /**
     * 대기열 정보 정리
     */
    private void cleanupQueueInfo(String sessionId) {
        try {
            // 일반 대기열 제거
            boolean removedFromGeneral = queueService.leaveQueue(sessionId);

            // 결제 대기열 제거
            boolean removedFromPayment = paymentQueueService.leavePaymentQueue(sessionId);

            if (removedFromGeneral || removedFromPayment) {
                log.info("로그아웃 시 대기열 정리 완료 - 세션: {}, 일반: {}, 결제: {}",
                        sessionId, removedFromGeneral, removedFromPayment);
            }

        } catch (Exception e) {
            log.warn("대기열 정리 중 오류 - 세션: {}", sessionId, e);
        }
    }

    /**
     * 쿠키 정리
     */
    private void cleanupCookies(HttpServletRequest request, HttpServletResponse response) {
        try {
            // 세션 관련 쿠키들 삭제
            String[] cookiesToDelete = {
                    "OFFCOURSE_SESSION",
                    "JSESSIONID",
                    "OLD_SESSION_ID"
            };

            for (String cookieName : cookiesToDelete) {
                Cookie cookie = new Cookie(cookieName, "");
                cookie.setMaxAge(0);
                cookie.setPath("/");
                cookie.setHttpOnly(true);
                response.addCookie(cookie);
            }

            log.debug("로그아웃 시 쿠키 정리 완료");

        } catch (Exception e) {
            log.warn("쿠키 정리 중 오류", e);
        }
    }
}