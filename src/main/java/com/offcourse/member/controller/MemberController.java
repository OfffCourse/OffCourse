package com.offcourse.member.controller;

import com.offcourse.member.model.dto.Member;
import com.offcourse.member.model.service.DuplicateMemberException;
import com.offcourse.member.model.service.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/member")
public class MemberController {

    private final MemberService memberService;

    @PostMapping("/enroll")
    public String enrollMember(
            @Validated Member member,
            BindingResult bindingResult,
            @RequestParam(value ="profileFile", required = false) MultipartFile profileFile,
            @RequestParam(value = "portfolioFile", required = false) MultipartFile portfolioFile,
            HttpSession session,
            Model model,
            RedirectAttributes redirectAttributes) {

        // 유효성 검사 에러
        if (bindingResult.hasErrors()) {
            model.addAttribute("msg", "입력값을 다시 확인해주세요.");
            model.addAttribute("member", member);
            return "member/enroll" + ("0".equals(member.getMemberType()) ? "Student" : "Instructor");
        }

        try {
            int result = memberService.insertMember(member, profileFile, portfolioFile, session);
            if (result > 0) {
                redirectAttributes.addFlashAttribute("msg", "회원가입 성공!");
                return "redirect:/member/loginform";
            } else {
                model.addAttribute("msg", "알 수 없는 오류가 발생했습니다. 다시 시도해주세요.");
            }
        } catch (DuplicateMemberException dup) {
            model.addAttribute("msg", dup.getMessage());
        } catch (Exception e) {
            log.error("회원가입 중 예외 발생", e);
            model.addAttribute("msg", "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }
        // 실패 시엔 폼으로 되돌아가기
        model.addAttribute("member", member);
        return "member/enroll" + ("0".equals(member.getMemberType()) ? "Student" : "Instructor");
    }

    @GetMapping("/enroll/select")
    public String showEnrollSelectPage() {
        return "member/enrollSelect";
    }

    @GetMapping("/enroll/student")
    public String showStudentEnrollPage(Model model) {
        if (!model.containsAttribute("member")) {
            model.addAttribute("member", new Member());
        }
        return "member/enrollStudent";
    }

    @GetMapping("/enroll/instructor")
    public String showInstructorEnrollPage(Model model) {
        if (!model.containsAttribute("member")) {
            model.addAttribute("member", new Member());
        }
        return "member/enrollInstructor";
    }

    @GetMapping("/loginform")
    public String loginForm() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            return "redirect:/";
        }
        return "member/login";
    }

    @GetMapping("/find-id")
    public String findIdForm() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            return "redirect:/";
        }
        return "member/findId";
    }

    @PostMapping("/find-id")
    public String findId(@RequestParam("memberEmail") String memberEmail, Model model) {
        Member member = memberService.findByEmail(memberEmail);
        if (member != null) {
            model.addAttribute("foundId", member.getMemberId());
        } else {
            model.addAttribute("msg", "회원가입 내역을 확인할 수 없습니다.");
        }
        return "member/findIdResult";
    }

    @GetMapping("/find-password")
    public String findPasswordForm() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
            return "redirect:/";
        }
        return "member/findPassword";
    }

    @PostMapping("/find-password")
    public String findPassword(@RequestParam("memberId") String memberId,
                               @RequestParam("memberEmail") String memberEmail,
                               Model model) {
        boolean success = memberService.resetPassword(memberId, memberEmail);
        if (!success) {
            model.addAttribute("msg", "일치하는 회원이 없습니다.");
        } else {
            model.addAttribute("msg", "입력한 이메일로 임시 비밀번호가 전송되었습니다.");
        }
        return "member/findPasswordResult";
    }

}
