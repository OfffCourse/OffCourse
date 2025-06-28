package com.offcourse.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.session.data.redis.config.annotation.web.http.EnableRedisHttpSession;
import org.springframework.session.web.http.CookieHttpSessionIdResolver;
import org.springframework.session.web.http.CookieSerializer;
import org.springframework.session.web.http.DefaultCookieSerializer;
import org.springframework.session.web.http.HttpSessionIdResolver;

/**
 * Spring Session 전용 설정 클래스
 * Redis 설정은 RedisConfig에서 처리하고, 여기서는 세션 관련 설정만 담당
 */
@Configuration
@EnableRedisHttpSession(
        maxInactiveIntervalInSeconds = 1800, // 30분
        redisNamespace = "offcourse:session"
)
public class SessionConfig {

    /**
     * 세션 쿠키 설정
     * 보안 및 동작 방식 커스터마이징
     */
    @Bean
    public CookieSerializer cookieSerializer() {
        DefaultCookieSerializer serializer = new DefaultCookieSerializer();

        // 쿠키 이름 설정
        serializer.setCookieName("OFFCOURSE_SESSION");

        // 쿠키 경로 설정
        serializer.setCookiePath("/");

        // HttpOnly 설정 (XSS 공격 방지)
        serializer.setUseHttpOnlyCookie(true);

        // Secure 설정 (HTTPS에서만 쿠키 전송)
        // 개발 환경에서는 false, 운영 환경에서는 true로 설정
        serializer.setUseSecureCookie(false);

        // SameSite 설정 (CSRF 공격 방지)
        serializer.setSameSite("Lax");

        // 쿠키 최대 나이 설정
        // -1: 브라우저 세션 동안만 유지 (브라우저 종료 시 삭제)
        serializer.setCookieMaxAge(-1);

        // Base64 인코딩 사용 안함 (URL 인코딩 방지)
        serializer.setUseBase64Encoding(false);

        return serializer;
    }

    /**
     * HttpSessionIdResolver 설정
     * URL rewriting을 완전히 비활성화하고 쿠키만 사용
     */
    @Bean
    public HttpSessionIdResolver httpSessionIdResolver() {
        // 쿠키만 사용하여 세션 ID 추적
        // 이 설정으로 URL에 ;jsessionid=xxx가 추가되지 않음
        return new CookieHttpSessionIdResolver();
    }
}