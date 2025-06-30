package com.offcourse.course.controller;

import com.offcourse.attachment.model.service.AttachmentService;
import com.offcourse.common.pagefactory.AjaxPageFactory;
import com.offcourse.common.pagefactory.StudentPageFactory;
import com.offcourse.course.exception.CourseEpisodeMismatchException;
import com.offcourse.course.model.dto.*;
import com.offcourse.course.model.service.CourseService;
import com.offcourse.member.model.dto.Member;
import com.offcourse.present.model.service.PresentService;
import com.offcourse.review.model.dto.ReviewViewResponse;
import com.offcourse.review.model.service.ReviewService;
import com.offcourse.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/course")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService service;
    private final PresentService presentService;
    private final AjaxPageFactory ajaxPageFactory;
    private final StudentPageFactory pageFactory;
    private final AttachmentService attachmentService;
    private final ReviewService reviewService;

    @GetMapping("/listpage")
    public String courseList() {
        return "course/courseList";
    }

    @ResponseBody
    @PostMapping("/search")
    public Map<String, Object> getCourseList(@RequestBody Map<String, Object> param) {

        int cPage = Integer.parseInt(String.valueOf(param.getOrDefault("cPage", "1")));
        int numPerPage = Integer.parseInt(String.valueOf(param.getOrDefault("numPerPage", "4")));
        int totalData = service.getCourseListCount(param);
        RowBounds rb = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalData);

        List<CourseListResponse> list = service.getCourseList(param, rb);

        return Map.of("courses", list, "pageBar", pageBar);
    }

    @PostMapping("/insert")
    public String insertEndCourse(@ModelAttribute Course course,
                                  @RequestParam("categoryType") String categoryType,
                                  @RequestParam("dayList") List<String> courseDays,
                                  Model model) {

        long categorySeq = service.getCategorySeqByType(categoryType);
        course.setCategorySeq(categorySeq);

        int result = service.insertCourse(course, courseDays);
        if (result > 0) {
            model.addAttribute("msg", "강의 등록 성공");
            model.addAttribute("loc", "/course/listpage");
        } else {
            model.addAttribute("msg", "강의 등록 실패");
            model.addAttribute("loc", "/mypage");
        }
        return "common/msg";
    }

    @PostMapping("/update")
    public String updateCourse(@ModelAttribute Course course, Model model) {
        int result = service.updateCourse(course);
        if (result > 0) {
            model.addAttribute("msg", "강의 수정 성공");
            model.addAttribute("loc", "/course/view?courseSeq=" + course.getCourseSeq());
        } else {
            model.addAttribute("msg", "강의 수정 실패");
            model.addAttribute("loc", "/mypage");
        }
        return "common/msg";
    }

    @GetMapping("/view")
    public String courseView(@RequestParam Long courseSeq,
                             Authentication authentication,
                             Model model) {
        Member member = null;
        if (authentication != null && authentication.isAuthenticated()) {
            Object principal = authentication.getPrincipal();
            if (principal instanceof CustomUserDetails) {
                member = ((CustomUserDetails) principal).getMember();
            }
        }
        CourseViewResponse course = service.getCourseBySeq(courseSeq);
        model.addAttribute("course", course);
        int countEpisode = service.countEpisodeByCourseSeq(courseSeq);
        model.addAttribute("countEpisode", countEpisode);
        LocalDate today = LocalDate.now();
        LocalDate courseStart = course.getCourseStartDate().toLocalDate();
        boolean isBeforeStart = today.isBefore(courseStart);
        model.addAttribute("isBeforeStart", isBeforeStart);
        if (member != null) {
            // 강사
            if (course.getMemberSeq().equals(member.getMemberSeq())) {
                return "course/teacherCourseView";
            }

            // 수강생 여부 확인
            Map<String, Long> param = new HashMap<>();
            param.put("memberSeq", member.getMemberSeq());
            param.put("courseSeq", courseSeq);
            boolean isEnrolled = service.checkStudent(param);

            if (isEnrolled) {
                //출석 여부 확인
                boolean isPresent = presentService.checkPresent(Map.of("memberSeq", member.getMemberSeq(), "courseSeq", courseSeq, "date", Date.valueOf(LocalDate.now())));
                model.addAttribute("isPresent", isPresent);
                return "course/studentCourseView";
            }
        }
        return "course/commonCourseView";
    }

    @PostMapping("/episodes")
    @ResponseBody
    public Map<String, Object> getEpisodeList(@RequestBody Map<String, Object> param) {
        Long courseSeq = Long.valueOf(param.get("courseSeq").toString());
        int cPage = Integer.parseInt(param.get("cPage").toString());
        int numPerPage = Integer.parseInt(param.get("numPerPage").toString());
        List<Episode> episodeList = attachmentService.getEpisodeByCourseSeq(courseSeq, cPage, numPerPage);
        int total = service.countEpisodeByCourseSeq(courseSeq);
        String pageBar = pageFactory.basicPageBar(cPage, numPerPage, total);

        return Map.of("episodes", episodeList, "pageBar", pageBar);
    }

    @PostMapping("/reviews")
    @ResponseBody
    public Map<String, Object> getReviews(@RequestBody Map<String, Object> param) {
        Long courseSeq = Long.valueOf(param.get("courseSeq").toString());
        int cPage = Integer.parseInt(param.get("cPage").toString());
        int numPerPage = Integer.parseInt(param.get("numPerPage").toString());
        List<ReviewViewResponse> reviews = reviewService.getReviewsBySeq(courseSeq, cPage, numPerPage);
        int totalCount = reviewService.getReviewCount(courseSeq);
        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalCount);

        return Map.of("reviews", reviews, "pageBar", pageBar);
    }

    @GetMapping("/teacher")
    public String getTeacherInfoView(@RequestParam Long memberSeq, Model model) {
        Teacher teacherBySeq = service.getTeacherBySeq(memberSeq);
        model.addAttribute("teacher", teacherBySeq);
        return "course/teacherInfoView";
    }

    @ResponseBody
    @PostMapping("/teacherajax")
    public Map<String, Object> getCourseListByTeacherSeq(@RequestParam Long memberSeq,
                                                         @RequestParam(defaultValue = "1") int cPage,
                                                         @RequestParam(defaultValue = "3") int numPerPage) {

        int totalData = service.getCourseCountByTeacher(memberSeq);
        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalData);
        List<CourseListResponse> list = service.getCourseListByTeacher(memberSeq, cPage, numPerPage);

        return Map.of("courses", list, "pageBar", pageBar);
    }


    @ExceptionHandler(value = CourseEpisodeMismatchException.class)
    public String handleException(CourseEpisodeMismatchException e, Model model) {
        model.addAttribute("msg", e.getMessage());
        model.addAttribute("loc", "/mypage");
        return "common/msg";
    }
}
