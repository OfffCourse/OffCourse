package com.offcourse.enrollment.model.dao;

import com.offcourse.enrollment.model.dto.Enrollment;
import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class EnrollmentDao {

    private final SqlSessionTemplate sqlSession;
    private static final String NAMESPACE = "enrollment.";


    public List<Long> findStudentSeqsByCourseSeq(Long courseSeq) {
        return sqlSession.selectList(NAMESPACE + "findStudentSeqsByCourseSeq", courseSeq);
    }

    public int updateEnrollmentStatus(Map param) {
        return sqlSession.update(NAMESPACE + "updateEnrollmentStatus", param);
    }

    public int insertEnrollment(Enrollment enrollment) {
        return sqlSession.insert(NAMESPACE + "insertEnrollment", enrollment);
    }

    public int updateEnrollmentStatusByEnrSeq(Map<String, Object> param) {
        return sqlSession.update(NAMESPACE + "updateEnrollmentStatusByEnrSeq", param);
    }

    public Enrollment selectEnrollmentBySeq(Long enrSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectEnrollmentBySeq", enrSeq);
    }

    public Long findStudentSeqByEnrSeq(Long enrSeq) {
        return sqlSession.selectOne(NAMESPACE + "findStudentSeqByEnrSeq", enrSeq);
    }
}
