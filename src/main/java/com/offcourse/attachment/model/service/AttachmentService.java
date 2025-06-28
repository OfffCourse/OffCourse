package com.offcourse.attachment.model.service;

import com.offcourse.attachment.model.dao.AttachmentDao;
import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.attachment.model.dto.AttachmentViewResponse;
import com.offcourse.attachment.model.dto.EpisodeAttachmentGroup;
import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.course.model.dto.Episode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AttachmentService {

    private final AttachmentDao dao;
    private final CourseDao courseDao;

    @Transactional
    public int insertAttachment(Attachment attachment) {
        return dao.insertAttachment(attachment);
    }

    public List<EpisodeAttachmentGroup> getEpisodeAttachment(Long courseSeq) {
        List<AttachmentViewResponse> attachments = dao.getAttachments(courseSeq);
        List<Episode> episodes = courseDao.getEpisodeByCourseSeq(courseSeq);

        return episodes.stream()
                .map(e -> {
                    List<AttachmentViewResponse> matching = attachments.stream()
                            .filter(a -> a.getEpisodeSeq().equals(e.getEpisodeSeq()))
                            .collect(Collectors.toList());

                    return EpisodeAttachmentGroup.builder()
                            .episodeCount(e.getEpisodeCount())
                            .episodeDate(e.getEpisodeDate())
                            .attachments(matching)
                            .build();
                })
                .sorted(Comparator.comparingInt(EpisodeAttachmentGroup::getEpisodeCount))
                .collect(Collectors.toList());
    }


}
