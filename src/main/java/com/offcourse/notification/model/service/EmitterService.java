package com.offcourse.notification.model.service;

import com.offcourse.notification.model.dao.EmitterRepository;
import com.offcourse.notification.model.dto.NotificationEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;

@Service
@RequiredArgsConstructor
public class EmitterService {
    private final EmitterRepository emitterRepository;

    public SseEmitter connect(Long memberSeq) {
        SseEmitter emitter = new SseEmitter(60 * 60 * 1000L);
        emitterRepository.save(memberSeq, emitter);
        emitter.onCompletion(() -> emitterRepository.delete(memberSeq));
        emitter.onTimeout(() -> emitterRepository.delete(memberSeq));
        emitter.onError((e) -> emitterRepository.delete(memberSeq));

        return emitter;
    }

    /**
     * 특정 사용자에게 알림 전송
     */
    public void sendToUser(NotificationEvent event) {
        SseEmitter emitter = emitterRepository.get(event.getMemberSeq());
        if (emitter != null) {
            try {
                emitter.send(SseEmitter.event().name("notification").data(event));
            } catch (IOException e) {
                emitterRepository.delete(event.getMemberSeq());
            }
        }
    }
}
