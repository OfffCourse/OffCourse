package com.offcourse.course.controller;

import com.offcourse.common.AjaxPageFactory;
import com.offcourse.course.exception.CourseEpisodeMismatchException;
import com.offcourse.course.model.dto.Course;
import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.course.model.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/course")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService service;
    private final AjaxPageFactory ajaxPageFactory;

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

    /*@GetMapping("/insertpage")
    public String insertCourse() {
        return "course/courseInsert";
    }*/

    @PostMapping("/insert")
    public String insertEndCourse(@ModelAttribute Course course,
                                  @RequestParam("categoryType") String categoryType,
                                  @RequestParam("episodeCount") Integer episodeCount,
                                  @RequestParam("dayList") List<String> courseDays,
                                  Model model) {

        long categorySeq = service.getCategorySeqByType(categoryType);
        course.setCategorySeq(categorySeq);

        int result = service.insertCourse(course, episodeCount, courseDays);
        if (result > 0) {
            model.addAttribute("msg", "강의 등록 성공!");
            model.addAttribute("loc", "/course/listpage");
        } else {
            model.addAttribute("msg", "강의 등록 실패");
            model.addAttribute("loc", "/mypage");
        }
        return "common/msg";
    }

    @ExceptionHandler(value=CourseEpisodeMismatchException.class)
    public String handleException(CourseEpisodeMismatchException e,Model model) {
        model.addAttribute("msg", e.getMessage());
        model.addAttribute("loc", "/mypage");
        return "common/msg";
    }
}
