package com.offcourse.course.model.service;

import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.course.model.dto.CourseListResponse;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private final CourseDao dao;

    @Override
    public List<CourseListResponse> getCourseList(Map<String, Object> param, RowBounds rb) {
        return dao.getCourseList(param, rb);
    }

    @Override
    public int getCourseListCount(Map<String, Object> param) {
        return dao.getCourseListCount(param);
    }
}
