package com.offcourse.notification.model.service;

import com.offcourse.notification.model.dao.EmitterRepository;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmitterService {
    private final EmitterRepository emitterRepository;
    private final RedisTemplate<String, Object> redisTemplate;
    private final RedisService redisService;

    public SseEmitter connect(Long memberSeq) {
        SseEmitter emitter = new SseEmitter(60 * 60 * 1000L);
        emitterRepository.save(memberSeq, emitter);

        emitter.onCompletion(() -> emitterRepository.delete(memberSeq));
        emitter.onTimeout(() -> emitterRepository.delete(memberSeq));
        emitter.onError((e) -> emitterRepository.delete(memberSeq));

        try {
            emitter.send(SseEmitter.event().name("connect").data("connected"));
        } catch (IOException e) {
            log.error("SSE 연결 알림 전송 실패", e);
        }

        //SSE 연결 복구 시 Redis 재전송 시도
        redisService.retryBackupNotifications(memberSeq, event -> {
            try {
                emitter.send(SseEmitter.event().name("notification").data(event));
                return true;
            } catch (IOException e) {
                return false;
            }
        });

        return emitter;
    }

    public void sendToUser(NotificationEvent event) {
        if (redisService.isAlreadySent(event)) {
            log.warn("중복 알림 전송 방지: memberSeq={}, msgSeq={}", event.getMemberSeq(), event.getMsgSeq());
            return;
        }

        SseEmitter emitter = emitterRepository.get(event.getMemberSeq());
        if (emitter != null) {
            try {
                emitter.send(SseEmitter.event().name("notification").data(event));
                redisService.markAsSent(event); // 전송 성공 시 기록
            } catch (IOException e) {
                emitterRepository.delete(event.getMemberSeq());
                log.error("SSE 전송 실패: {}", e.getMessage());
                backupToRedis(event); // 실패 시 백업
            }
        } else {
            log.warn("SSE 연결 없음: memberSeq={} => Redis로 백업", event.getMemberSeq());
            backupToRedis(event);
        }
    }

    private void backupToRedis(NotificationEvent event) {
        try {
            String key = "unread:member:" + event.getMemberSeq();
            redisTemplate.opsForList().rightPush(key, event);
            redisTemplate.expire(key, 7, TimeUnit.DAYS); // 데이터 유효기간 설정
        } catch (DataAccessException e) {
            log.error("Redis 백업 실패 - 알림 유실 위험: memberSeq={}, event={}", event.getMemberSeq(), event);
        }
    }
}
