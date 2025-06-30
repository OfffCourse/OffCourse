package com.offcourse.admin.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MemberAll {
    private Long memberSeq;
    private String memberId;
    private String memberName;
    private String memberNickname;
    private String memberEmail;
    private String memberPhone;
    private String memberProfile;
    private String memberType;
    private Timestamp memberCreateTime;
}
