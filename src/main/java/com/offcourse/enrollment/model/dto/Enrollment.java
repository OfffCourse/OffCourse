package com.offcourse.enrollment.model.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Enrollment {
    private Long enrSeq;
    private Timestamp enrDate;
    private String enrStatus;
    private Long courseSeq;
    private Long memberSeq;
}
