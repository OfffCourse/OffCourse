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
import com.offcourse.payment.util.PortOneApiUtil;
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
    private final PortOneApiUtil portOneApiUtil;


    @Override
    @Transactional(rollbackFor = Exception.class)
    public void processEnrollmentPayment(Long courseSeq, Long memberSeq, BigDecimal paymentPrice, String orderId, String impUid) {
        // 결제 정보 검증
        Map<String, Object> paymentInfo = portOneApiUtil.getPaymentInfo(impUid);
        String status = (String) paymentInfo.get("status");
        BigDecimal paidAmount = new BigDecimal(paymentInfo.get("amount").toString());

        if (!"paid".equals(status) || paymentPrice.compareTo(paidAmount) != 0) {
            throw new IllegalStateException("결제 검증 실패: 결제 금액 또는 상태 불일치");
        }
        // 수강신청 INSERT
        Enrollment enrollment = Enrollment.builder()
                .enrStatus(EnrollmentStatus.ENROLL)
                .courseSeq(courseSeq)
                .memberSeq(memberSeq)
                .build();
        int eResult = enrollmentDao.insertEnrollment(enrollment);
        if (eResult < 1) throw new IllegalStateException("ENROLLMENT INSERT 실패");
        // 결제내역 INSERT
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
            log.error("⚠️ Kafka 알림 발송 실패 (결제): {}", kafkaEx.getMessage());
        }
    }

    @Override
    @Transactional
    public void refundPayment(Long paymentSeq, Long enrSeq, String reason) {
        // 1. 결제내역 조회
        PaymentHistory payment = paymentHistoryDao.selectBySeq(paymentSeq);
        if (payment == null) {
            throw new IllegalStateException("결제내역을 찾을 수 없습니다: paymentSeq=" + paymentSeq);
        }
        // 환불 요청자 소유권 검증
        Enrollment enrollment = enrollmentDao.selectEnrollmentBySeq(enrSeq);
        if (enrollment == null) {
            throw new IllegalStateException("수강신청 내역을 찾을 수 없습니다: enrSeq=" + enrSeq);
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

        Enrollment e = enrollmentDao.selectEnrollmentBySeq(enrSeq);
        try {
            notificationProducer.send(
                    NotificationEvent.builder()
                            .msgDate(new Timestamp(System.currentTimeMillis()))
                            .memberSeq(e.getMemberSeq())
                            .msgType(NotificationType.REFUND_SUCCESS)
                            .redirectLocation(NotificationType.REFUND_SUCCESS.getRedirectLocation())
                            .build());
        } catch (Exception kafkaEx) {
            log.error("⚠️ Kafka 알림 발송 실패 (환불): {}", kafkaEx.getMessage());
        }
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