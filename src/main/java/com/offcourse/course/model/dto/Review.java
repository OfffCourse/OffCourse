package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Review {
    private Long reviewSeq;
    private String reviewContent;
    private Integer reviewRate;
    private Long enrSeq;
}
