<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Off Course - 오프라인 강의 예약</title>
    <!-- jQuery library -->
    <script src="${pageContext.request.contextPath}/resources/js/jquery-3.7.1.min.js"></script>

    <!-- Popper JS -->
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">

    <!-- Latest compiled JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css"/>

    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js"></script>

    <style>
        /* 알림 버튼 스타일 */
        .notification-wrapper {
            position: relative;
            display: inline-block;
            margin-right: 15px;
        }

        .notification-btn {
            background: none;
            border: none;
            color: #333;
            font-size: 18px;
            padding: 8px;
            border-radius: 50%;
            transition: all 0.3s ease;
            position: relative;
        }

        .notification-btn:hover {
            background-color: #f8f9fa;
            color: #007bff;
        }

        /* body 스크롤 잠금용 클래스 */
        .body-no-scroll {
            overflow: hidden;
        }

        .notification-spacer {
            height: 40px;
            pointer-events: none;
            background: transparent;
        }

        /* 헤더 종 아이콘용 뱃지 (작은 빨간 점) */
        .notification-badge.icon {
            position: absolute;
            top: -6px;
            right: -6px;
            background-color: #dc3545;
            color: white;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            font-size: 11px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            min-width: 18px;
            z-index: 10;
        }

        .notification-list {
            margin-bottom: 100px;
        }

        /* 알림 모달 제목 옆용 뱃지 */
        .notification-badge.title {
            position: static;
            background-color: #dc3545;
            color: white;
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 12px;
            font-weight: bold;
        }

        .notification-title-wrapper {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .notification-count-badge {
            display: inline-block;
            padding: 4px 10px;
            background: linear-gradient(135deg, #ff416c, #ff4b2b); /* 그라데이션 배경 */
            color: white;
            font-weight: bold;
            font-size: 13px;
            border-radius: 999px;
            box-shadow: 0 2px 6px rgba(255, 75, 43, 0.5);
            animation: pop-in 0.3s ease-in-out;
        }

        /* 간단한 등장 애니메이션 */
        @keyframes pop-in {
            from {
                opacity: 0;
                transform: scale(0.7);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }


        /* 알림 모달 스타일 */
        .notification-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1050;
        }

        .notification-modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 500px;
            max-height: 80vh;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .notification-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #e9ecef;
            background-color: #f8f9fa;
        }

        .notification-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin: 0;
        }

        .notification-close {
            background: none;
            border: none;
            font-size: 24px;
            color: #6c757d;
            cursor: pointer;
            padding: 0;
        }

        .notification-close:hover {
            color: #333;
        }

        .notification-tabs {
            display: flex;
            border-bottom: 1px solid #e9ecef;
            background-color: white;
        }

        .notification-tab {
            flex: 1;
            padding: 12px 16px;
            text-align: center;
            background: none;
            border: none;
            cursor: pointer;
            color: #6c757d;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .notification-tab.active {
            color: #007bff;
            border-bottom: 2px solid #007bff;
            background-color: #f8f9fa;
        }

        .notification-body {
            max-height: 400px;
            overflow-y: auto;
            padding: 0 0 12px 0; /* ⬅️ 하단 여백 추가 */
        }

        .notification-controls {
            padding: 15px 20px;
            border-bottom: 1px solid #e9ecef;
            background-color: #f8f9fa;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .notification-select-all {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .notification-actions {
            display: flex;
            gap: 10px;
        }

        .notification-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .notification-item {
            display: flex;
            align-items: flex-start;
            padding: 16px 20px;
            border-bottom: 1px solid #f1f3f4;
            transition: background-color 0.2s ease;
            cursor: pointer;
            min-height: 60px;
            pointer-events: auto !important;
            z-index: 9999 !important;
        }

        .notification-item:hover {
            background-color: #f8f9fa;
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .notification-item.unread {
            background-color: #f0f8ff;
            border-left: 3px solid #007bff;
        }

        .notification-checkbox {
            margin-right: 12px;
            margin-top: 2px;
            cursor: pointer;
            z-index: 10;
        }

        .notification-icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 12px;
            margin-top: 2px;
            flex-shrink: 0;
        }

        .notification-icon.info {
            background-color: #e3f2fd;
            color: #1976d2;
        }

        .notification-icon.warning {
            background-color: #fff3e0;
            color: #f57c00;
        }

        .notification-icon.success {
            background-color: #e8f5e8;
            color: #388e3c;
        }

        .notification-icon.error {
            background-color: #ffebee;
            color: #d32f2f;
        }

        .notification-content {
            flex: 1;
            min-width: 0;
        }

        .notification-message {
            font-size: 14px;
            color: #333;
            margin: 0 0 4px 0;
            line-height: 1.4;
        }

        .notification-time {
            font-size: 12px;
            color: #6c757d;
            margin: 0;
        }

        .notification-status {
            display: inline-block;
            padding: 3px 8px;
            font-size: 12px;
            font-weight: bold;
            border-radius: 999px;
            text-transform: uppercase;
            margin-left: 10px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .notification-status.unread {
            background: linear-gradient(135deg, #ff416c, #ff4b2b);
            color: white;
            animation: pulse 1.2s infinite;
        }

        .notification-status.read {
            background-color: #adb5bd;
            color: white;
        }

        @keyframes pulse {
            0% {
                transform: scale(1);
                box-shadow: 0 0 0 0 rgba(255, 65, 108, 0.7);
            }
            70% {
                transform: scale(1.05);
                box-shadow: 0 0 0 10px rgba(255, 65, 108, 0);
            }
            100% {
                transform: scale(1);
                box-shadow: 0 0 0 0 rgba(255, 65, 108, 0);
            }
        }

        /* [추가 상태 예시] */
        .notification-status.error {
            background-color: #d32f2f;
            color: white;
        }

        .notification-status.system {
            background-color: #6c757d;
            color: white;
        }

        .notification-status.info {
            background-color: #17a2b8;
            color: white;
        }

        .notification-empty {
            text-align: center;
            padding: 40px 20px;
            color: #6c757d;
        }

        .loading-spinner {
            text-align: center;
            padding: 20px;
            display: none;
        }

        .btn-sm-custom {
            font-size: 11px;
            border-radius: 20px;
            font-weight: 500;
            line-height: 0.6;
        }

        /* 읽음 처리 버튼 - 남색 */
        .btn-navy {
            background-color: #162A46;
            color: white;
            border: none;
        }

        .btn-navy:hover {
            background-color: #0f1c30;
            color: white;
        }

        /* 삭제 버튼 - 회색 */
        .btn-gray {
            background-color: #6c757d;
            color: white;
            border: none;
        }

        .btn-gray:hover {
            background-color: #5a6268;
            color: white;
        }

    </style>
</head>
<body>
<c:if test="${not empty msg}">
<script>
    alert("${msg}");
</script>
</c:if>

<!-- Header -->
<header class="hc-header">
    <div class="hc-header-container">
        <a href="${path}" class="hc-logo"><img src="${path}/resources/images/logo.png" alt="Off Course" width="50px"
                                               height="50px">Off Course</a>
        <!-- Search Section -->
        <section class="search-section">
            <div class="hc-search-container">
                <form id="headerSearchForm" class="hc-search-form"
                      action="${pageContext.request.contextPath}/course/listpage" method="GET">
                    <input type="text" name="courseTitle" class="hc-search-input" placeholder="관심있는 강의를 검색해보세요">
                    <button class="hc-btn hc-btn-outline">검색</button>
                </form>
            </div>
        </section>
        <nav>
            <ul class="hc-nav-menu">
                <li><a href="${pageContext.request.contextPath}/course/listpage">강의</a></li>
            </ul>
        </nav>

        <!-- 로그인 상태에 따른 헤더 표시 -->
        <div class="hc-header-actions">
            <!-- 로그인한 사용자에게만 알림 버튼 표시 -->
            <sec:authorize access="isAuthenticated()">
                <div class="notification-wrapper">
                    <button class="notification-btn" id="notificationBtn">
                        <i class="fas fa-bell"></i>
                        <span class="notification-badge icon" id="notificationBadge" style="display: none;">0</span>
                    </button>
                </div>
            </sec:authorize>

            <c:choose>
                <%-- 로그인 안 된 경우 --%>
                <c:when test="${empty loginMember}">
                    <a href="${path}/member/loginform" class="hc-btn hc-btn-outline">로그인</a>
                    <button onclick="location.assign('${path}/member/enroll/select')"
                            class="hc-btn btn-link text-muted small align-self-center">회원가입
                    </button>
                </c:when>

                <%-- 로그인 된 경우 --%>
                <c:otherwise>
                    <span class="welcome-msg font-weight-bold mr-2">${loginMember.memberNickname}님,<br> 환영합니다!</span>
                    <c:choose>
                        <c:when test='${loginMember.memberId eq "admin" }'>
                            <a href="${path}/admin/listpage" class="hc-btn hc-btn-primary mr-2">관리자페이지</a>
                        </c:when>
                        <%-- 일반과 강사회원의 마이페이지 주소 다르게 --%>
                        <c:when test="${loginMember.memberType == '0'}">
                            <a href="${path}/mypage/student" class="hc-btn hc-btn-primary mr-2">마이페이지</a>
                        </c:when>
                        <c:when test="${loginMember.memberType == '1'}">
                            <a href="${path}/mypage/teacher" class="hc-btn hc-btn-primary mr-2">마이페이지</a>
                        </c:when>
                    </c:choose>
                    <%--<a href="${path}/member/logout" class="text-muted small align-self-center"
                       style="margin-top: 4px;">로그아웃</a>
                    <c:set var="_csrf" value="${_csrf}" />--%>
                    <form id="logoutForm" action="${path}/member/logout" method="post" style="display:inline;">
                            <%--
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                    csrf 를 끄면 get 방식으로도 로그아웃이 되긴 되지만, 추후에 csrf 기능도 키려면,
                                                    post 방식으로 로그아웃을 보내야 security-context 에서도 받아내고 로그아웃을 시켜줌
                            --%>
                        <button type="submit" class="hc-btn btn-link text-muted small align-self-center">로그아웃
                        </button>
                    </form>

                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
<!-- 알림 모달 -->
<sec:authorize access="isAuthenticated()">
<div class="notification-modal" id="notificationModal">
    <div class="notification-modal-content">
        <div class="notification-header">
            <div class="notification-title-wrapper">
                <h5 class="notification-title">알림</h5>
                <span class="notification-count-badge" id="modalNotificationBadge" style="display: none;">12</span>
            </div>
            <button class="notification-close" id="notificationModalClose">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <div class="notification-tabs">
            <button class="notification-tab active" data-filter="all">전체 (<span id="totalCount">0</span>)</button>
            <button class="notification-tab" data-filter="unread">읽지 않음 (<span id="unreadCount">0</span>)</button>
            <button class="notification-tab" data-filter="read">읽음 (<span id="readCount">0</span>)</button>
        </div>

        <div class="notification-controls">
            <div class="notification-select-all">
                <input type="checkbox" id="selectAllCheckbox">
                <label for="selectAllCheckbox">전체 선택</label>
            </div>
            <div class="notification-actions">
                <button class="hc-btn btn-sm-custom btn-navy" id="markSelectedReadBtn">읽음 처리</button>
                <button class="hc-btn btn-sm-custom btn-gray" id="deleteSelectedBtn">삭제</button>
            </div>
        </div>

        <div class="notification-body">
            <ul class="notification-list" id="notificationList">
                <!-- 알림 항목들이 여기에 동적으로 추가됩니다 -->
            </ul>
            <div class="loading-spinner" id="loadingSpinner">
                <i class="fas fa-spinner fa-spin"></i> 로딩 중...
            </div>
            <div class="notification-empty" id="notificationEmpty" style="display: none;">
                알림이 없습니다.
            </div>
        </div>
    </div>
</div>
</sec:authorize>
<div id="test" style="margin-bottom: 120px"></div>
<script>

    (function () {
        // URL에서 세션 관련 파라미터 제거
        const cleanUrl = () => {
            const url = new URL(window.location);

            // sessionId 파라미터 제거
            url.searchParams.delete('sessionId');
            url.searchParams.delete('jsessionid');

            // URL에 ;jsessionid= 패턴이 있으면 제거
            let cleanPath = url.pathname.replace(/;jsessionid=[^?\/]*/g, '');

            // URL이 변경되었으면 히스토리 교체
            if (url.pathname !== cleanPath || url.searchParams.has('sessionId') || url.searchParams.has('jsessionid')) {
                const newUrl = cleanPath + (url.search ? url.search : '');
                window.history.replaceState({}, document.title, newUrl);
            }
        };

        // 페이지 로드 시 실행
        cleanUrl();

        // 모든 링크에 대해 세션 파라미터 제거
        document.addEventListener('click', function (e) {
            const link = e.target.closest('a');
            if (link && link.href) {
                const url = new URL(link.href);
                if (url.searchParams.has('sessionId') || url.searchParams.has('jsessionid')) {
                    e.preventDefault();
                    url.searchParams.delete('sessionId');
                    url.searchParams.delete('jsessionid');
                    window.location.href = url.toString();
                }
            }
        });
    })();

    let selectedNotifications = new Set();

    // 알림 목록 리셋 함수 수정
    function resetNotificationList() {
        console.log('🔄 알림 목록 리셋');
        $('#notificationList').empty();
        $('#notificationEmpty').hide();
        $('#loadingSpinner').hide();

        // ✅ 상태 완전 초기화
        lastMsgSeq = null;
        hasMoreData = true;
        isLoading = false;

        selectedNotifications.clear();
        updateSelectAllCheckbox();

        console.log('✅ 리셋 완료: lastMsgSeq=', lastMsgSeq, 'hasMoreData=', hasMoreData, 'isLoading=', isLoading);
    }

    let currentFilter = 'all';
    let lastMsgSeq = null;
    let isLoading = false;
    let hasMoreData = true;
    let eventSource = null;

    /* 대기열 Heartbeat */
    class QueueHeartbeatManager {
        constructor() {
            this.heartbeatInterval = null;
            this.isActive = true;
            this.failCount = 0;
            this.maxFailCount = 3;
            this.contextPath = window.location.pathname.split('/')[1] ? '/' + window.location.pathname.split('/')[1] : '';

            this.init();
        }

        init() {
            this.startHeartbeat();

            // Visibility API로 탭 상태 감지
            document.addEventListener('visibilitychange', () => {
                if (document.visibilityState === 'visible') {
                    this.resumeHeartbeat();
                } else {
                    this.pauseHeartbeat();
                }
            });

            // 페이지 이탈 시 정리
            window.addEventListener('beforeunload', () => {
                this.stopHeartbeat();
                this.sendLeaveSignal();
            });
        }

        startHeartbeat() {
            if (this.heartbeatInterval) return;

            // 45초마다 heartbeat 전송
            this.heartbeatInterval = setInterval(() => {
                this.sendHeartbeat();
            }, 450000);

            console.log('활성 사용자 Heartbeat 시작 (45초 간격)');
        }

        pauseHeartbeat() {
            if (this.heartbeatInterval) {
                clearInterval(this.heartbeatInterval);
                this.heartbeatInterval = null;
            }
            console.log('Heartbeat 일시중지');
        }

        resumeHeartbeat() {
            this.startHeartbeat();
            // 즉시 한 번 전송
            this.sendHeartbeat();
            console.log('Heartbeat 재시작');
        }

        stopHeartbeat() {
            if (this.heartbeatInterval) {
                clearInterval(this.heartbeatInterval);
                this.heartbeatInterval = null;
            }
            console.log('Heartbeat 중지');
        }

        async sendHeartbeat() {
            if (!this.isActive) return;

            try {
                const response = await fetch(this.contextPath + '/queue/heartbeat', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    signal: AbortSignal.timeout(5000)
                });

                if (response.ok) {
                    const data = await response.json();
                    this.failCount = 0; // 성공 시 실패 카운트 리셋

                    console.log('Header Heartbeat 성공');

                    // 정상: ALLOW 상태 유지 (활성 사용자가 계속 서비스 이용)
                    if (data.queueStatus === 'ALLOW') {
                        console.log('활성 상태 유지 - 세션 연장됨');
                        // 아무 액션 없음, 계속 서비스 이용
                    }
                    // 예외: 갑자기 대기열 상태로 변경됨 (관리자 액션, 세션 만료 등)
                    else if (data.queueStatus === 'WAITING') {
                        console.log('예외 상황: 활성 사용자가 대기열로 변경됨');
                        console.log('원인: 관리자 액션, 세션 만료, 또는 시스템 오류');
                        alert('세션이 만료되거나 시스템 상태가 변경되었습니다. 대기열로 이동합니다.');
                        this.redirectToQueue('SESSION_EXPIRED');
                    }
                } else {
                    console.error('Header Heartbeat HTTP 오류:', response.status, response.statusText);
                    this.handleHeartbeatFailure();
                }

            } catch (error) {
                console.warn('Header Heartbeat 실패:', error.message);
                this.handleHeartbeatFailure();
            }
        }

        handleHeartbeatFailure() {
            this.failCount++;
            console.warn('Header Heartbeat 실패 횟수: ' + this.failCount + '/' + this.maxFailCount);

            if (this.failCount >= this.maxFailCount) {
                console.error('Header Heartbeat 연속 실패! 대기열로 강제 이동');
                alert('네트워크 연결에 문제가 있거나 세션이 만료되었습니다. 대기열 페이지로 이동합니다.');
                this.redirectToQueue('HEARTBEAT_FAILED');
            }
        }

        // 대기열 페이지로 이동하는 메서드 (사유 추가)
        redirectToQueue(reason = 'SESSION_EXPIRED') {
            console.log('대기열 페이지로 리다이렉트 시작 - 사유:', reason);
            this.stopHeartbeat(); // heartbeat 중지

            try {
                // 강제 대기열 진입 엔드포인트로 이동
                window.location.href = this.contextPath + '/queue/insert?reason=' + reason;
            } catch (error) {
                console.error('페이지 리다이렉트 실패:', error);
                // 폴백: 일반 대기열 페이지로 이동
                window.location.href = this.contextPath + '/queue';
            }
        }

        sendLeaveSignal() {
            if (navigator.sendBeacon) {
                const formData = new FormData();
                navigator.sendBeacon(this.contextPath + '/queue/leave', formData);
                console.log('활성 사용자 이탈 신호 전송');
            }
        }
    } /* 대기열 Heartbeat end */

    $(document).ready(function () {
        // 로그인한 사용자만 알림 기능 초기화
        <sec:authorize access="isAuthenticated()">

        $(".notification-body").on('click', '.notification-item', function (e) {
            if ($(e.target).is('.notification-checkbox')) return;

            e.preventDefault();
            e.stopPropagation(); // ← 이벤트 버블링 방지

            const url = $(this).data('url');
            const msgSeq = $(this).data('msg-seq');

            if (!msgSeq) {
                if (url) window.location.href = url;
                return;
            }

            // 읽음 처리 AJAX
            $.ajax({
                url: '${path}/notifications/read/select',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify([msgSeq]), // 단일 항목도 배열로
                success: function () {
                    // UI 업데이트 (선택적으로)
                    const item = $(`.notification-item[data-msg-seq="\${msgSeq}"]`);
                    item.removeClass('unread');
                    item.find('.notification-status').removeClass('unread').addClass('read').text('읽음');

                    // 숫자 뱃지 갱신
                    updateNotificationBadge();

                    // 이동
                    if (url) window.location.href = url;
                },
                error: function () {
                    console.error('읽음 처리 실패');
                    // 실패해도 이동은 시도
                    if (url) window.location.href = url;
                }
            });
        });

        // 3. 체크박스 클릭 이벤트 별도 처리
        $(document).on('click', '.notification-checkbox', function (e) {
            console.log('✅ 체크박스 클릭');
            e.stopPropagation(); // 부모 요소의 클릭 이벤트 방지

            // 체크박스 상태 업데이트
            refreshSelectedNotifications();
            updateSelectAllCheckbox();
        });

        // 디바운스 유틸 함수
        function debounce(func, delay) {
            let timeoutId;
            return function (...args) {
                if (timeoutId) clearTimeout(timeoutId);
                timeoutId = setTimeout(() => func.apply(this, args), delay);
            };
        }

        // SSE 연결 설정
        function connectSSE() {
            if (eventSource) {
                eventSource.close();
            }

            eventSource = new EventSource('${path}/notifications/subscribe');

            // 1️⃣ 연결 확인용
            eventSource.addEventListener("connect", function (event) {
                console.log("✅ SSE 연결 성공:", event.data); // "connected"
            });

            // 2️⃣ 실시간 알림 도착 처리
            eventSource.addEventListener("notification", function (event) {
                const data = JSON.parse(event.data);
                console.log("🔔 새 알림 수신:", data);

                updateNotificationBadge();

                // 모달이 열려있고 현재 필터에 해당하면 목록에 추가
                if ($('#notificationModal').is(':visible') && shouldShowInCurrentFilter(data)) {
                    prependNotificationToList(data);
                }
            });

            // 3️⃣ fallback 기본 메시지 처리 (서버에서 .name() 없이 보낸 경우)
            eventSource.onmessage = function (event) {
                console.log("📩 기본 SSE 메시지 수신:", event.data);
            };

            // 4️⃣ 오류 시 자동 재연결
            eventSource.onerror = function (event) {
                console.error('❌ SSE 연결 오류:', event);
                eventSource.close();
                setTimeout(connectSSE, 5000); // 5초 후 재시도
            };
        }


        // 페이지 로드 시 SSE 연결 및 배지 업데이트
        connectSSE();
        updateNotificationBadge();

        // 알림 버튼 클릭
        $('#notificationBtn').click(function () {
            $('#notificationModal').show();
            $('body').addClass('body-no-scroll');
            resetNotificationList();
            loadNotifications();
        });

        // 모달 배경 클릭 시 닫기
        $('.notification-modal').click(function (e) {
            if (e.target === this) {
                $('#notificationModal').hide();
                $('body').removeClass('body-no-scroll');
                selectedNotifications.clear();
                updateSelectAllCheckbox();
            }
        });

        // X 버튼 클릭 시 닫기
        $('#notificationModalClose').click(function () {
            $('#notificationModal').hide();
            selectedNotifications.clear();
            updateSelectAllCheckbox();
        });

        // 모달 내부 클릭 시 닫기 방지
        $('.notification-modal-content').click(function (e) {
            e.stopPropagation();
        });

        // 탭 클릭 이벤트 수정
        $('.notification-tab').click(function () {
            if ($(this).hasClass('active')) return;

            $('.notification-tab').removeClass('active');
            $(this).addClass('active');

            const newFilter = $(this).data('filter');
            console.log('🔄 탭 변경:', currentFilter, '->', newFilter);

            currentFilter = newFilter;
            resetNotificationList();

            // 약간의 지연 후 로드 (UI 업데이트 완료 대기)
            setTimeout(() => {
                loadNotifications();
            }, 100);
        });


        // 4. 중복된 loadNotifications 함수 제거 및 통합
        function loadNotifications() {
            if (isLoading || !hasMoreData) {
                console.log('🟡 loadNotifications 중단: isLoading=', isLoading, 'hasMoreData=', hasMoreData);
                return;
            }

            isLoading = true;
            $('#loadingSpinner').show();

            console.log('🟡 loadNotifications 시작: lastMsgSeq=', lastMsgSeq, 'currentFilter=', currentFilter);

            $.ajax({
                url: '${path}/notifications',
                method: 'GET',
                data: {
                    filter: currentFilter,
                    lastMsgSeq: lastMsgSeq,
                    size: 10
                },
                success: function (response) {
                    console.log('🟢 서버 응답:', response);

                    updateNotificationCounts(response);

                    const list = response.notificationEventList;

                    if (!list || !Array.isArray(list)) {
                        console.log('🔴 잘못된 응답 구조:', list);
                        hasMoreData = false;
                        return;
                    }

                    console.log('📊 받은 데이터:', list.map(item => ({msgSeq: item.msgSeq, msgType: item.msgType})));

                    if (list.length === 0) {
                        hasMoreData = false;
                        console.log('🔴 더 이상 데이터 없음 (빈 응답)');

                        if ($('#notificationList').children().length === 0) {
                            $('#notificationEmpty').show();
                        }
                    } else {
                        // 중복 체크 추가 - 이미 존재하는 msgSeq는 추가하지 않음
                        let addedCount = 0;

                        list.forEach(notification => {
                            const existingItem = $(`.notification-item[data-msg-seq="${notification.msgSeq}"]`);
                            if (existingItem.length === 0) {
                                appendNotificationToList(notification);
                                addedCount++;
                            } else {
                                console.log('⚠️ 중복 데이터 스킵:', notification.msgSeq);
                            }
                        });

                        console.log('📝 실제 추가된 아이템 수:', addedCount);

                        // lastMsgSeq 업데이트 로직
                        if (list.length > 0) {
                            const newLastMsgSeq = list[list.length - 1].msgSeq;

                            if (lastMsgSeq === newLastMsgSeq) {
                                console.log('🔴 lastMsgSeq가 동일함 - 무한 루프 방지를 위해 중단');
                                hasMoreData = false;
                            } else {
                                lastMsgSeq = newLastMsgSeq;
                                console.log('📝 lastMsgSeq 업데이트:', lastMsgSeq);
                            }
                        }

                        // 받은 데이터가 요청 크기보다 적거나 실제 추가된 아이템이 없으면 더 이상 데이터 없음
                        if (list.length < 10 || addedCount === 0) {
                            hasMoreData = false;
                            console.log('🔴 더 이상 데이터 없음 (마지막 페이지 또는 중복 데이터)');
                        }
                    }
                },
                error: function (xhr, status, error) {
                    console.error('🔴 알림 로드 실패:', error);
                    hasMoreData = false;
                },
                complete: function () {
                    isLoading = false;
                    $('#loadingSpinner').hide();
                    console.log('✅ loadNotifications 완료: isLoading=', isLoading, 'hasMoreData=', hasMoreData, 'lastMsgSeq=', lastMsgSeq);
                }
            });
        }

        const debouncedLoadNotifications = debounce(() => {
            console.log('🔄 디바운스 함수 실행 시도');
            console.log('📊 현재 상태:', {
                isLoading: isLoading,
                hasMoreData: hasMoreData,
                lastMsgSeq: lastMsgSeq,
                currentListLength: $('#notificationList').children().length
            });

            if (!isLoading && hasMoreData) {
                console.log('✅ 조건 만족 - loadNotifications 호출');
                loadNotifications();
            } else {
                console.log('🔴 조건 불만족 - 디바운스에서 로드 중단');
            }
        }, 500); // 디바운스 시간을 500ms로 증가

// 무한 스크롤 이벤트 수정 - 더 엄격한 조건
        $('.notification-body').on('scroll', function () {
            if (!hasMoreData || isLoading) {
                return;
            }

            const scrollTop = $(this).scrollTop();
            const scrollHeight = $(this)[0].scrollHeight;
            const clientHeight = $(this).innerHeight();

            const scrollPercentage = (scrollTop + clientHeight) / scrollHeight;

            // 90% 이상 스크롤했을 때만 로드
            if (scrollPercentage >= 0.9) {
                console.log('🟡 스크롤 90% 도달 - 디바운스 함수 호출');
                debouncedLoadNotifications();
            }
        });
    });

    // 알림 항목을 목록에 추가
    function appendNotificationToList(notification) {
        const notificationItem = createNotificationItem(notification);
        // 1. 기존 spacer 제거
        $('#notificationList .notification-spacer').remove();

        // 2. 알림 추가
        $('#notificationList').append(notificationItem);

        // 3. spacer 다시 추가
        $('#notificationList').append('<li class="notification-spacer" aria-hidden="true"></li>');

        $('#notificationEmpty').hide();
    }

    // 알림 항목을 목록 맨 앞에 추가 (실시간 알림용)
    function prependNotificationToList(notification) {
        const notificationItem = createNotificationItem(notification);
        $('#notificationList').prepend(notificationItem);
        $('#notificationEmpty').hide();
    }

    // 알림 항목 HTML 생성
    // 알림 로드 함수 수정 - lastMsgSeq 업데이트 문제 해결
    function loadNotifications() {
        if (isLoading || !hasMoreData) {
            console.log('🟡 loadNotifications 중단: isLoading=', isLoading, 'hasMoreData=', hasMoreData);
            return;
        }

        isLoading = true;
        $('#loadingSpinner').show();

        console.log('🟡 loadNotifications 시작: lastMsgSeq=', lastMsgSeq, 'currentFilter=', currentFilter);

        $.ajax({
            url: '${path}/notifications',
            method: 'GET',
            data: {
                filter: currentFilter,
                lastMsgSeq: lastMsgSeq,
                size: 10
            },
            success: function (response) {
                console.log('🟢 서버 응답:', response);

                updateNotificationCounts(response);

                const list = response.notificationEventList;

                if (!list || !Array.isArray(list)) {
                    console.log('🔴 잘못된 응답 구조:', list);
                    hasMoreData = false;
                    return;
                }

                console.log('📊 받은 데이터:', list.map(item => ({msgSeq: item.msgSeq, msgType: item.msgType})));

                if (list.length === 0) {
                    hasMoreData = false;
                    console.log('🔴 더 이상 데이터 없음 (빈 응답)');

                    if ($('#notificationList').children().length === 0) {
                        $('#notificationEmpty').show();
                    }
                } else {
                    // ✅ 중복 체크 추가 - 이미 존재하는 msgSeq는 추가하지 않음
                    let addedCount = 0;

                    list.forEach(notification => {
                        const existingItem = $(`.notification-item[data-msg-seq="${notification.msgSeq}"]`);
                        if (existingItem.length === 0) {
                            appendNotificationToList(notification);
                            addedCount++;
                        } else {
                            console.log('⚠️ 중복 데이터 스킵:', notification.msgSeq);
                        }
                    });

                    console.log('📝 실제 추가된 아이템 수:', addedCount);

                    // ✅ lastMsgSeq 업데이트 로직 개선
                    if (list.length > 0) {
                        const newLastMsgSeq = list[list.length - 1].msgSeq;

                        // lastMsgSeq가 변경되었는지 확인
                        if (lastMsgSeq === newLastMsgSeq) {
                            console.log('🔴 lastMsgSeq가 동일함 - 무한 루프 방지를 위해 중단');
                            hasMoreData = false;
                        } else {
                            lastMsgSeq = newLastMsgSeq;
                            console.log('📝 lastMsgSeq 업데이트:', lastMsgSeq);
                        }
                    }

                    // 받은 데이터가 요청 크기보다 적거나 실제 추가된 아이템이 없으면 더 이상 데이터 없음
                    if (list.length < 10 || addedCount === 0) {
                        hasMoreData = false;
                        console.log('🔴 더 이상 데이터 없음 (마지막 페이지 또는 중복 데이터)');
                    }
                }
            },
            error: function (xhr, status, error) {
                console.error('🔴 알림 로드 실패:', error);
                hasMoreData = false;
            },
            complete: function () {
                isLoading = false;
                $('#loadingSpinner').hide();
                console.log('✅ loadNotifications 완료: isLoading=', isLoading, 'hasMoreData=', hasMoreData, 'lastMsgSeq=', lastMsgSeq);
            }
        });
    }

    function getNotificationUrl(msgType, notification) {
        switch (msgType) {
            case 'STUDENT_JOIN_SUCCESS':
                return '/course/listpage';
            case 'TEACHER_JOIN_SUCCESS':
                return '/mypage/teacher';
            case 'ENROLL_SUCCESS':
            case 'ATTENDANCE_REQUEST':
            case 'MATERIAL_UPLOADED':
            case 'VIDEO_UPLOADED':
                return `/course/view?courseSeq=\${notification.courseSeq}`;
            case 'REFUND_SUCCESS':
                return '/mypage/student';
            case 'CERTIFICATE_ISSUED':
                return '/mypage/certificates';
            case 'ACCOUNT_AVAILABLE':
                return '/mypage/teacher?section=settlement';
            case 'DELETE_REQUEST_STATUS':
                return '/mypage/teacher?section=manage-courses';
            default:
                return '/notifications';
        }
    }


    // 알림 항목 HTML 생성 함수 수정 - msgSeq 확인 로그 추가
    function createNotificationItem(notification) {
        const isRead = notification.msgReadTime !== null;
        const statusClass = isRead ? 'read' : 'unread';
        const iconClass = getNotificationIconClass(notification.msgType);
        const timeString = formatTime(notification.msgDate);
        const url = getNotificationUrl(notification.msgType, notification);

        // 템플릿 리터럴 백틱 수정
        return `
        <li class="notification-item \${!isRead ? 'unread' : ''}"
            data-msg-seq="\${notification.msgSeq}"
            data-url="\${notification.redirectLocation}">
            <input type="checkbox" class="notification-checkbox" data-msg-seq="\${notification.msgSeq}">
            <div class="notification-icon \${iconClass}">
                <i class="fas \${getNotificationIcon(notification.msgType)}"></i>
            </div>
            <div class="notification-content">
                <p class="notification-message">\${getNotificationMessage(notification.msgType)}</p>
                <p class="notification-time">\${timeString}
                    <span class="notification-status \${statusClass}">\${isRead ? '읽음' : '신규'}</span>
                </p>
            </div>
        </li>
    `;
    }

    // 알림 타입별 아이콘 클래스
    function getNotificationIconClass(msgType) {
        switch (msgType) {
            case 'STUDENT_JOIN_SUCCESS':
                return 'primary';   // 파란색 계열
            case 'TEACHER_JOIN_SUCCESS':
                return 'primary';
            case 'ENROLL_SUCCESS':
                return 'success';   // 초록색 계열
            case 'REFUND_SUCCESS':
                return 'info';      // 하늘색 계열
            case 'ATTENDANCE_REQUEST':
                return 'warning';   // 노란색 계열
            case 'CERTIFICATE_ISSUED':
                return 'success';
            case 'ACCOUNT_AVAILABLE':
                return 'primary';
            case 'MATERIAL_UPLOADED':
                return 'info';
            case 'VIDEO_UPLOADED':
                return 'info';
            case 'DELETE_REQUEST_STATUS':
                return 'secondary'; // 회색 계열
            default:
                return 'info';
        }
    }


    // 알림 타입별 아이콘
    function getNotificationIcon(msgType) {
        switch (msgType) {
            case 'STUDENT_JOIN_SUCCESS':
                return 'fa-user-plus';
            case 'TEACHER_JOIN_SUCCESS':
                return 'fa-chalkboard-teacher';
            case 'ENROLL_SUCCESS':
                return 'fa-check-circle';
            case 'REFUND_SUCCESS':
                return 'fa-money-bill-wave';
            case 'ATTENDANCE_REQUEST':
                return 'fa-user-check';
            case 'CERTIFICATE_ISSUED':
                return 'fa-certificate';
            case 'ACCOUNT_AVAILABLE':
                return 'fa-coins';
            case 'MATERIAL_UPLOADED':
                return 'fa-book';
            case 'VIDEO_UPLOADED':
                return 'fa-video';
            case 'DELETE_REQUEST_STATUS':
                return 'fa-info-circle';
            default:
                return 'fa-bell';
        }
    }


    // 알림 타입별 메시지 (enum에서 가져온 메시지)
    function getNotificationMessage(msgType) {
        switch (msgType) {
            case 'STUDENT_JOIN_SUCCESS':
                return '회원가입이 성공적으로 완료되었습니다. 원하는 강의를 찾아보세요';
            case 'TEACHER_JOIN_SUCCESS':
                return '회원가입이 성공적으로 완료되었습니다. 원하는 강의를 등록해보세요';
            case 'ENROLL_SUCCESS':
                return '수강신청 및 결제가 완료되었습니다.';
            case 'REFUND_SUCCESS':
                return '강의 환불이 완료되었습니다.';
            case 'ATTENDANCE_REQUEST':
                return '출석 확인을 위해 인증 코드를 입력해주세요.';
            case 'CERTIFICATE_ISSUED':
                return '강의 수료를 축하합니다!! 수료증이 발급되었습니다.';
            case 'ACCOUNT_AVAILABLE':
                return '정산 신청이 가능합니다. 지금 신청하세요.';
            case 'MATERIAL_UPLOADED':
                return '강의 자료가 새로 등록되었습니다.';
            case 'VIDEO_UPLOADED':
                return '새로운 강의 영상이 업로드되었습니다.';
            case 'DELETE_REQUEST_STATUS':
                return '강의 삭제 요청 처리 결과를 확인하세요.';
            default:
                return '새로운 알림이 있습니다.';
        }
    }

    function getNotificationStatusClass(notification) {
        if (notification.msgReadTime) return 'read';

        switch (notification.msgType) {
            case 'ERROR_ALERT':
                return 'error';
            case 'SYSTEM_ALERT':
                return 'system';
            case 'INFO_NOTICE':
                return 'info';
            default:
                return 'unread';
        }
    }

    // 시간 포맷팅
    function formatTime(timestamp) {
        const date = new Date(timestamp);
        const now = new Date();
        const diff = now - date;
        console.log("date:" + date)
        console.log("now:" + now)
        console.log("diff:" + diff)
        if (diff < 60000) { // 1분 미만
            return '방금 전';
        } else if (diff < 3600000) { // 1시간 미만
            return Math.floor(diff / 60000) + '분 전';
        } else if (diff < 86400000) { // 24시간 미만
            return Math.floor(diff / 3600000) + '시간 전';
        } else {
            return date.toLocaleDateString();
        }
    }

    // 현재 필터에 맞는 알림인지 확인
    function shouldShowInCurrentFilter(notification) {
        const isRead = notification.msgReadTime !== null;
        switch (currentFilter) {
            case 'read':
                return isRead;
            case 'unread':
                return !isRead;
            case 'all':
                return true;
            default:
                return true;
        }
    }

    // 서버 응답 구조 확인을 위한 로그 추가
    function updateNotificationCounts(response) {
        console.log('📊 알림 카운트 업데이트:', {
            total: response.totalNotificationCount,
            unread: response.totalUnreadNotificationCount,
            read: response.totalReadNotificationCount,
            currentListLength: response.notificationEventList ? response.notificationEventList.length : 0
        });

        $('#totalCount').text(response.totalNotificationCount || 0);
        $('#unreadCount').text(response.totalUnreadNotificationCount || 0);
        $('#readCount').text(response.totalReadNotificationCount || 0);
    }

    // 배지 업데이트
    function updateNotificationBadge() {
        $.ajax({
            url: '${path}/notifications',
            method: 'GET',
            data: {filter: 'unread', size: 1},
            success: function (response) {
                const unreadCount = response.totalUnreadNotificationCount || 0;
                if (unreadCount > 0) {
                    $('#notificationBadge, #modalNotificationBadge').text(unreadCount).show();
                } else {
                    $('#notificationBadge, #modalNotificationBadge').hide();
                }
            }
        });
    }

    // 체크박스 개별 선택
    $(document).on('change', '.notification-checkbox', function () {
        refreshSelectedNotifications();
        updateSelectAllCheckbox();
    });

    // 전체 선택/해제
    $('#selectAllCheckbox').change(function () {
        const isChecked = $(this).is(':checked');
        $('.notification-checkbox').prop('checked', isChecked);

        refreshSelectedNotifications();
        updateSelectAllCheckbox();
    });

    // 전체 선택 체크박스 상태 업데이트
    function updateSelectAllCheckbox() {
        const totalCheckboxes = $('.notification-checkbox').length;
        const checkedCheckboxes = $('.notification-checkbox:checked').length;

        if (checkedCheckboxes === 0) {
            $('#selectAllCheckbox').prop('indeterminate', false).prop('checked', false);
        } else if (checkedCheckboxes === totalCheckboxes) {
            $('#selectAllCheckbox').prop('indeterminate', false).prop('checked', true);
        } else {
            $('#selectAllCheckbox').prop('indeterminate', true);
        }
    }

    // 현재 체크된 알림들을 selectedNotifications에 저장
    function refreshSelectedNotifications() {
        selectedNotifications.clear();
        $('.notification-checkbox:checked').each(function () {
            const msgSeq = $(this).data('msg-seq');
            if (msgSeq !== undefined) {
                selectedNotifications.add(msgSeq);
            }
        });
    }

    // 선택된 알림 읽음 처리
    $('#markSelectedReadBtn').click(function () {
        // ✅ 선택된 항목 갱신
        selectedNotifications.clear();
        $('.notification-checkbox:checked').each(function () {
            const msgSeq = $(this).data('msg-seq');
            if (msgSeq !== undefined) {
                selectedNotifications.add(msgSeq);
            }
        });

        if (selectedNotifications.size === 0) {
            alert('읽음 처리할 알림을 선택해주세요.');
            return;
        }

        const msgSeqList = Array.from(selectedNotifications);

        $.ajax({
            url: '${path}/notifications/read/select',
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(msgSeqList),
            success: function (response) {
                alert('선택된 알림이 읽음 처리되었습니다.');
                // UI 업데이트
                msgSeqList.forEach(msgSeq => {
                    const item = $(`.notification-item[data-msg-seq="${msgSeq}"]`);
                    item.removeClass('unread');
                    item.find('.notification-status').removeClass('unread').addClass('read').text('읽음');
                });
                selectedNotifications.clear();
                updateSelectAllCheckbox();
                updateNotificationBadge();
                resetNotificationList();
                loadNotifications();
            },
            error: function (xhr, status, error) {
                console.error('읽음 처리 실패:', error);
                alert('읽음 처리 중 오류가 발생했습니다.');
            }
        });
    });

    //선택 항목 삭제
    $('#deleteSelectedBtn').click(function () {
        // ✅ 선택 항목 다시 갱신
        selectedNotifications.clear();
        $('.notification-checkbox:checked').each(function () {
            const msgSeq = $(this).data('msg-seq');
            if (msgSeq !== undefined) {
                selectedNotifications.add(msgSeq);
            }
        });

        if (selectedNotifications.size === 0) {
            alert('삭제할 알림을 선택해주세요.');
            return;
        }

        if (!confirm('선택된 알림을 삭제하시겠습니까?')) {
            return;
        }

        const msgSeqList = Array.from(selectedNotifications);

        $.ajax({
            url: '${path}/notifications',
            method: 'DELETE',
            contentType: 'application/json',
            data: JSON.stringify(msgSeqList),
            success: function (response) {
                alert('선택된 알림이 삭제되었습니다.');
                msgSeqList.forEach(msgSeq => {
                    $(`.notification-item[data-msg-seq="${msgSeq}"]`).remove();
                });
                selectedNotifications.clear();
                updateSelectAllCheckbox();
                updateNotificationBadge();
                resetNotificationList();
                loadNotifications();

                if ($('#notificationList').children().length === 0) {
                    $('#notificationEmpty').show();
                }
            },
            error: function (xhr, status, error) {
                console.error('삭제 실패:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        });
    });

    // 페이지 종료 시 SSE 연결 해제
    $(window).on('beforeunload', function () {
        if (eventSource) {
            eventSource.close();
        }
    });

    </sec:authorize>
</script>
