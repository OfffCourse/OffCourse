package com.offcourse.member.model.service;

public interface MailService {
    void sendEmail(String to, String subject, String text);
}
