package com.offcourse.payment.model.service;

import com.offcourse.enrollment.model.dao.EnrollmentDao;
import com.offcourse.enrollment.model.dto.Enrollment;
import com.offcourse.enrollment.model.dto.EnrollmentStatus;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.dto.NotificationType;
import com.offcourse.notification.model.service.NotificationProducer;
import com.offcourse.payment.model.dao.PaymentHistoryDao;
import com.offcourse.payment.model.dto.PaymentHistory;
import com.offcourse.payment.model.dto.PaymentStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentServiceImpl implements PaymentService {

    private final EnrollmentDao enrollmentDao;
    private final PaymentHistoryDao paymentHistoryDao;
    private final NotificationProducer notificationProducer;

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


        try {
            notificationProducer.send(
                    NotificationEvent.builder()
                            .msgDate(new Timestamp(System.currentTimeMillis()))
                            .memberSeq(memberSeq)
                            .msgType(NotificationType.ENROLL_SUCCESS)
                            .redirectLocation(NotificationType.ENROLL_SUCCESS.getRedirectLocation())
                            .build());
        } catch (Exception kafkaEx) {
            log.warn("⚠️ Kafka 알림 발송 실패 (결제): {}", kafkaEx.getMessage());
        }
    }

    @Override
    @Transactional
    public void refundPayment(Long paymentSeq, Long enrSeq) {
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