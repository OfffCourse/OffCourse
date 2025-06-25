package com.offcourse.present.model.dao;

import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
@RequiredArgsConstructor
public class PresentDao {
    private final SqlSessionTemplate session;

    public int countPresentByCourseAndStudent(Long courseSeq, Long studentSeq) {
        return session.selectOne("present.countPresentByCourseAndStudent", Map.of("courseSeq", courseSeq, "studentSeq", studentSeq));
    }
}
