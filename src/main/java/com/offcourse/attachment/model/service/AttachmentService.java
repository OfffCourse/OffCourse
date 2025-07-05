package com.offcourse.attachment.model.service;

import com.offcourse.attachment.model.dao.AttachmentDao;
import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.course.model.dto.Episode;
import com.offcourse.notification.model.dto.NotificationEvent;
import com.offcourse.notification.model.dto.NotificationType;
import com.offcourse.notification.model.service.EmitterService;
import com.offcourse.notification.model.service.NotificationProducer;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttachmentService {
    private final AttachmentDao dao;
    private final CourseDao courseDao;
    private final NotificationProducer notificationProducer;
    private final EmitterService emitterService;

    @Transactional
    public int insertAttachment(Attachment attachment) {
        return dao.insertAttachment(attachment);

    }

    public List<Episode> getEpisodeByCourseSeq(Long courseSeq, int cPage, int numPerPage) {
        return dao.getEpisodeByCourseSeq(courseSeq, cPage, numPerPage);
    }

    public List<Attachment> getAttachByEpisodeSeq(Long episodeSeq) {
        return dao.getAttachByEpisodeSeq(episodeSeq);
    }

    public List<Attachment> getVideoFile(Long episodeSeq) {
        return dao.getVideoFile(episodeSeq);
    }

    @Transactional
    public int deleteAttachmentBySeq(Long attachSeq) {
        return dao.deleteAttachmentBySeq(attachSeq);
    }

    public void sendVideoNotifications(Long courseSeq, Long episodeSeq) {
        List<Long> memberSeqList = dao.findMemberSeqListByEpisodeSeq(episodeSeq);
        for (Long memberSeq : memberSeqList) {
            try {
                notificationProducer.send(
                        NotificationEvent.builder()
                                .msgType(NotificationType.VIDEO_UPLOADED)
                                .redirectLocation(NotificationType.VIDEO_UPLOADED.getRedirectLocation() + courseSeq)
                                .memberSeq(memberSeq)
                                .courseSeq(courseSeq)
                                .msgDate(new Timestamp(System.currentTimeMillis()))
                                .build()
                );
            } catch (Exception kafkaEx) {
                log.error("⚠️ Kafka 알림 발송 실패 (영상 업로드): {}", kafkaEx.getMessage());
            }
        }
    }

    public void sendAttachNotifications(Long courseSeq, Long episodeSeq) {
        List<Long> memberSeqList = dao.findMemberSeqListByEpisodeSeq(episodeSeq);
        for (Long memberSeq : memberSeqList) {
            try {
                notificationProducer.send(
                        NotificationEvent.builder()
                                .msgType(NotificationType.MATERIAL_UPLOADED)
                                .redirectLocation(NotificationType.MATERIAL_UPLOADED.getRedirectLocation() + courseSeq)
                                .memberSeq(memberSeq)
                                .courseSeq(courseSeq)
                                .msgDate(new Timestamp(System.currentTimeMillis()))
                                .build()
                );
            } catch (Exception kafkaEx) {
                log.error("⚠️ Kafka 알림 발송 실패 (수업자료 업로드): {}", kafkaEx.getMessage());
            }
        }
    }
}
