package com.offcourse.deleterequest.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class DeleteCourseRequestAll {
    private Long deleteRequestSeq;
    private String deleteRequestContent;
    private DeleteRequestStatus deleteRequestStatus;
    private Long courseSeq;
    private String courseName;
    private String teacherName;
    private int enrollStudentsCount;
}