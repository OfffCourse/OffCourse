package com.offcourse.course.model.service;

import com.offcourse.course.model.dto.*;
import org.apache.ibatis.session.RowBounds;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface CourseService {
    List<CourseListResponse> getCourseList(Map<String, Object> param, RowBounds rb);

    int getCourseListCount(Map<String, Object> param);

    int insertCourse(Course course, List<String> courseDays);

    long getCategorySeqByType(String categoryType);

    int updateCourse(Course course);

    CourseViewResponse getCourseBySeq(Long courseSeq);

    boolean checkStudent(Map<String, Long> param);

    Teacher getTeacherBySeq(Long memberSeq);

    List<CourseListResponse> getCourseListByTeacher(Long memberSeq, int cPage, int numPerPage);

    int getCourseCountByTeacher(Long memberSeq);

    List<Long> getCourseSeqsInProgress(LocalDate localDate);

    List<CourseStudentDto> getCourseSeqsByEndDate(LocalDate localDate);

    int countEpisodeByCourseSeq(Long courseSeq);

    List<Episode> getEpisodeByCourseSeq(Long courseSeq);
}
