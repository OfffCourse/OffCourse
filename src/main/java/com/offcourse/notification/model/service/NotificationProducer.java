package com.offcourse.notification.model.service;

import com.offcourse.notification.model.dto.NotificationEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationProducer {
    private final KafkaTemplate<String, NotificationEvent> kafkaTemplate;

    public void send(NotificationEvent event) {
        kafkaTemplate.send("offcourse-topic", event);
    }
}
