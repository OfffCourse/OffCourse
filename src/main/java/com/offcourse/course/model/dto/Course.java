package com.offcourse.course.model.dto;

import lombok.*;

import java.sql.Date;
import java.sql.Timestamp;

@Setter
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
    private Date courseEndDate;
    private Timestamp courseDeleteTime;
    private Integer courseDiscount;
    private String courseQaLink;
    private Integer courseSize;
    private Long memberSeq;
    private Long categorySeq;
}
