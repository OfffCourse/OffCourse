package com.offcourse.attachment.model.dto;

import lombok.*;

import java.sql.Date;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttachmentViewResponse {
    private Long attSeq;
    private String attOriName;
    private String attRenamedName;
    private String attType;
    private Long episodeSeq;
    private int episodeCount;
    private Date episodeDate;
}

