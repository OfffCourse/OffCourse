package com.offcourse.mypage.model.dto;

import lombok.*;

@Setter
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
