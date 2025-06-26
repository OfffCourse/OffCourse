package com.offcourse.attachment.model.service;

import com.offcourse.attachment.model.dao.AttachmentDao;
import com.offcourse.attachment.model.dto.Attachment;
import com.offcourse.attachment.model.dto.EpisodeAttachmentGroup;
import com.offcourse.course.model.dto.AttachmentViewResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.AbstractMap;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AttachmentService {

    private final AttachmentDao dao;

    @Transactional
    public int insertAttachment(Attachment attachment) {
        return dao.insertAttachment(attachment);
    }

    public List<EpisodeAttachmentGroup> getEpisodeAttachment(Long courseSeq){
        List<AttachmentViewResponse> all = dao.getAttachments(courseSeq);
        return all.stream()
                .collect(Collectors.groupingBy(att -> new AbstractMap.SimpleEntry<>(att.getEpisodeCount(), att.getEpisodeDate())))
                .entrySet().stream()
                .map(entry -> EpisodeAttachmentGroup.builder()
                        .episodeCount(entry.getKey().getKey())
                        .episodeDate(entry.getKey().getValue())
                        .attachments(entry.getValue())
                        .build())
                .sorted(Comparator.comparingInt(EpisodeAttachmentGroup::getEpisodeCount))
                .collect(Collectors.toList());
    }

}
