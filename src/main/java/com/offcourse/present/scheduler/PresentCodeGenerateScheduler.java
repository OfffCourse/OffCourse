package com.offcourse.present.scheduler;

import com.offcourse.course.model.service.CourseService;
import com.offcourse.enrollment.model.service.EnrollmentService;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.dto.NotificationType;
import com.offcourse.notification.model.service.NotificationProducer;
import com.offcourse.redis.model.service.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Component
public class PresentCodeGenerateScheduler {
    private final RedisService redisService;
    private final NotificationProducer notificationProducer;
    private final CourseService courseService;
    private final EnrollmentService enrollmentService;

    /**
     * 강의별 출석 코드를 생성하는 스케줄러
     * 오전 9시마다 강의별 출석코드를 난수로 생성해서 Redis에 30분동안 저장
     * 강의 시작일 <= 오늘날짜 <= 강의 종료일인 강의 찾기
     * 해당 강의를 수강하고 있는 학생들에게 Kafka 메시지 전송
     */
//    @Scheduled(cron = "0 0 9 * * *")
    @Scheduled(cron = "0 0 * * * *")
    public void generatePresentCode() {
        int countStudents = 0;

        //오늘 수업 있는 강의 조회
        List<Long> courseSeqList = courseService.getCourseSeqsInProgress(LocalDate.now());
        for (Long courseSeq : courseSeqList) {
            //수강생 목록 조회
            List<Long> studentSeqList = enrollmentService.findStudentSeqsByCourseSeq(courseSeq);
            countStudents += studentSeqList.size();

            //출석 코드 생성(영문 + 숫자 6자리)
            String presentCode = generateRandomCode();

            //Redis 저장
            String key = "present:course:" + courseSeq;
            redisService.setValueWithTTL(key, presentCode, 1800);

            //Kafka 메시지 publish
            for (Long memberSeq : studentSeqList) {
                try {
                    notificationProducer.send(
                            NotificationEvent.builder()
                                    .memberSeq(memberSeq)
                                    .msgDate(new Timestamp(System.currentTimeMillis()))
                                    .msgType(NotificationType.ATTENDANCE_REQUEST)
                                    .redirectLocation(NotificationType.ATTENDANCE_REQUEST.getRedirectLocation() + courseSeq)
                                    .courseSeq(courseSeq)
                                    .build());
                } catch (Exception kafkaEx) {
                    log.error("⚠️ Kafka 알림 발송 실패 (회원가입): {}", kafkaEx.getMessage());
                }
            }
        }
        log.info("출석 코드 생성 총 {}개 강의, {}명 학생에게 알림 전송 완료", courseSeqList.size(), countStudents);
    }

    private String generateRandomCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 6; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }
}
