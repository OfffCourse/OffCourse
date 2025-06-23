package com.offcourse.security;

import com.offcourse.member.model.dto.Member;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Slf4j
@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

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

        // 로그인 성공 후 메인 페이지로 이동
        response.sendRedirect(request.getContextPath() + "/");
    }
}
