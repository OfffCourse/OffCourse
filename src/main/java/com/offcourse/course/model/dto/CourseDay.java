package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CourseDay {
    public String dayDays;

    public String getDayName() {
        DayCode code = DayCode.fromCode(dayDays);
        return code != null ? code.getName() : "";
    }


}
