package com.offcourse.redis.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 대기열 상태를 나타내는 값 객체 (Value Object)
 * 세션별 대기열 정보와 응답 DTO 역할을 모두 담당
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Queue {
    private QueueStatus status;          // 현재 상태
    private Long position;               // 대기 순번
    private Long estimatedWaitTime;      // 예상 대기 시간 (초)
    private String message;              // 사용자에게 표시할 메시지
    private LocalDateTime timestamp;     // 응답 생성 시간
    private String sessionId;            // 세션 ID
    private QueueType queueType;

    // 결제 대기열 관련 필드
    private Long courseSeq;
    private Long memberSeq;
    private BigDecimal paymentPrice;
    private String courseName;
    private Integer courseCurrentSize;
    private Integer courseMaxSize;

    // AJAX 응답을 위한 편의 메서드들
    public boolean isAccessAllowed() {
        return status == QueueStatus.ALLOW;
    }

    public int getHttpStatus() {
        return isAccessAllowed() ? 200 : 403;
    }

    /**
     * 허용된 큐 상태를 생성하는 정적 팩토리 메서드
     */
    public static Queue createAllowedQueue(String sessionId, QueueType queueType) {
        return Queue.builder()
                .sessionId(sessionId)
                .status(QueueStatus.ALLOW)
                .queueType(queueType)
                .position(0L)
                .estimatedWaitTime(0L)
                .message(queueType == QueueType.PAYMENT ?
                        "결제를 진행하실 수 있습니다." :
                        "서비스를 이용하실 수 있습니다.")
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * 대기 중인 큐 상태를 생성하는 정적 팩토리 메서드
     */
    public static Queue createWaitingQueue(String sessionId, QueueType queueType,
                                           Long position, Long estimatedWaitTime) {
        return Queue.builder()
                .sessionId(sessionId)
                .status(QueueStatus.WAITING)
                .queueType(queueType)
                .position(position)
                .estimatedWaitTime(estimatedWaitTime)
                .message(queueType == QueueType.PAYMENT ?
                        "결제 대기열에서 대기 중입니다." :
                        "대기열에서 대기 중입니다.")
                .timestamp(LocalDateTime.now())
                .build();
    }

}