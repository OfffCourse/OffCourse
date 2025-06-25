package com.offcourse.redis.model.service;

import com.offcourse.redis.model.dto.Queue;
import com.offcourse.redis.model.dto.QueueStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.connection.DataType;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class QueueService {

    private final StringRedisTemplate stringRedisTemplate;

    // Redis Key 상수
    private static final String WAITING_QUEUE_KEY = "queue:waiting";
    private static final String ACTIVE_SET_KEY = "queue:active";
    private static final String LAST_ACTIVITY_KEY = "queue:activity:";

    @Value("${queue.max-processing-count:5}")
    private int maxProcessingCount;

    @Value("${queue.avg-processing-time:30}")
    private int avgProcessingTime;

    // 이중 타임아웃 시스템
    @Value("${queue.waiting-timeout:60}")
    private int waitingTimeout;

    @Value("${queue.active-timeout:1800}")
    private int activeTimeout;

    /**
     * 대기열 진입/상태 확인
     */
    public Queue enterQueue(String sessionId) {
        // 1. 활성 사용자 확인
        if (Boolean.TRUE.equals(stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, sessionId))) {
            updateActivity(sessionId, true);
            return Queue.builder()
                    .status(QueueStatus.ALLOW)
                    .sessionId(sessionId)
                    .position(0L)
                    .estimatedWaitTime(0L)
                    .message("서비스 이용 중입니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }

        // 2. 대기열 확인
        Double score = stringRedisTemplate.opsForZSet().score(WAITING_QUEUE_KEY, sessionId);
        if (score != null) {
            Long position = getWaitingPosition(sessionId);
            Long estimatedTime = calculateEstimatedWaitTime(position);

            // 차례가 되었는지 확인 (첫 번째 순서이고 자리가 있는 경우)
            if (position != null && position == 1 && canEnterService()) {
                // 활성 사용자로 이동
                Long removed = stringRedisTemplate.opsForZSet().remove(WAITING_QUEUE_KEY, sessionId);
                if (removed != null && removed > 0) {
                    stringRedisTemplate.opsForSet().add(ACTIVE_SET_KEY, sessionId);
                    updateActivity(sessionId, true);

                    log.debug("사용자 {} 대기열에서 활성화됨", sessionId);

                    return Queue.builder()
                            .status(QueueStatus.ALLOW)
                            .sessionId(sessionId)
                            .position(0L)
                            .estimatedWaitTime(0L)
                            .message("서비스 이용이 가능합니다.")
                            .timestamp(LocalDateTime.now())
                            .build();
                }
            }

            updateActivity(sessionId, false);
            return Queue.builder()
                    .status(QueueStatus.WAITING)
                    .sessionId(sessionId)
                    .position(position)
                    .estimatedWaitTime(estimatedTime)
                    .message("대기열에 등록되었습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }

        // 3. 처음 접근하는 사용자
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount == null) activeCount = 0L;

        log.debug("현재 활성 사용자 수: {}/{}", activeCount, maxProcessingCount);

        if (activeCount < maxProcessingCount) {
            // 즉시 서비스 이용 가능
            stringRedisTemplate.opsForSet().add(ACTIVE_SET_KEY, sessionId);
            updateActivity(sessionId, true);

            log.info("신규 사용자 {} 즉시 활성화 (활성: {}/{})", sessionId, activeCount + 1, maxProcessingCount);

            return Queue.builder()
                    .status(QueueStatus.ALLOW)
                    .sessionId(sessionId)
                    .position(0L)
                    .estimatedWaitTime(0L)
                    .message("서비스 이용이 가능합니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        } else {
            // 대기열에 추가
            long currentTime = System.currentTimeMillis();
            stringRedisTemplate.opsForZSet().add(WAITING_QUEUE_KEY, sessionId, currentTime);
            updateActivity(sessionId, false);

            Long position = getWaitingPosition(sessionId);
            Long estimatedTime = calculateEstimatedWaitTime(position);

            log.info("사용자 {} 대기열 추가 (순번: {})", sessionId, position);

            return Queue.builder()
                    .status(QueueStatus.WAITING)
                    .sessionId(sessionId)
                    .position(position)
                    .estimatedWaitTime(estimatedTime)
                    .message("대기열에 등록되었습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }
    }

    /**
     * 사용자 활동 업데이트 (인터셉터에서 호출)
     */
    public void updateUserActivity(String sessionId) {
        // 활성 사용자인지 대기 사용자인지 확인해서 적절한 타임아웃 적용
        if (Boolean.TRUE.equals(stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, sessionId))) {
            updateActivity(sessionId, true);
        } else if (stringRedisTemplate.opsForZSet().score(WAITING_QUEUE_KEY, sessionId) != null) {
            updateActivity(sessionId, false);
        }
    }

    /**
     * 서비스 이용 완료
     */
    public void completeService(String sessionId) {
        boolean wasActive = stringRedisTemplate.opsForSet().remove(ACTIVE_SET_KEY, sessionId) > 0;
        if (wasActive) {
            stringRedisTemplate.delete(LAST_ACTIVITY_KEY + sessionId);
            log.info("사용자 {} 서비스 완료", sessionId);
            processNextUser();
        }
    }

    /**
     * 사용자 제거 (브라우저 종료, 관리자 제거, 세션 만료 등)
     */
    public boolean leaveQueue(String sessionId) {
        boolean removedFromWaiting = stringRedisTemplate.opsForZSet().remove(WAITING_QUEUE_KEY, sessionId) > 0;
        boolean removedFromActive = stringRedisTemplate.opsForSet().remove(ACTIVE_SET_KEY, sessionId) > 0;

        if (removedFromWaiting || removedFromActive) {
            stringRedisTemplate.delete(LAST_ACTIVITY_KEY + sessionId);
        }

        if (removedFromActive) {
            log.info("활성 사용자 {} 제거됨", sessionId);
            processNextUser(); // 자리가 생겼으니 다음 사용자 처리
        } else if (removedFromWaiting) {
            log.info("대기열 사용자 {} 제거됨", sessionId);
        }

        return removedFromWaiting || removedFromActive;
    }

    /**
     * 대기열 처리 (스케줄러용)
     */
    public void processWaitingQueue() {
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount == null) activeCount = 0L;

        int availableSlots = maxProcessingCount - activeCount.intValue();
        if (availableSlots <= 0) return;

        log.debug("대기열 처리 시작 - 가용 슬롯: {}", availableSlots);

        int processedCount = 0;
        for (int i = 0; i < availableSlots; i++) {
            if (!processNextUser()) break;
            processedCount++;
        }

        if (processedCount > 0) {
            log.info("대기열 처리 완료 - {}명 활성화", processedCount);
        }
    }

    /**
     * 비활성 사용자 정리 (이중 타임아웃 적용)
     */
    public void cleanupInactiveUsers() {
        long currentTime = System.currentTimeMillis();

        // 서비스 이용 중인 사용자 정리 (긴 타임아웃)
        int activeCleanupCount = cleanupUsers(ACTIVE_SET_KEY, currentTime, activeTimeout, true);

        // 대기열 사용자 정리 (짧은 타임아웃)
        int waitingCleanupCount = cleanupUsers(WAITING_QUEUE_KEY, currentTime, waitingTimeout, false);

        if (activeCleanupCount > 0) {
            log.info("서비스 이용 중 사용자 {}명 정리", activeCleanupCount);
            processWaitingQueue(); // 자리가 생겼으니 대기열 처리
        }

        if (waitingCleanupCount > 0) {
            log.info("대기열 사용자 {}명 정리", waitingCleanupCount);
        }
    }

    /**
     * 시스템 상태 조회
     */
    public Map<String, Object> getSystemStatus() {
        Long waitingCount = stringRedisTemplate.opsForZSet().zCard(WAITING_QUEUE_KEY);
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);

        Map<String, Object> status = new HashMap<>();
        status.put("waitingCount", waitingCount != null ? waitingCount : 0);
        status.put("activeCount", activeCount != null ? activeCount : 0);
        status.put("maxProcessingCount", maxProcessingCount);
        status.put("waitingTimeout", waitingTimeout);
        status.put("activeTimeout", activeTimeout);
        status.put("totalUsers", (waitingCount != null ? waitingCount : 0) +
                (activeCount != null ? activeCount : 0));
        status.put("availableSlots", maxProcessingCount - (activeCount != null ? activeCount : 0));

        // 대기 중인 사용자 목록 (최대 10명)
        Set<String> waitingUsers = stringRedisTemplate.opsForZSet().range(WAITING_QUEUE_KEY, 0, 9);
        status.put("waitingUsers", waitingUsers);

        return status;
    }

    /**
     * 전체 대기열 삭제 (관리자용)
     */
    public Map<String, Object> clearAllQueue() {
        Long waitingCount = stringRedisTemplate.opsForZSet().zCard(WAITING_QUEUE_KEY);
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);

        // 활동 기록 삭제
        Set<String> allUsers = new HashSet<>();
        Set<String> activeUsers = stringRedisTemplate.opsForSet().members(ACTIVE_SET_KEY);
        Set<String> waitingUsers = stringRedisTemplate.opsForZSet().range(WAITING_QUEUE_KEY, 0, -1);

        if (activeUsers != null) allUsers.addAll(activeUsers);
        if (waitingUsers != null) allUsers.addAll(waitingUsers);

        // 모든 데이터 삭제
        stringRedisTemplate.delete(WAITING_QUEUE_KEY);
        stringRedisTemplate.delete(ACTIVE_SET_KEY);

        for (String sessionId : allUsers) {
            stringRedisTemplate.delete(LAST_ACTIVITY_KEY + sessionId);
        }

        log.warn("관리자에 의해 대기열 완전 삭제 - 대기: {}, 활성: {}", waitingCount, activeCount);

        return Map.of(
                "success", true,
                "clearedWaiting", waitingCount != null ? waitingCount : 0,
                "clearedActive", activeCount != null ? activeCount : 0,
                "timestamp", LocalDateTime.now()
        );
    }

    // === Private 헬퍼 메서드들 ===

    private boolean canEnterService() {
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        return activeCount != null && activeCount < maxProcessingCount;
    }

    private boolean processNextUser() {
        if (!canEnterService()) return false;

        Set<String> nextUsers = stringRedisTemplate.opsForZSet().range(WAITING_QUEUE_KEY, 0, 0);
        if (nextUsers == null || nextUsers.isEmpty()) return false;

        String nextSessionId = nextUsers.iterator().next();
        Long removed = stringRedisTemplate.opsForZSet().remove(WAITING_QUEUE_KEY, nextSessionId);

        if (removed != null && removed > 0) {
            stringRedisTemplate.opsForSet().add(ACTIVE_SET_KEY, nextSessionId);
            updateActivity(nextSessionId, true);
            log.info("다음 사용자 활성화: {}", nextSessionId);
            return true;
        }

        return false;
    }

    /**
     * 상태별 활동 업데이트 (이중 타임아웃 적용)
     */
    private void updateActivity(String sessionId, boolean isActive) {
        int timeout = isActive ? activeTimeout : waitingTimeout;
        stringRedisTemplate.opsForValue().set(
                LAST_ACTIVITY_KEY + sessionId,
                String.valueOf(System.currentTimeMillis()),
                timeout * 2, // Redis TTL은 더 길게 설정
                TimeUnit.SECONDS
        );
    }

    private Long getWaitingPosition(String sessionId) {
        Long rank = stringRedisTemplate.opsForZSet().rank(WAITING_QUEUE_KEY, sessionId);
        return rank != null ? rank + 1 : null;
    }

    private Long calculateEstimatedWaitTime(Long position) {
        if (position == null || position <= 0) return 0L;
        return (long) Math.ceil((double) (position - 1) / maxProcessingCount) * avgProcessingTime;
    }

    /**
     * 사용자 정리 (Set 또는 ZSet에서)
     */
    private int cleanupUsers(String key, long currentTime, int timeoutSeconds, boolean isActiveSet) {
        Set<String> users = isActiveSet ?
                stringRedisTemplate.opsForSet().members(key) :
                stringRedisTemplate.opsForZSet().range(key, 0, -1);

        if (users == null || users.isEmpty()) return 0;

        int cleanupCount = 0;
        for (String sessionId : users) {
            if (isUserInactive(sessionId, currentTime, timeoutSeconds)) {
                if (isActiveSet) {
                    stringRedisTemplate.opsForSet().remove(key, sessionId);
                } else {
                    stringRedisTemplate.opsForZSet().remove(key, sessionId);
                }
                stringRedisTemplate.delete(LAST_ACTIVITY_KEY + sessionId);
                cleanupCount++;

                log.info("비활성 사용자 정리: {} ({} 타임아웃: {}초)",
                        sessionId, isActiveSet ? "서비스" : "대기열", timeoutSeconds);
            }
        }
        return cleanupCount;
    }

    private boolean isUserInactive(String sessionId, long currentTime, int timeoutSeconds) {
        String lastActivityStr = stringRedisTemplate.opsForValue().get(LAST_ACTIVITY_KEY + sessionId);

        if (lastActivityStr == null) return true;

        try {
            long lastActivity = Long.parseLong(lastActivityStr);
            long inactiveTime = (currentTime - lastActivity) / 1000;
            return inactiveTime > timeoutSeconds;
        } catch (NumberFormatException e) {
            return true;
        }
    }

    // 디버깅용 - Redis 데이터 조회
    public Map<String, Object> getAllRedisData() {
        Map<String, Object> result = new LinkedHashMap<>();
        Set<String> keys = stringRedisTemplate.keys("queue:*");

        if (keys == null || keys.isEmpty()) {
            result.put("message", "Redis에 저장된 대기열 키가 없습니다.");
            return result;
        }

        for (String key : keys) {
            DataType type = stringRedisTemplate.type(key);
            switch (type.code()) {
                case "string":
                    result.put(key, stringRedisTemplate.opsForValue().get(key));
                    break;
                case "set":
                    result.put(key, stringRedisTemplate.opsForSet().members(key));
                    break;
                case "zset":
                    result.put(key, stringRedisTemplate.opsForZSet().rangeWithScores(key, 0, -1));
                    break;
            }
        }
        return result;
    }
}