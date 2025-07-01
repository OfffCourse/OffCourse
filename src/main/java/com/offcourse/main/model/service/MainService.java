package com.offcourse.main.model.service;

import com.offcourse.course.model.dto.CourseListResponse;
import com.offcourse.main.model.dao.MainDao;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MainService {
    private final MainDao dao;

    public List<CourseListResponse> getRecommendedCourses(List<String> categoryList) {
        return dao.getRecommendedCourses(categoryList);
    }
}
