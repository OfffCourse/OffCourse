package com.offcourse.payment.model.dto;

public enum PaymentStatus {
    PAYMENT("0"),          // 결제
    REFUND_REQUEST("1"),   // 환불신청
    REFUND("2");           // 환불

    private final String value;

    PaymentStatus(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return this.value;
    }
}