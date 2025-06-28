package com.offcourse.review.model.dao;

import com.offcourse.review.model.dto.ReviewViewResponse;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ReviewDao {
    private final SqlSessionTemplate session;

    public List<ReviewViewResponse> getReviewsBySeq(Long courseSeq, int cPage, int numPerPage) {
        RowBounds rowBounds
                = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("review.selectReviewByCourseSeq", courseSeq, rowBounds);
    }

    public int getReviewCount(Long courseSeq) {
        return session.selectOne("review.selectReviewCount", courseSeq);
    }
}
