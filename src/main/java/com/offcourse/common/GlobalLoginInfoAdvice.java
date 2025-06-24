package com.offcourse.common;

import com.offcourse.member.model.dto.Member;
import com.offcourse.security.CustomUserDetails;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice // 전역적으로 적용되는 컨트롤러 클래스
public class GlobalLoginInfoAdvice {

    @ModelAttribute("loginMember") // JSP나 컨트롤러에서 바로 loginMember라는 이름으로 사용 가능하게 해줌
    public Member loginMember(Authentication auth) {
        if (auth != null &&
                auth.isAuthenticated() &&
                auth.getPrincipal() instanceof CustomUserDetails) {

            return ((CustomUserDetails) auth.getPrincipal()).getMember();
        }

        return null;
    }
}
