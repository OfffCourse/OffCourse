package com.offcourse.payment.model.service;

import com.offcourse.payment.model.dto.PaymentHistory;

public interface PaymentService {
    void recordPayment(PaymentHistory paymentHistory);
    void changePaymentStatus(Long paymentSeq, String status);
    PaymentHistory findByOrderId(String orderId);
}
