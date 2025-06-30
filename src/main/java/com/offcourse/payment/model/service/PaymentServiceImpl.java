package com.offcourse.payment.model.service;

import com.offcourse.enrollment.model.dao.EnrollmentDao;
import com.offcourse.enrollment.model.dto.Enrollment;
import com.offcourse.enrollment.model.dto.EnrollmentStatus;
import com.offcourse.payment.model.dao.PaymentHistoryDao;
import com.offcourse.payment.model.dto.PaymentHistory;
import com.offcourse.payment.model.dto.PaymentStatus;
import com.offcourse.payment.util.PortOneApiUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PaymentServiceImpl implements PaymentService {

    private final EnrollmentDao enrollmentDao;
    private final PaymentHistoryDao paymentHistoryDao;
    private final PortOneApiUtil portOneApiUtil;


    @Override
    @Transactional(rollbackFor = Exception.class)
    public void processEnrollmentPayment(Long courseSeq, Long memberSeq, BigDecimal paymentPrice, String orderId, String impUid) {
        Enrollment enrollment = Enrollment.builder()
                .enrStatus(EnrollmentStatus.ENROLL)
                .courseSeq(courseSeq)
                .memberSeq(memberSeq)
                .build();
        int eResult = enrollmentDao.insertEnrollment(enrollment);
        if (eResult < 1) throw new IllegalStateException("ENROLLMENT INSERT 실패");

        PaymentHistory ph = PaymentHistory.builder()
                .paymentPrice(paymentPrice)
                .paymentOrderId(orderId)
                .paymentImpUid(impUid)
                .paymentStatus(PaymentStatus.PAYMENT)
                .enrSeq(enrollment.getEnrSeq())
                .build();
        int pResult = paymentHistoryDao.insertPaymentHistory(ph);
        if (pResult < 1) throw new IllegalStateException("PAYMENT_HISTORY INSERT 실패");
    }

    @Override
    @Transactional
    public void refundPayment(Long paymentSeq, Long enrSeq, String reason) {
        // 1. 결제내역 조회
        PaymentHistory payment = paymentHistoryDao.selectBySeq(paymentSeq);
        if (payment == null) {
            throw new IllegalStateException("결제내역을 찾을 수 없습니다: paymentSeq=" + paymentSeq);
        }
        // 2. 포트원 환불 API 호출
        portOneApiUtil.cancelPayment(
                payment.getPaymentImpUid(),
                payment.getPaymentPrice(),
                reason
        );
        // 3. DB 상태 변경
        int pResult = paymentHistoryDao.updatePaymentStatus(
                Map.of("paymentSeq", paymentSeq, "status", PaymentStatus.REFUND.toString())
        );
        if (pResult < 1) throw new IllegalStateException("PAYMENT_STATUS UPDATE 실패");

        int eResult = enrollmentDao.updateEnrollmentStatusByEnrSeq(
                Map.of("enrSeq", enrSeq, "status", EnrollmentStatus.CANCEL.toString())
        );
        if (eResult < 1) throw new IllegalStateException("ENROLLMENT STATUS UPDATE 실패");
    }

    @Override
    public PaymentHistory findPaymentHistoryBySeq(Long paymentSeq) {
        return paymentHistoryDao.selectBySeq(paymentSeq);
    }

    @Override
    public PaymentHistory findPaymentHistoryByEnrSeq(Long enrSeq) {
        return paymentHistoryDao.selectByEnrSeq(enrSeq);
    }


}