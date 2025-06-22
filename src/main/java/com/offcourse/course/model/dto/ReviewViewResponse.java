package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReviewViewResponse {
    private Long reviewSeq;
    private String reviewContent;
    private Integer reviewRate;
    private String memberName;
    private Timestamp reviewCreateTime;
    private Timestamp reviewEditTime;
    private Long enrSeq;
}
