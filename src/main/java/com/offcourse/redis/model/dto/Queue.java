package com.offcourse.redis.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

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
    private String sessionId;            // 세션 ID (필요시)

    // AJAX 응답을 위한 편의 메서드들
    public boolean isAccessAllowed() {
        return status == QueueStatus.ALLOW;
    }

    public boolean requiresQueue() {
        return !isAccessAllowed();
    }

    public int getHttpStatus() {
        return isAccessAllowed() ? 200 : 403;
    }

}