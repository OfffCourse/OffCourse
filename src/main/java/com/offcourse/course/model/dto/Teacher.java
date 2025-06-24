package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Teacher {
    private Long memberSeq;
    private String memberName;
    private String memberEmail;
    private String memberProfile;
    private String portfolioFileName;
}
