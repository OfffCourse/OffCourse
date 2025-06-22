package com.offcourse.course.model.dao;

import com.offcourse.course.model.dto.Course;
import com.offcourse.course.model.dto.CourseDay;
import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.course.model.dto.Episode;
import org.apache.ibatis.session.RowBounds;

import java.util.List;
import java.util.Map;

public interface CourseDao {
    List<CourseListResponse> getCourseList(Map<String,Object> param, RowBounds rb);
    int getCourseListCount(Map<String,Object> param);
    int insertCourse(Course course);
    int insertCourseDay(CourseDay courseDay);
    int insertEpisode(Episode episode);
    long getCategorySeqByType(String categoryType);
}
