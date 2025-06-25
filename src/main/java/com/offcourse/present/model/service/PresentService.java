package com.offcourse.present.model.service;

import com.offcourse.present.model.dao.PresentDao;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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
}
