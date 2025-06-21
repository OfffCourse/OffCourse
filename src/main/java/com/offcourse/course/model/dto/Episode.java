package com.offcourse.course.model.dto;

import lombok.*;

import java.sql.Date;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Episode {
    private Long episodeSeq;
    private Integer episodeCount;
    private Date episodeDate;
    private Long courseSeq;
}
