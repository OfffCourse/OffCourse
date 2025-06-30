package com.offcourse.admin.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MemberAllResponse {
    private List<MemberAll> memberAllList;
    private String pageBar;
}
