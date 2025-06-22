<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
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
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
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
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
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
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
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
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
</style>

<!-- Main Container -->
<div class="main-container">
  <!-- Sidebar -->
  <aside class="sidebar">
    <div class="user-profile">
      <div class="profile-image">김</div>
      <div class="user-name">김학생</div>
      <div class="user-level">Regular 회원</div>
    </div>

    <ul class="sidebar-menu">
      <li><a href="#" class="menu-item active" data-section="profile">
        <span class="icon">👤</span>
        <span>개인정보 수정</span>
      </a></li>
      <li><a href="#" class="menu-item" data-section="courses">
        <span class="icon">📚</span>
        <span>수강 신청 내역</span>
      </a></li>
      <li><a href="#" class="menu-item" data-section="attendance">
        <span class="icon">📅</span>
        <span>출석 정보</span>
      </a></li>
      <li><a href="#" class="menu-item" data-section="refund">
        <span class="icon">💰</span>
        <span>환불</span>
      </a></li>
      <li><a href="#" class="menu-item" data-section="settings">
        <span class="icon">⚙️</span>
        <span>설정</span>
      </a></li>
    </ul>
  </aside>

  <!-- Main Content -->
  <main class="main-content">
    <!-- Profile Section -->
    <div class="profile-section active" id="profile">
      <div class="page-header">
        <h1 class="page-title">개인정보 수정</h1>
        <p class="page-subtitle">개인정보를 안전하게 관리하세요</p>
      </div>

      <form class="profile-form">
        <div class="form-row">
          <div class="form-group">
            <label class="form-label">이름</label>
            <input type="text" class="form-input" value="김학생" required>
          </div>
          <div class="form-group">
            <label class="form-label">생년월일</label>
            <input type="date" class="form-input" value="1995-03-15">
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">이메일</label>
          <input type="email" class="form-input" value="student@example.com" required>
        </div>

        <div class="form-group">
          <label class="form-label">휴대폰 번호</label>
          <input type="tel" class="form-input" value="010-1234-5678" required>
        </div>

        <div class="form-group">
          <label class="form-label">주소</label>
          <input type="text" class="form-input" value="서울시 강남구 역삼동">
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="form-label">새 비밀번호</label>
            <input type="password" class="form-input" placeholder="변경하려면 입력하세요">
          </div>
          <div class="form-group">
            <label class="form-label">비밀번호 확인</label>
            <input type="password" class="form-input" placeholder="비밀번호를 다시 입력하세요">
          </div>
        </div>

        <button type="submit" class="btn btn-primary">저장하기</button>
      </form>
    </div>

    <!-- Courses Section -->
    <div class="course-section" id="courses">
      <div class="page-header">
        <h1 class="page-title">수강 신청 내역</h1>
        <p class="page-subtitle">신청한 강의를 확인하고 관리하세요</p>
      </div>

      <div class="course-tabs">
        <button class="tab-btn active" data-tab="current">수강중</button>
        <button class="tab-btn" data-tab="completed">수강완료</button>
        <button class="tab-btn" data-tab="pending">대기중</button>
      </div>

      <div class="course-list" id="currentCourses">
        <div class="course-item">
          <div class="course-header">
            <div class="course-info">
              <h3>풀스택 웹개발 마스터 부트캠프</h3>
              <div class="course-meta">
                <span>📅 2025.01.15 ~ 2025.04.15</span>
                <span>⏰ 평일 19:00-22:00</span>
                <span>📍 강남 캠퍼스</span>
              </div>
            </div>
            <div class="course-status status-progress">수강중</div>
          </div>
          <div class="course-progress">
            <div class="progress-header">
              <span>진도율</span>
              <span>65%</span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill" style="width: 65%"></div>
            </div>
          </div>
        </div>

        <div class="course-item">
          <div class="course-header">
            <div class="course-info">
              <h3>React Native 모바일 앱 개발</h3>
              <div class="course-meta">
                <span>📅 2025.02.01 ~ 2025.03.26</span>
                <span>⏰ 주말 10:00-18:00</span>
                <span>📍 강남 캠퍼스</span>
              </div>
            </div>
            <div class="course-status status-progress">수강중</div>
          </div>
          <div class="course-progress">
            <div class="progress-header">
              <span>진도율</span>
              <span>30%</span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill" style="width: 30%"></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Attendance Section -->
    <div class="attendance-section" id="attendance">
      <div class="page-header">
        <h1 class="page-title">출석 정보</h1>
        <p class="page-subtitle">출석률을 확인하고 관리하세요</p>
      </div>

      <div class="attendance-stats">
        <div class="stat-card">
          <div class="stat-number">85%</div>
          <div class="stat-label">전체 출석률</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">34</div>
          <div class="stat-label">출석일</div>
        </div>
        <div class="stat-card">
          <div class="stat-number">6</div>
          <div class="stat-label">결석일</div>
        </div>
      </div>

      <div class="attendance-calendar">
        <div class="calendar-header">
          <h3 class="calendar-title">2025년 6월</h3>
          <div class="calendar-nav">
            <button class="nav-btn">◀</button>
            <button class="nav-btn">▶</button>
          </div>
        </div>
        <div class="calendar-grid">
          <div class="calendar-day">일</div>
          <div class="calendar-day">월</div>
          <div class="calendar-day">화</div>
          <div class="calendar-day">수</div>
          <div class="calendar-day">목</div>
          <div class="calendar-day">금</div>
          <div class="calendar-day">토</div>
          <div class="calendar-day">1</div>
          <div class="calendar-day attended">2</div>
          <div class="calendar-day attended">3</div>
          <div class="calendar-day attended">4</div>
          <div class="calendar-day attended">5</div>
          <div class="calendar-day attended">6</div>
          <div class="calendar-day">7</div>
          <div class="calendar-day">8</div>
          <div class="calendar-day attended">9</div>
          <div class="calendar-day attended">10</div>
          <div class="calendar-day attended">11</div>
          <div class="calendar-day attended">12</div>
          <div class="calendar-day absent">13</div>
          <div class="calendar-day">14</div>
          <div class="calendar-day">15</div>
          <div class="calendar-day today">16</div>
          <div class="calendar-day">17</div>
          <div class="calendar-day">18</div>
          <div class="calendar-day">19</div>
          <div class="calendar-day">20</div>
          <div class="calendar-day">21</div>
          <div class="calendar-day">22</div>
          <div class="calendar-day">23</div>
          <div class="calendar-day">24</div>
          <div class="calendar-day">25</div>
          <div class="calendar-day">26</div>
          <div class="calendar-day">27</div>
          <div class="calendar-day">28</div>
          <div class="calendar-day">29</div>
          <div class="calendar-day">30</div>
        </div>
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

