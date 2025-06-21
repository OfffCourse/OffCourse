package com.offcourse.notification.model.service;

import com.offcourse.notification.model.dto.NotificationEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationConsumer {
    private final NotificationService notificationService;

    @KafkaListener(topics = "offcourse-topic", groupId = "offcourse-notify")
    public void consume(NotificationEvent event) {
        notificationService.processNotification(event);
    }
}
