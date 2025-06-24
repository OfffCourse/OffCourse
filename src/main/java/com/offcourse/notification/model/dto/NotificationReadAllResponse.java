package com.offcourse.notification.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
public class NotificationReadAllResponse {
    private List<NotificationEvent> notificationEventList;
    private int totalNotificationCount;
    private int totalReadNotificationCount;
    private int totalUnreadNotificationCount;
    private Long lastMsgSeq;
    private boolean isLast;
}
