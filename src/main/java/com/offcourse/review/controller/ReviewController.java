package com.offcourse.review.controller;

import com.offcourse.review.model.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ReviewController {
    private final ReviewService reviewService;

}
