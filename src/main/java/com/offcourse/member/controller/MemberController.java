// MemberController.java
package com.offcourse.member.controller;

import com.offcourse.member.model.dto.Member;
import com.offcourse.member.model.service.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@Controller
@RequiredArgsConstructor
@Slf4j
public class MemberController {

    private final MemberService memberService;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/member/enroll")
    public String enrollMember(
//            @RequestParam Map<String, Object> map,
            @Validated Member member,
            BindingResult bindingResult,
            @RequestParam(value ="profileFile", required = false) MultipartFile profileFile,
            @RequestParam(value = "portfolioFile", required = false) MultipartFile portfolioFile,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        System.out.println("🔥 컨트롤러 메서드 진입!");

        if (bindingResult.hasErrors()) {
            bindingResult.getAllErrors().forEach(error -> System.out.println("❗️" + error.getDefaultMessage()));
            redirectAttributes.addFlashAttribute("msg", "입력값 검증 실패");
            System.out.println("바인딩 실패");
            return "redirect:/member/enroll/student";
        }

        String profileFileName = null;
        String portfolioFileName = null;
        String profilePath="";
        String portfolioPath="";
        try {
//            map.forEach((k,v)-> System.out.println(k + " = " + v));
            log.info("📌 member = {}", member);
            System.out.println(member.toString());
            System.out.println(profileFile);
            // 🔐 비밀번호 암호화
            System.out.println("🔥 컨트롤러 메서드 진입!");
            member.setMemberPwd(passwordEncoder.encode(member.getMemberPwd()));


            // 🔽 파일 저장 경로 설정
            profilePath = session.getServletContext().getRealPath(
                    member.getMemberType().equals("1") ? "/resources/upload/instructor/profile" :
                            "/resources/upload/student/profile");

            portfolioPath = session.getServletContext().getRealPath("/resources/upload/instructor/portfolio");
            // 🔽 프로필 파일 저장
            if (profileFile != null && !profileFile.isEmpty()) {
                profileFileName = saveFile(profileFile, profilePath);
                member.setMemberProfile(profileFileName);
            }


            // 🔽 포트폴리오 파일 저장 (강사 전용)
            if ("1".equals(member.getMemberType()) && portfolioFile != null && !portfolioFile.isEmpty()) {
                portfolioFileName = saveFile(portfolioFile, portfolioPath);
                member.setPortfolioFileName(portfolioFileName);
            }

            // 🔽 DB 저장 (트랜잭션 적용된 서비스)
            int result = memberService.insertMember(member);
//            int result = 1;
            if (result > 0) {
                redirectAttributes.addFlashAttribute("msg", "회원가입 성공!");
                return "redirect:/";
            } else {
                deleteFile(profilePath, profileFileName);
                deleteFile(portfolioPath, portfolioFileName);
                redirectAttributes.addFlashAttribute("msg", "회원가입 실패. 다시 시도해주세요.");
                System.out.println("디비 저장이 안 된건가");

                return "redirect:/member/enroll/select";
            }

        } catch (Exception e) {
            log.error("회원가입 중 예외 발생", e);
            deleteFile(profilePath, profileFileName);
            deleteFile(portfolioPath, portfolioFileName);
            redirectAttributes.addFlashAttribute("msg", "오류가 발생했습니다.");
            System.out.println("회원가입 중 예외 발생..ㅜㅜ");

            return "redirect:/member/enroll/select";
        }
    }

    private String saveFile(MultipartFile file, String path) throws IOException {
        String oriName = file.getOriginalFilename();
        String ext = oriName.substring(oriName.lastIndexOf("."));
        int rnd = (int) (Math.random() * 1000) + 1;
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmssSSS").format(new Date());
        String rename = "offcourse_" + timeStamp + "_" + rnd + ext;

        File dir = new File(path);
        if (!dir.exists()) dir.mkdirs();

        file.transferTo(new File(dir, rename));
        return rename;
    }

    private void deleteFile(String path, String fileName) {
        if (fileName != null) {
            File file = new File(path, fileName);
            if (file.exists()) {
                boolean deleted = file.delete();
                if (deleted) {
                    log.info("🗑️ 삭제된 파일: {}", file.getAbsolutePath());
                } else {
                    log.warn("⚠️ 파일 삭제 실패: {}", file.getAbsolutePath());
                }
            }
        }
    }


    @GetMapping("/member/enroll/select")
    public String showEnrollSelectPage() {
        return "member/enrollSelect";
    }

    @GetMapping("/member/enroll/student")
    public String showStudentEnrollPage(Model model) {
        model.addAttribute("memberType", "student");
        return "member/enrollStudent";
    }

    @GetMapping("/member/enroll/instructor")
    public String showInstructorEnrollPage(Model model) {
        model.addAttribute("memberType", "instructor");
        return "member/enrollInstructor";
    }
}
