<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<link rel="stylesheet" href="${path}/resources/css/teacherView.css"/>
<!-- Instructor Profile -->
<div class="instructor-profile">
  <!-- Instructor Sidebar -->
  <aside class="instructor-sidebar">
    <div class="instructor-photo">
      👨‍💻
    </div>
    <div class="instructor-info">
      <h2>김민수</h2>
      <p class="instructor-title">풀스택 개발자 / 시니어 강사</p>

      <div class="instructor-stats">
        <div class="stat-item">
          <span class="stat-label">총 강의</span>
          <span class="stat-value">12개</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">총 수강생</span>
          <span class="stat-value">1,247명</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">평균 평점</span>
          <span class="stat-value">⭐ 4.8</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">경력</span>
          <span class="stat-value">8년</span>
        </div>
      </div>

      <button class="portfolio-btn" onclick="downloadPortfolio()">
        📄 포트폴리오 다운로드
      </button>

      <div class="instructor-bio">
        <h3>강사 소개</h3>
        <p>
          10년간 다양한 프로젝트를 진행하며 쌓은 실무 경험을 바탕으로
          실전에서 사용할 수 있는 개발 기술을 전달합니다.
          현재 테크 스타트업에서 CTO로 재직 중이며,
          최신 기술 트렌드를 반영한 실용적인 교육을 제공합니다.
        </p>
      </div>
    </div>
  </aside>

  <!-- Main Content -->
  <main class="main-content">
    <div class="content-header">
      <div>
        <h2>김민수 강사의 강의</h2>
        <p class="course-count">총 <strong>12개</strong>의 강의</p>
      </div>
      <div class="sort-options">
        <select class="sort-select" onchange="sortCourses()">
          <option value="latest">최신순</option>
          <option value="popular">인기순</option>
          <option value="rating">평점순</option>
        </select>
      </div>
    </div>

    <div class="course-grid" id="courseGrid">
      <!-- Sample Course Cards -->
      <div class="course-card" onclick="viewCourse(1)">
        <div class="course-image">
          <span class="course-badge">HOT</span>
          Java 완전정복
        </div>
        <div class="course-content">
          <div class="course-meta">
            <span>👨‍💻 백엔드</span>
            <span>⭐4.9 156명 수강</span>
          </div>
          <h3 class="course-title">Java 완전정복 - 기초부터 실전까지</h3>
          <div class="course-schedule">
            <div class="schedule-row">
              <span class="schedule-label">시작일</span>
              <span class="schedule-value">2025-07-01</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">일시</span>
              <span class="schedule-value">월, 수, 금</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">장소</span>
              <span class="schedule-value">강남캠퍼스</span>
            </div>
          </div>
          <div class="course-footer">
            <div class="course-price">
              <span class="price-original">200,000원</span>
              <span class="price-current">150,000원</span>
            </div>
            <button class="btn-enroll">수강 신청</button>
          </div>
        </div>
      </div>

      <div class="course-card" onclick="viewCourse(2)">
        <div class="course-image">
          <span class="course-badge">NEW</span>
          Spring Boot 마스터
        </div>
        <div class="course-content">
          <div class="course-meta">
            <span>👨‍💻 백엔드</span>
            <span>⭐4.8 89명 수강</span>
          </div>
          <h3 class="course-title">Spring Boot로 배우는 웹 개발</h3>
          <div class="course-schedule">
            <div class="schedule-row">
              <span class="schedule-label">시작일</span>
              <span class="schedule-value">2025-07-15</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">일시</span>
              <span class="schedule-value">화, 목</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">장소</span>
              <span class="schedule-value">온라인</span>
            </div>
          </div>
          <div class="course-footer">
            <div class="course-price">
              <span class="price-original">250,000원</span>
              <span class="price-current">180,000원</span>
            </div>
            <button class="btn-enroll">수강 신청</button>
          </div>
        </div>
      </div>

      <div class="course-card" onclick="viewCourse(3)">
        <div class="course-image">
          React 실전 프로젝트
        </div>
        <div class="course-content">
          <div class="course-meta">
            <span>💻 프론트엔드</span>
            <span>⭐4.7 124명 수강</span>
          </div>
          <h3 class="course-title">React로 만드는 실전 웹 애플리케이션</h3>
          <div class="course-schedule">
            <div class="schedule-row">
              <span class="schedule-label">시작일</span>
              <span class="schedule-value">2025-08-01</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">일시</span>
              <span class="schedule-value">토, 일</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">장소</span>
              <span class="schedule-value">홍대캠퍼스</span>
            </div>
          </div>
          <div class="course-footer">
            <div class="course-price">
              <span class="price-original">300,000원</span>
              <span class="price-current">220,000원</span>
            </div>
            <button class="btn-enroll">수강 신청</button>
          </div>
        </div>
      </div>

      <div class="course-card" onclick="viewCourse(4)">
        <div class="course-image">
          데이터베이스 설계
        </div>
        <div class="course-content">
          <div class="course-meta">
            <span>🗄️ 데이터베이스</span>
            <span>⭐4.6 67명 수강</span>
          </div>
          <h3 class="course-title">실무 중심 데이터베이스 설계 및 최적화</h3>
          <div class="course-schedule">
            <div class="schedule-row">
              <span class="schedule-label">시작일</span>
              <span class="schedule-value">2025-07-20</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">일시</span>
              <span class="schedule-value">월, 수</span>
            </div>
            <div class="schedule-row">
              <span class="schedule-label">장소</span>
              <span class="schedule-value">온라인</span>
            </div>
          </div>
          <div class="course-footer">
            <div class="course-price">
              <span class="price-original">180,000원</span>
              <span class="price-current">140,000원</span>
            </div>
            <button class="btn-enroll">수강 신청</button>
          </div>
        </div>
      </div>
    </div>
  </main>
</div>

<script>
  // 포트폴리오 다운로드 함수
  function downloadPortfolio() {
    // 실제로는 서버에서 파일을 다운로드하는 로직이 들어갑니다
    alert('포트폴리오 다운로드가 시작됩니다.');

    // 예시: 가상의 PDF 파일 다운로드
    const link = document.createElement('a');
    link.href = '#'; // 실제 PDF 파일 경로
    link.download = '김민수_포트폴리오.pdf';
    link.click();
  }

  // 강의 정렬 함수
  function sortCourses() {
    const sortValue = document.querySelector('.sort-select').value;
    console.log('정렬 기준:', sortValue);

    // 실제로는 서버에 정렬 요청을 보내거나
    // 클라이언트에서 정렬 로직을 수행합니다
    alert(`${sortValue} 기준으로 정렬합니다.`);
  }

  // 강의 상세 보기
  function viewCourse(courseId) {
    console.log('강의 ID:', courseId);
    alert(`강의 ${courseId} 상세 페이지로 이동합니다.`);
    // 실제로는 강의 상세 페이지로 이동
    // window.location.href = `/course/view?courseSeq=${courseId}`;
  }

  // 페이지 로드 시 초기화
  document.addEventListener('DOMContentLoaded', function() {
    console.log('강사 프로필 페이지가 로드되었습니다.');

    // 실제로는 서버에서 강사 정보와 강의 목록을 불러오는 로직이 들어갑니다
    // loadInstructorInfo();
    // loadInstructorCourses();
  });

  // 수강 신청 버튼 이벤트 처리
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('btn-enroll')) {
      e.stopPropagation(); // 카드 클릭 이벤트 방지
      alert('수강 신청 페이지로 이동합니다.');
    }
  });
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>