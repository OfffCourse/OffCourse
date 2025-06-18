package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.sql.Date;
import java.sql.Timestamp;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Course {
    private Long courseSeq;
    private String courseName;
    private String courseCurriculum;
    private String courseAddress;
    private String courseDetailAddress;
    private Integer coursePrice;
    private Date courseStartDate;
    private Date coureEndDate;
    private Timestamp courseDeleteTime;
    private Integer courseDiscount;
    private String courseQaLink;
    private Long memberSeq;
    private Long categorySeq;
}
