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

        // size + 1 로 요청하여 다음 페이지 여부 확인
        int querySize = size + 1;

        switch (filter.toLowerCase()) {
            case "read":
                events = notificationRepository.findReadNotificationNoOffset(memberSeq, lastMsgSeq, querySize);
                break;
            case "unread":
                events = notificationRepository.findUnreadNotificationNoOffset(memberSeq, lastMsgSeq, querySize);
                break;
            case "all":
            default:
                events = notificationRepository.findAllNotificationNoOffset(memberSeq, lastMsgSeq, querySize);
                break;
        }

        // isLast 판단: 데이터가 size 초과로 왔으면 다음 페이지 있음
        boolean isLast = events.size() <= size;

        // 실제로 응답할 리스트는 최대 size 개까지만
        List<NotificationEvent> trimmedList = events.size() > size ? events.subList(0, size) : events;

        int total = notificationRepository.countNotificationAllByMemberSeq(memberSeq);
        int read = notificationRepository.countReadNotificationAllByMemberSeq(memberSeq);
        int unread = total - read;

        Long nextLastMsgSeq = trimmedList.isEmpty() ? null : trimmedList.get(trimmedList.size() - 1).getMsgSeq();

        return NotificationReadAllResponse.builder()
                .notificationEventList(trimmedList)
                .totalReadNotificationCount(read)
                .totalUnreadNotificationCount(unread)
                .totalNotificationCount(total)
                .lastMsgSeq(nextLastMsgSeq)
                .isLast(isLast)
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
    public void markSelectedAsRead(List<Long> msgSeqList) {
        int count = notificationRepository.countUnreadNotificationByMsgSeqs(msgSeqList);
        notificationRepository.markSelectedAsRead(msgSeqList,count);
    }

    @Transactional
    public void deleteSelectedNotifications(List<Long> msgSeqList) {
        notificationRepository.deleteSelectedNotifications(msgSeqList);
    }
}
