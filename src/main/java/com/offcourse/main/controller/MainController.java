package com.offcourse.main.controller;

import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.main.model.service.MainService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class MainController {
    private final MainService service;

    @RequestMapping("/")
    public String index() {
        return "index";
    }

    @GetMapping("/main/recommend")
    @ResponseBody
    public List<CourseListResponse> getRecommendedCourses(
            @RequestParam(value = "categoryList", required = false) String categoryList
    ) {
        List<String> categories = categoryList != null ? Arrays.asList(categoryList.split(",")) : Collections.emptyList();
        return service.getRecommendedCourses(categories);
    }

}
