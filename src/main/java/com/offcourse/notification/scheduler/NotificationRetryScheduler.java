package com.offcourse.notification.scheduler;

import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.service.EmitterService;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;

@Slf4j
@RequiredArgsConstructor
@Component
public class NotificationRetryScheduler {
    private final RedisService redisService;
    private final EmitterService emitterService;

    //5분마다 Redis에 백업된 알림 재전송 시도
    //@Scheduled(fixedDelay = 5 * 60 * 1000)
    @Scheduled(fixedDelay = 30 * 60 * 1000)
    public void retryUnsentNotifications() {
        Set<String> keys = redisService.getAllBackupKeys();

        for (String key : keys) {
            try {
                Long memberSeq = Long.valueOf(key.replace("backup:notification:", ""));
                List<Object> backupEvents = redisService.getBackupNotifications(memberSeq);

                for (Object obj : backupEvents) {
                    if (obj instanceof NotificationEvent event) {
                        try {
                            emitterService.sendToUser(event);
                            redisService.removeFirstBackupNotification(memberSeq);
                        } catch (Exception e) {
                            log.warn("재전송 실패: memberSeq={}, event={}", memberSeq, event);
                            break;
                        }
                    }
                }
            } catch (Exception e) {
                log.error("재전송 중 예외 발생: {}", key, e);
            }
        }
    }
}
