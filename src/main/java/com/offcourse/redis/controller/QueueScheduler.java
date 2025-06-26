package com.offcourse.redis.controller;

import com.offcourse.redis.model.service.QueueService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
@RequiredArgsConstructor
@Slf4j
public class QueueScheduler {

    private final QueueService queueService;
    private final StringRedisTemplate stringRedisTemplate;

    /**
     * 30초마다 대기열 처리
     */
    @Scheduled(fixedDelay = 30000)
    public void processQueuePeriodically() {
        try {
            if (!queueService.shouldProcessQueue()) {
                return; // 조건에 맞지 않으면 종료
            }

            queueService.processWaitingQueue();
        } catch (Exception e) {
            log.warn("대기열 처리 중 오류: {}" , e.getMessage());
        }
    }

    /**
     * 1분마다 비활성 사용자 정리
     */
    @Scheduled(fixedRate = 60000)
    public void cleanupInactiveUsers() {
        try {
            queueService.cleanupInactiveUsers();
        } catch (Exception e) {
            log.warn("비활성 사용자 정리 중 오류: {}" , e.getMessage());
        }
    }

    /**
     * 5분마다 시스템 상태 로그 출력
     */
    @Scheduled(fixedRate = 300000)
    public void logSystemStatus() {
        try {
            if (!queueService.shouldProcessQueue()) {
                return; // 조건에 맞지 않으면 종료
            }
            var status = queueService.getSystemStatus();
            log.debug("=== 대기열 시스템 상태 ===");
            log.debug("대기 중: {}",status.get("waitingCount"));
            log.debug("활성 사용자: {}" ,status.get("activeCount"));
            log.debug("최대 처리 수: {}" , status.get("maxProcessingCount"));
            log.debug("=======================");
        } catch (Exception e) {
            log.warn("시스템 상태 로그 출력 중 오류: {}" , e.getMessage());
        }
    }

    /**
     * 1시간마다 Redis 정리 (선택사항 - 메모리 절약)
     */
    @Scheduled(fixedRate = 3600000)
    public void redisCleanup() {
        try {
            // 만료된 키들 정리 (Spring Session이 놓친 것들)
            Set<String> allKeys = stringRedisTemplate.keys("queue:activity:*");
            if (allKeys != null && !allKeys.isEmpty()) {
                long currentTime = System.currentTimeMillis();
                int cleanedCount = 0;

                for (String key : allKeys) {
                    String lastActivityStr = stringRedisTemplate.opsForValue().get(key);
                    if (lastActivityStr != null) {
                        try {
                            long lastActivity = Long.parseLong(lastActivityStr);
                            long inactiveHours = (currentTime - lastActivity) / (1000 * 60 * 60);

                            // 2시간 이상 비활성인 activity 키 삭제
                            if (inactiveHours > 2) {
                                stringRedisTemplate.delete(key);
                                cleanedCount++;
                            }
                        } catch (Exception ignored) {
                            stringRedisTemplate.delete(key);
                            cleanedCount++;
                        }
                    }
                }

                if (cleanedCount > 0) {
                    log.info("Redis 정리 완료: {}개 만료된 키 삭제", cleanedCount);
                }
            }
        } catch (Exception e) {
            log.warn("Redis 정리 중 오류: {}", e.getMessage());
        }
    }
}