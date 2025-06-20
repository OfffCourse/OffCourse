package com.offcourse.course.model.dao;

import com.offcourse.course.model.dto.CourseListResponse;

import java.util.List;
import java.util.Map;

public interface CourseDao {
    List<CourseListResponse> courseList(Map<String,Integer> param);
    int courseCount();
}
