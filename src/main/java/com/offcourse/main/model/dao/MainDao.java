package com.offcourse.main.model.dao;

import com.offcourse.course.model.dto.CourseListResponse;
import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class MainDao {
    private final SqlSessionTemplate session;

    public List<CourseListResponse> getRecommendedCourses(List<String> categoryList) {
        return session.selectList("main.getRecommendedCourses", categoryList);
    }
}
