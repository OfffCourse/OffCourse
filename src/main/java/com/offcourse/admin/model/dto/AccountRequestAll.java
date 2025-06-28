package com.offcourse.admin.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AccountRequestAll {
    private Long accountSeq;
    private Long accountPrice;
    private String bankName;
    private String bankNumber;
    private Long courseSeq;
    private String courseName;
}
