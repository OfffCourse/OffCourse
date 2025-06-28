package com.offcourse.attachment.model.dto;

import lombok.*;

import java.sql.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EpisodeAttachmentGroup {
    private Long episodeSeq;
    private Integer episodeCount; //1회차
    private Date episodeDate;
    private List<AttachmentViewResponse> attachments;
}

