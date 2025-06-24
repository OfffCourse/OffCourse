package com.offcourse.notification.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationEvent {
    private Long msgSeq;
    private Timestamp msgDate;
    private Timestamp msgReadTime;
    private NotificationType msgType; //Location + Msg
    private String redirectLocation;
    private Long memberSeq;
    private Long courseSeq;
}
