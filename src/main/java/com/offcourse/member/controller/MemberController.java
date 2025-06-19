package com.offcourse.member.controller;

import com.offcourse.member.model.dto.Member;
import com.offcourse.member.model.service.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
@Slf4j
public class MemberController {

    private final MemberService memberService;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/member/enroll")
    public String enrollMember(Member member, RedirectAttributes redirectAttributes) {
        try {
            // 비밀번호 암호화
            member.setMemberPwd(passwordEncoder.encode(member.getMemberPwd()));

            int result = memberService.insertMember(member);

            if (result > 0) {
                redirectAttributes.addFlashAttribute("msg", "회원가입 성공!");
                return "redirect:/";
            } else {
                redirectAttributes.addFlashAttribute("msg", "회원가입 실패. 다시 시도해주세요.");
                return "redirect:/member/enroll";
            }
        } catch (Exception e) {
            log.error("회원가입 중 예외 발생", e);
            redirectAttributes.addFlashAttribute("msg", "오류가 발생했습니다.");
            return "redirect:/member/enroll";
        }
    }
}
