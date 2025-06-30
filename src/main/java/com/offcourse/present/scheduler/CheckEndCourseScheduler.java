package com.offcourse.present.scheduler;

import com.offcourse.course.model.dto.CourseStudentDto;
import com.offcourse.course.model.service.CourseService;
import com.offcourse.enrollment.model.service.EnrollmentService;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.dto.NotificationType;
import com.offcourse.notification.model.service.NotificationProducer;
import com.offcourse.present.model.service.PresentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;

@Component
@Slf4j
@RequiredArgsConstructor
public class CheckEndCourseScheduler {
    private final NotificationProducer notificationProducer;
    private final CourseService courseService;
    private final EnrollmentService enrollmentService;
    private final PresentService presentService;

    /**
     * 수료증 발급 & 정산 스케줄러
     * 오전 3시마다 모든 강의 종료일자 체크 후 어제 날짜와 동일한 강의 찾기
     * 해당 강의 강사에게는 정산 요청 알림 전송
     * 해당 강의 수강생 중 80%이상 수강한 학생들에게는 수료증 발급 알림 전송하기
     */
    @Scheduled(cron = "0 0 3 * * *")
    public void checkEndCourse() {
        List<CourseStudentDto> courseList = courseService.getCourseSeqsByEndDate(LocalDate.now().minusDays(1));
        for (CourseStudentDto courseStudentDto : courseList) {
            Long teacherSeq = courseStudentDto.getMemberSeq();
            Long courseSeq = courseStudentDto.getCourseSeq();
            //강사 메시지 발행
            try {
                notificationProducer.send(NotificationEvent.builder()
                        .memberSeq(teacherSeq)
                        .msgDate(new Timestamp(System.currentTimeMillis()))
                        .msgType(NotificationType.ACCOUNT_AVAILABLE)
                        .redirectLocation(NotificationType.ACCOUNT_AVAILABLE.getRedirectLocation())
                        .courseSeq(courseSeq)
                        .build());
            } catch (Exception kafkaEx) {
                log.error("⚠️ Kafka 알림 발송 실패 (정산 신청): {}", kafkaEx.getMessage());
            }

            List<Long> studentSeqList = enrollmentService.findStudentSeqsByCourseSeq(courseSeq);
            int countEpisode = courseService.countEpisodeByCourseSeq(courseSeq);
            for (Long studentSeq : studentSeqList) {
                int countPresent = presentService.countPresentByCourseAndStudent(courseSeq, studentSeq);
                double presentRate = countEpisode == 0 ? 0 : ((double) countPresent / countEpisode) * 100;

                if (presentRate >= 80) {
                    if (enrollmentService.updateEnrollmentStatus(courseSeq, studentSeq, "2")) {
                        try {
                            notificationProducer.send(NotificationEvent.builder()
                                    .courseSeq(courseSeq)
                                    .memberSeq(studentSeq)
                                    .msgType(NotificationType.CERTIFICATE_ISSUED)
                                    .redirectLocation(NotificationType.CERTIFICATE_ISSUED.getRedirectLocation())
                                    .msgDate(new Timestamp(System.currentTimeMillis()))
                                    .build());
                        } catch (Exception kafkaEx) {
                            log.error("⚠️ Kafka 알림 발송 실패 (수료증 발급): {}", kafkaEx.getMessage());
                        }
                    }
                } else {
                    enrollmentService.updateEnrollmentStatus(courseSeq, studentSeq, "3");
                }
            }
        }
    }
}
