package com.offcourse.admin.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStat {
    private long deleteCourseRequestCount;
    private long accountRequestCount;
    private long memberCount;
    private long inProgressCourseCount;
}
