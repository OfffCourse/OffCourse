<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<script>
    // ✅ 먼저 이 두 함수 정의
    function getStatusClass(status) {
        switch (status) {
            case 'pending':
                return 'status-pending';
            case 'approved':
                return 'status-approved';
            case 'rejected':
                return 'status-rejected';
            default:
                return 'status-pending';
        }
    }

    function getStatusText(status) {
        switch (status) {
            case 'pending':
                return '대기중';
            case 'approved':
                return '승인됨';
            case 'rejected':
                return '거부됨';
            default:
                return '대기중';
        }
    }

    // ✅ 그 다음 메인 함수 정의
    function loadAdminDeleteRequests(status = 'pending', cPage = 1) {
        const tabName = status.charAt(0).toUpperCase() + status.slice(1);
        fetch(`${path}/admin/delete-requests?status=\${status}&page=\${cPage}`)
            .then(res => res.json())
            .then(data => {
                let $container;
                if (tabName === 'Pending') {
                    $container = $("#deletePendingTab");
                } else if (tabName === 'Approved') {
                    $container = $("#deleteApprovedTab");
                } else {
                    $container = $("#deleteRejectedTab");
                }
                $container.empty();

                if (!data.courseList || data.courseList.length === 0) {
                    $container.append('<div class="no-data">삭제 요청이 없습니다.</div>');
                    $('#pageBarContainer').empty();
                    return;
                }

                data.courseList.forEach(req => {
                    const isPending = status === 'pending';

                    const buttonsHtml = isPending ? `
                        <div class="request-actions">
                            <button class="btn btn-success" onclick="handleDeleteRequest('\${req.deleteRequestSeq}', 'approve','\${req.courseSeq}')">승인</button>
                            <button class="btn btn-danger" onclick="handleDeleteRequest('\${req.deleteRequestSeq}', 'reject','\${req.courseSeq}')">거부</button>
                        </div>
                    ` : '';

                    $container.append(`
                        <div class="request-item">
                            <div class="request-header">
                                <div class="request-info">
                                    <h3>\${req.courseName}</h3>
                                    <div class="request-meta">
                                        <span>👤 요청자: \${req.teacherName}</span>
                                        <span>👥 수강생: \${req.enrollStudentsCount}명</span>
                                    </div>
                                </div>
                                <div class="request-status \${getStatusClass(status)}">\${getStatusText(status)}</div>
                            </div>
                            <div class="request-details"><strong>삭제 사유:</strong><br>\${req.deleteRequestContent}</div>
                            \${buttonsHtml}
                        </div>
                    `);
                });


                $('#pageBarContainer').html(data.pageBar || '');
            })
            .catch(err => {
                console.error("삭제 요청 로드 실패", err);
                $('#deletePendingTab').html('<div class="error-message">데이터를 불러오는데 실패했습니다.</div>');
            });
    }

    // ✅ 페이지 로드 시 실행
    $(document).ready(() => {
        loadAdminDeleteRequests('pending', 1);
    });

    // ✅ 페이지바 클릭 이벤트
    $('#pageBarContainer').on('click', 'a.page-link', function (e) {
        e.preventDefault();
        const page = $(this).data('page');
        const status = $('.tab-btn.active').data('tab').replace('delete-', '');
        if (page) {
            loadAdminDeleteRequests(status, page);
        }
    });
