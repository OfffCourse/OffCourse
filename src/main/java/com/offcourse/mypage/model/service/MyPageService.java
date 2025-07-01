package com.offcourse.mypage.model.service;

import com.offcourse.course.model.service.CourseService;
import com.offcourse.mypage.model.dao.MyPageDao;
import com.offcourse.mypage.model.dto.Account;
import com.offcourse.mypage.model.dto.DeleteCourseRequest;
import com.offcourse.mypage.model.dto.StudentMyPageResponse;
import com.offcourse.mypage.model.dto.TeacherMyPageResponse;
import com.offcourse.present.model.service.PresentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class MyPageService {

    private final MyPageDao dao;
    private final CourseService courseService;
    private final PresentService presentService;

    public List<TeacherMyPageResponse> getMyPageByTeacher(Map<String, Object> param) {
        return dao.getMyPageByTeacher(param);
    }

    public int teacherCourseCount(long memberSeq) {
        return dao.teacherCourseCount(memberSeq);
    }

    @Transactional
    public int insertAccount(Account account) {
        return dao.insertAccount(account);
    }

    @Transactional
    public int updateAccount(Account account) {
        return dao.updateAccount(account);
    }

    @Transactional
    public int insertDeleteCourseRequest(DeleteCourseRequest request) {
        return dao.insertDeleteCourseRequest(request);
    }

    @Transactional
    public int updateDeleteCourseRequest(DeleteCourseRequest request) {
        return dao.updateDeleteCourseRequest(request);
    }

    public List<StudentMyPageResponse> getCurrentCoursesByStudent(Map<String, Object> param) {
        List<StudentMyPageResponse> courseList = dao.getCurrentCoursesByStudent(param);
        Long memberSeq = (Long) param.get("memberSeq");
        return getPresentRate(courseList, memberSeq);
    }

    public List<StudentMyPageResponse> getCompletedCoursesByStudent(Map<String, Object> param) {
        List<StudentMyPageResponse> courseList = dao.getCompletedCoursesByStudent(param);
        Long memberSeq = (Long) param.get("memberSeq");
        return getPresentRate(courseList, memberSeq);
    }

    public List<StudentMyPageResponse> getPendingCoursesByStudent(Map<String, Object> param) {
        List<StudentMyPageResponse> courseList = dao.getPendingCoursesByStudent(param);
        Long memberSeq = (Long) param.get("memberSeq");
        return getPresentRate(courseList, memberSeq);
    }

    private List<StudentMyPageResponse> getPresentRate(List<StudentMyPageResponse> courseList, Long memberSeq) {
        for (StudentMyPageResponse course : courseList) {
            Long courseSeq = course.getCourseSeq();
            int countEpisode = courseService.countEpisodeByCourseSeq(courseSeq);
            Map<String, Long> param=new HashMap<>();
            param.put("courseSeq",courseSeq);
            param.put("memberSeq",memberSeq);
            int countPresent = dao.countPresent(param);
            double presentRate = countEpisode == 0 ? 0 : ((double) countPresent / countEpisode) * 100;
            course.setPresentRate(presentRate);
        }
        return courseList;
    }

    public int countCurrentCoursesByStudent(Long memberSeq) {
        return dao.countCurrentCoursesByStudent(memberSeq);
    }

    public int countCompletedCoursesByStudent(Long memberSeq) {
        return dao.countCompletedCoursesByStudent(memberSeq);
    }

    public int countPendingCoursesByStudent(Long memberSeq) {
        return dao.countPendingCoursesByStudent(memberSeq);
    }

    public List<Timestamp> selectPresentTimestampsByCourse(Map<String, Long> param) {
        return dao.selectPresentTimestampsByCourse(param);
    }

    public List<StudentMyPageResponse> selectAttendanceCourses(Long memberSeq) {
        List<StudentMyPageResponse> courses = dao.selectAttendanceCourses(memberSeq);
        return getPresentRate(courses, memberSeq);
    }

}
