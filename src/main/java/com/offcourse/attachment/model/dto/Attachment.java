package com.offcourse.attachment.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Attachment {
    private Long attSeq;
    private String attOriName;
    private String attRenamedName;
    private String attType;
    private Long episodeSeq;
}
