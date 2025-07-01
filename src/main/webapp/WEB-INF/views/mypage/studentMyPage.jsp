<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<!-- 전체 화면 오버레이 스피너 -->
<div id="loadingOverlay" style="
     display: none;
     position: fixed;
     top: 0; left: 0;
     width: 100%; height: 100%;
     background: rgba(255,255,255,0.7);
     z-index: 9999;
     justify-content: center;
     align-items: center;
">
    <div class="spinner-border text-primary" role="status">
        <span class="sr-only">Loading...</span>
    </div>
</div>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        line-height: 1.6;
        color: #333;
        background-color: #f8f9fa;
    }

    /* Header */
    .header {
        background: #fff;
        border-bottom: 1px solid #e5e5e5;
        position: sticky;
        top: 0;
        z-index: 1000;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .header-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        height: 80px;
    }

    .logo {
        font-size: 24px;
        font-weight: 700;
        color: #162D43;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .nav-menu {
        display: flex;
        list-style: none;
        gap: 40px;
    }

    .nav-menu a {
        text-decoration: none;
        color: #333;
        font-weight: 500;
        font-size: 16px;
        transition: color 0.2s;
    }

    .nav-menu a:hover {
        color: #162D43;
    }

    .header-actions {
        display: flex;
        align-items: center;
        gap: 16px;
    }

    .btn {
        padding: 12px 24px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        font-size: 14px;
    }

    .btn-outline {
        background: transparent;
        color: #666;
        border: 1px solid #ddd;
    }

    .btn-outline:hover {
        background: #f8f9fa;
        border-color: #162D43;
        color: #162D43;
    }

    .btn-primary {
        background: #162D43;
        color: white;
    }

    .btn-primary:hover {
        background: #0f1f2f;
    }

    /* Main Container */
    .main-container {
        max-width: 1200px;
        margin: 30px auto;
        padding: 0 20px;
        display: grid;
        grid-template-columns: 280px 1fr;
        gap: 30px;
    }

    /* Sidebar */
    .sidebar {
        background: white;
        border-radius: 12px;
        padding: 24px;
        height: fit-content;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .user-profile {
        text-align: center;
        padding-bottom: 24px;
        border-bottom: 1px solid #e5e5e5;
        margin-bottom: 24px;
    }

    .profile-image {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: linear-gradient(135deg, #162D43, #264058);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 24px;
        font-weight: bold;
        margin: 0 auto 16px;
    }

    .user-name {
        font-size: 18px;
        font-weight: 600;
        color: #333;
        margin-bottom: 4px;
    }

    .user-level {
        font-size: 14px;
        color: #666;
        background: #f8f9fa;
        padding: 4px 12px;
        border-radius: 16px;
        display: inline-block;
    }

    .sidebar-menu {
        list-style: none;
    }

    .sidebar-menu li {
        margin-bottom: 8px;
    }

    .sidebar-menu a {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        color: #666;
        text-decoration: none;
        border-radius: 8px;
        transition: all 0.2s;
        font-size: 14px;
    }

    .sidebar-menu a:hover,
    .sidebar-menu a.active {
        background: #162D43;
        color: white;
    }

    .sidebar-menu .icon {
        font-size: 16px;
    }

    /* Main Content */
    .main-content {
        background: white;
        border-radius: 12px;
        padding: 32px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .page-header {
        margin-bottom: 32px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e5e5e5;
    }

    .page-title {
        font-size: 24px;
        font-weight: 700;
        color: #162D43;
        margin-bottom: 8px;
    }

    .page-subtitle {
        color: #666;
        font-size: 14px;
    }

    /* Profile Section */
    .profile-section {
        display: none;
    }

    .profile-section.active {
        display: block;
    }

    .profile-form {
        max-width: 600px;
    }

    .form-group {
        margin-bottom: 24px;
    }

    .form-label {
        display: block;
        margin-bottom: 8px;
        font-weight: 600;
        color: #333;
        font-size: 14px;
    }

    .form-input {
        width: 100%;
        padding: 12px 16px;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        font-size: 14px;
        transition: border-color 0.2s;
    }

    .form-input:focus {
        outline: none;
        border-color: #162D43;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
    }

    /* Course Section */
    .course-section {
        display: none;
    }

    .course-section.active {
        display: block;
    }

    .course-tabs {
        display: flex;
        gap: 8px;
        margin-bottom: 24px;
        border-bottom: 1px solid #e5e5e5;
    }

    .tab-btn {
        padding: 12px 20px;
        background: none;
        border: none;
        color: #666;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        border-bottom: 2px solid transparent;
        transition: all 0.2s;
    }

    .tab-btn.active {
        color: #162D43;
        border-bottom-color: #162D43;
    }

    .course-list {
        display: grid;
        gap: 20px;
    }

    .course-item {
        border: 1px solid #e5e5e5;
        border-radius: 12px;
        padding: 20px;
        transition: all 0.2s;
    }

    .course-item:hover {
        border-color: #162D43;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    .course-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 16px;
    }

    .course-info h3 {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
    }

    .course-meta {
        display: flex;
        gap: 16px;
        font-size: 12px;
        color: #666;
    }

    .course-status {
        padding: 4px 12px;
        border-radius: 16px;
        font-size: 12px;
        font-weight: 500;
    }

    .status-progress {
        background: #e3f2fd;
        color: #1976d2;
    }

    .status-completed {
        background: #e8f5e8;
        color: #2e7d32;
    }

    .status-pending {
        background: #fff3e0;
        color: #f57c00;
    }

    .course-progress {
        margin-top: 16px;
    }

    .progress-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
        font-size: 12px;
    }

    .progress-bar {
        width: 100%;
        height: 8px;
        background: #f0f0f0;
        border-radius: 4px;
        overflow: hidden;
    }

    .progress-fill {
        height: 100%;
        background: #162D43;
        transition: width 0.3s;
    }

    /* Attendance Section */
    .attendance-section {
        display: none;
    }

    .attendance-section.active {
        display: block;
    }

    .attendance-calendar {
        background: #f8f9fa;
        border-radius: 12px;
        padding: 24px;
        margin-bottom: 24px;
    }

    .calendar-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }

    .calendar-title {
        font-size: 18px;
        font-weight: 600;
        color: #333;
    }

    .calendar-nav {
        display: flex;
        gap: 8px;
    }

    .nav-btn {
        padding: 8px;
        background: white;
        border: 1px solid #ddd;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .nav-btn:hover {
        border-color: #162D43;
        color: #162D43;
    }

    .calendar-grid {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 4px;
    }

    .calendar-day {
        aspect-ratio: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        background: white;
        border-radius: 8px;
        font-size: 12px;
        font-weight: 500;
        position: relative;
        cursor: pointer;
        transition: all 0.2s;
    }

    .calendar-day.attended {
        background: #162D43;
        color: white;
    }

    .calendar-day.absent {
        background: #ffebee;
        color: #c62828;
    }

    .calendar-day.today {
        border: 2px solid #162D43;
    }

    .attendance-stats {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
        margin-bottom: 24px;
    }

    .stat-card {
        background: white;
        border: 1px solid #e5e5e5;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
    }

    .stat-number {
        font-size: 24px;
        font-weight: 700;
        color: #162D43;
        margin-bottom: 4px;
    }

    .stat-label {
        font-size: 12px;
        color: #666;
    }

    /* Refund Section */
    .refund-section {
        display: none;
    }

    .refund-section.active {
        display: block;
    }

    .refund-policy {
        background: #f8f9fa;
        border-radius: 12px;
        padding: 24px;
        margin-bottom: 24px;
    }

    .policy-title {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 16px;
    }

    .policy-list {
        list-style: none;
        margin-bottom: 16px;
    }

    .policy-list li {
        padding: 8px 0;
        color: #666;
        font-size: 14px;
        border-bottom: 1px solid #e5e5e5;
    }

    .policy-list li:last-child {
        border-bottom: none;
    }

    .refund-form {
        max-width: 600px;
    }

    .form-textarea {
        min-height: 120px;
        resize: vertical;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .main-container {
            grid-template-columns: 1fr;
            gap: 20px;
        }

        .sidebar {
            order: 2;
        }

        .main-content {
            order: 1;
            padding: 20px;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 16px;
            text-align: left;
        }

        .profile-image {
            margin: 0;
        }

        .sidebar-menu {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 8px;
        }

        .form-row {
            grid-template-columns: 1fr;
        }

        .attendance-stats {
            grid-template-columns: 1fr;
        }

        .course-tabs {
            flex-wrap: wrap;
        }
    }

    /* Loading */
    .loading {
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 40px;
    }

    .spinner {
        width: 32px;
        height: 32px;
        border: 3px solid #f3f3f3;
        border-top: 3px solid #162D43;
        border-radius: 50%;
        animation: spin 1s linear infinite;
    }

    @keyframes spin {
        0% {
            transform: rotate(0deg);
        }
        100% {
            transform: rotate(360deg);
        }
    }


    /* Review Modal */
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: none;
        justify-content: center;
        align-items: center;
        z-index: 10000;
    }

    .modal-overlay.active {
        display: flex;
    }

    .review-modal {
        background: white;
        border-radius: 16px;
        padding: 32px;
        max-width: 500px;
        width: 90%;
        max-height: 80vh;
        overflow-y: auto;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
        transform: translateY(-50px);
        transition: transform 0.3s ease;
    }

    .modal-overlay.active .review-modal {
        transform: translateY(0);
    }

    .modal-header {
        text-align: center;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e5e5e5;
    }

    .modal-title {
        font-size: 20px;
        font-weight: 700;
        color: #162D43;
        margin-bottom: 8px;
    }

    .modal-subtitle {
        color: #666;
        font-size: 14px;
    }

    .rating-section {
        margin-bottom: 24px;
    }

    .rating-label {
        display: block;
        margin-bottom: 12px;
        font-weight: 600;
        color: #333;
    }

    .star-rating {
        display: flex;
        gap: 4px;
        justify-content: center;
        margin-bottom: 8px;
    }

    .star {
        font-size: 32px;
        color: #ddd;
        cursor: pointer;
        transition: color 0.2s;
    }

    .star:hover,
    .star.active {
        color: #ffd700;
    }

    .rating-text {
        text-align: center;
        font-size: 14px;
        color: #666;
        min-height: 20px;
    }

    .review-form {
        margin-bottom: 24px;
    }

    .review-textarea {
        width: 100%;
        min-height: 120px;
        padding: 16px;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        font-size: 14px;
        resize: vertical;
        font-family: inherit;
    }

    .review-textarea:focus {
        outline: none;
        border-color: #162D43;
    }

    .modal-actions {
        display: flex;
        gap: 12px;
        justify-content: flex-end;
    }

    .btn-modal {
        padding: 12px 24px;
        border: none;
        border-radius: 8px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s;
        font-size: 14px;
    }

    .btn-cancel {
        background: #f8f9fa;
        color: #666;
        border: 1px solid #dee2e6;
    }

    .btn-cancel:hover {
        background: #e9ecef;
    }

    .btn-submit {
        background: #162D43;
        color: white;
    }

    .btn-submit:hover {
        background: #0f1f2f;
    }

    .btn-submit:disabled {
        background: #ccc;
        cursor: not-allowed;
    }

    /* 이메일 인증 버튼 */
    #sendCodeBtn {
        opacity: 0.6;
        transition: all 0.2s;
    }
    #sendCodeBtn:not([disabled]) {
        opacity: 1;
        background: #162D43;
        border-color: #162D43;
        color: #fff;
    }
    #sendCodeBtn:not([disabled]):hover {
        background: #0f1f2f;
    }

    /* 주소 변경 버튼 */
    #toggleAddressBtn {
        background: #f1f1f1;
        border-color: #ccc;
        color: #162D43;
        font-weight: 600;
        transition: all 0.2s;
    }
    #toggleAddressBtn:hover {
        background: #162D43;
        color: #fff;
        border-color: #162D43;
    }

    /* “비밀번호 변경” 버튼*/
    #pwdVerifyBtn {
        background: #162D43;
        color: #fff;
        border-color: #162D43;
        transition: background 0.2s;
    }
    #pwdVerifyBtn:hover {
        background: #0f1f2f;
    }
    #pwChangeSection .form-input {
        border-color: #162D43;
    }

