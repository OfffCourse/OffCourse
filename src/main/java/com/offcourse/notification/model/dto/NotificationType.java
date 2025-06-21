package com.offcourse.notification.model.dto;

public enum NotificationType {

    /**
     * 강의 예약 및 결제 성공 알림
     */
    ENROLL_SUCCESS(
            "강의 예약 및 결제가 완료되었습니다.",
            "/mypage/enrollments"
    ),
    /**
     * 강의 환불 성공 알림
     */
    REFUND_SUCCESS(
            "강의 환불이 완료되었습니다.",
            "/mypage/payments"
    ),
    /**
     * 강의 시작 임박 알림
     */
    COURSE_START_REMINDER(
            "수강 예정인 강의가 곧 시작됩니다.",
            "/mypage/schedule"
    ),
    /**
     * 출석 인증 요청
     */
    ATTENDANCE_REQUEST(
            "출석 확인을 위해 인증 코드를 입력해주세요.",
            "/course/attendance"
    ),
    /**
     * 수료증 발급 알림
     */
    CERTIFICATE_ISSUED(
            "수료증이 발급되었습니다.",
            "/mypage/certificates"
    ),
    /**
     * 강의 삭제 요청 승인/반려 알림 (강사용)
     */
    DELETE_REQUEST_STATUS(
            "강의 삭제 요청 처리 결과를 확인하세요.",
            "/mypage/course-delete"
    );
    private final String msg;
    private final String redirectLocation;


    NotificationType(String msg, String redirectLocation) {
        this.msg = msg;
        this.redirectLocation = redirectLocation;
    }

    public String getMsg() {
        return msg;
    }

    public String getRedirectLocation() {
        return redirectLocation;
    }
}
