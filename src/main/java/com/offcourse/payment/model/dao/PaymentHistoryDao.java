package com.offcourse.payment.model.dao;

import com.offcourse.payment.model.dto.PaymentHistory;

public interface PaymentHistoryDao {
    int insertPaymentHistory(PaymentHistory ph);
    int updatePaymentStatus(Long paymentSeq, String status);
    PaymentHistory selectByOrderId(String orderId);
}
