package com.offcourse.course.model.service;

import com.offcourse.course.model.dto.Course;
import com.offcourse.course.model.dto.CourseListResponse;
import org.apache.ibatis.session.RowBounds;

import java.util.List;
import java.util.Map;

public interface CourseService {
    List<CourseListResponse> getCourseList(Map<String,Object> param, RowBounds rb);
    int getCourseListCount(Map<String,Object> param);
    int insertCourse(Course course, Integer episodeCount, List<String> courseDays);
    long getCategorySeqByType(String categoryType);
}
