package com.offcourse.mypage.controller;

import com.offcourse.common.MyPageFactory;
import com.offcourse.mypage.model.dto.TeacherMyPageResponse;
import com.offcourse.mypage.model.service.MyPageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/mypage")
public class MyPageController {

    private final MyPageService service;
    private final MyPageFactory pageFactory;

    @GetMapping
    public String getMyPage(Model model, HttpSession session, HttpServletRequest request,
                            @RequestParam(defaultValue = "1") int cPage,
                            @RequestParam(defaultValue = "3") int numPerPage,
                            @RequestParam(required = false) String section) {

        //로그인 세션 저장되면 주석풀기

        /*Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null) {
            return "redirect:/member/login";
        }

        long memberSeq = loginMember.getMemberSeq();

        if(loginMember.getMemberType().equals("1")){
            List<TeacherMyPageResponse> myPageResponses = service.getMyPageByTeacher(memberSeq);
            model.addAttribute("m", myPageResponses);
            return "mypage/teacherMyPage";
        }
        List<StudentMyPageResponse> myPageResponses = service.getMyPageByStudent(memberSeq);
        model.addAttribute("m", myPageResponses);
        return "mypage/studentMyPage";
        */
        String url = request.getContextPath() + "/mypage?section=" + section;
        List<TeacherMyPageResponse> myPageResponses = service.getMyPageByTeacher(Map.of("memberSeq", 1L, "cPage", cPage, "numPerPage", numPerPage));
        model.addAttribute("myPageResponses", myPageResponses);
        model.addAttribute("pageBar",
                pageFactory.basicPageBar(cPage, numPerPage,
                        service.teacherCourseCount(1L), url));
        model.addAttribute("section", section == null ? "create-course" : section);
        return "mypage/teacherMyPage";
    }

}
