package com.offcourse.member.model.service;

import org.springframework.stereotype.Service;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;
import java.util.ResourceBundle;

@Service
public class MailServiceImpl implements MailService {

    private final String FROM;
    private final String APP_PASSWORD;

    public MailServiceImpl() {
        ResourceBundle bundle = ResourceBundle.getBundle("properties/application");
        this.FROM = bundle.getString("mail.username");
        this.APP_PASSWORD = bundle.getString("mail.password");
    }
    @Override
    public void sendEmail(String to, String subject, String text) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props,
                new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(FROM, APP_PASSWORD);
                    }
                });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(text);

            Transport.send(message);
            System.out.println("✅ 이메일 전송 성공!");

        } catch (MessagingException e) {
            e.printStackTrace();
            throw new RuntimeException("이메일 전송 실패", e);
        }
    }
}
