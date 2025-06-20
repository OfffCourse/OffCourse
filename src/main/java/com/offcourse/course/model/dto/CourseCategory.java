package com.offcourse.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CourseCategory {
    private String categoryType;
    private Long categoryParentSeq;
    private String parentCategoryType;

    //카테고리 출력 메소드
    public String getFullCategoryName() {
        return parentCategoryType != null
                ? parentCategoryType + " - " + categoryType
                : categoryType;
    }
}
