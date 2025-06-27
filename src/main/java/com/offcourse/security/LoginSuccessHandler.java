package com.offcourse.security;

import com.offcourse.member.model.dto.Member;
import com.offcourse.redis.model.service.QueueService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@Slf4j
@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    private QueueService queueService;

    // Lazy 로딩으로 순환 참조 및 빈 찾기 문제 해결
    @Autowired
    @Lazy
    public void setQueueService(QueueService queueService) {
        this.queueService = queueService;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        // 로그인 성공한 사용자 정보 추출
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member loginMember = userDetails.getMember();

//        // 세션에 로그인 정보 저장
//        HttpSession session = request.getSession();
//        session.setAttribute("loginMember", loginMember);
//        // 일반회원과 강사회원 모두 이렇게 세션에 저장해주고,
//        // loginMember의 memberType 값을 통해서 분기를 통해
//        // 일반회원과 강사회원의 화면을 다르게 보여주거나
//        // 마이페이지 눌렀을때 다른 화면을 보여주게 할 계획

        log.info("✅ 로그인 성공: {}", loginMember.getMemberId());

        // ✅ 아이디 저장 처리
        String saveId = request.getParameter("saveId");
        if (saveId != null) {
            Cookie cookie = new Cookie("savedId", loginMember.getMemberId());
            cookie.setPath("/");
            cookie.setMaxAge(60 * 60 * 24 * 14); // 14일 유지
            response.addCookie(cookie);
        } else {
            Cookie cookie = new Cookie("savedId", null);
            cookie.setPath("/");
            cookie.setMaxAge(0); // 쿠키 삭제
            response.addCookie(cookie);
        }

        // URL에서 세션 파라미터 제거하여 리다이렉트
        String targetUrl = request.getContextPath() + "/";

        // 이전 페이지가 있다면 그곳으로 리다이렉트 (세션 파라미터 제거)
        String redirectUrl = request.getParameter("redirect");
        if (redirectUrl != null && !redirectUrl.isEmpty()) {
            targetUrl = cleanUrl(redirectUrl);
        }

        response.sendRedirect(targetUrl);
    }

    /**
     * 세션 변경 시 대기열 정보 이전 처리
     */
    private void handleSessionChange(HttpServletRequest request, Authentication authentication) {
        try {
            // 이전 세션 ID 가져오기
//            String oldSessionId = null;
//            WebAuthenticationDetails details = (WebAuthenticationDetails) authentication.getDetails();
//            if (details != null) {
//                oldSessionId = details.getSessionId();
//            }
            String oldSessionId = request.getRequestedSessionId();

            // 현재 세션 ID
            HttpSession session = request.getSession();
            String newSessionId = session.getId();

            // 세션이 변경되었다면 대기열 정보 이전
            if (oldSessionId != null && !oldSessionId.equals(newSessionId)) {
                log.info("세션 변경 감지 - 이전: {}, 새: {}", oldSessionId, newSessionId);

                boolean transferred = queueService.transferQueueSession(oldSessionId, newSessionId);
                if (transferred) {
                    log.info("대기열 세션 정보 이전 완료");
                }
            }
        } catch (Exception e) {
            log.error("세션 변경 처리 중 오류", e);
            // 오류가 발생해도 로그인은 계속 진행
        }
    }

    /**
     * URL에서 세션 관련 파라미터 제거
     */
    private String cleanUrl(String url) {
        if (url == null) return "";

        // sessionId 파라미터 제거
        url = url.replaceAll("[?&]sessionId=[^&]*", "");
        // jsessionid 제거
        url = url.replaceAll(";jsessionid=[^?]*", "");
        // 첫 번째 & 를 ? 로 변경
        url = url.replaceAll("\\?&", "?");
        // 마지막 ? 제거
        if (url.endsWith("?")) {
            url = url.substring(0, url.length() - 1);
        }

        return url;
    }

}
