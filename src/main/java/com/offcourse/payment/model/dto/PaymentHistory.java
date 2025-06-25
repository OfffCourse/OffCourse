package com.offcourse.payment.model.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentHistory {
    private Long paymentSeq;
    private BigDecimal paymentPrice;
    // 원화로만 계산하고 소숫점 값이 나오지 않으면 Long 으로 해도 되지만,
    // 할인을 적용했을때 소숫점 값이 나온다거나, 해외 통화를 환율 계산하면 소숫점 값이 나온다던지
    // 그런 확장성을 생각해서 BigDecimal 로 type 잡음.
    private Timestamp paymentTime;
    private String paymentOrderId;
    private String paymentStatus;
    private Long enrSeq;
}
