package com.offcourse.present.model.service;

import com.offcourse.present.model.dao.PresentDao;
import com.offcourse.present.model.dto.CheckPresentCode;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PresentService {
    private final PresentDao dao;
    private final RedisService redisService;

    public String getPresentCode(Long courseSeq) {
        return redisService.getValue("present:course:" + courseSeq);
    }

    public int countPresentByCourseAndStudent(Long courseSeq, Long studentSeq) {
        return dao.countPresentByCourseAndStudent(courseSeq, studentSeq);
    }

    @Transactional
    public boolean checkPresentCode(CheckPresentCode checkPresentCode) {
        String presentCode = getPresentCode(checkPresentCode.getCourseSeq());
        if (!presentCode.equals(checkPresentCode.getPresentCode())) {
            return false;
        }

        int result = dao.insertPresent(checkPresentCode);
        if (result < 0) {
            return false;
        }
        return true;
    }
}
