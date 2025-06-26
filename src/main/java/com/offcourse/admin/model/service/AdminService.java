package com.offcourse.admin.model.service;

import com.offcourse.acccount.model.dao.AccountDao;
import com.offcourse.admin.model.dto.DashboardStat;
import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.deleterequest.model.dao.DeleteRequestDao;
import com.offcourse.member.model.dao.MemberDao;
import com.offcourse.mypage.model.dto.DeleteCourseRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final DeleteRequestDao requestDao;
    private final AccountDao accountDao;
    private final MemberDao memberDao;
    private final CourseDao courseDao;

    public List<DeleteCourseRequest> getDeleteRequestAll() {
        return requestDao.getDeleteRequestAll();
    }

    public DashboardStat getDashboardStat() {
        long deleteCourseRequestCount = requestDao.countDeleteRequestAll();
        long accountRequestCount = accountDao.countAccountRequestAll();
        long memberCount = memberDao.countMemberAll();
        long inProgressCourseCount = courseDao.countInProgressCourseAll();
        return DashboardStat.builder()
                .deleteCourseRequestCount(deleteCourseRequestCount)
                .accountRequestCount(accountRequestCount)
                .memberCount(memberCount)
                .inProgressCourseCount(inProgressCourseCount)
                .build();
    }
}
