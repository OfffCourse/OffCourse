package com.offcourse.deleterequest.model.dao;

import com.offcourse.deleterequest.model.dto.DeleteCourseRequestAll;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class DeleteRequestDao {
    private final SqlSessionTemplate session;

    public long countDeleteRequestAll() {
        return session.selectOne("deleteCourseRequest.countDeleteRequestAll");
    }

    public List<DeleteCourseRequestAll> getDeleteRequestAll(Map<String, Object> param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        RowBounds rb = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        int status = (int) param.get("status");

        return session.selectList("deleteCourseRequest.getDeleteRequestAll", status, rb);
    }

    public int countDeleteRequestAllByStatus(int status) {
        return session.selectOne("deleteCourseRequest.countDeleteRequestAllByStatus", status);
    }
}
