package com.offcourse.enrollment.model.dao;

import com.offcourse.enrollment.model.dto.Enrollment;

import java.util.List;
import java.util.Map;

public interface EnrollmentDao {
    int updateEnrollmentStatus(Map param);
    List<Long> findStudentSeqsByCourseSeq(Long courseSeq);

    int insertEnrollment(Enrollment enrollment);
    int updateEnrollmentStatusByEnrSeq(Map<String, Object> param);
    }
