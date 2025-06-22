package com.offcourse.mypage.model.dto;

import lombok.*;

@Setter
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
