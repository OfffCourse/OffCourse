package com.offcourse.enrollment.model.service;

import com.offcourse.enrollment.model.dao.EnrollmentDao;
import com.offcourse.enrollment.model.dto.Enrollment;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

@Service
@RequiredArgsConstructor
public class EnrollmentServiceImpl implements EnrollmentService {

    private final EnrollmentDao enrollmentDao;

    @Override
    @Transactional
    public void enrollCourse(Long courseSeq, Long memberSeq) {
        Enrollment e = new Enrollment();
        e.setCourseSeq(courseSeq);
        e.setMemberSeq(memberSeq);
        e.setEnrDate(new Timestamp(System.currentTimeMillis()));
        e.setEnrStatus("0");
        enrollmentDao.insertEnrollment(e);
    }

    @Override
    @Transactional
    public void updateStatus(Long enrSeq, String status) {
        enrollmentDao.updateEnrollmentStatus(enrSeq, status);
    }

    @Override
    public Enrollment getEnrollment(Long enrSeq) {
        return enrollmentDao.selectEnrollmentBySeq(enrSeq);
    }
}