</style>

<!-- Main Container -->
<div class="main-container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="user-profile">
            <div>
                <c:choose>
                    <%-- memberProfile이 "default"로 시작하면 기본 이미지 --%>
                    <c:when test="${fn:startsWith(loginMember.memberProfile, 'default')}">
                        <img
                                src="${path}/resources/images/student.png"
                                alt="프로필 기본 이미지"
                                id="profile-image"
                                class="profile-image" />
                    </c:when>
                    <%-- 그 외에는 업로드된 이미지 --%>
                    <c:otherwise>
                        <img
                                src="${path}/resources/upload/student/profile/${loginMember.memberProfile}"
                                alt="프로필"
                                id="profile-image"
                                class="profile-image" />
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="user-name">${loginMember.memberName}</div>
            <%--<div class="user-level">Regular 회원</div>--%>
        </div>

        <ul class="sidebar-menu">
            <li><a href="#" class="menu-item active" data-section="profile">
                <span class="icon">👤</span>
                <span>개인정보 확인</span>
            </a></li>
            <li><a href="#" class="menu-item" data-section="courses">
                <span class="icon">📚</span>
                <span>수강 정보</span>
            </a></li>
            <li><a href="#" class="menu-item" data-section="attendance">
                <span class="icon">📅</span>
                <span>출석 정보</span>
            </a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Profile Section -->
        <div class="profile-section active" id="profile">
            <div class="page-header">
                <h1 class="page-title">개인정보</h1>
                <p class="page-subtitle">개인정보를 안전하게 관리하세요</p>
            </div>

            <!-- 읽기 전용 프로필 -->
            <div id="profileView">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">이름</label>
                        <input type="text" class="form-input" value="${loginMember.memberName}" readonly>
                    </div>
                    <div class="form-group">
                        <label class="form-label">닉네임</label>
                        <input type="text" class="form-input" value="${loginMember.memberNickname}" readonly>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">이메일</label>
                    <input type="email" class="form-input" value="${loginMember.memberEmail}" readonly>
                </div>

                <div class="form-group">
                    <label class="form-label">전화번호</label>
                    <input type="tel" class="form-input" value="${loginMember.memberPhone}" readonly>
                </div>

                <div class="form-group">
                    <label class="form-label">주소</label>
                    <input type="text" class="form-input" value="${loginMember.memberAddress}" readonly>
                </div>

                <button type="button" id="editProfileBtn" class="btn btn-primary" style="float:right;">개인정보 수정하기</button>
            </div>
        </div>
        <!-- 수정 폼 (초기엔 숨김) -->
        <div id="profileEdit" style="display:none;">
            <h1 class="page-title">개인정보 수정</h1>
            <form action="${path}/member/update/student" method="post" enctype="multipart/form-data" id="profileUpdateForm">
                <input type="hidden" name="memberSeq" value="${loginMember.memberSeq}"/>

                <!-- 이름 & 닉네임 -->
                <div class="form-row">
                    <div class="form-group">
                        <label>이름</label>
                        <input type="text" name="memberName" class="form-input" value="${loginMember.memberName}" required/>
                    </div>
                    <div class="form-group">
                        <label>닉네임</label>
                        <input type="text" name="memberNickname" class="form-input" value="${loginMember.memberNickname}" required/>
                    </div>
                </div>

                <!-- 이메일 인증 -->
                <div class="form-group">
                    <label>이메일</label>
                    <div style="display:flex; gap:8px; align-items:center;">
                        <input type="email" id="memberEmail" name="memberEmail" class="form-input" value="${loginMember.memberEmail}" required/>
                        <button type="button" id="sendCodeBtn" class="btn btn-outline-secondary" disabled>인증번호 요청</button>
                    </div>
                    <div id="codeSection" style="display:none; margin-top:8px; gap:8px; align-items:center;">
                        <input type="text" id="authCode" placeholder="6자리 인증번호" class="form-input" style="width:150px;"/>
                        <button type="button" id="verifyCodeBtn" class="btn btn-outline-secondary">확인</button>
                        <span id="timer">05:00</span>
                    </div>
                    <small id="emailMsg" class="form-text"></small>
                </div>

                <!-- 주소 -->
                <div class="form-group" id="addressView">
                    <label>주소</label>
                    <div style="display:flex; gap:8px; align-items:center;">
                        <input type="text" class="form-input" value="${loginMember.memberAddress}" readonly>
                        <button type="button" id="toggleAddressBtn" class="btn btn-outline-secondary" style="margin-left:8px;">주소 변경</button>
                    </div>
                </div>

                <div id="addressEdit" style="display:none;">
                    <label>주소</label>
                    <div style="display:flex; gap:8px;">
                        <input type="text" id="postcode" placeholder="우편번호" readonly class="form-input" style="width:150px;"/>
                        <button type="button" class="btn btn-outline" onclick="execDaumPostcode()">주소 찾기</button>
                    </div>
                    <input type="text" id="roadAddress" placeholder="도로명 주소" readonly class="form-input mt-2"/>
                    <input type="text" id="memberAddress" name="memberAddress" placeholder="상세 주소를 입력하세요" class="form-input mt-2" value="${loginMember.memberAddress}" readonly/>
                    <div style="margin-top:8px; display:flex; gap:8px;">
                        <button type="button" id="applyAddressBtn" class="btn btn-primary">적용</button>
                        <button type="button" id="cancelAddressBtn" class="btn btn-outline-secondary">취소</button>
                    </div>
                </div>


                <!-- 전화번호 -->
                <div class="form-group">
                    <label>전화번호</label>
                    <input type="text" name="memberPhone" class="form-input" pattern="\d{10,11}" value="${loginMember.memberPhone}" required/>
                    <small class="form-text text-muted">숫자만 입력해주세요. 예: 01012345678</small>
                </div>

                <!-- 프로필 이미지 -->
                <div class="form-group">
                    <label>프로필 이미지</label>
                    <div style="margin-bottom:8px;">
                        <c:choose>
                            <%-- 기본 이미지인 경우 --%>
                            <c:when test="${fn:startsWith(loginMember.memberProfile, 'default')}">
                                <img
                                        id="profilePreview"
                                        src="${path}/resources/images/student.png"
                                        alt="기본 프로필"
                                        style="width:80px; height:80px; border-radius:50%; object-fit:cover;"/>
                            </c:when>
                            <%-- 업로드된 이미지인 경우 --%>
                            <c:otherwise>
                                <img
                                        id="profilePreview"
                                        src="${path}/resources/upload/student/profile/${loginMember.memberProfile}"
                                        alt="현재 프로필"
                                        style="width:80px; height:80px; border-radius:50%; object-fit:cover;"/>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <input type="file"
                           name="profileFile"
                           id="profileFile"
                           class="form-control-file"/>
                    <input type="hidden" name="oldProfile" value="${loginMember.memberProfile}"/>
                </div>


                <!-- 기존 비밀번호 -->
                <div class="form-group" id="currentPwdSection">
                    <label>기존 비밀번호</label>
                    <div style="display:flex; gap:8px; align-items:center;">
                        <input type="password" id="currentPwd" name="currentPwd" class="form-input" placeholder="비밀번호 변경 희망 시 기존 비밀번호 인증 후에 변경 가능합니다."/>
                        <button type="button" id="pwdVerifyBtn" class="btn btn-outline-secondary">비밀번호 변경희망</button>
                    </div>
                    <span id="pwdVerifyMsg" style="margin-left:8px;color:#c62828;"></span>
                </div>

                <!-- 새 비밀번호 입력(초기 숨김) -->
                <div id="pwChangeSection" style="display:none;">
                    <div class="form-row">
                        <div class="form-group">
                            <label>새 비밀번호</label>
                            <input type="password" id="newPwd" name="memberPwd" class="form-input" placeholder="8자 이상·영문·숫자·특수문자 포함"/>
                            <small id="pwdCriteria" style="color:red; margin-top:6px;">
                                <ul style="list-style:none; padding:0;">
                                    <li id="crit-letter">• 영문자 사용</li>
                                    <li id="crit-number">• 숫자 사용</li>
                                    <li id="crit-special">• 특수문자 사용</li>
                                    <li id="crit-length">• 8자 이상</li>
                                </ul>
                            </small>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>비밀번호 확인</label>
                            <input type="password" id="newConfirmPwd" name="confirmPwd" class="form-input" placeholder="다시 입력하세요"/>
                            <small id="pwdCheckMsg" class="form-text"></small>
                        </div>
                    </div>
                </div>


                <!-- 저장 / 취소 버튼 -->
                <div style="margin-top:20px;">
                    <button type="submit" class="btn btn-primary">저장하기</button>
                    <button type="button" id="cancelEditBtn" class="btn btn-outline-secondary">취소</button>
                </div>
            </form>
        </div>


        <!-- Courses Section -->
        <div class="course-section" id="courses">
            <div class="page-header">
                <h1 class="page-title">수강 정보</h1>
                <p class="page-subtitle">신청한 강의를 확인하고 관리하세요</p>
            </div>

            <div class="course-tabs">
                <button class="tab-btn active" data-tab="current">수강중</button>
                <button class="tab-btn" data-tab="completed">수강완료</button>
                <button class="tab-btn" data-tab="pending">대기중</button>
            </div>

            <div class="course-list" id="currentCourses">

            </div>
            <div id="pageBarContainer" style="margin-top: 20px; text-align: center;"></div>
        </div>

        <!-- Attendance Section -->
        <div class="attendance-section" id="attendance">
            <div class="page-header">
                <h1 class="page-title">출석 정보</h1>
                <select id="courseSelect" class="form-control"></select>
            </div>

            <div class="attendance-stats">
                <div class="stat-card">
                    <div class="stat-number" id="statRate">0%</div>
                    <div class="stat-label">출석률</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="statPresent">0</div>
                    <div class="stat-label">출석일</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="statAbsent">0</div>
                    <div class="stat-label">결석일</div>
                </div>
            </div>

            <div class="attendance-calendar">
                <div id="calendar"></div>
            </div>
        </div>


        <!-- Refund Section -->
        <div class="refund-section" id="refund">
            <div class="page-header">
                <h1 class="page-title">환불</h1>
                <p class="page-subtitle">환불 정책을 확인하고 신청하세요</p>
            </div>

            <div class="refund-policy">
                <h3 class="policy-title">환불 정책</h3>
                <ul class="policy-list">
                    <li>결제일로부터 7일 지난 경우 환불 불가 (7일 전에 환불 시 100%)</li>
                    <li>환불 방식 (결제 API 활용하는 방법은 우선순위 하)</li>
                    <li>모든 강의를 보여주고 환불 불가능한 강의를 선택하면 알림창으로 환불불가 메시지 보여주기</li>
                    <li>출석 80% 이상만 수료 가능 (이수증 발급 가능)</li>
                    <li>수료한 사람만 리뷰 작성 가능</li>
                    <li>출석은 강사가 알려주는 번호를 입력해서 인증해야 출석 인증</li>
                    <li>캘린더로 출석정보 출력</li>
                </ul>
            </div>

            <form class="refund-form">
                <div class="form-group">
                    <label class="form-label">환불 요청 강의</label>
                    <select class="form-input" required>
                        <option value="">강의를 선택하세요</option>
                        <option value="course1">풀스택 웹개발 마스터 부트캠프</option>
                        <option value="course2">React Native 모바일 앱 개발</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">환불 사유</label>
                    <textarea class="form-input form-textarea" placeholder="환불 사유를 상세히 입력해주세요" required></textarea>
                </div>

                <div class="form-group">
                    <label class="form-label">연락처</label>
                    <input type="tel" class="form-input" value="010-1234-5678" required>
                </div>

                <button type="submit" class="btn btn-primary">환불 신청</button>
            </form>
        </div>

        <!-- Settings Section -->
        <div class="settings-section" id="settings" style="display: none;">
            <div class="page-header">
                <h1 class="page-title">설정</h1>
                <p class="page-subtitle">알림 및 계정 설정을 관리하세요</p>
            </div>

            <div class="settings-form">
                <div class="form-group">
                    <label class="form-label">알림 설정</label>
                    <div class="setting-options">
                        <div class="setting-option">
                            <input type="checkbox" id="email-notify" checked>
                            <label for="email-notify">이메일 알림</label>
                        </div>
                        <div class="setting-option">
                            <input type="checkbox" id="sms-notify" checked>
                            <label for="sms-notify">SMS 알림</label>
                        </div>
                        <div class="setting-option">
                            <input type="checkbox" id="push-notify">
                            <label for="push-notify">푸시 알림</label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">마케팅 수신 동의</label>
                    <div class="setting-options">
                        <div class="setting-option">
                            <input type="checkbox" id="marketing-email">
                            <label for="marketing-email">마케팅 이메일 수신</label>
                        </div>
                        <div class="setting-option">
                            <input type="checkbox" id="marketing-sms">
                            <label for="marketing-sms">마케팅 SMS 수신</label>
                        </div>
                    </div>
                </div>

                <div class="danger-zone">
                    <h3>계정 관리</h3>
                    <button type="button" class="btn btn-outline" onclick="confirmAction('회원탈퇴')">회원 탈퇴</button>
                </div>
            </div>
        </div>
    </main>
