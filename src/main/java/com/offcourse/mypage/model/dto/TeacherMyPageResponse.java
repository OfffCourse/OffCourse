package com.offcourse.mypage.model.dto;

import lombok.*;

import java.sql.Date;

@Setter
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
    private Integer courseSize;
    private Integer courseCurrentSize;
    private Integer accountPrice;
    private String accountStatus;
    private String deleteRequestStatus;
}
