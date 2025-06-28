package com.offcourse.course.model.dao;

import com.offcourse.course.model.dto.*;
import org.apache.ibatis.session.RowBounds;

import java.sql.Date;
import java.util.List;
import java.util.Map;

public interface CourseDao {
    List<CourseListResponse> getCourseList(Map<String, Object> param, RowBounds rb);

    int getCourseListCount(Map<String, Object> param);

    int insertCourse(Course course);

    int insertCourseDay(CourseDay courseDay);

    int insertEpisode(Episode episode);

    long getCategorySeqByType(String categoryType);

    int updateCourse(Course course);

    CourseViewResponse getCourseBySeq(Long courseSeq);

    boolean checkStudent(Map<String, Long> param);

    Teacher getTeacherBySeq(Long memberSeq);

    List<CourseListResponse> getCourseListByTeacher(Long memberSeq, int cPage, int numPerPage);

    int getCourseCountByTeacher(Long memberSeq);

    List<Long> getCourseSeqsInProgress(Date date);

    List<CourseStudentDto> getCourseSeqsByEndDate(Date date);

    int countEpisodeByCourseSeq(Long courseSeq);

    List<Episode> getEpisodeByCourseSeq(Long courseSeq);
}
