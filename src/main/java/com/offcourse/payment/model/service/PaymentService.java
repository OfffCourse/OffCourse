package com.offcourse.payment.model.service;

import java.math.BigDecimal;

public interface PaymentService {
    void processEnrollmentPayment(Long courseSeq, Long memberSeq, BigDecimal paymentPrice, String orderId);
    void refundPayment(Long paymentSeq, Long enrSeq);
}
