package com.offcourse.admin.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class HandleDeleteRequest {
    private Long deleteRequestSeq;
    private String action;
    private Long courseSeq;
}
