package com.offcourse.payment.model.service;

import com.offcourse.payment.model.dao.PaymentHistoryDao;
import com.offcourse.payment.model.dto.PaymentHistory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final PaymentHistoryDao paymentDao;

    @Override
    @Transactional
    public void recordPayment(PaymentHistory ph) {
        ph.setPaymentTime(new Timestamp(System.currentTimeMillis()));
        paymentDao.insertPaymentHistory(ph);
    }

    @Override
    @Transactional
    public void changePaymentStatus(Long paymentSeq, String status) {
        paymentDao.updatePaymentStatus(paymentSeq, status);
    }

    @Override
    public PaymentHistory findByOrderId(String orderId) {
        return paymentDao.selectByOrderId(orderId);
    }
}