<script>
  // Menu navigation
  document.querySelectorAll('.menu-item').forEach(item => {
    item.addEventListener('click', function(e) {
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
    btn.addEventListener('click', function() {
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

  function updateCourseList(tab) {
    const courseList = document.getElementById('currentCourses');

    switch(tab) {
      case 'current':
        courseList.innerHTML = `
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>풀스택 웹개발 마스터 부트캠프</h3>
                                    <div class="course-meta">
                                        <span>📅 2025.01.15 ~ 2025.04.15</span>
                                        <span>⏰ 평일 19:00-22:00</span>
                                        <span>📍 강남 캠퍼스</span>
                                    </div>
                                </div>
                                <div class="course-status status-progress">수강중</div>
                            </div>
                            <div class="course-progress">
                                <div class="progress-header">
                                    <span>진도율</span>
                                    <span>65%</span>
                                </div>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 65%"></div>
                                </div>
                            </div>
                        </div>
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>React Native 모바일 앱 개발</h3>
                                    <div class="course-meta">
                                        <span>📅 2025.02.01 ~ 2025.03.26</span>
                                        <span>⏰ 주말 10:00-18:00</span>
                                        <span>📍 강남 캠퍼스</span>
                                    </div>
                                </div>
                                <div class="course-status status-progress">수강중</div>
                            </div>
                            <div class="course-progress">
                                <div class="progress-header">
                                    <span>진도율</span>
                                    <span>30%</span>
                                </div>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 30%"></div>
                                </div>
                            </div>
                        </div>
                    `;
        break;
      case 'completed':
        courseList.innerHTML = `
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>JavaScript 기초 완성 과정</h3>
                                    <div class="course-meta">
                                        <span>📅 2024.10.01 ~ 2024.12.15</span>
                                        <span>⏰ 평일 19:00-21:00</span>
                                        <span>📍 강남 캠퍼스</span>
                                    </div>
                                </div>
                                <div class="course-status status-completed">수강완료</div>
                            </div>
                            <div class="course-progress">
                                <div class="progress-header">
                                    <span>수료증 발급 가능</span>
                                    <button class="btn btn-primary" style="padding: 4px 12px; font-size: 12px;">수료증 다운로드</button>
                                </div>
                            </div>
                        </div>
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>HTML/CSS 웹 디자인 기초</h3>
                                    <div class="course-meta">
                                        <span>📅 2024.08.01 ~ 2024.09.30</span>
                                        <span>⏰ 주말 10:00-16:00</span>
                                        <span>📍 홍대 캠퍼스</span>
                                    </div>
                                </div>
                                <div class="course-status status-completed">수강완료</div>
                            </div>
                            <div class="course-progress">
                                <div class="progress-header">
                                    <span>수료증 발급 가능</span>
                                    <button class="btn btn-primary" style="padding: 4px 12px; font-size: 12px;">수료증 다운로드</button>
                                </div>
                            </div>
                        </div>
                    `;
        break;
      case 'pending':
        courseList.innerHTML = `
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>Vue.js 프론트엔드 개발</h3>
                                    <div class="course-meta">
                                        <span>📅 2025.07.01 ~ 2025.08.30</span>
                                        <span>⏰ 평일 19:00-22:00</span>
                                        <span>📍 판교 캠퍼스</span>
                                    </div>
                                </div>
                                <div class="course-status status-pending">개강대기</div>
                            </div>
                            <div class="course-progress">
                                <div class="progress-header">
                                    <span>개강까지 15일 남음</span>
                                    <button class="btn btn-outline" style="padding: 4px 12px; font-size: 12px;" onclick="confirmAction('수강취소')">수강 취소</button>
                                </div>
                            </div>
                        </div>
                    `;
        break;
    }
  }

  // Calendar navigation
  document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      // Calendar navigation logic would go here
      console.log('Calendar navigation clicked');
    });
  });

  // Form submissions
  document.querySelector('.profile-form').addEventListener('submit', function(e) {
    e.preventDefault();
    showAlert('개인정보가 성공적으로 수정되었습니다.');
  });

  document.querySelector('.refund-form').addEventListener('submit', function(e) {
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
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
