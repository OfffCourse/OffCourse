package com.offcourse.course.model.dao;

import com.offcourse.course.model.dto.*;
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
        return session.insert("course.insertCourse", course);
    }

    @Override
    public int insertCourseDay(CourseDay courseDay) {
        return session.insert("course.insertCourseDay", courseDay);
    }

    @Override
    public int insertEpisode(Episode episode) {
        return session.insert("course.insertEpisode", episode);
    }

    @Override
    public long getCategorySeqByType(String categoryType) {
        return session.selectOne("course.selectCategorySeqByType", categoryType);
    }

    @Override
    public int updateCourse(Course course) {
        return session.update("course.updateCourse", course);
    }

    @Override
    public CourseViewResponse getCourseBySeq(Long courseSeq) {
        return session.selectOne("course.selectCourseBySeq", courseSeq);
    }

    @Override
    public List<ReviewViewResponse> getReviewsBySeq(Long courseSeq, int cPage, int numPerPage) {
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("course.selectReviewByCourseSeq", courseSeq, rowBounds);
    }

    @Override
    public int getReviewCount(Long courseSeq) {
        return session.selectOne("course.selectReviewCount", courseSeq);
    }

    @Override
    public boolean checkStudent(Map<String, Long> param) {
        return session.selectOne("course.checkStudent", param);
    }

    @Override
    public List<AttachmentViewResponse> getAttachments(Long courseSeq) {
        return session.selectList("course.selectAttachmentsByCourseSeq", courseSeq);
    }

    @Override
    public Teacher getTeacherBySeq(Long memberSeq) {
        return session.selectOne("course.selectTeacherBySeq", memberSeq);
    }

    @Override
    public List<CourseListResponse> getCourseListByTeacher(Long memberSeq, int cPage, int numPerPage) {
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("course.selectCourseListByTeacherSeq", memberSeq, rowBounds);
    }

    @Override
    public int getCourseCountByTeacher(Long memberSeq) {
        return session.selectOne("course.selectCourseByTeacherCount", memberSeq);
    }
}
