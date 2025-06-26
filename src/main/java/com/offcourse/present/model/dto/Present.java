package com.offcourse.present.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Present {
    private Long prSeq;
    private Timestamp prDate;
    private Long episodeSeq;
    private Long enrSeq;
}