</div>
<!-- Review Modal -->
<div class="modal-overlay" id="reviewModal">
    <div class="review-modal">
        <div class="modal-header">
            <h2 class="modal-title" id="reviewCourseTitle">강의 리뷰 작성</h2>
            <p class="modal-subtitle">수강하신 강의에 대한 솔직한 후기를 남겨주세요</p>
        </div>

        <div class="rating-section">
            <label class="rating-label">강의 만족도</label>
            <div class="star-rating" id="starRating">
                <span class="star" data-rating="1">★</span>
                <span class="star" data-rating="2">★</span>
                <span class="star" data-rating="3">★</span>
                <span class="star" data-rating="4">★</span>
                <span class="star" data-rating="5">★</span>
            </div>
            <div class="rating-text" id="ratingText">별점을 선택해주세요</div>
        </div>

        <form class="review-form" id="reviewForm">
            <div class="form-group">
                <label class="form-label">리뷰 내용</label>
                <textarea
                        class="review-textarea"
                        id="reviewContent"
                        placeholder="강의에 대한 상세한 후기를 작성해주세요. 다른 수강생들에게 도움이 되는 정보를 포함해주시면 더욱 좋습니다."
                        required
                ></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-modal btn-cancel" onclick="closeReviewModal()">취소</button>
                <button type="submit" class="btn-modal btn-submit" id="submitReview" disabled>리뷰 등록</button>
            </div>
        </form>
    </div>
