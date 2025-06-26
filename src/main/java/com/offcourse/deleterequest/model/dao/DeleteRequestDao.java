package com.offcourse.deleterequest.model.dao;

import com.offcourse.mypage.model.dto.DeleteCourseRequest;
import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class DeleteRequestDao {
    private final SqlSessionTemplate session;

    public List<DeleteCourseRequest> getDeleteRequestAll() {
        return session.selectList("deleteCourseRequest.getDeleteRequestAll");
    }

    public long countDeleteRequestAll() {
        return session.selectOne("deleteCourseRequest.countDeleteRequestAll");
    }
}
