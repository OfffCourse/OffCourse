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
    @Autowired
    @Lazy
    private QueueService queueService;

    // Lazy 로딩으로 순환 참조 및 빈 찾기 문제 해결

   // public void setQueueService(QueueService queueService) {
//        this.queueService = queueService;
//    }

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

        try {
            HttpSession session = request.getSession();
            String newSessionId = session.getId();
            String oldSessionId = getOldSessionId(request);

            try {
                boolean queueTransferred = queueService.transferQueueSession(oldSessionId, newSessionId);
            } catch (Exception e) {
                log.warn("일반 대기열 세션 전환 실패: {} -> {}", oldSessionId, newSessionId, e);
            }

            // 아이디 저장 처리
            handleSaveId(request, response, loginMember);

            // 로그인 성공 후 리다이렉트
            handleRedirect(request, response);

        } catch (Exception e) {
            log.error("로그인 성공 처리 중 오류 - 사용자: {}", loginMember.getMemberId(), e);

            // 오류 발생해도 기본 리다이렉트는 수행
            String targetUrl = request.getContextPath() + "/";
            response.sendRedirect(targetUrl);
        }
    }
    /**
     * 세션 변경 시 대기열 정보 이전 처리 (개선됨)
     */
    private void handleSessionChange(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession();
        String newSessionId = session.getId();
        try {
            // 이전 세션 ID 가져오기 (쿠키나 요청 파라미터에서)
            String oldSessionId = getOldSessionId(request);

            if (oldSessionId != null && !oldSessionId.equals(newSessionId)) {
                log.info("로그인 성공 - 세션 전환 처리: {} -> {}", oldSessionId, newSessionId);

                // 일반 대기열 세션 전환
                boolean queueTransferred = false;

                try {
                    queueTransferred = queueService.transferQueueSession(oldSessionId, newSessionId);
                } catch (Exception e) {
                    log.warn("일반 대기열 세션 전환 실패: {} -> {}", oldSessionId, newSessionId, e);
                }

                if (queueTransferred) {
                    log.info("세션 전환 완료 - 일반: {}", queueTransferred);
                } else {
                    log.debug("전환할 대기열 정보 없음 - {} -> {}", oldSessionId, newSessionId);
                }

                // 세션 무효화 후 새 세션 시작
                if (session != null) {
                    session.invalidate();
                }

            } else {
                log.debug("로그인 성공 - 새 세션: {}", newSessionId);
            }
        } catch (Exception e) {
            log.error("세션 변경 처리 중 오류", e);
            // 오류가 발생해도 로그인은 계속 진행
        }
    }

    /**
     * 이전 세션 ID 가져오기
     */
    private String getOldSessionId(HttpServletRequest request) {
        if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if ("OFFCOURSE_SESSION".equals(cookie.getName()) || "JSESSIONID".equals(cookie.getName())) {
                    String cookieValue = cookie.getValue();
                    if (cookieValue != null && !cookieValue.isEmpty()) {
                        return cookieValue;
                    }
                }
            }
        }

        return null;
    }

    /**
     * 이전 세션 ID를 쿠키에 저장 (클라이언트 JavaScript에서 사용 가능)
     */
    private void addOldSessionCookie(HttpServletResponse response, String oldSessionId) {
        try {
            Cookie oldSessionCookie = new Cookie("OLD_SESSION_ID", oldSessionId);
            oldSessionCookie.setPath("/");
            oldSessionCookie.setMaxAge(300); // 5분 후 자동 삭제
            oldSessionCookie.setHttpOnly(false); // JavaScript에서 접근 가능
            response.addCookie(oldSessionCookie);

            log.debug("이전 세션 ID 쿠키 추가: {}", oldSessionId);
        } catch (Exception e) {
            log.warn("이전 세션 ID 쿠키 추가 실패", e);
        }
    }

    /**
     * 아이디 저장 처리
     */
    private void handleSaveId(HttpServletRequest request, HttpServletResponse response, Member loginMember) {
        try {
            String saveId = request.getParameter("saveId");
            if (saveId != null) {
                Cookie cookie = new Cookie("savedId", loginMember.getMemberId());
                cookie.setPath("/");
                cookie.setMaxAge(60 * 60 * 24 * 14); // 14일 유지
                response.addCookie(cookie);
                log.debug("아이디 저장 쿠키 설정: {}", loginMember.getMemberId());
            } else {
                Cookie cookie = new Cookie("savedId", null);
                cookie.setPath("/");
                cookie.setMaxAge(0); // 쿠키 삭제
                response.addCookie(cookie);
                log.debug("아이디 저장 쿠키 삭제");
            }
        } catch (Exception e) {
            log.warn("아이디 저장 처리 중 오류", e);
        }
    }

    /**
     * 리다이렉트 처리
     */
    private void handleRedirect(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 기본 타겟 URL
        String targetUrl = request.getContextPath() + "/";

        // 이전 페이지가 있다면 그곳으로 리다이렉트 (세션 파라미터 제거)
        String redirectUrl = request.getParameter("redirect");
        if (redirectUrl != null && !redirectUrl.isEmpty()) {
            targetUrl = cleanUrl(redirectUrl);
            log.debug("리다이렉트 URL 설정: {}", targetUrl);
        }

        log.info("로그인 성공 리다이렉트: {}", targetUrl);
        response.sendRedirect(targetUrl);
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
