package com.offcourse.mypage.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DeleteCourseRequest {
    private Long deleteRequestSeq;
    private String deleteRequestContent;
    private String deleteRequestStatus;
    private Long courseSeq;
}
