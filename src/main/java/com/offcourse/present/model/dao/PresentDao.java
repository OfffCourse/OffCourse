package com.offcourse.present.model.dao;

import com.offcourse.present.model.dto.CheckPresentCode;
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

    public int insertPresent(CheckPresentCode checkPresentCode) {
        return session.insert("present.insertPresent", checkPresentCode);
    }

    public int checkPresent(Map<String, Object> param) {
        return session.selectOne("present.checkPresent", param);
    }
}
