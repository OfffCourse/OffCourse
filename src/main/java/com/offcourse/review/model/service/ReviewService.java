package com.offcourse.review.model.service;

import com.offcourse.review.model.dao.ReviewDao;
import com.offcourse.review.model.dto.Review;
import com.offcourse.review.model.dto.ReviewViewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    public void insertReview(Review review) {
        dao.insertReview(review);
    }

    @Transactional
    public void updateReview(Review review) {
        dao.updateReview(review);
    }

    @Transactional
    public void softDeleteReview(Long enrSeq) {
        dao.softDeleteReview(enrSeq);
    }

}
