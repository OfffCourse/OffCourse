package com.offcourse.payment.model.service;

import com.offcourse.payment.model.dto.PaymentHistory;

import java.math.BigDecimal;

public interface PaymentService {
    void processEnrollmentPayment(Long courseSeq, Long memberSeq, BigDecimal paymentPrice, String orderId, String impUid);
    void refundPayment(Long paymentSeq, Long enrSeq, String reason);
    PaymentHistory findPaymentHistoryBySeq(Long paymentSeq);
    PaymentHistory findPaymentHistoryByEnrSeq(Long enrSeq);

}
