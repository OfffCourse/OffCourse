/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 20.
  Time: 오후 4:39
*/
package com.offcourse.redis.model.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;

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
}