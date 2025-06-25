package com.offcourse.enrollment.model.dao;

import com.offcourse.enrollment.model.dto.Enrollment;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
public class EnrollmentDaoImpl implements EnrollmentDao {

    private final SqlSessionTemplate sqlSession;
    private static final String NAMESPACE = "enrollment.";

    public EnrollmentDaoImpl(SqlSessionTemplate sqlSession) {
        this.sqlSession = sqlSession;
    }

    @Override
    public int insertEnrollment(Enrollment enrollment) {
        return sqlSession.insert(NAMESPACE + "insertEnrollment", enrollment);
    }

    @Override
    public int updateEnrollmentStatus(Long enrSeq, String status) {
        Map<String,Object> params = new HashMap<>();
        params.put("enrSeq", enrSeq);
        params.put("status", status);
        return sqlSession.update(NAMESPACE + "updateEnrollmentStatus", params);
    }

    @Override
    public Enrollment selectEnrollmentBySeq(Long enrSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectEnrollmentBySeq", enrSeq);
    }
}
