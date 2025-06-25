package com.offcourse.enrollment.model.service;

import com.offcourse.enrollment.model.dto.Enrollment;

public interface EnrollmentService {
    void enrollCourse(Long courseSeq, Long memberSeq);
    void updateStatus(Long enrSeq, String status);
    Enrollment getEnrollment(Long enrSeq);
}
