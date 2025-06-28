package com.offcourse.mypage.controller;

import com.offcourse.common.pagefactory.MyPageFactory;
import com.offcourse.common.pagefactory.StudentPageFactory;
import com.offcourse.member.model.dto.Member;
import com.offcourse.mypage.model.dto.Account;
import com.offcourse.mypage.model.dto.DeleteCourseRequest;
import com.offcourse.mypage.model.dto.StudentMyPageResponse;
import com.offcourse.mypage.model.dto.TeacherMyPageResponse;
import com.offcourse.mypage.model.service.MyPageService;
import com.offcourse.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/mypage")
public class MyPageController {

    private final MyPageService service;
    private final MyPageFactory pageFactory;
    private final StudentPageFactory ajaxPageFactory;

    @GetMapping("/teacher")
    public String getMyPageByTeacher(Model model, HttpServletRequest request,
                                     Authentication authentication,
                                     @RequestParam(defaultValue = "1") int cPage,
                                     @RequestParam(defaultValue = "3") int numPerPage,
                                     @RequestParam(required = false) String section) {
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member loginMember = userDetails.getMember();
        Long memberSeq = loginMember.getMemberSeq();
        String url = request.getContextPath() + "/mypage/teacher?section=" + section;
        List<TeacherMyPageResponse> myPageResponses = service.getMyPageByTeacher(Map.of("memberSeq", memberSeq
                , "cPage", cPage, "numPerPage", numPerPage));
        model.addAttribute("myPageResponses", myPageResponses);
        model.addAttribute("pageBar",
                pageFactory.basicPageBar(cPage, numPerPage,
                        service.teacherCourseCount(memberSeq), url));
        model.addAttribute("section", section == null ? "create-course" : section);
        return "mypage/teacherMyPage";
    }

    @GetMapping("/student")
    public String getMyPageByStudent() {
        return "mypage/studentMyPage";
    }

    @PostMapping("/student-current")
    @ResponseBody
    public Map<String, Object> getCurrentCourseByStudent(Authentication authentication,
                                                         @RequestParam(defaultValue = "1") int cPage,
                                                         @RequestParam(defaultValue = "3") int numPerPage) {

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member loginMember = userDetails.getMember();
        Long memberSeq = loginMember.getMemberSeq();
        int totalData = service.countCurrentCoursesByStudent(memberSeq);
        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalData);
        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberSeq", memberSeq);
        paramMap.put("cPage", cPage);
        paramMap.put("numPerPage", numPerPage);
        List<StudentMyPageResponse> list = service.getCurrentCoursesByStudent(paramMap);

        return Map.of("courses", list, "pageBar", pageBar);
    }

    @PostMapping("/student-complete")
    @ResponseBody
    public Map<String, Object> getCompleteCourseByStudent(Authentication authentication,
                                                          @RequestParam(defaultValue = "1") int cPage,
                                                          @RequestParam(defaultValue = "3") int numPerPage) {
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member loginMember = userDetails.getMember();
        Long memberSeq = loginMember.getMemberSeq();
        int totalData = service.countCompletedCoursesByStudent(memberSeq);
        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalData);
        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberSeq", memberSeq);
        paramMap.put("cPage", cPage);
        paramMap.put("numPerPage", numPerPage);
        List<StudentMyPageResponse> list = service.getCompletedCoursesByStudent(paramMap);

        return Map.of("courses", list, "pageBar", pageBar);
    }

    @PostMapping("/student-pending")
    @ResponseBody
    public Map<String, Object> getPendingCourseByStudent(Authentication authentication,
                                                         @RequestParam(defaultValue = "1") int cPage,
                                                         @RequestParam(defaultValue = "3") int numPerPage) {
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Member loginMember = userDetails.getMember();
        Long memberSeq = loginMember.getMemberSeq();
        int totalData = service.countPendingCoursesByStudent(memberSeq);
        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalData);
        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("memberSeq", memberSeq);
        paramMap.put("cPage", cPage);
        paramMap.put("numPerPage", numPerPage);
        List<StudentMyPageResponse> list = service.getPendingCoursesByStudent(paramMap);

        return Map.of("courses", list, "pageBar", pageBar);
    }


    @PostMapping("/account")
    public String insertAccount(@ModelAttribute Account account, Model model) {
        int result = service.insertAccount(account);
        if (result > 0) {
            model.addAttribute("msg", "정산 신청 성공");
            model.addAttribute("loc", "/mypage/teacher?section=settlement");
        } else {
            model.addAttribute("msg", "정산 신청 실패");
            model.addAttribute("loc", "/mypage/teacher?section=settlement");
        }
        return "common/msg";
    }

    @PostMapping("/deleterequest")
    public String insertDeleteCourseRequest(@ModelAttribute DeleteCourseRequest req,
                                            Model model) {
        int result = service.insertDeleteCourseRequest(req);
        if (result > 0) {
            model.addAttribute("msg", "삭제 신청 성공");
            model.addAttribute("loc", "/mypage");
        } else {
            model.addAttribute("msg", "삭제 신청 실패");
            model.addAttribute("loc", "/mypage");
        }
        return "common/msg";
    }

}
