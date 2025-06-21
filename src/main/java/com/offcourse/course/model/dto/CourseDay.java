package com.offcourse.course.model.dto;

import lombok.*;

@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CourseDay {
    public String dayDays;
    public Long courseSeq;

    //요일 출력 메소드
    public String getDayName() {
        DayCode code = DayCode.fromCode(dayDays);
        return code != null ? code.getName() : "";
    }


}
