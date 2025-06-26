package com.offcourse.enrollment.model.service;

import java.util.List;

public interface EnrollmentService {
    List<Long> findStudentSeqsByCourseSeq(Long courseSeq);
    boolean updateEnrollmentStatus(Long courseSeq, Long studentSeq, String status);
}
