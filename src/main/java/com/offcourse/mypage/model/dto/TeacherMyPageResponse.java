package com.offcourse.mypage.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.sql.Date;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class TeacherMyPageResponse {
    private Long courseSeq;
    private String courseName;
    private String courseCurriculum;
    private Date courseStartDate;
    private Date courseEndDate;
    private String courseAddress;
    private String courseDetailAddress;
    private Integer coursePrice;
    private Integer courseDiscount;
    private String courseQaLink;
    private Integer reviewCount;
    private Double averageRating;
    private Integer courseSize;
    private Integer courseCurrentSize;
    private Integer accountPrice;
}
