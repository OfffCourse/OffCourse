package com.offcourse.payment.model.dao;

import com.offcourse.payment.model.dto.PaymentHistory;

import java.util.Map;

public interface PaymentHistoryDao {
    int insertPaymentHistory(PaymentHistory paymentHistory);
    int updatePaymentStatus(Map<String, Object> param);
    PaymentHistory selectBySeq(Long paymentSeq);
    PaymentHistory selectByEnrSeq(Long enrSeq);

}
