package com.offcourse.enrollment.model.service;

import com.offcourse.enrollment.model.dao.EnrollmentDao;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EnrollmentServiceImpl implements EnrollmentService {

    private final EnrollmentDao enrollmentDao;

    @Override
    public List<Long> findStudentSeqsByCourseSeq(Long courseSeq) {
        return enrollmentDao.findStudentSeqsByCourseSeq(courseSeq);
    }

    @Override
    @Transactional
    public boolean updateEnrollmentStatus(Long courseSeq, Long studentSeq, String status) {
        int result = enrollmentDao.updateEnrollmentStatus(Map.of("courseSeq", courseSeq, "studentSeq", studentSeq, "status", status));
        if (result > 0) {
            return true;
        }
        throw new IllegalStateException("ENR_STATUS 업데이트에 실패했습니다.");
    }
}
