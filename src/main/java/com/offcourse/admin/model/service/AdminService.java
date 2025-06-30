package com.offcourse.admin.model.service;

import com.offcourse.acccount.model.dao.AccountDao;
import com.offcourse.admin.model.dto.AccountRequestAll;
import com.offcourse.admin.model.dto.DashboardStat;
import com.offcourse.admin.model.dto.HandleAccountRequest;
import com.offcourse.admin.model.dto.MemberAll;
import com.offcourse.course.model.dao.CourseDao;
import com.offcourse.deleterequest.model.dao.DeleteRequestDao;
import com.offcourse.deleterequest.model.dto.DeleteCourseRequestAll;
import com.offcourse.deleterequest.model.dto.DeleteRequestStatus;
import com.offcourse.enrollment.model.dao.EnrollmentDao;
import com.offcourse.member.model.dao.MemberDao;
import com.offcourse.payment.model.dao.PaymentHistoryDao;
import com.offcourse.payment.model.dto.PaymentHistory;
import com.offcourse.payment.model.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminService {
    private final DeleteRequestDao requestDao;
    private final AccountDao accountDao;
    private final MemberDao memberDao;
    private final CourseDao courseDao;
    private final EnrollmentDao enrollmentDao;
    private final PaymentHistoryDao paymentHistoryDao;
    private final PaymentService paymentService;

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

    public int countDeleteRequestAllByStatus(DeleteRequestStatus enumStatus) {
        return requestDao.countDeleteRequestAllByStatus(enumStatus);
    }

    @Transactional
    public boolean handleDeleteRequest(Long deleteRequestId, String action, Long courseSeq) {
        HashMap param = new HashMap();
        param.put("deleteRequestSeq", deleteRequestId);
        param.put("action", action);
        param.put("courseSeq", courseSeq);
        int result = requestDao.updateDeleteRequestStatus(param);
        if (result <= 0) {
            return false;
        }

        if (action.equals("approve")) {
            List<Long> enrSeqList = enrollmentDao.findEnrSeqsByCourseSeq(courseSeq);

            // enrSeqList가 null 이거나 empty면 상태변경 로직을 스킵
            if (enrSeqList != null && !enrSeqList.isEmpty()) {
                for (Long enrSeq : enrSeqList) {
                    PaymentHistory payment = paymentHistoryDao.selectByEnrSeq(enrSeq);
                    if (payment == null) {
                        throw new IllegalStateException("결제내역이 없는 수강신청 발견: enrSeq=" + enrSeq);
                    }
                    paymentService.refundPayment(payment.getPaymentSeq(), enrSeq, "강의 삭제로 인한 환불");
                }
            }
            int result2 = courseDao.deleteCourse(courseSeq);
            if (result2 == 0) {
                throw new IllegalStateException("삭제 요청 처리 실패");
            }
            return true;
        }
        return false;
    }

    public List<AccountRequestAll> getAccountRequestAll(Map param) {
        return accountDao.getAccountRequestAll(param);
    }

    public int countAccountRequestsAllByStatus(String status) {
        return accountDao.countAccountRequestsAllByStatus(status);
    }

    @Transactional
    public boolean handleAccountRequest(HandleAccountRequest handleAccountRequest) {
        return accountDao.updateAccountStatus(Map.of("accountSeq", handleAccountRequest.getAccountSeq(), "action", handleAccountRequest.getAction())) >0;
    }

    public long countMemberAll() {
        return memberDao.countMemberAll();
    }

    public long countTeacherAll() {
        return memberDao.countTeacherAll();
    }

    public List<MemberAll> getMemberAllByRole(Map param) {
        return memberDao.getMemberAllByRole(param);
    }

    public int countMemberAllByRole(Map param) {
        return memberDao.countMemberAllByRole(param);
    }
}
