package com.offcourse.course.model.dao;

import com.offcourse.course.model.dto.Course;
import com.offcourse.course.model.dto.CourseDay;
import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.course.model.dto.Episode;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class CourseDaoImpl implements CourseDao {

    private final SqlSessionTemplate session;

    @Override
    public List<CourseListResponse> getCourseList(Map<String, Object> param, RowBounds rb) {
        return session.selectList("course.selectCourseList", param, rb);
    }

    @Override
    public int getCourseListCount(Map<String, Object> param) {
        return session.selectOne("course.selectCourseCount", param);
    }

    @Override
    public int insertCourse(Course course) {
        return session.insert("course.insertCourse",course);
    }

    @Override
    public int insertCourseDay(CourseDay courseDay) {
        return session.insert("course.insertCourseDay",courseDay);
    }

    @Override
    public int insertEpisode(Episode episode) {
        return session.insert("course.insertEpisode",episode);
    }

    @Override
    public long getCategorySeqByType(String categoryType) {
        return session.selectOne("course.selectCategorySeqByType",categoryType);
    }
}
