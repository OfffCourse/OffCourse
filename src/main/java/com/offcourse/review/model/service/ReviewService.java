package com.offcourse.review.model.service;

import com.offcourse.review.model.dao.ReviewDao;
import com.offcourse.review.model.dto.ReviewViewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewDao dao;

    public List<ReviewViewResponse> getReviewsBySeq(Long courseSeq, int cPage, int numPerPage) {
        return dao.getReviewsBySeq(courseSeq, cPage, numPerPage);
    }

    public int getReviewCount(Long courseSeq) {
        return dao.getReviewCount(courseSeq);
    }

}