</script>


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

    .btn-danger {
        background: #dc3545;
        color: white;
    }

    .btn-danger:hover {
        background: #c82333;
    }

    .btn-success {
        background: #28a745;
        color: white;
    }

    .btn-success:hover {
        background: #218838;
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
        background: linear-gradient(135deg, #dc3545, #c82333);
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

    .admin-badge {
        background: #dc3545;
        color: white;
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

    /* Admin Sections */
    .admin-section {
        display: none;
    }

    .admin-section.active {
        display: block;
    }

    .admin-tabs {
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

    .request-list {
        display: grid;
        gap: 20px;
    }

    .request-item {
        border: 1px solid #e5e5e5;
        border-radius: 12px;
        padding: 20px;
        transition: all 0.2s;
    }

    .request-item:hover {
        border-color: #162D43;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    .request-header {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        margin-bottom: 16px;
    }

    .request-info h3 {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
    }

    .request-meta {
        display: flex;
        gap: 16px;
        font-size: 12px;
        color: #666;
    }

    .request-status {
        padding: 4px 12px;
        border-radius: 16px;
        font-size: 12px;
        font-weight: 500;
    }

    .status-pending {
        background: #fff3e0;
        color: #f57c00;
    }

    .status-approved {
        background: #e8f5e8;
        color: #2e7d32;
    }

    .status-rejected {
        background: #ffebee;
        color: #c62828;
    }

    .request-actions {
        display: flex;
        gap: 8px;
        align-items: center;
        margin-top: 16px;
    }

    .request-details {
        margin-top: 16px;
        padding: 16px;
        background: #f8f9fa;
        border-radius: 8px;
        font-size: 14px;
        color: #666;
    }

    /* Stats Cards */
    .stats-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
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

    /* Form Styles */
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

    .form-textarea {
        min-height: 120px;
        resize: vertical;
    }

    /* Modal Styles */
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

    .modal {
        background: white;
        border-radius: 16px;
        padding: 32px;
        max-width: 500px;
        width: 90%;
        max-height: 80vh;
        overflow-y: auto;
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
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

    .modal-actions {
        display: flex;
        gap: 12px;
        justify-content: flex-end;
        margin-top: 24px;
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

        .stats-container {
            grid-template-columns: 1fr;
        }
    }
</style>
<!-- Main Container -->
<div class="main-container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="user-profile">
            <div class="profile-image">관</div>
            <div class="user-name">관리자</div>
            <div class="user-level admin-badge">Admin</div>
        </div>
        <ul class="sidebar-menu">
            <li><a href="#" class="menu-item active" data-section="dashboard">
                <span class="icon">📊</span><span>대시보드</span></a></li>
            <li><a href="#" class="menu-item" data-section="course-delete">
                <span class="icon">🗑️</span><span>강의 삭제 요청</span></a></li>
            <li><a href="#" class="menu-item" data-section="settlement">
                <span class="icon">💰</span><span>정산 요청</span></a></li>
            <li><a href="#" class="menu-item" data-section="user-management">
                <span class="icon">👥</span><span>회원 관리</span></a></li>
            <li><a href="#" class="menu-item" data-section="settings">
                <span class="icon">⚙️</span><span>시스템 설정</span></a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Dashboard -->
        <div class="admin-section active" id="dashboard">
            <div class="page-header">
                <h1 class="page-title">대시보드</h1>
                <p class="page-subtitle">Off Course 관리자 대시보드</p>
            </div>
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">강의 삭제 요청</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">정산 요청</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">총 회원 수</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">활성 강의</div>
                </div>
            </div>
        </div>

        <!-- 삭제 요청 -->
        <div class="admin-section" id="course-delete">
            <div class="page-header">
                <h1 class="page-title">강의 삭제 요청</h1>
                <p class="page-subtitle">강의 삭제 요청을 확인하고 처리하세요</p>
            </div>
            <div class="admin-tabs">
                <button class="tab-btn active" data-tab="delete-pending">대기중</button>
                <button class="tab-btn" data-tab="delete-approved">승인됨</button>
                <button class="tab-btn" data-tab="delete-rejected">거부됨</button>
            </div>
            <div class="request-list" id="deletePendingTab"></div>
            <div class="request-list" id="deleteApprovedTab" style="display:none;"></div>
            <div class="request-list" id="deleteRejectedTab" style="display:none;"></div>
            <div id="pageBarContainer" style="margin-top:20px;"></div>
        </div>

        <!-- 정산 요청 -->
        <div class="admin-section" id="settlement">
            <div class="page-header">
                <h1 class="page-title">정산 요청</h1>
                <p class="page-subtitle">정산 요청을 확인하고 처리하세요</p>
            </div>
            <div class="admin-tabs">
                <button class="tab-btn active" data-tab="settlement-pending">대기중</button>
                <button class="tab-btn" data-tab="settlement-approved">승인됨</button>
                <button class="tab-btn" data-tab="settlement-rejected">거부됨</button>
            </div>
            <div class="request-list" id="settlementPendingTab"></div>
            <div class="request-list" id="settlementApprovedTab" style="display:none;"></div>
            <div class="request-list" id="settlementRejectedTab" style="display:none;"></div>
        </div>

        <!-- 회원 관리 -->
        <div class="admin-section" id="user-management">
            <div class="page-header">
                <h1 class="page-title">회원 관리</h1>
                <p class="page-subtitle">회원 정보를 관리하세요</p>
            </div>
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">총 회원 수</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">강사 수</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">수강생 수</div>
                </div>
            </div>
        </div>

        <!-- 시스템 설정 -->
        <!-- 시스템 설정 섹션 개선 버전 -->
        <div class="admin-section" id="settings">
            <div class="page-header">
                <h1 class="page-title">시스템 설정</h1>
                <p class="page-subtitle">시스템 설정을 관리하세요</p>
            </div>

            <div class="settings-form">
                <div class="form-group">
                    <label class="form-label">알림 설정</label>
                    <div class="checkbox-group">
                        <div class="checkbox-item">
                            <input type="checkbox" id="deleteNotification" checked>
                            <label for="deleteNotification">강의 삭제 요청 알림</label>
                        </div>
                        <div class="checkbox-item">
                            <input type="checkbox" id="settlementNotification" checked>
                            <label for="settlementNotification">정산 요청 알림</label>
                        </div>
                        <div class="checkbox-item">
                            <input type="checkbox" id="memberJoinNotification">
                            <label for="memberJoinNotification">회원 가입 알림</label>
                        </div>
                    </div>
                </div>

                <div class="settings-actions">
                    <button class="btn btn-primary" onclick="saveSystemSettings()">설정 저장</button>
                    <button class="btn btn-outline" onclick="loadSystemSettings()">설정 초기화</button>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- 추가 CSS 스타일 -->
<style>
    /* 빈 데이터 표시 */
    .no-data {
        text-align: center;
        padding: 60px 20px;
        color: #666;
        font-size: 16px;
    }

    .no-data::before {
        content: "📝";
        display: block;
        font-size: 48px;
        margin-bottom: 16px;
    }

    /* 에러 메시지 */
    .error-message {
        text-align: center;
        padding: 60px 20px;
        color: #dc3545;
        font-size: 16px;
        background: #fff5f5;
        border: 1px solid #fed7d7;
        border-radius: 8px;
    }

    .error-message::before {
        content: "⚠️";
        display: block;
        font-size: 48px;
        margin-bottom: 16px;
    }

    /* 로딩 표시 */
    .loading {
        text-align: center;
        padding: 60px 20px;
        color: #666;
        font-size: 16px;
    }

    .loading::before {
        content: "⏳";
        display: block;
        font-size: 48px;
        margin-bottom: 16px;
        animation: pulse 1.5s ease-in-out infinite;
    }

    @keyframes pulse {
        0%, 100% {
            opacity: 1;
        }
        50% {
            opacity: 0.5;
        }
    }

    /* 시스템 설정 폼 개선 */
    .settings-form {
        background: #f8f9fa;
        padding: 24px;
        border-radius: 12px;
        margin-bottom: 24px;
    }

    .checkbox-group {
        display: flex;
        flex-direction: column;
        gap: 16px;
    }

    .checkbox-item {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px;
        background: white;
        border-radius: 8px;
        border: 1px solid #e5e5e5;
    }

    .checkbox-item input[type="checkbox"] {
        width: 18px;
        height: 18px;
        accent-color: #162D43;
    }

    .checkbox-item label {
        font-size: 14px;
        color: #333;
        cursor: pointer;
        flex: 1;
    }

    .settings-actions {
        margin-top: 24px;
    }

    /* 요청 아이템 hover 효과 개선 */
    .request-item {
        transition: all 0.3s ease;
    }

    .request-item:hover {
        transform: translateY(-2px);
    }

    /* 통계 카드 hover 효과 */
    .stat-card {
        transition: all 0.3s ease;
        cursor: pointer;
    }

    .stat-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    }

    /* 반응형 개선 */
    @media (max-width: 480px) {
        .request-actions {
            flex-direction: column;
        }

        .request-actions .btn {
            width: 100%;
        }

        .modal {
            margin: 20px;
            width: calc(100% - 40px);
        }
    }
</style>
<script>
    const path = "${path}";

    // 섹션 전환 (사이드바)
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function (e) {
            e.preventDefault();
            document.querySelectorAll('.menu-item').forEach(m => m.classList.remove('active'));
            this.classList.add('active');
            document.querySelectorAll('.admin-section').forEach(s => {
                s.style.display = 'none';
                s.classList.remove('active');
            });
            const sec = document.getElementById(this.dataset.section);
            if (sec) {
                sec.style.display = 'block';
                sec.classList.add('active');

                // 섹션별 초기 데이터 로드
                loadSectionData(this.dataset.section);
            }
        });
    });

    // 탭 전환
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const container = this.closest('.admin-tabs');
            container.querySelectorAll('.tab-btn').forEach(t => t.classList.remove('active'));
            this.classList.add('active');

            const section = this.closest('.admin-section');
            section.querySelectorAll('.request-list').forEach(r => r.style.display = 'none');

            const tabId = this.dataset.tab;
            let targetId = '';
            if (tabId.startsWith('delete-')) {
                targetId = 'delete' + tabId.replace('delete-', '').replace(/^\w/, c => c.toUpperCase()) + 'Tab';
            } else if (tabId.startsWith('settlement-')) {
                targetId = 'settlement' + tabId.replace('settlement-', '').replace(/^\w/, c => c.toUpperCase()) + 'Tab';
            }
            const targ = document.getElementById(targetId);
            if (targ) {
                targ.style.display = 'block';

                // 탭별 데이터 로드
                loadTabData(tabId);
            }
        });
    });

    // 섹션별 데이터 로드 함수
    function loadSectionData(section) {
        switch (section) {
            case 'dashboard':
                loadDashboardData();
                break;
            case 'course-delete':
                loadDeleteRequests('pending'); // 기본으로 대기중 탭 로드
                break;
            case 'settlement':
                loadSettlementRequests('pending'); // 기본으로 대기중 탭 로드
                break;
            case 'user-management':
                loadUserManagementData();
                break;
            case 'settings':
                loadSystemSettings();
                break;
        }
    }

    // 탭별 데이터 로드 함수
    function loadTabData(tabId) {
        if (tabId.startsWith('delete-')) {
            const status = tabId.replace('delete-', '');
            loadDeleteRequests(status);
        } else if (tabId.startsWith('settlement-')) {
            const status = tabId.replace('settlement-', '');
            loadSettlementRequests(status);
        }
    }

    // 대시보드 데이터 로드
    function loadDashboardData() {
        fetch('${path}/admin/dashboard')
            .then(r => r.json())
            .then(stats => {
                const statNumbers = document.querySelectorAll('#dashboard .stat-number');
                statNumbers[0].textContent = stats.deleteCourseRequestCount || 0;
                statNumbers[1].textContent = stats.accountRequestCount || 0;
                statNumbers[2].textContent = stats.memberCount || 0;
                statNumbers[3].textContent = stats.inProgressCourseCount || 0;
            })
            .catch(error => {
                console.error('대시보드 데이터 로드 실패:', error);
            });
    }


    // 정산 요청 데이터 로드
    function loadSettlementRequests(status = 'pending') {
        fetch(`${path}/admin/settlement-requests?status=\${status}`)
            .then(r => {
                if (!r.ok) throw new Error('Network response was not ok');
                return r.json();
            })
            .then(data => {
                const containerId = `settlement\${status.charAt(0).toUpperCase() + status.slice(1)}Tab`;
                const container = document.getElementById(containerId);

                if (!container) {
                    console.error(`Container \${containerId} not found`);
                    return;
                }

                container.innerHTML = '';

                if (!data || data.length === 0) {
                    container.innerHTML = '<div class="no-data">해당 상태의 요청이 없습니다.</div>';
                    return;
                }

                data.forEach(req => {
                    const statusClass = getStatusClass(status);
                    const statusText = getStatusText(status);
                    const actionsHtml = status === 'pending' ?
                        `<div class="request-actions">
                        <button class="btn btn-success" onclick="handleSettlementRequest('\${req.id}','approve')">승인</button>
                        <button class="btn btn-danger" onclick="handleSettlementRequest('\${req.id}','reject')">거부</button>
                    </div>` : ``;

                    container.insertAdjacentHTML('beforeend', `
                    <div class="request-item">
                        <div class="request-header">
                            <div class="request-info">
                                <h3>\${req.title || '제목 없음'}</h3>
                                <div class="request-meta">
                                    <span>👤 요청자: \${req.instructorName || '알 수 없음'}</span>
                                    <span>📅 요청일: \${req.requestDate || '날짜 없음'}</span>
                                    <span>💰 총액: ₩\${(req.totalAmount || 0).toLocaleString()}</span>
                                </div>
                            </div>
                            <div class="request-status \${statusClass}">\${statusText}</div>
                        </div>
                        <div class="request-details"><strong>내역:</strong><br>\${req.details || '내역 없음'}</div>
                        \${actionsHtml}
                    </div>
                `);
                });
            })
            .catch(error => {
                console.error('정산 요청 데이터 로드 실패:', error);
                const containerId = `settlement\${status.charAt(0).toUpperCase() + status.slice(1)}Tab`;
                const container = document.getElementById(containerId);
                if (container) {
                    container.innerHTML = '<div class="error-message">데이터를 불러오는데 실패했습니다.</div>';
                }
            });
    }

    // 회원 관리 데이터 로드
    function loadUserManagementData() {
        Promise.all([
            fetch(`${path}/admin/users/total`).then(r => r.json()),
            fetch(`${path}/admin/users/instructors`).then(r => r.json()),
            fetch(`${path}/admin/users/students`).then(r => r.json())
        ]).then(([totalUsers, instructors, students]) => {
            const statNumbers = document.querySelectorAll('#user-management .stat-number');
            statNumbers[0].textContent = totalUsers.count || 0;
            statNumbers[1].textContent = instructors.count || 0;
            statNumbers[2].textContent = students.count || 0;
        }).catch(error => {
            console.error('회원 관리 데이터 로드 실패:', error);
        });
    }

    // 시스템 설정 로드
    function loadSystemSettings() {
        fetch(`${path}/admin/settings`)
            .then(r => r.json())
            .then(settings => {
                const checkboxes = document.querySelectorAll('#settings input[type="checkbox"]');
                checkboxes[0].checked = settings.deleteRequestNotification || false;
                checkboxes[1].checked = settings.settlementRequestNotification || false;
                checkboxes[2].checked = settings.memberJoinNotification || false;
            })
            .catch(error => {
                console.error('시스템 설정 로드 실패:', error);
            });
    }


    // 강의 삭제 요청 처리
    function handleDeleteRequest(id, action, courseSeq) {
        if (!confirm(`정말로 이 요청을 \${action == 'approve' ? '승인' : '거부'}하시겠습니까?`)) {
            return;
        }

        fetch(`${path}/admin/course/delete`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({deleteRequestSeq: id, action, courseSeq})
        })
            .then(r => {
                if (!r.ok) throw new Error('Network response was not ok');
                return r.json();
            })
            .then(result => {
                alert(result.message || '처리가 완료되었습니다.');
                loadDeleteRequests('pending'); // 대기중 탭 새로고침
                loadDashboardData(); // 대시보드 통계 업데이트
            })
            .catch(error => {
                console.error('강의 삭제 요청 처리 실패:', error);
                alert('처리 중 오류가 발생했습니다.');
            });
    }

    // 정산 요청 처리
    function handleSettlementRequest(id, action, courseId) {
        if (!confirm(`정말로 이 요청을 \${action == 'approve' ? '승인' : '거부'}하시겠습니까?`)) {
            return;
        }

        fetch(`${path}/admin/settlement`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({requestId: id, action, courseId})
        })
            .then(r => {
                if (!r.ok) throw new Error('Network response was not ok');
                return r.json();
            })
            .then(result => {
                alert(result.message || '처리가 완료되었습니다.');
                loadSettlementRequests('pending'); // 대기중 탭 새로고침
                loadDashboardData(); // 대시보드 통계 업데이트
            })
            .catch(error => {
                console.error('정산 요청 처리 실패:', error);
                alert('처리 중 오류가 발생했습니다.');
            });
    }

    // 시스템 설정 저장
    function saveSystemSettings() {
        const checkboxes = document.querySelectorAll('#settings input[type="checkbox"]');
        const settings = {
            deleteRequestNotification: checkboxes[0].checked,
            settlementRequestNotification: checkboxes[1].checked,
            memberJoinNotification: checkboxes[2].checked
        };

        fetch(`${path}/admin/settings`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(settings)
        })
            .then(r => {
                if (!r.ok) throw new Error('Network response was not ok');
                return r.json();
            })
            .then(result => {
                alert('설정이 저장되었습니다.');
            })
            .catch(error => {
                console.error('시스템 설정 저장 실패:', error);
                alert('설정 저장 중 오류가 발생했습니다.');
            });
    }

    // 초기 로드
    document.addEventListener('DOMContentLoaded', function () {
        // 대시보드 초기 로드
        loadDashboardData();
    });

    // Wrapper 함수 정의 (탭 전환 시 사용될 함수)
    function loadDeleteRequests(status) {
        loadAdminDeleteRequests(status, 1);
    }

</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>