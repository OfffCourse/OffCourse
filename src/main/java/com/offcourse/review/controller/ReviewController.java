package com.offcourse.review.controller;

import com.offcourse.review.model.dto.Review;
import com.offcourse.review.model.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequiredArgsConstructor
@RequestMapping("/review")
public class ReviewController {
    private final ReviewService reviewService;

    @PostMapping("/insert")
    public ResponseEntity<?> insertReview(@RequestBody Review review) {
        reviewService.insertReview(review);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/delete")
    public ResponseEntity<?> deleteReview(@RequestBody Review review) {
        reviewService.softDeleteReview(review.getEnrSeq());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateReview(@RequestBody Review review) {
        reviewService.updateReview(review);
        return ResponseEntity.ok().build();
    }

}
