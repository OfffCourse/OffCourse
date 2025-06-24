package com.offcourse.notification.model.service;

import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationConsumer {
    private final NotificationService notificationService;
    private final RedisService redisService;

    @KafkaListener(topics = "offcourse-topic", groupId = "offcourse-notify", containerFactory = "kafkaListenerContainerFactory")
    public void consume(ConsumerRecord<String, NotificationEvent> record, Acknowledgment ack) {
        NotificationEvent event = record.value();
        try {
            notificationService.processNotification(event); // DB 저장 및 SSE 전송
            ack.acknowledge(); // 커밋
        } catch (Exception e) {
            // 실패 시 Redis 백업 큐에 저장
            redisService.backupNotification(event);
        }
    }
}
