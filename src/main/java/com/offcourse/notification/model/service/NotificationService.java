package com.offcourse.notification.model.service;

import com.offcourse.notification.exception.NotificationUpdateMismatchException;
import com.offcourse.notification.model.dao.NotificationRepository;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.dto.NotificationReadAllResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final EmitterService emitterService;
    private final NotificationRepository notificationRepository;

    @Transactional
    public void processNotification(NotificationEvent event) {
        //DB 저장 후 사용자에게 실시간 전송
        int result = notificationRepository.insertNotification(event);
        if (result > 0) {
            emitterService.sendToUser(event);
        }
    }

    public NotificationReadAllResponse getNotificationsNoOffset(Long memberSeq, String filter, Long lastMsgSeq, int size) {
        List<NotificationEvent> events;

        switch (filter.toLowerCase()) {
            case "read":
                events = notificationRepository.findReadNotificationNoOffset(memberSeq, lastMsgSeq, size);
                break;
            case "unread":
                events = notificationRepository.findUnreadNotificationNoOffset(memberSeq, lastMsgSeq, size);
                break;
            case "all":
            default:
                events = notificationRepository.findAllNotificationNoOffset(memberSeq, lastMsgSeq, size);
                break;
        }

        int total = notificationRepository.countNotificationAllByMemberSeq(memberSeq);
        int read = notificationRepository.countReadNotificationAllByMemberSeq(memberSeq);
        int unread = total - read;

        return NotificationReadAllResponse.builder()
                .notificationEventList(events)
                .totalReadNotificationCount(read)
                .totalUnreadNotificationCount(unread)
                .totalNotificationCount(total)
                .build();
    }

    @Transactional
    public void markAllAsRead(Long memberSeq) {
        int count = notificationRepository.countUnreadNotificationAllByMemberSeq(memberSeq);
        int result = notificationRepository.markAllAsRead(memberSeq);
        if (count != result) {
            throw new NotificationUpdateMismatchException("실제 읽음 처리된 알림 수와 예상 알림 수가 다릅니다.");
        }
    }

    @Transactional
    public void markSelectedAsRead(Long memberSeq, List<Long> msgSeqList) {
        int count = notificationRepository.countUnreadNotificationAllByMemberSeq(memberSeq);
        notificationRepository.markSelectedAsRead(msgSeqList, count);
    }

    @Transactional
    public void deleteSelectedNotifications(List<Long> msgSeqList) {
        notificationRepository.deleteSelectedNotifications(msgSeqList);
    }
}
