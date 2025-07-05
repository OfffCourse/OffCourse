package com.offcourse.notification.scheduler;

import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.service.EmitterService;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;

import java.util.List;
import java.util.Set;

@Slf4j
@RequiredArgsConstructor
//@Component
public class NotificationRetryScheduler {
    private final RedisService redisService;
    private final EmitterService emitterService;

    //5분마다 Redis에 백업된 알림 재전송 시도
    //부하를 줄이기 위해 스케줄러 대신 이벤트 처리 방식으로 진행
    @Scheduled(fixedDelay = 5 * 60 * 1000)
    public void retryUnsentNotifications() {
        Set<String> keys = redisService.getAllBackupKeys();

        for (String key : keys) {
            try {
                Long memberSeq = Long.valueOf(key.replace("backup:notification:", ""));
                List<NotificationEvent> backupEvents = redisService.getBackupNotifications(memberSeq);

                for (NotificationEvent event : backupEvents) {
                    try {
                        emitterService.sendToUser(event);
                        // 전송 성공 시 해당 이벤트만 삭제
                        redisService.removeBackupNotification(event);
                    } catch (Exception e) {
                        log.warn("재전송 실패: memberSeq={}, event={}", memberSeq, event);
                        // 실패 시 다음 이벤트 재전송을 잠시 중단하고 넘어감
                        break;
                    }
                }
            } catch (Exception e) {
                log.error("재전송 중 예외 발생: {}", key, e);
            }
        }
    }
}