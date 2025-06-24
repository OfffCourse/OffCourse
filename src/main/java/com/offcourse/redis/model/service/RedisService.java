/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 20.
  Time: 오후 4:39
*/
package com.offcourse.redis.model.service;

import com.offcourse.notification.model.dto.NotificationEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;
import java.util.Set;
import java.util.function.Function;

@RequiredArgsConstructor
@Service
public class RedisService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final StringRedisTemplate stringRedisTemplate;

    // 기본 SET/GET
    public void setValue(String key, String value) {
        stringRedisTemplate.opsForValue().set(key, value);
    }

    public String getValue(String key) {
        return stringRedisTemplate.opsForValue().get(key);
    }

    // TTL 설정
    public void setValueWithTTL(String key, String value, long timeout) {
        stringRedisTemplate.opsForValue().set(key, value, Duration.ofSeconds(timeout));
    }

    // 객체 저장
    public void setObject(String key, Object obj) {
        redisTemplate.opsForValue().set(key, obj);
    }

    public Object getObject(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    // 리스트 조작
    public void addToList(String key, String value) {
        stringRedisTemplate.opsForList().rightPush(key, value);
    }

    public List<String> getList(String key) {
        return stringRedisTemplate.opsForList().range(key, 0, -1);
    }

    // Hash 조작
    public void setHashValue(String key, String field, String value) {
        stringRedisTemplate.opsForHash().put(key, field, value);
    }

    public String getHashValue(String key, String field) {
        return (String) stringRedisTemplate.opsForHash().get(key, field);
    }

    //Redis에 백업 알림 메시지 저장
    public void backupNotification(NotificationEvent event) {
        String key = "backup:notification:" + event.getMemberSeq();
        redisTemplate.opsForList().rightPush(key, event);
        redisTemplate.expire(key, Duration.ofDays(7));
    }

    //Redis에 백업된 특정 회원의 알림 메시지 가져오기
    public List<Object> getBackupNotifications(Long memberSeq) {
        String key = "backup:notification:" + memberSeq;
        return redisTemplate.opsForList().range(key, 0, -1);
    }

    //Redis에 백업된 메시지 중 전송 완료된 메시지 삭제
    public void removeFirstBackupNotification(Long memberSeq) {
        String key = "backup:notification:" + memberSeq;
        redisTemplate.opsForList().leftPop(key);
    }

    // 백업된 알림 재전송
    public void retryBackupNotifications(Long memberSeq, Function<NotificationEvent, Boolean> sendLogic) {
        List<Object> backupList = getBackupNotifications(memberSeq);
        for (Object obj : backupList) {
            if (obj instanceof NotificationEvent event) {
                if (isAlreadySent(event)) {
                    removeFirstBackupNotification(memberSeq); // 이미 보낸 알림이면 제거
                    continue;
                }

                boolean success = sendLogic.apply(event);
                if (success) {
                    removeFirstBackupNotification(memberSeq);
                    resetFailCount(event);
                    markAsSent(event); // 성공 시 기록
                } else {
                    incrementFailCount(event);
                    if (getFailCount(event) > 5) {
                        moveToDeadLetter(event);
                        resetFailCount(event);
                        removeFirstBackupNotification(memberSeq);
                    }
                    break;
                }
            }
        }
    }

    //재전송 무한루프 방지를 위한 failCount 증가
    private void incrementFailCount(NotificationEvent event) {
        String key = "fail:notification:" + event.getMsgSeq();
        stringRedisTemplate.opsForValue().increment(key);
        stringRedisTemplate.expire(key, Duration.ofDays(7));
    }

    //failCount 가져오기
    private int getFailCount(NotificationEvent event) {
        String key = "fail:notification:" + event.getMsgSeq();
        String val = stringRedisTemplate.opsForValue().get(key);
        return val != null ? Integer.parseInt(val) : 0;
    }

    //failCount reset 처리
    private void resetFailCount(NotificationEvent event) {
        String key = "fail:notification:" + event.getMsgSeq();
        stringRedisTemplate.delete(key);
    }

    //재전송 일정 횟수 이상 시도 시 삭제처리
    private void moveToDeadLetter(NotificationEvent event) {
        redisTemplate.opsForList().rightPush("deadletter:notification", event);
    }

    //백업된 모든 메시지 가져오기
    public Set<String> getAllBackupKeys() {
        return redisTemplate.keys("backup:notification:*");
    }

    //이미 보낸 메시지인지 체크
    public boolean isAlreadySent(NotificationEvent event) {
        String key = "sent:notification:" + event.getMsgSeq();
        return Boolean.TRUE.equals(stringRedisTemplate.hasKey(key));
    }

    //메시지 전송했음을 기록 (중복처리 방지)
    public void markAsSent(NotificationEvent event) {
        String key = "sent:notification:" + event.getMsgSeq();
        stringRedisTemplate.opsForValue().set(key, "1", Duration.ofDays(7)); // 보존 기간 7일
    }
}