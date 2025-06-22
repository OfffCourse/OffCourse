package com.offcourse.mypage.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Account {
    private Long accountSeq;
    private Integer accountPrice;
    private String accountBankName;
    private String accountBankNumber;
    private String accountStatus;
    private Long courseSeq;
}
