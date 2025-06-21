package com.offcourse.notification.model.dao;

import org.springframework.stereotype.Repository;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class EmitterRepository {
    //SSE 연결 상태를 관리하는 임시저장소로 DB에 직접 저장 X 
    //ConcurrentHashMap을 쓰는 이유 => 동시에 여러 사용자가 연결 요청을 보내므로, 멀티스레드 환경에서 안전하게 접근할 수 있는 Map이 필요
    //ConcurrentHashMap은 락 분할 구조로 되어 있어 성능도 좋고 병렬성도 보장
    //DB에 저장하지 않는 이유 => SSE 연결은 끊기기 쉽고 짧은 생명주기기에 DB에 저장하기엔 부적합하고 객체를 DB에 저장하기에는 좋지않음, DB에 넣고 빼면 오히려 오버헤드 발생
    private final Map<Long, SseEmitter> emitters = new ConcurrentHashMap<>();

    public void save(Long memberSeq, SseEmitter emitter) {
        emitters.put(memberSeq, emitter);
    }

    public SseEmitter get(Long memberSeq) {
        return emitters.get(memberSeq);
    }

    public void delete(Long memberSeq) {
        emitters.remove(memberSeq);
    }

    public boolean exists(Long memberSeq) {
        return emitters.containsKey(memberSeq);
    }

    public Map<Long, SseEmitter> findAll() {
        return emitters;
    }
}
