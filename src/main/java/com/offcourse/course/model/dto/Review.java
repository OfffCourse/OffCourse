package com.offcourse.course.model.dto;

import lombok.*;

@Setter
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
