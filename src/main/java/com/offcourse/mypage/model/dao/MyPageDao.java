package com.offcourse.mypage.model.dao;

import com.offcourse.mypage.model.dto.Account;
import com.offcourse.mypage.model.dto.DeleteCourseRequest;
import com.offcourse.mypage.model.dto.StudentMyPageResponse;
import com.offcourse.mypage.model.dto.TeacherMyPageResponse;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class MyPageDao {

    private final SqlSessionTemplate session;

    public List<TeacherMyPageResponse> getMyPageByTeacher(Map<String, Object> param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        long memberSeq = (long) param.get("memberSeq");
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("mypage.getMyPageByTeacher", memberSeq, rowBounds);
    }

    public int teacherCourseCount(long memberSeq) {
        return session.selectOne("mypage.teacherCourseCount", memberSeq);
    }

    public int insertAccount(Account account) {
        return session.insert("mypage.insertAccount", account);
    }

    public int insertDeleteCourseRequest(DeleteCourseRequest request) {
        return session.insert("mypage.insertDeleteCourseRequest", request);
    }

    public List<StudentMyPageResponse> getCurrentCoursesByStudent(Map<String, Object> param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        long memberSeq = (long) param.get("memberSeq");
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("mypage.getCurrentCoursesByStudent", memberSeq, rowBounds);
    }

    public List<StudentMyPageResponse> getCompletedCoursesByStudent(Map<String, Object> param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        long memberSeq = (long) param.get("memberSeq");
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("mypage.getCompletedCoursesByStudent", memberSeq, rowBounds);
    }

    public List<StudentMyPageResponse> getPendingCoursesByStudent(Map<String, Object> param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        long memberSeq = (long) param.get("memberSeq");
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("mypage.getPendingCoursesByStudent", memberSeq, rowBounds);
    }

    public int countCurrentCoursesByStudent(Long memberSeq) {
        return session.selectOne("mypage.countCurrentCoursesByStudent", memberSeq);
    }

    public int countCompletedCoursesByStudent(Long memberSeq) {
        return session.selectOne("mypage.countCompletedCoursesByStudent", memberSeq);
    }

    public int countPendingCoursesByStudent(Long memberSeq) {
        return session.selectOne("mypage.countPendingCoursesByStudent", memberSeq);
    }


}
