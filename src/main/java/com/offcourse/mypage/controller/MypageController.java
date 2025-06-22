package com.offcourse.mypage.controller;

import com.offcourse.course.model.service.CourseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
@RequestMapping("/mypage")
public class MypageController {

    private final CourseService courseService;

    @GetMapping
    public String teacherMypage(){
        return "mypage/teacherMypage";
    }

}
