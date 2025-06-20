/*
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 20.
  Time: 오후 4:44
*/
package com.offcourse.redis.controller;


import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/redis")
@RequiredArgsConstructor
public class RedisController {

    private final RedisService redisService;

    @GetMapping("/test")
    public String testRedis() {
        // 기본 테스트
        redisService.setValue("test-key", "Hello Redis!");
        String value = redisService.getValue("test-key");

        return "Redis 테스트 결과: " + value;
    }

    @PostMapping("/set/{key}/{value}")
    public String setValue(@PathVariable String key, @PathVariable String value) {
        redisService.setValue(key, value);
        return "저장 완료: " + key + " = " + value;
    }

    @GetMapping("/get/{key}")
    public String getValue(@PathVariable String key) {
        String value = redisService.getValue(key);
        return value != null ? value : "키를 찾을 수 없습니다.";
    }

    @PostMapping("/list/{key}/{value}")
    public String addToList(@PathVariable String key, @PathVariable String value) {
        redisService.addToList(key, value);
        return "리스트에 추가: " + value;
    }

    @GetMapping("/list/{key}")
    public List<String> getList(@PathVariable String key) {
        return redisService.getList(key);
    }
}