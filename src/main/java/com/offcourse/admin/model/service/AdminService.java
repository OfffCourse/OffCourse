package com.offcourse.admin.model.service;

import com.offcourse.acccount.model.dao.AccountDao;
import com.offcourse.admin.model.dto.DashboardStat;
import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.deleterequest.model.dao.DeleteRequestDao;
import com.offcourse.deleterequest.model.dto.DeleteCourseRequestAll;
import com.offcourse.member.model.dao.MemberDao;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final DeleteRequestDao requestDao;
    private final AccountDao accountDao;
    private final MemberDao memberDao;
    private final CourseDao courseDao;

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

    public List<DeleteCourseRequestAll> getDeleteRequestAll(Map<String, Object> param) {
        return requestDao.getDeleteRequestAll(param);
    }

    public int countDeleteRequestAllByStatus(int status) {
        return requestDao.countDeleteRequestAllByStatus(status);
    }
}
