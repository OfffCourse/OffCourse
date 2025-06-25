package com.offcourse.attachment.model.dto;

import com.offcourse.course.model.dto.AttachmentViewResponse;
import lombok.*;

import java.sql.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EpisodeAttachmentGroup {
    private int episodeCount; // ex: 1회차
    private Date episodeDate;
    private List<AttachmentViewResponse> attachments;
}

