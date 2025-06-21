package com.offcourse.notification.controller;

import com.offcourse.member.model.dto.Member;
import com.offcourse.notification.exception.NotificationBatchUpdateException;
import com.offcourse.notification.exception.NotificationDeleteMismatchException;
import com.offcourse.notification.exception.NotificationUpdateMismatchException;
import com.offcourse.notification.model.dto.NotificationReadAllResponse;
import com.offcourse.notification.model.service.EmitterService;
import com.offcourse.notification.model.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/notifications")
public class NotificationController {
    private final EmitterService emitterService;
    private final NotificationService notificationService;

    // SSE 연결 (실시간 알림 구독)
    @GetMapping("/subscribe")
    public SseEmitter subscribe(Authentication authentication) {
        Member member = (Member) authentication.getPrincipal();
        return emitterService.connect(member.getMemberSeq());
    }

    // NoOffset 페이징 처리
    @GetMapping
    @ResponseBody
    public NotificationReadAllResponse getNotifications(
            Authentication authentication,
            @RequestParam(defaultValue = "all") String filter, // all, read, unread
            @RequestParam(required = false) Long lastMsgSeq,
            @RequestParam(defaultValue = "10") int size
    ) {
        return notificationService.getNotificationsNoOffset(((Member) authentication.getPrincipal()).getMemberSeq(), filter, lastMsgSeq, size);
    }

    // 전체 알림 읽음 처리
    @PostMapping("/read/all")
    public ResponseEntity<String> markAllAsRead(Authentication authentication) {
        notificationService.markAllAsRead(((Member) authentication.getPrincipal()).getMemberSeq());
        return ResponseEntity.ok("알림이 정상적으로 읽음 처리되었습니다.");
    }

    // 선택 알림 읽음 처리
    @PostMapping("/read/select")
    public ResponseEntity<String> markSelectedAsRead(@RequestBody List<Long> msgSeqList, Authentication authentication) {
        notificationService.markSelectedAsRead(((Member) authentication.getPrincipal()).getMemberSeq(), msgSeqList);
        return ResponseEntity.ok("알림이 정상적으로 읽음 처리되었습니다.");
    }

    // 선택된 알림들 삭제
    @DeleteMapping
    public ResponseEntity<String> deleteSelected(@RequestBody List<Long> msgSeqList) {
        notificationService.deleteSelectedNotifications(msgSeqList);
        return ResponseEntity.ok("알림이 정상적으로 삭제 처리되었습니다.");
    }

    // 예외 처리
    @ExceptionHandler(value = {NotificationBatchUpdateException.class, NotificationUpdateMismatchException.class, NotificationDeleteMismatchException.class})
    public ResponseEntity<String> failHandle(NotificationBatchUpdateException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
    }
}
