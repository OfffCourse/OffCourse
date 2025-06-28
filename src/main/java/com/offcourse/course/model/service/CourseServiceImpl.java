package com.offcourse.course.model.service;

import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.course.model.dto.*;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

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

    @Override
    @Transactional
    public int insertCourse(Course course, List<String> courseDays) {
        int result = dao.insertCourse(course);
        Long courseSeq = course.getCourseSeq();

        if (result > 0 && !courseDays.isEmpty()) {
            for (String day : courseDays) {
                CourseDay cd = new CourseDay();
                cd.setCourseSeq(courseSeq);
                cd.setDayDays(day);
                dao.insertCourseDay(cd);
            }
        }

        if (result > 0) {
            LocalDate start = course.getCourseStartDate().toLocalDate();
            LocalDate end = course.getCourseEndDate().toLocalDate();

            List<DayOfWeek> days = courseDays.stream()
                    .map(DayCode::fromCode)
                    .filter(Objects::nonNull)
                    .map(DayCode::toDayOfWeek)
                    .collect(Collectors.toList());

            // 가능한 날짜 계산
            List<LocalDate> possibleDates = getEpisodeDates(start, end, days);

            int count = 1;
            for (LocalDate date : possibleDates) {
                Episode ep = new Episode();
                ep.setEpisodeCount(count++);
                ep.setEpisodeDate(Date.valueOf(date));
                ep.setCourseSeq(courseSeq);
                dao.insertEpisode(ep);
            }
        }
        return result;
    }

    @Override
    public long getCategorySeqByType(String categoryType) {
        return dao.getCategorySeqByType(categoryType);
    }

    @Override
    @Transactional
    public int updateCourse(Course course) {
        return dao.updateCourse(course);
    }

    @Override
    public CourseViewResponse getCourseBySeq(Long courseSeq) {
        return dao.getCourseBySeq(courseSeq);
    }

    @Override
    public boolean checkStudent(Map<String, Long> param) {
        return dao.checkStudent(param);
    }

    @Override
    public Teacher getTeacherBySeq(Long memberSeq) {
        return dao.getTeacherBySeq(memberSeq);
    }

    @Override
    public List<CourseListResponse> getCourseListByTeacher(Long memberSeq, int cPage, int numPerPage) {
        return dao.getCourseListByTeacher(memberSeq, cPage, numPerPage);
    }

    @Override
    public int getCourseCountByTeacher(Long memberSeq) {
        return dao.getCourseCountByTeacher(memberSeq);
    }

    @Override
    public List<Long> getCourseSeqsInProgress(LocalDate localDate) {
        return dao.getCourseSeqsInProgress(Date.valueOf(localDate));
    }

    @Override
    public List<CourseStudentDto> getCourseSeqsByEndDate(LocalDate localDate) {
        return dao.getCourseSeqsByEndDate(Date.valueOf(localDate));
    }

    @Override
    public int countEpisodeByCourseSeq(Long courseSeq) {
        return dao.countEpisodeByCourseSeq(courseSeq);
    }

    @Override
    public List<Episode> getEpisodeByCourseSeq(Long courseSeq) {
        return dao.getEpisodeByCourseSeq(courseSeq);
    }

    //날짜 계산용 메소드
    private List<LocalDate> getEpisodeDates(LocalDate start, LocalDate end,
                                            List<DayOfWeek> days) {
        List<LocalDate> result = new ArrayList<>();
        for (LocalDate date = start; !date.isAfter(end) && result.size() < Integer.MAX_VALUE; date = date.plusDays(1)) {
            if (days.contains(date.getDayOfWeek())) {
                result.add(date);
            }
        }
        return result;
    }
}
