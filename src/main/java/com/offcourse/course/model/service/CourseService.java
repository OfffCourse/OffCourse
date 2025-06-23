package com.offcourse.course.model.service;

import com.offcourse.course.model.dto.Course;
import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.course.model.dto.CourseViewResponse;
import com.offcourse.course.model.dto.ReviewViewResponse;
import org.apache.ibatis.session.RowBounds;

import java.util.List;
import java.util.Map;

public interface CourseService {
    List<CourseListResponse> getCourseList(Map<String,Object> param, RowBounds rb);
    int getCourseListCount(Map<String,Object> param);
    int insertCourse(Course course, List<String> courseDays);
    long getCategorySeqByType(String categoryType);
    int updateCourse(Course course);
    CourseViewResponse getCourseBySeq(Long courseSeq);
    List<ReviewViewResponse> getReviewsBySeq(Long courseSeq, int cPage, int numPerPage);
    int getReviewCount(Long courseSeq);
}
