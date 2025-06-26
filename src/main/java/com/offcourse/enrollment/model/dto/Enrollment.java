package com.offcourse.enrollment.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Builder
@NoArgsConstructor
@AllArgsConstructor
@Data
public class Enrollment {
    private Long enrSeq;
    private Timestamp enrDate;
    private EnrollmentStatus enrStatus;
    private Long courseSeq;
    private Long memberSeq;
}