</div>
<script>

    // Menu navigation
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function (e) {
            e.preventDefault();

            // Remove active class from all menu items
            document.querySelectorAll('.menu-item').forEach(menu => {
                menu.classList.remove('active');
            });

            // Add active class to clicked item
            this.classList.add('active');

            // Hide all sections
            document.querySelectorAll('.profile-section, .course-section, .attendance-section, .refund-section, .settings-section').forEach(section => {
                section.style.display = 'none';
                section.classList.remove('active');
            });

            // Show selected section
            const sectionId = this.dataset.section;
            const section = document.getElementById(sectionId);
            if (section) {
                section.style.display = 'block';
                section.classList.add('active');
            }
        });
    });

    // Course tabs
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            // Remove active class from all tabs
            document.querySelectorAll('.tab-btn').forEach(tab => {
                tab.classList.remove('active');
            });

            // Add active class to clicked tab
            this.classList.add('active');

            // Update course list based on tab
            updateCourseList(this.dataset.tab);
        });
    });


    // Calendar navigation
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            // Calendar navigation logic would go here
            console.log('Calendar navigation clicked');
        });
    });

    document.querySelector('.refund-form').addEventListener('submit', function (e) {
        e.preventDefault();
        const selectedCourse = this.querySelector('select').value;

        if (selectedCourse === 'course1') {
            showAlert('해당 강의는 환불 불가능합니다. (7일 경과)', 'error');
            return;
        }

        showAlert('환불 신청이 완료되었습니다. 처리까지 3-5일 소요됩니다.');
    });

    // Utility functions
    function showAlert(message, type = 'success') {
        const alertDiv = document.createElement('div');
        alertDiv.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 16px 24px;
                background: \${type === 'error' ? '#ff6b6b' : '#162D43'};
                color: white;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
                z-index: 10000;
                animation: slideIn 0.3s ease;
            `;
        alertDiv.textContent = message;

        document.body.appendChild(alertDiv);

        setTimeout(() => {
            alertDiv.remove();
        }, 3000);
    }

    function confirmAction(action) {
        if (confirm(`정말로 \${action}하시겠습니까?`)) {
            showAlert(`\${action} 요청이 처리되었습니다.`);
        }
    }

    // Add CSS animation
    const style = document.createElement('style');
    style.textContent = `
            @keyframes slideIn {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }

            .setting-options {
                display: flex;
                flex-direction: column;
                gap: 12px;
                margin-top: 8px;
            }

            .setting-option {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .setting-option input[type="checkbox"] {
                accent-color: #162D43;
            }

            .setting-option label {
                cursor: pointer;
                font-size: 14px;
                color: #333;
            }

            .danger-zone {
                margin-top: 40px;
                padding-top: 24px;
                border-top: 1px solid #ffebee;
            }

            .danger-zone h3 {
                color: #c62828;
                margin-bottom: 16px;
                font-size: 16px;
            }

            .danger-zone .btn {
                border-color: #c62828;
                color: #c62828;
            }

            .danger-zone .btn:hover {
                background: #c62828;
                color: white;
            }
        `;
    document.head.appendChild(style);
</script>
<script>
    let currentTab = 'current';

    $(document).ready(() => {
        updateCourseList('current', 1);
    });

    $('#pageBarContainer').on('click', 'a', function (e) {
        e.preventDefault();
        const page = $(this).data('page');
        if (!page) return;
        updateCourseList(currentTab, page);
    });

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.tab-btn').forEach(tab => tab.classList.remove('active'));
            this.classList.add('active');
            const tab = this.dataset.tab;
            currentTab = tab;
            updateCourseList(tab, 1);
        });
    });

    function updateCourseList(tab, page = 1) {
        let url = '';
        if (tab === 'current') url = `${path}/mypage/student-current`;
        else if (tab === 'completed') url = `${path}/mypage/student-complete`;
        else if (tab === 'pending') url = `${path}/mypage/student-pending`;

        $.ajax({
            url,
            method: 'POST',
            data: {cPage: page, numPerPage: 1},
            success: function (res) {
                const courseList = res.courses || [];
                const $container = $('#currentCourses');
                $container.empty();

                if (courseList.length === 0) {
                    $container.append('<p>수강 내역이 없습니다.</p>');
                    $('#pageBarContainer').empty();
                    return;
                }

                courseList.forEach(course => {
                    const rate = course.presentRate ? course.presentRate.toFixed(0) : 0;
                    const statusText = getCourseStatus(course.courseStartDate, course.courseEndDate);
                    const statusClass = {
                        '수강중': 'status-progress',
                        '수강완료': 'status-completed',
                        '대기중': 'status-pending'
                    }[statusText];

                    let html = `
                        <div class="course-item" onclick="location.assign('<%=request.getContextPath()%>/course/view?courseSeq='+\${course.courseSeq})">
                          <div class="course-header">
                            <div class="course-info">
                              <h3>\${course.courseName}</h3>
                              <div class="course-meta">
                                <span>📅 \${formatDate(course.courseStartDate)} ~ \${formatDate(course.courseEndDate)}</span>
                                <span>📍 \${course.courseAddress}</span>
                              </div>
                            </div>
                            <div class="course-status \${statusClass}">\${statusText}</div>
                          </div>
                      `;

                    if (tab !== 'pending') {
                        html += `
                          <div class="course-progress">
                            <div class="progress-header">
                              <span>출석률</span>
                              <span>\${rate}%</span>
                            </div>
                            <div class="progress-bar">
                              <div class="progress-fill" style="width: \${rate}%"></div>
                            </div>
                          </div>
                        `;
                        if (tab === 'completed' && rate == 0) {//rate>=80 으로 바꾸기
                            html += `<div class="course-actions" style="margin-top: 10px;">`;

                            if (course.reviewWritten === 'N') {
                                html += `
                                    <button class="btn btn-primary"
                                    onclick="event.stopPropagation(); openReviewModal('\${course.courseName}', \${course.enrSeq})"
                                    style="padding: 4px 12px; font-size: 12px;">리뷰 작성</button>
                                `;
                            } else {
                                html += `
                                    <button class="btn btn-primary"
                                            onclick="event.stopPropagation(); openReviewModal('\${course.courseName}', \${course.enrSeq}, '\${course.reviewContent}', \${course.reviewRate})"
                                            style="padding: 4px 12px; font-size: 12px;">리뷰 수정</button>
                                    <button class="btn btn-outline"
                                            onclick="event.stopPropagation(); deleteReview(\${course.enrSeq})"
                                            style="padding: 4px 12px; font-size: 12px;">리뷰 삭제</button>
                                `;
                            }

                            html += `
                                    <button class="btn btn-primary"
                                            onclick="event.stopPropagation(); downloadCertificatePost(\${course.courseSeq},'\${course.courseName}','\${course.courseStartDate}','\${course.courseEndDate}')"
                                            style="padding: 4px 12px; font-size: 12px;">수료증 다운로드</button>
                                </div>`;
                        }
                    } else {
                        if (course.cancelable == 'Y') {
                            html += `
                            <div style="text-align: right; margin-top: 10px;">
                              <button class="btn btn-outline btn-sm cancel-btn" onclick="event.stopPropagation(); location.assign('${path}/payment/refund-form?enrSeq=\${course.enrSeq}')">수강 취소</button>
                            </div>
                          `;
                        }
                    }

                    html += `</div>`; // course-item 닫기

                    $container.append(html);
                });

                $('#pageBarContainer').html(res.pageBar);
            }
        });
    }

    function downloadCertificatePost(courseSeq, courseName, courseStartDate, courseEndDate) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = `${path}/certificate`;
        form.style.display = 'none';

        const fields = {
            courseSeq,
            courseName,
            courseStartDate,
            courseEndDate
        };

        for (const key in fields) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = key;
            input.value = fields[key];
            form.appendChild(input);
        }

        document.body.appendChild(form);
        form.submit();
    }



    // Review Modal Functions
    let currentEnrSeq = 0;
    let currentRating = 0;
    let isEditMode = false;

    function openReviewModal(courseName, enrSeq, reviewContent = '', reviewRate = 0) {
        currentCourse = courseName;
        currentEnrSeq = enrSeq;
        isEditMode = reviewRate > 0;

        document.getElementById('reviewCourseTitle').textContent = isEditMode ? `${courseName} 리뷰 수정` : `${courseName} 리뷰 작성`;
        document.getElementById('reviewModal').classList.add('active');
        document.body.style.overflow = 'hidden';

        // 별점 설정
        currentRating = reviewRate;
        document.querySelectorAll('.star').forEach((star, idx) => {
            if (idx < reviewRate) star.classList.add('active');
            else star.classList.remove('active');
        });

        // 텍스트 설정
        const ratingTexts = ['', '별로예요', '그저그래요', '보통이에요', '좋아요', '최고예요!'];
        document.getElementById('ratingText').textContent = reviewRate > 0 ? ratingTexts[reviewRate] : '별점을 선택해주세요';

        // 리뷰 내용 설정
        document.getElementById('reviewContent').value = reviewContent;

        checkFormValidity(); // 버튼 활성화 여부 체크
    }


    function closeReviewModal() {
        document.getElementById('reviewModal').classList.remove('active');
        document.body.style.overflow = 'auto';
        resetReviewForm();
    }

    function resetReviewForm() {
        currentRating = 0;
        document.querySelectorAll('.star').forEach(star => {
            star.classList.remove('active');
        });
        document.getElementById('ratingText').textContent = '별점을 선택해주세요';
        document.getElementById('reviewContent').value = '';
        document.getElementById('submitReview').disabled = true;
    }

    // Star rating functionality
    document.querySelectorAll('.star').forEach(star => {
        star.addEventListener('click', function () {
            const rating = parseInt(this.dataset.rating);
            currentRating = rating;

            // Update star display
            document.querySelectorAll('.star').forEach((s, index) => {
                if (index < rating) {
                    s.classList.add('active');
                } else {
                    s.classList.remove('active');
                }
            });

            // Update rating text
            const ratingTexts = [
                '',
                '별로예요',
                '그저그래요',
                '보통이에요',
                '좋아요',
                '최고예요!'
            ];
            document.getElementById('ratingText').textContent = ratingTexts[rating];

            // Check if form is valid
            checkFormValidity();
        });

        // Hover effect
        star.addEventListener('mouseenter', function () {
            const rating = parseInt(this.dataset.rating);
            document.querySelectorAll('.star').forEach((s, index) => {
                if (index < rating) {
                    s.style.color = '#ffd700';
                } else {
                    s.style.color = '#ddd';
                }
            });
        });
    });

    // Reset hover effect when leaving star area
    document.getElementById('starRating').addEventListener('mouseleave', function () {
        document.querySelectorAll('.star').forEach((star, index) => {
            if (index < currentRating) {
                star.style.color = '#ffd700';
            } else {
                star.style.color = '#ddd';
            }
        });
    });

    // Check form validity
    function checkFormValidity() {
        const content = document.getElementById('reviewContent').value.trim();
        const submitBtn = document.getElementById('submitReview');

        if (currentRating > 0 && content.length > 0) {
            submitBtn.disabled = false;
        } else {
            submitBtn.disabled = true;
        }
    }

    // Review content validation
    document.getElementById('reviewContent').addEventListener('input', checkFormValidity);

    // Review form submission
    $('#reviewForm').on('submit', function (e) {
        e.preventDefault();
        const content = $('#reviewContent').val().trim();

        if (currentRating === 0 || content.length < 10) {
            showAlert('별점과 리뷰 내용을 입력해주세요.', 'error');
            return;
        }

        const data = {
            enrSeq: currentEnrSeq,
            reviewContent: content,
            reviewRate: currentRating
        };

        const url = isEditMode ? `${path}/review/update` : `${path}/review/insert`;

        $.ajax({
            url,
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(data),
            success: function () {
                showAlert(isEditMode ? '리뷰가 수정되었습니다!' : '리뷰가 등록되었습니다!');
                closeReviewModal();
                updateCourseList(currentTab, 1);
            },
            error: function () {
                showAlert('리뷰 저장 중 오류가 발생했습니다.', 'error');
            }
        });
    });


    function deleteReview(enrSeq) {
        if (!confirm('리뷰를 삭제하시겠습니까?')) return;

        $.ajax({
            url: `${path}/review/delete`,
            method: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({enrSeq: enrSeq}),
            success: function (response) {
                showAlert('리뷰가 삭제되었습니다.');
                updateCourseList(currentTab, 1);
            },
            error: function () {
                showAlert('리뷰 삭제 중 오류가 발생했습니다.', 'error');
            }
        });
    }


    // Close modal when clicking outside
    document.getElementById('reviewModal').addEventListener('click', function (e) {
        if (e.target === this) {
            closeReviewModal();
        }
    });

    // Escape key to close modal
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && document.getElementById('reviewModal').classList.contains('active')) {
            closeReviewModal();
        }
    });

    function getCourseStatus(startDateStr, endDateStr) {
        const today = new Date();
        const startDate = new Date(startDateStr);
        const endDate = new Date(endDateStr);

        if (today < startDate) return '대기중';
        if (today > endDate) return '수강완료';
        return '수강중';
    }

    function formatDate(date) {
        const d = new Date(date);
        return d.toLocaleDateString('ko-KR', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        });
    }

</script>
<script>
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function () {
            const sectionId = this.dataset.section;
            if (sectionId === 'attendance') {
                loadAttendanceCourses();
            }
        });
    });

    let calendar;

    function loadAttendanceCourses() {
        $.ajax({
            url: `${path}/mypage/attend-courses`,
            method: 'GET',
            success: function (courses) {
                const $select = $('#courseSelect');
                $select.empty();
                $select.append('<option value="">강의 선택</option>');

                courses.forEach(course => {
                    $select.append(`<option value="\${course.courseSeq}"
                    data-rate="\${course.presentRate}"
                    data-present="\${course.presentCount}"
                    data-total="\${course.totalEpisodeCount}">
                    \${course.courseName}
                </option>`);
                });
            }
        });
    }

    $('#courseSelect').on('change', function () {
        const courseSeq = $(this).val();
        if (!courseSeq) return;

        const rateRaw = $('option:selected', this).data('rate') ?? 0;
        const rate = Math.round(rateRaw);
        const present = $('option:selected', this).data('present') ?? 0;
        const total = $('option:selected', this).data('total') ?? 0;
        const absent = total - present;

        $('#statRate').text(rate + '%');
        $('#statPresent').text(present);
        $('#statAbsent').text(absent < 0 ? 0 : absent);

        loadPresentDates(courseSeq);
    });

    function loadPresentDates(courseSeq) {
        $.ajax({
            url: `${path}/mypage/attend-dates`,
            method: 'GET',
            data: {courseSeq},
            success: function (timestamps) {
                const events = timestamps.map(ts => ({
                    title: '출석',
                    start: ts,
                    allDay: true,
                    color: '#162D43'
                }));

                if (calendar) calendar.destroy();

                calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
                    initialView: 'dayGridMonth',
                    events
                });

                calendar.render();
            }
        });
    }

</script>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const path = '${path}';
        const overlay       = document.getElementById('loadingOverlay');
        const editBtn       = document.getElementById('editProfileBtn');
        const cancelBtn     = document.getElementById('cancelEditBtn');
        const profileView   = document.getElementById('profileView');
        const profileEdit   = document.getElementById('profileEdit');
        const toggleAddrBtn = document.getElementById('toggleAddressBtn');
        const addrView      = document.getElementById('addressView');
        const addrEdit      = document.getElementById('addressEdit');
        const detailInput   = document.getElementById('memberAddress');
        const postcodeEl   = document.getElementById('postcode');
        const roadAddressEl   = document.getElementById('roadAddress');
        const applyBtn      = document.getElementById('applyAddressBtn');
        const cancelAddrBtn = document.getElementById('cancelAddressBtn');
        const form          = document.getElementById('profileUpdateForm');
        const profileFile   = document.getElementById('profileFile');
        const profileImgEl  = document.getElementById('profilePreview');
        const sendBtn       = document.getElementById('sendCodeBtn');
        const verifyBtn     = document.getElementById('verifyCodeBtn');
        const emailInput    = document.getElementById('memberEmail');
        const codeInput     = document.getElementById('authCode');
        const emailMsg      = document.getElementById('emailMsg');
        const codeSection   = document.getElementById('codeSection');
        const timerEl       = document.getElementById('timer');
        let timerInterval;
        let originalEmail    = emailInput.defaultValue;
        let isEmailChanged     = false;
        let isEmailVerified    = false;

        // 1) 개인정보 수정 토글
        editBtn.addEventListener('click', () => {
            profileView.style.display = 'none';
            profileEdit.style.display = 'block';
        });
        cancelBtn.addEventListener('click', () => {
            profileEdit.style.display = 'none';
            profileView.style.display = 'block';
        });

        // 2) 주소 변경 토글
        toggleAddrBtn.addEventListener('click', () => {
            const isEditing = addrEdit.style.display !== 'block';
            // 편집 모드 토글
            addrView.style.display = isEditing ? 'none'  : 'block';
            addrEdit.style.display = isEditing ? 'block' : 'none';
            // 편집 모드일 때만 활성화
            detailInput.readOnly       = !isEditing;
            // 필수 여부도 함께 토글
            postcodeEl.required      =  isEditing;
            roadAddressEl.required   =  isEditing;
            detailInput.required     =  isEditing;
        });
        applyBtn.addEventListener('click', () => {
            const full = document.getElementById('roadAddress').value
                + ' ' + document.getElementById('memberAddress').value;
            document.querySelector('#addressView input').value = full;
            addrEdit.style.display = 'none';
            addrView.style.display = 'block';
        });
        cancelAddrBtn.addEventListener('click', () => {
            document.getElementById('postcode').value       = '';
            document.getElementById('roadAddress').value    = '';
            document.getElementById('memberAddress').value  = '';
            addrEdit.style.display = 'none';
            addrView.style.display = 'block';
        });

        // 3) Daum Postcode
        window.execDaumPostcode = function() {
            new daum.Postcode({
                oncomplete: function(data) {
                    document.getElementById('postcode').value      = data.zonecode;
                    document.getElementById('roadAddress').value   = data.roadAddress;
                    document.getElementById('memberAddress').focus();
                }
            }).open();
        };

        // 4) 프로필 수정 폼 제출 전 최종 검증
        form.addEventListener('submit', function(e) {
            // 이메일 변경 시도했으나 인증 안 된 경우
            if (isEmailChanged && !isEmailVerified) {
                e.preventDefault();
                alert('이메일을 변경하려면 인증을 완료해야 합니다.');
                return;
            }

            // “주소 편집” 모드라면 우편번호·도로명주소 값이 채워졌는지 확인
            if (addrEdit.style.display === 'block') {
                if (!postcodeEl.value.trim() || !roadAddressEl.value.trim()) {
                    e.preventDefault();
                    alert('주소를 제대로 입력하지 않았습니다.');
                    return;
                }
                this.memberAddress.value =
                    roadAddressEl.value.trim()
                    + ' '
                    + detailInput.value.trim();
            }

            // 비밀번호 복합성 검증
            const v  = document.getElementById('newPwd').value;
            if (pwChangeSec.style.display === 'block' && !v) {
                e.preventDefault();
                alert('새 비밀번호를 입력하지 않아 기존 비밀번호가 유지됩니다.');
                return;
            }
            if (v) {
                const ok = v.length >= 8
                    && /[A-Za-z]/.test(v)
                    && /\d/.test(v)
                    && /[!@#$%^&*()_+=-]/.test(v);
                if (!ok) {
                    e.preventDefault();
                    alert('비밀번호는 8자 이상, 영문자·숫자·특수문자를 최소 1개씩 포함해야 합니다.');
                    return;
                }
            }

            if (pwChangeSec.style.display === 'block' && v) {
                if (newPwd.value !== newConfirm.value) {
                    e.preventDefault();
                    alert('새 비밀번호와 비밀번호 확인이 일치하지 않습니다.');
                    return;
                }
            }
            overlay.style.display = 'flex';
        });

        // 5) 프로필 이미지 미리보기
        profileFile.addEventListener('change', e => {
            const file = e.target.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = evt => profileImgEl.src = evt.target.result;
            reader.readAsDataURL(file);
        });

        // 6) 이메일 인증 요청
        emailInput.addEventListener('input', () => {
            isEmailChanged = emailInput.value.trim() !== originalEmail.trim();
            // 변경 시도 시에만 인증 요청 버튼 활성화
            sendBtn.disabled   = !isEmailChanged;
            // 입력 바꾸면 이전에 완료된 인증 무효화
            isEmailVerified    = false;
            verifyBtn.disabled = true;
            codeSection.style.display = 'none';
            emailMsg.textContent      = '';
        });

        sendBtn.addEventListener('click', function() {
            const email = emailInput.value.trim();
            if (!email) {
                alert('이메일을 입력해주세요.');
                return;
            }

            // 1. 이메일 중복 체크
            overlay.style.display = 'flex';
            fetch(path + '/member/check-email?email=' + encodeURIComponent(email))
                .then(res => {
                    if (!res.ok) throw new Error(res.status);
                    return res.json();
                })
                .then(data => {
                    overlay.style.display = 'none';
                    if (data.duplicate) {
                        alert('이미 사용 중인 이메일입니다. 다른 이메일을 입력해주세요.');
                        return;
                    }

                    // 2. 중복이 아니라면 인증번호 요청
                    emailMsg.textContent = '';
                    overlay.style.display = 'flex';
                    return fetch(path + '/member/sendAuthCode', {
                        method: 'POST',
                        headers: {'Content-Type':'application/x-www-form-urlencoded'},
                        body: 'email=' + encodeURIComponent(email)
                    });
                })
                .then(res => {
                    if (!res) return; // 중복된 경우 fetch null
                    overlay.style.display = 'none';
                    if (!res.ok) throw new Error(res.status);
                    return res.text();
                })
                .then(msg => {
                    if (!msg) return; // 중복된 경우
                    codeSection.style.display = 'flex';
                    emailInput.readOnly       = true;
                    sendBtn.textContent       = '재요청';
                    verifyBtn.disabled        = false;
                    startTimer(300);
                })
                .catch(err => {
                    overlay.style.display = 'none';
                    console.error(err);
                    alert('인증번호 요청 중 오류가 발생했습니다.');
                });
        });

        // 7) 인증번호 확인
        verifyBtn.addEventListener('click', function() {
            const code = codeInput.value;
            fetch(path + '/member/verifyAuthCode', {
                method: 'POST',
                headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: 'code=' + encodeURIComponent(code)
            })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        clearInterval(timerInterval);
                        originalEmail = emailInput.value;   // 기존값 업데이트
                        isEmailChanged = false;
                        isEmailVerified  = true;
                        emailMsg.textContent       = '✅ 이메일 인증 완료';
                        emailInput.readOnly       = true;
                        codeInput.readOnly        = true;
                        sendBtn.disabled           = true;
                        verifyBtn.disabled         = true;
                    } else {
                        emailMsg.textContent       = data.error;
                    }
                })
                .catch(err => { console.error(err); alert('인증번호 확인 중 오류가 발생했습니다.'); });
        });

        // 8) 타이머 로직
        function startTimer(sec) {
            clearInterval(timerInterval);
            timerInterval = setInterval(() => {
                if (sec <= 0) {
                    clearInterval(timerInterval);
                    emailMsg.textContent = '⏰ 인증시간 만료. 다시 요청해주세요.';
                    return;
                }
                sec--;
                const m = String(Math.floor(sec/60)).padStart(2,'0');
                const s = String(sec % 60).padStart(2,'0');
                timerEl.textContent   = m + ':' + s;
            }, 1000);
        }

        // 9) 비밀번호 변경 검증
        const pwdVerifyBtn = document.getElementById('pwdVerifyBtn');
        const currentPwd   = document.getElementById('currentPwd');
        const pwdVerifyMsg = document.getElementById('pwdVerifyMsg');
        const pwChangeSec  = document.getElementById('pwChangeSection');

        pwdVerifyBtn.addEventListener('click', () => {
            const pwd = currentPwd.value.trim();
            if (!pwd) { pwdVerifyMsg.textContent = '기존 비밀번호를 입력해주세요.'; return; }
            pwdVerifyMsg.textContent = '';
            overlay.style.display    = 'flex';

            fetch(path + '/member/verifyCurrentPwd', {
                method: 'POST',
                headers: {'Content-Type':'application/x-www-form-urlencoded'},
                body: 'currentPwd=' + encodeURIComponent(pwd)
            })
                .then(res => { overlay.style.display = 'none'; if (!res.ok) throw new Error(res.status); return res.json(); })
                .then(data => {
                    if (data.success) {
                        pwChangeSec.style.display = 'block';
                        pwdVerifyBtn.disabled     = true;
                        currentPwd.readOnly       = true;
                        pwdVerifyMsg.style.color  = 'green';
                        pwdVerifyMsg.textContent  = '✅ 인증 완료';

                    } else {
                        pwdVerifyMsg.style.color  = '#c62828';
                        pwdVerifyMsg.textContent  = data.error || '비밀번호가 일치하지 않습니다.';
                    }
                })
                .catch(err => {
                    overlay.style.display    = 'none';
                    console.error(err);
                    pwdVerifyMsg.style.color = '#c62828';
                    pwdVerifyMsg.textContent = '서버 오류, 잠시 후 다시 시도해주세요.';
                });
        });

        // 10) 새 비밀번호–확인 일치 여부 실시간 체크
        const newPwd     = document.getElementById('newPwd');
        const newConfirm = document.getElementById('newConfirmPwd');
        const pwdCheckMsg= document.getElementById('pwdCheckMsg');

        function checkNewPwdMatch() {
            if (!newPwd.value || !newConfirm.value) {
                pwdCheckMsg.textContent = '';
                return;
            }
            if (newPwd.value === newConfirm.value) {
                pwdCheckMsg.style.color   = 'green';
                pwdCheckMsg.textContent   = '비밀번호가 일치합니다.';
            } else {
                pwdCheckMsg.style.color   = 'red';
                pwdCheckMsg.textContent   = '비밀번호가 일치하지 않습니다.';
            }
        }
        newPwd.addEventListener('input', checkNewPwdMatch);
        newConfirm.addEventListener('input', checkNewPwdMatch);

        // 11) 새 비밀번호 복합성 실시간 체크
        newPwd.addEventListener('input', function () {
            const v = this.value;
            const checks = {
                'crit-length': v.length >= 8,
                'crit-letter': /[A-Za-z]/.test(v),
                'crit-number': /\d/.test(v),
                'crit-special': /[!@#$%^&*()_+=-]/.test(v)
            };
            for (let id in checks) {
                const el = document.getElementById(id);
                if (checks[id]) {
                    el.style.color = 'green';
                    el.style.textDecoration = 'none';
                } else {
                    el.style.color = 'red';
                    el.style.textDecoration = 'none';
                }
            }
        });


    }); // end DOMContentLoaded
</script>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
