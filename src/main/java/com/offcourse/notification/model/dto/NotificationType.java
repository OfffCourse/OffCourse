package com.offcourse.notification.model.dto;

public enum NotificationType {

    /**
     * 회원가입 일반회원
     * 강의 리스트 페이지로 이동
     */
    STUDENT_JOIN_SUCCESS(
            "회원가입이 성공적으로 완료되었습니다. 원하는 강의를 찾아보세요",
            "/course/listpage"
    ),

    /**
     * 회원가입 강사회원
     * 강사 마이페이지로 이동
     */
    TEACHER_JOIN_SUCCESS(
            "회원가입이 성공적으로 완료되었습니다. 원하는 강의를 등록해보세요",
            "/mypage/teacher"
    ),

    /**
     * 수강신청 및 결제 성공 알림
     * 학생용 마이페이지 중 수강 신청 내역 페이지
     */
    ENROLL_SUCCESS(
            "수강신청 및 결제가 완료되었습니다.",
            "/mypage/student"
    ),

    /**
     * 강의 환불 성공 알림
     * 학생용 마이페이지중 수강 신청 내역로 이동
     */
    REFUND_SUCCESS(
            "강의 환불이 완료되었습니다.",
            "/mypage/student"
    ),

    /**
     * 출석 인증 요청 => 스케쥴러로 출석코드만듦과 동시에 하기 각 강의별 출석코드 별도로 레디스에 저장
     * 해당 강의 상세페이지
     */
    ATTENDANCE_REQUEST(
            "출석 확인을 위해 인증 코드를 입력해주세요.",
            "/course/view?courseSeq="
    ),

    /**
     * 수료증 발급 알림 => 출석 코드를 만드는 스케줄러에서 강의 종료일 비교해서 가져오고 끝난 강의 학생 중 80%이상인 사람 가져와서 알림 뿌려주기
     * 학생용 마이페이지중 수강 신청 내역로 이동
     */
    CERTIFICATE_ISSUED(
            "수료증이 발급되었습니다.",
            "/mypage/student"
    ),

    /**
     * 정산 신청 가능 알림 (정산 가능 조건 충족 시)
     * 강사 마이페이지 > 정산 신청
     */
    ACCOUNT_AVAILABLE(
            "정산 신청이 가능합니다. 지금 신청하세요.",
            "/mypage/teacher?section=settlement"
    ),

    /**
     * 강의 자료 업로드 알림 (교재 등)
     * 해당 강의 상세페이지
     */
    MATERIAL_UPLOADED(
            "강의 자료가 새로 등록되었습니다.",
            "/course/view?courseSeq="
    ),

    /**
     * 강의 영상 업로드 알림
     * 해당 강의 상세페이지
     */
    VIDEO_UPLOADED(
            "새로운 강의 영상이 업로드되었습니다.",
            "/course/view?courseSeq="
    ),


    /**
     * 강의 삭제 요청 승인/반려 알림 (강사용)
     * 강사한테만 강사 마이페이지로 이동
     */
    DELETE_REQUEST_STATUS(
            "강의 삭제 요청 처리 결과를 확인하세요.",
            "/mypage/teacher?section=manage-courses"
    );


    private final String msg;
    private final String redirectLocation;
    private static final String PATH = "/offcourse";

    NotificationType(String msg, String redirectLocation) {
        this.msg = msg;
        this.redirectLocation = PATH + redirectLocation;
    }

    public String getMsg() {
        return msg;
    }

    public String getRedirectLocation() {
        return redirectLocation;
    }
}
