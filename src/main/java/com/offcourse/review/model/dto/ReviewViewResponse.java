package com.offcourse.review.model.dto;

import lombok.*;

import java.sql.Timestamp;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ReviewViewResponse {
    private Long reviewSeq;
    private String memberProfile;
    private String reviewContent;
    private Integer reviewRate;
    private String memberName;
    private Timestamp reviewCreateTime;
    private Timestamp reviewEditTime;
    private Long enrSeq;
}
