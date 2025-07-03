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
    private static final String LOCK_KEY = "queue:lock:";

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
     * 대기열 진입/상태 확인 (동시성 문제 해결)
     */
    public Queue enterQueue(String sessionId) {
        // 분산 락으로 동시성 제어
        String lockKey = LOCK_KEY + sessionId;
        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 5, TimeUnit.SECONDS);

        if (Boolean.FALSE.equals(lockAcquired)) {
            // 락 획득 실패 시 현재 상태 반환 (중복 처리 방지)
            log.warn("세션 {} 락 획득 실패, 현재 상태 반환", sessionId);
            return getCurrentStatus(sessionId);
        }

        try {
            return processQueue(sessionId);
        } finally {
            // 락 해제 (반드시 실행)
            stringRedisTemplate.delete(lockKey);
        }
    }

    /**
     * 대기열 처리 로직 (락 보호 하에 실행)
     */
    private Queue processQueue(String sessionId) {
        // 1. 활성 사용자 확인 (중복 체크 강화)
        Boolean isActive = stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, sessionId);
        if (Boolean.TRUE.equals(isActive)) {
            updateActivity(sessionId, true);
            log.debug("이미 활성 사용자: {}", sessionId);
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

            // 차례가 되었는지 확인 (원자적 연산으로 처리)
            if (position != null && position == 1) {
                if (tryMoveToActive(sessionId)) {
                    log.info("사용자 {} 대기열에서 활성화됨", sessionId);
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
                    .estimatedWaitTime(calculateEstimatedWaitTime(position))
                    .message("대기열에 등록되었습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }

        // 3. 신규 사용자 처리 (원자적 연산)
        return handleNewUser(sessionId);
    }

    /**
     * 현재 상태 반환 (락 없이 조회만)
     */
    private Queue getCurrentStatus(String sessionId) {
        Boolean isActive = stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, sessionId);
        if (Boolean.TRUE.equals(isActive)) {
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

        Double score = stringRedisTemplate.opsForZSet().score(WAITING_QUEUE_KEY, sessionId);
        if (score != null) {
            Long position = getWaitingPosition(sessionId);
            updateActivity(sessionId, false);
            return Queue.builder()
                    .status(QueueStatus.WAITING)
                    .sessionId(sessionId)
                    .position(position)
                    .estimatedWaitTime(calculateEstimatedWaitTime(position))
                    .message("대기열에 등록되었습니다.")
                    .timestamp(LocalDateTime.now())
                    .build();
        }

        // 상태를 알 수 없는 경우 대기열에 추가
        return handleNewUser(sessionId);
    }

    /**
     * 신규 사용자 처리 (원자적 연산)
     */
    private Queue handleNewUser(String sessionId) {
        // 현재 활성 사용자 수 확인
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount == null) activeCount = 0L;

        log.info("신규 사용자 {} 처리 - 현재 활성: {}/{}", sessionId, activeCount, maxProcessingCount);

        if (activeCount < maxProcessingCount) {
            // 원자적으로 활성 사용자에 추가 시도
            if (tryAddToActive(sessionId)) {
                Long newActiveCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
                log.info("신규 사용자 {} 즉시 활성화 (활성: {})", sessionId, newActiveCount);

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

        // 대기열에 추가
        addToWaiting(sessionId);
        Long position = getWaitingPosition(sessionId);
        log.info("사용자 {} 대기열 추가 (순번: {})", sessionId, position);

        return Queue.builder()
                .status(QueueStatus.WAITING)
                .sessionId(sessionId)
                .position(position)
                .estimatedWaitTime(calculateEstimatedWaitTime(position))
                .message("대기열에 등록되었습니다.")
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * 활성 사용자로 안전하게 추가 (중복 방지)
     */
    private boolean tryAddToActive(String sessionId) {
        // 이미 활성 사용자인지 다시 한번 확인
        Boolean isAlreadyActive = stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, sessionId);
        if (Boolean.TRUE.equals(isAlreadyActive)) {
            log.debug("이미 활성 사용자임: {}", sessionId);
            updateActivity(sessionId, true);
            return true;
        }

        // 현재 활성 사용자 수 재확인
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount != null && activeCount >= maxProcessingCount) {
            log.debug("활성 사용자 수 초과로 추가 실패: {} (현재: {})", sessionId, activeCount);
            return false;
        }

        // 활성 사용자에 추가
        Long added = stringRedisTemplate.opsForSet().add(ACTIVE_SET_KEY, sessionId);
        if (added != null && added > 0) {
            updateActivity(sessionId, true);
            log.debug("활성 사용자 추가 성공: {}", sessionId);
            return true;
        } else {
            log.debug("활성 사용자 추가 실패 (이미 존재): {}", sessionId);
            updateActivity(sessionId, true);
            return true; // 이미 존재하는 경우도 성공으로 처리
        }
    }

    /**
     * 대기열에서 활성으로 안전하게 이동
     */
    private boolean tryMoveToActive(String sessionId) {
        // 현재 활성 사용자 수 확인
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount != null && activeCount >= maxProcessingCount) {
            return false;
        }

        // 대기열에서 제거
        Long removed = stringRedisTemplate.opsForZSet().remove(WAITING_QUEUE_KEY, sessionId);
        if (removed != null && removed > 0) {
            // 활성 사용자에 추가
            if (tryAddToActive(sessionId)) {
                return true;
            } else {
                // 실패 시 다시 대기열에 추가
                addToWaiting(sessionId);
                return false;
            }
        }
        return false;
    }

    /**
     * 대기열에 추가
     */
    private void addToWaiting(String sessionId) {
        long currentTime = System.currentTimeMillis();
        stringRedisTemplate.opsForZSet().add(WAITING_QUEUE_KEY, sessionId, currentTime);
        updateActivity(sessionId, false);
    }


    /**
     * 강제로 대기열에 추가 (heartbeat 실패, 관리자 액션 등)
     */
    public Queue forceAddToQueue(String sessionId, String reason) {
        // 분산 락으로 동시성 제어
        String lockKey = LOCK_KEY + sessionId;
        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 5, TimeUnit.SECONDS);

        if (Boolean.FALSE.equals(lockAcquired)) {
            log.warn("세션 {} 락 획득 실패 (강제 진입), 현재 상태 반환", sessionId);
            // 락 실패 시에도 강제로 처리하되, 짧은 대기 후 재시도
            try {
                Thread.sleep(100); // 100ms 대기
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return forceProcessQueueEntry(sessionId, reason);
        }

        try {
            return forceProcessQueueEntry(sessionId, reason);
        } finally {
            // 락 해제 (반드시 실행)
            stringRedisTemplate.delete(lockKey);
        }
    }

    /**
     * 강제 대기열 진입 처리 로직
     */
    private Queue forceProcessQueueEntry(String sessionId, String reason) {
        log.info("강제 대기열 진입 처리 시작 - 세션: {}, 사유: {}", sessionId, reason);

        // 1. 활성 사용자에서 제거 (있다면)
        boolean wasActive = stringRedisTemplate.opsForSet().remove(ACTIVE_SET_KEY, sessionId) > 0;
        if (wasActive) {
            log.info("활성 사용자에서 제거됨 - 세션: {}", sessionId);
            // 다음 사용자 처리 (자리가 생겼으므로)
            processNextUser();
        }

        // 2. 기존 대기열에서도 제거 (중복 방지)
        boolean wasWaiting = stringRedisTemplate.opsForZSet().remove(WAITING_QUEUE_KEY, sessionId) > 0;
        if (wasWaiting) {
            log.debug("기존 대기열에서 제거됨 - 세션: {}", sessionId);
        }

        // 3. 기존 활동 기록 삭제
        stringRedisTemplate.delete(LAST_ACTIVITY_KEY + sessionId);

        // 4. 강제로 대기열에 추가 (우선순위 고려)
        long currentTime = System.currentTimeMillis();

        // heartbeat 실패나 세션 만료의 경우 기존 시간보다 약간 앞에 추가 (약간의 우대)
        if ("HEARTBEAT_FAILED".equals(reason) || "SESSION_EXPIRED".equals(reason)) {
            currentTime -= 10000; // 10초 앞으로 (약간의 우선권)
        }

        stringRedisTemplate.opsForZSet().add(WAITING_QUEUE_KEY, sessionId, currentTime);
        updateActivity(sessionId, false);

        // 5. 현재 위치 확인
        Long position = getWaitingPosition(sessionId);
        Long estimatedWaitTime = calculateEstimatedWaitTime(position);

        String message = getForceEntryMessage(reason, wasActive);

        log.info("강제 대기열 진입 완료 - 세션: {}, 순번: {}, 이전 상태: {}",
                sessionId, position, wasActive ? "활성" : "대기/신규");

        return Queue.builder()
                .status(QueueStatus.WAITING)
                .sessionId(sessionId)
                .position(position)
                .estimatedWaitTime(estimatedWaitTime)
                .message(message)
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * 강제 진입 사유별 메시지 생성
     */
    private String getForceEntryMessage(String reason, boolean wasActive) {
        String baseMessage = "대기열에 등록되었습니다.";

        switch (reason) {
            case "HEARTBEAT_FAILED":
                return wasActive ?
                        "연결이 불안정하여 대기열로 이동되었습니다. " + baseMessage :
                        baseMessage;
            case "SESSION_EXPIRED":
                return wasActive ?
                        "세션이 만료되어 대기열로 이동되었습니다. " + baseMessage :
                        baseMessage;
            case "ADMIN_ACTION":
                return "관리자에 의해 대기열로 이동되었습니다. " + baseMessage;
            case "SYSTEM_ERROR":
                return "시스템 오류로 인해 대기열로 이동되었습니다. " + baseMessage;
            default:
                return baseMessage;
        }
    }

    /**
     * 사용자 활동 업데이트 (인터셉터에서 호출)
     */
    public void updateUserActivity(String sessionId) {
        Boolean isActive = stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, sessionId);
        if (Boolean.TRUE.equals(isActive)) {
            updateActivity(sessionId, true);
        } else {
            Double score = stringRedisTemplate.opsForZSet().score(WAITING_QUEUE_KEY, sessionId);
            if (score != null) {
                updateActivity(sessionId, false);
            }
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

    public void processWaitingQueue() {
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount == null) activeCount = 0L;

        int availableSlots = maxProcessingCount - activeCount.intValue();
        if (availableSlots <= 0) {
            log.debug("사용 가능한 슬롯 없음 - 활성: {}/{}", activeCount, maxProcessingCount);
            return;
        }

        log.warn("대기열 처리 시작 - 활성: {}/{}, 가용 슬롯: {}", activeCount, maxProcessingCount, availableSlots);

        int processedCount = 0;
        for (int i = 0; i < availableSlots; i++) {
            if (!processNextUser()) break;
            processedCount++;
        }

        if (processedCount > 0) {
            log.info("대기열 처리 완료 - {}명 활성화", processedCount);
        }
    }

    private boolean processNextUser() {
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount != null && activeCount >= maxProcessingCount) {
            return false;
        }

        Set<String> nextUsers = stringRedisTemplate.opsForZSet().range(WAITING_QUEUE_KEY, 0, 0);
        if (nextUsers == null || nextUsers.isEmpty()) {
            return false;
        }

        String nextSessionId = nextUsers.iterator().next();

        if (tryMoveToActive(nextSessionId)) {
            log.info("다음 사용자 활성화: {}", nextSessionId);
            return true;
        }

        return false;
    }

    public boolean shouldProcessQueue() {
        // 대기열에 사람이 있는지
        Long waitingCount = stringRedisTemplate.opsForZSet().zCard(WAITING_QUEUE_KEY);
        if (waitingCount == null || waitingCount == 0) {
            return false;
        }

        // 여유 자리가 있는지
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);
        if (activeCount != null && activeCount >= maxProcessingCount) {
            return false;
        }

        return true;
    }

    public void cleanupInactiveUsers() {
        long currentTime = System.currentTimeMillis();

        int activeCleanupCount = cleanupUsers(ACTIVE_SET_KEY, currentTime, activeTimeout, true);
        int waitingCleanupCount = cleanupUsers(WAITING_QUEUE_KEY, currentTime, waitingTimeout, false);

        if (activeCleanupCount > 0) {
            log.debug("서비스 이용 중 사용자 {}명 정리", activeCleanupCount);
            processWaitingQueue();
        }

        if (waitingCleanupCount > 0) {
            log.debug("대기열 사용자 {}명 정리", waitingCleanupCount);
        }
    }

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

        Set<String> waitingUsers = stringRedisTemplate.opsForZSet().range(WAITING_QUEUE_KEY, 0, 9);
        status.put("waitingUsers", waitingUsers);

        return status;
    }

    public Map<String, Object> clearAllQueue() {
        Long waitingCount = stringRedisTemplate.opsForZSet().zCard(WAITING_QUEUE_KEY);
        Long activeCount = stringRedisTemplate.opsForSet().size(ACTIVE_SET_KEY);

        Set<String> allUsers = new HashSet<>();
        Set<String> activeUsers = stringRedisTemplate.opsForSet().members(ACTIVE_SET_KEY);
        Set<String> waitingUsers = stringRedisTemplate.opsForZSet().range(WAITING_QUEUE_KEY, 0, -1);

        if (activeUsers != null) allUsers.addAll(activeUsers);
        if (waitingUsers != null) allUsers.addAll(waitingUsers);

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

    private void updateActivity(String sessionId, boolean isActive) {
        int timeout = isActive ? activeTimeout : waitingTimeout;
        stringRedisTemplate.opsForValue().set(
                LAST_ACTIVITY_KEY + sessionId,
                String.valueOf(System.currentTimeMillis()),
                timeout * 2,
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

    /**
     * 세션 ID 변경 시 대기열 정보 이전 (로그인 시 사용)
     * QueueService.java에 추가할 메서드
     */
    public boolean transferQueueSession(String oldSessionId, String newSessionId) {
        // 분산 락으로 동시성 제어
        String lockKey = LOCK_KEY + oldSessionId;
        Boolean lockAcquired = stringRedisTemplate.opsForValue().setIfAbsent(lockKey, "1", 5, TimeUnit.SECONDS);

        if (Boolean.FALSE.equals(lockAcquired)) {
            log.warn("세션 이전 락 획득 실패: {} -> {}", oldSessionId, newSessionId);
            return false;
        }

        try {
            boolean transferred = false;

            // 1. 활성 사용자에서 이전
            Boolean wasActive = stringRedisTemplate.opsForSet().isMember(ACTIVE_SET_KEY, oldSessionId);
            if (Boolean.TRUE.equals(wasActive)) {
                stringRedisTemplate.opsForSet().remove(ACTIVE_SET_KEY, oldSessionId);
                stringRedisTemplate.opsForSet().add(ACTIVE_SET_KEY, newSessionId);
                transferred = true;
                log.info("활성 사용자 세션 이전: {} -> {}", oldSessionId, newSessionId);
            }

            // 2. 대기열에서 이전
            Double score = stringRedisTemplate.opsForZSet().score(WAITING_QUEUE_KEY, oldSessionId);
            if (score != null) {
                stringRedisTemplate.opsForZSet().remove(WAITING_QUEUE_KEY, oldSessionId);
                stringRedisTemplate.opsForZSet().add(WAITING_QUEUE_KEY, newSessionId, score);
                transferred = true;
                log.info("대기열 사용자 세션 이전: {} -> {} (score: {})", oldSessionId, newSessionId, score);
            }

            // 3. 활동 기록 이전
            String lastActivity = stringRedisTemplate.opsForValue().get(LAST_ACTIVITY_KEY + oldSessionId);
            if (lastActivity != null) {
                stringRedisTemplate.delete(LAST_ACTIVITY_KEY + oldSessionId);
                int timeout = wasActive ? activeTimeout : waitingTimeout;
                stringRedisTemplate.opsForValue().set(
                        LAST_ACTIVITY_KEY + newSessionId,
                        lastActivity,
                        timeout * 2,
                        TimeUnit.SECONDS
                );
            }

            return transferred;

        } finally {
            // 락 해제
            stringRedisTemplate.delete(lockKey);
        }
    }
}