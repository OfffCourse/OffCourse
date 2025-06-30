package com.offcourse.enrollment.model.service;

import com.offcourse.enrollment.model.dao.EnrollmentDao;
import com.offcourse.enrollment.model.dto.Enrollment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EnrollmentService {
    private final EnrollmentDao dao;

    public List<Long> findStudentSeqsByCourseSeq(Long courseSeq) {
        return dao.findStudentSeqsByCourseSeq(courseSeq);
    }

    @Transactional
    public boolean updateEnrollmentStatus(Long courseSeq, Long studentSeq, String status) {
        int result = dao.updateEnrollmentStatus(Map.of("courseSeq", courseSeq, "studentSeq", studentSeq, "status", status));
        if (result > 0) {
            return true;
        }
        throw new IllegalStateException("ENR_STATUS 업데이트에 실패했습니다.");
    }

    public Enrollment selectEnrollmentBySeq(Long enrSeq) {
        return dao.selectEnrollmentBySeq(enrSeq);
    }

}
