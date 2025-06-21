package com.offcourse.course.controller;

import com.offcourse.common.AjaxPageFactory;
import com.offcourse.common.PageFactory;
import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.course.model.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/course")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService service;
    private final PageFactory pageFactory;
    private final AjaxPageFactory ajaxPageFactory;

    @ResponseBody
    @PostMapping("/search")
    public Map<String, Object> getCourseList(@RequestBody Map<String, Object> param) {
        int cPage = Integer.parseInt(String.valueOf(param.getOrDefault("cPage", "1")));
        int numPerPage = Integer.parseInt(String.valueOf(param.getOrDefault("numPerPage", "4")));

        int totalData = service.getCourseListCount(param);
        RowBounds rb = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        List<CourseListResponse> list = service.getCourseList(param, rb);

        String pageBar = ajaxPageFactory.basicPageBar(cPage, numPerPage, totalData);

        return Map.of("courses", list, "pageBar", pageBar);
    }

    @GetMapping("/listpage")
    public String courseList() {
        return "course/courseList";
    }

}
