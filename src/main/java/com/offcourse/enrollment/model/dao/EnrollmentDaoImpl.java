package com.offcourse.enrollment.model.dao;

import com.offcourse.enrollment.model.dto.Enrollment;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class EnrollmentDaoImpl implements EnrollmentDao {

    private final SqlSessionTemplate sqlSession;
    private static final String NAMESPACE = "enrollment.";

    public EnrollmentDaoImpl(SqlSessionTemplate sqlSession) {
        this.sqlSession = sqlSession;
    }

    public List<Long> findStudentSeqsByCourseSeq(Long courseSeq) {
        return sqlSession.selectList(NAMESPACE + "findStudentSeqsByCourseSeq", courseSeq);
    }

    public int updateEnrollmentStatus(Map param) {
        return sqlSession.update(NAMESPACE + "updateEnrollmentStatus", param);
    }

    @Override
    public int insertEnrollment(Enrollment enrollment) {
        return sqlSession.insert(NAMESPACE + "insertEnrollment", enrollment);
    }

    @Override
    public int updateEnrollmentStatusByEnrSeq(Map<String, Object> param) {
        return sqlSession.update(NAMESPACE + "updateEnrollmentStatusByEnrSeq", param);
    }



}
