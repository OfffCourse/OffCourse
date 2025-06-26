package com.offcourse.present.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CheckPresentCode {
    private String presentCode;
    private Long courseSeq;
    private Long memberSeq;
}
