package com.offcourse.course.model.dto;

import lombok.*;

import java.sql.Date;
import java.util.List;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CourseListResponse {
    private Long courseSeq;
    private String courseName;
    private String memberName;
    private Long memberSeq;
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

}


