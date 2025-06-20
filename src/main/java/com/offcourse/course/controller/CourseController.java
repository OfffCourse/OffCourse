package com.offcourse.course.controller;

import com.offcourse.common.PageFactory;
import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.course.model.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/course")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService service;
    private final PageFactory pageFactory;

    @GetMapping("/listpage")
    public String courseList(Model model,
                             @RequestParam(defaultValue = "1") int cPage,
                             @RequestParam(defaultValue = "4") int numPerPage) {
        List<CourseListResponse> courselist = service.courseList(Map.of("cPage", cPage, "numPerPage", numPerPage));
        model.addAttribute("courselist", courselist);
        model.addAttribute("pageBar",
                pageFactory.basicPageBar(cPage, numPerPage,
                        service.courseCount(), "listpage"));
        return "course/courselist";
    }

}
