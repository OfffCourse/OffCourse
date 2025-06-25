package com.offcourse.enrollment.model.dao;

import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class EnrollmentDao {
    private final SqlSessionTemplate session;

    public List<Long> findStudentSeqsByCourseSeq(Long courseSeq) {
        return session.selectList("enrollment.findStudentSeqsByCourseSeq", courseSeq);
    }

    public int updateEnrollmentStatus(Map param) {
        return session.update("enrollment.updateEnrollmentStatusToComplete", param);
    }
}
