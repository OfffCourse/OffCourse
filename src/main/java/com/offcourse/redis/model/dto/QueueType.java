/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 30.
  Time: 오후 3:49
*/
package com.offcourse.redis.model.dto;

public enum QueueType {
    /**
     * 일반 서비스 이용 대기열
     * - 전체 시스템 접근을 위한 대기열
     * - 동시 접속자 수 제한
     */
    GENERAL("일반 대기열", "서비스 이용을 위한 대기열"),

    /**
     * 결제 전용 대기열
     * - 특정 강의 수강신청을 위한 대기열
     * - 강의별 인원 제한에 따른 대기
     */
    PAYMENT("결제 대기열", "수강신청 결제를 위한 대기열");

    private final String displayName;
    private final String description;

    QueueType(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }

    /**
     * 결제 대기열인지 확인
     */
    public boolean isPaymentQueue() {
        return this == PAYMENT;
    }

    /**
     * 일반 대기열인지 확인
     */
    public boolean isGeneralQueue() {
        return this == GENERAL;
    }
}

