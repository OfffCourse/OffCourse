package com.offcourse.enrollment.model.dao;

import com.offcourse.enrollment.model.dto.Enrollment;

public interface EnrollmentDao {
    int insertEnrollment(Enrollment enrollment);
    int updateEnrollmentStatus(Long enrSeq, String status);
    Enrollment selectEnrollmentBySeq(Long enrSeq);
}
