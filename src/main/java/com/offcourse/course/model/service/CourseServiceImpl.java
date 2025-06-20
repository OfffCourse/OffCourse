package com.offcourse.course.model.service;

import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.course.model.dto.CourseListResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private final CourseDao dao;

    @Override
    public List<CourseListResponse> courseList(Map<String, Integer> param) {
        return dao.courseList(param);
    }

    @Override
    public int courseCount() {
        return dao.courseCount();
    }
}
