package com.offcourse.mypage.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentMyPageResponse {
    private Long courseSeq;
    private Long enrSeq;
    private String courseName;
    private Date courseStartDate;
    private Date courseEndDate;
    private String courseAddress;
    private Double presentRate;
    private String cancelable;
    private String reviewWritten;
    private Integer courseCurrentSize;
}
