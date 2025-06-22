package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.sql.Date;
import java.util.List;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CourseViewResponse {
    private String courseName;
    private String memberName;
    private Date courseStartDate;
    private Date courseEndDate;
    private String courseAddress;
    private String courseDetailAddress;
    private Integer coursePrice;
    private Integer courseDiscount;
    private Integer reviewCount;
    private Double averageRating;
    private Integer courseSize;
    private Integer courseCurrentSize;

    private CourseCategory courseCategory;
    private List<CourseDay> courseDays;
    private List<ReviewViewResponse> reviews;
}
