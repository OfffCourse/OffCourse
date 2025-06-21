package com.offcourse.notification.exception;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class NotificationUpdateMismatchException extends RuntimeException {
    public NotificationUpdateMismatchException(String message) {
        super(message);
    }
}
