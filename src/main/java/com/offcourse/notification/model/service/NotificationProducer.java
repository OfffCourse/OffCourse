package com.offcourse.notification.model.service;

import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationProducer {
    private final KafkaTemplate<String, NotificationEvent> kafkaTemplate;
    private final RedisService redisService;

    public void send(NotificationEvent event) {
        // 1. Redis에 백업
        redisService.backupNotification(event);

        // 2. Kafka 전송
        kafkaTemplate.send("offcourse-topic", event)
                .addCallback(
                        result -> {
                            log.info("Kafka 전송 성공: {}", event);
                            // msgSeq 기반 정확한 삭제 필요
                            redisService.removeBackupNotification(event);
                            redisService.markAsSent(event);
                        },
                        ex -> log.error("Kafka 전송 실패: {}", event, ex)
                );
    }
}
