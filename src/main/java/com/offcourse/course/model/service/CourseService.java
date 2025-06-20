package com.offcourse.course.model.service;

import com.offcourse.course.model.dto.CourseListResponse;

import java.util.List;
import java.util.Map;

public interface CourseService {
    List<CourseListResponse> courseList(Map<String,Integer> param);
    int courseCount();
}
