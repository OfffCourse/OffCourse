package com.offcourse.common.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import java.io.IOException;

/**
 * URL Rewriting을 완전히 비활성화하는 필터
 * encodeURL, encodeRedirectURL 메서드를 오버라이드하여 세션 ID가 URL에 추가되지 않도록 함
 */
public class DisableUrlRewritingFilter implements Filter {


    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        if (response instanceof HttpServletResponse) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            HttpServletResponse httpResponse = (HttpServletResponse) response;

            // URL rewriting을 비활성화하는 래퍼 사용
            DisableUrlRewritingResponseWrapper wrappedResponse =
                    new DisableUrlRewritingResponseWrapper(httpResponse, httpRequest);

            chain.doFilter(request, wrappedResponse);
        } else {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
        // 정리 로직 (필요시)
    }

    /**
     * URL rewriting을 비활성화하는 Response 래퍼
     */
    private static class DisableUrlRewritingResponseWrapper extends HttpServletResponseWrapper {

        private final HttpServletRequest request;

        public DisableUrlRewritingResponseWrapper(HttpServletResponse response,
                                                  HttpServletRequest request) {
            super(response);
            this.request = request;
        }

        @Override
        public String encodeURL(String url) {
            // 세션 ID를 URL에 추가하지 않고 원본 URL 그대로 반환
            return removeSessionId(url);
        }

        @Override
        public String encodeRedirectURL(String url) {
            // 리다이렉트 URL에도 세션 ID를 추가하지 않음
            return removeSessionId(url);
        }

        @Override
        @Deprecated
        public String encodeUrl(String url) {
            return removeSessionId(url);
        }

        @Override
        @Deprecated
        public String encodeRedirectUrl(String url) {
            return removeSessionId(url);
        }

        /**
         * URL에서 세션 ID 제거
         */
        private String removeSessionId(String url) {
            if (url == null) return null;

            // ;jsessionid= 패턴 제거
            url = url.replaceAll(";jsessionid=[^?#]*", "");

            // ?sessionId= 또는 &sessionId= 패턴 제거
            url = url.replaceAll("[?&]sessionId=[^&#]*", "");

            // 첫 번째 & 를 ? 로 변경
            if (url.contains("&") && !url.contains("?")) {
                url = url.replaceFirst("&", "?");
            }

            // 마지막 ? 제거
            if (url.endsWith("?")) {
                url = url.substring(0, url.length() - 1);
            }

            return url;
        }
    }
}