package com.offcourse.mypage.model.service;

import com.offcourse.mypage.model.dao.MyPageDao;
import com.offcourse.mypage.model.dto.TeacherMyPageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MyPageService {

    private final MyPageDao dao;

    public List<TeacherMyPageResponse> getMyPageByTeacher(Map<String,Object> param){
        return dao.getMyPageByTeacher(param);
    }

    public int teacherCourseCount(long memberSeq){
        return dao.teacherCourseCount(memberSeq);
    }
}
