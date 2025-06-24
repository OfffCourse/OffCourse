<%--
  Created by IntelliJ IDEA.
  User: parks
  Date: 2025-06-23
  Time: 오후 2:24
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<style>
  @font-face {
    font-family: 'Cafe24Supermagic-Bold-v1.0';
    src: url('https://fastly.jsdelivr.net/gh/projectnoonnu/noonfonts_2307-2@1.0/Cafe24Supermagic-Bold-v1.0.woff2') format('woff2');
    font-weight: 700;
    font-style: normal;
  }

  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  body {
    font-family: 'Cafe24Supermagic-Bold-v1.0', -apple-system, BlinkMacSystemFont, system-ui, Roboto, 'Helvetica Neue', 'Segoe UI', 'Apple SD Gothic Neo', 'Noto Sans KR', 'Malgun Gothic', sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f8f9fa;
    padding-top: 100px;
  }

  /* Header */
  .header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    z-index: 1000;
    padding: 20px 0;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  }

  .header-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .header-container a{
    text-decoration:none;
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .logo {
    font-size: 32px;
    font-weight: 800;
    color: #162D43;
    text-decoration: none;
    letter-spacing: -0.5px;
  }

  .nav-menu {
    display: flex;
    list-style: none;
    gap: 40px;
  }

  .nav-menu a {
    text-decoration: none;
    color: #1d1d1f;
    font-weight: 500;
    transition: color 0.3s;
    font-size: 19px;
  }

  .nav-menu a:hover {
    color: #162D43;
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
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 40px 20px;
  }

  .detail-wrapper {
    display: grid;
    grid-template-columns: 1fr 400px;
    gap: 40px;
    margin-bottom: 60px;
  }

  /* Left Content */
  .course-main {
    background: white;
    border-radius: 16px;
    padding: 40px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  }

  .course-hero {
    background: linear-gradient(135deg, #162D43, #264058);
    color: white;
    padding: 60px;
    border-radius: 12px;
    text-align: center;
    margin-bottom: 40px;
    position: relative;
  }

  .course-badge {
    position: absolute;
    top: 20px;
    left: 20px;
    background: rgba(255, 255, 255, 0.9);
    color: #162D43;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
  }

  .course-hero h1 {
    font-size: 36px;
    margin-bottom: 20px;
    font-weight: 800;
  }

  .course-meta {
    display: flex;
    justify-content: center;
    gap: 30px;
    font-size: 16px;
    opacity: 0.9;
  }

  .course-meta span {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  /* Course Info Sections */
  .course-section {
    margin-bottom: 40px;
  }

  .section-title {
    font-size: 24px;
    font-weight: 700;
    color: #162D43;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #162D43;
  }

  .category-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .category-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    background: #f8f9fa;
    border-radius: 8px;
    border-left: 4px solid #162D43;
  }

  .category-checkbox {
    width: 20px;
    height: 20px;
    border: 2px solid #162D43;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: white;
  }

  .category-checkbox.checked {
    background: #162D43;
    color: white;
  }

  .category-checkbox.checked::after {
    content: '✓';
    font-size: 14px;
  }

  .category-text {
    font-size: 16px;
    font-weight: 500;
  }

  .curriculum-list {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 24px;
  }

  .curriculum-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 0;
    border-bottom: 1px solid #e9ecef;
  }

  .curriculum-item:last-child {
    border-bottom: none;
  }

  .curriculum-number {
    font-size: 18px;
    font-weight: 700;
    color: #162D43;
    margin-right: 16px;
  }

  .curriculum-content {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .curriculum-actions {
    display: flex;
    gap: 8px;
  }

  .action-btn {
    padding: 8px 16px;
    border: 1px solid #162D43;
    background: white;
    color: #162D43;
    border-radius: 20px;
    font-size: 12px;
    cursor: pointer;
    transition: all 0.2s;
  }

  .action-btn:hover {
    background: #162D43;
    color: white;
  }

  /* Right Sidebar */
  .course-sidebar {
    background: white;
    border-radius: 16px;
    padding: 30px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    height: fit-content;
    position: sticky;
    top: 120px;
  }

  .sidebar-title {
    font-size: 20px;
    font-weight: 700;
    color: #162D43;
    margin-bottom: 24px;
    text-align: center;
  }

  .schedule-grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 8px;
    margin-bottom: 30px;
  }

  .day-cell {
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }

  .day-header {
    background: #162D43;
    color: white;
  }

  .day-number {
    background: #f8f9fa;
    color: #666;
    border: 1px solid #e9ecef;
  }

  .day-number:hover {
    background: #e9ecef;
  }

  .day-selected {
    background: #162D43 !important;
    color: white !important;
  }

  .course-schedule-info {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 30px;
  }

  .schedule-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 12px;
    font-size: 14px;
  }

  .schedule-row:last-child {
    margin-bottom: 0;
  }

  .schedule-label {
    color: #666;
    font-weight: 500;
  }

  .schedule-value {
    font-weight: 600;
    color: #333;
  }

  .enroll-section {
    text-align: center;
  }

  .price-info {
    margin-bottom: 20px;
  }

  .price-original {
    font-size: 16px;
    color: #999;
    text-decoration: line-through;
    margin-bottom: 4px;
  }

  .price-current {
    font-size: 28px;
    font-weight: 800;
    color: #162D43;
  }

  .enroll-btn {
    width: 100%;
    padding: 16px;
    background: #162D43;
    color: white;
    border: none;
    border-radius: 12px;
    font-size: 18px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s;
    margin-bottom: 12px;
  }

  .enroll-btn:hover {
    background: #0f1f2f;
    transform: translateY(-2px);
  }

  .wishlist-btn {
    width: 100%;
    padding: 12px;
    background: white;
    color: #162D43;
    border: 2px solid #162D43;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }

  .wishlist-btn:hover {
    background: #162D43;
    color: white;
  }

  .review-header {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 12px;
  }


  /* Responsive */
  @media (max-width: 768px) {
    .detail-wrapper {
      grid-template-columns: 1fr;
      gap: 20px;
    }

    .course-sidebar {
      position: static;
    }

    .course-hero {
      padding: 40px 20px;
    }

    .course-hero h1 {
      font-size: 24px;
    }

    .course-meta {
      flex-direction: column;
      gap: 12px;
    }

    .schedule-grid {
      grid-template-columns: repeat(7, 1fr);
    }

    /* 리뷰 섹션 */
    .reviews-section {
      background: white;
      padding: 40px;
      border-radius: 12px;
      box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
    }

    .review-summary {
      display: flex;
      gap: 30px;
      margin-bottom: 30px;
      padding-bottom: 20px;
      border-bottom: 1px solid #e9ecef;
    }

    .rating-score {
      text-align: center;
    }

    .score-number {
      font-size: 48px;
      font-weight: 700;
      color: #ff6b35;
    }

    .stars {
      color: #FFD700;
      font-size: 20px;
      margin-bottom: 8px;
    }

    .rating-distribution {
      flex: 1;
    }

    .rating-bar {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 8px;
    }

    .bar-fill {
      flex: 1;
      height: 8px;
      background: #e9ecef;
      border-radius: 4px;
      overflow: hidden;
    }

    .bar-progress {
      height: 100%;
      background: #FFD700;
      transition: width 0.3s ease;
    }

    .review-item {
      padding: 20px 0;
      border-bottom: 1px solid #f1f3f4;
    }

    .review-header {
      display: flex;
      gap: 16px;
      margin-bottom: 12px;
    }

    .review-avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: #667eea;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-weight: 600;
    }

    .review-meta h4 {
      font-size: 14px;
      margin-bottom: 4px;
    }

    .review-date {
      font-size: 12px;
      color: #999;
    }

    .review-content {
      font-size: 14px;
      line-height: 1.6;
      color: #555;
    }
  }
</style>
<!-- Main Content -->
<div class="container">
  <div class="detail-wrapper">
    <!-- Left Content -->
    <div class="course-main">
      <!-- Course Hero -->
      <div class="course-hero">
        <span class="course-badge">HOT</span>
        <h1>${course.courseName}</h1>
        <div class="course-meta">
          <span>👨‍💻 ${course.courseCategory.fullCategoryName}</span>
          <span>⭐ ${course.averageRating}</span>
          <span>📚 총 12강</span>
        </div>
      </div>

      <!-- Course Categories -->
      <div class="course-section">
        <h2 class="section-title">강의 목록</h2>
        <div class="category-list">
          <div class="category-item">
            <div class="category-checkbox checked"></div>
            <span class="category-text">강의 소개</span>
          </div>
          <div class="category-item">
            <div class="category-checkbox checked"></div>
            <span class="category-text">기본 문법</span>
          </div>
          <div class="category-item">
            <div class="category-checkbox"></div>
            <span class="category-text">고급 기능</span>
          </div>
        </div>
      </div>

      <!-- Curriculum -->
      <div class="course-section">
        <h2 class="section-title">커리큘럼</h2>
        <div class="curriculum-list">
          <div class="curriculum-item">
            <span class="curriculum-number">1.</span>
            <div class="curriculum-content">
              <span>Java 기초와 개발환경 설정</span>
            </div>
            <div class="curriculum-actions">
              <button class="action-btn">영상보기</button>
              <button class="action-btn">자료받기</button>
            </div>
          </div>
          <div class="curriculum-item">
            <span class="curriculum-number">2.</span>
            <div class="curriculum-content">
              <span>객체지향 프로그래밍 기초</span>
            </div>
            <div class="curriculum-actions">
              <button class="action-btn">영상보기</button>
              <button class="action-btn">자료받기</button>
            </div>
          </div>
        </div>
      </div>
      <div class="course-section">
        <h2 class="section-title">수강생 리뷰</h2>
        <div class="curriculum-list">
          <div class="curriculum-item">
            <div class="review-item">
              <div class="review-header">
                <div class="review-avatar">김</div>
                <div class="review-meta">
                  <h5>김개발자</h5>
                </div>
                <div class="review-date">2024년 6월 5일</div>
              </div>
              <div class="stars" style="font-size: 14px; margin-bottom: 8px;">★★★★★</div>
              <div class="review-content">
                정말 실무에서 바로 적용할 수 있는 내용들로 가득했습니다.
                강사님의 설명도 이해하기 쉽고, 실습 위주로 진행되어서 지루하지 않았어요.
                특히 프로젝트 부분이 매우 유용했습니다!
              </div>
            </div>
          </div>
        </div>
        <div id="review-page-bar"></div>
        <%--<section class="course-reviews">
          <h3>수강생 리뷰</h3>
          <c:forEach var="r" items="${reviews}">
            <div class="review-item">
              <p><strong>${r.memberName}</strong> (${r.reviewRate}점)</p>
              <p>${r.reviewContent}</p>
            </div>
          </c:forEach>
        </section>--%>

      </div>
    </div>

    <!-- Right Sidebar -->
    <div class="course-sidebar">
      <h3 class="sidebar-title">수강 신청</h3>

      <!-- Course Schedule Info -->
      <div class="course-schedule-info">
        <div class="schedule-row" id="teacherview" onclick="location.assign('${path}/course/teacher')"><%--seq추가--%>
          <span class="schedule-label">강사</span>
          <span class="schedule-value">김강사</span>
        </div>
        <div class="schedule-row">
          <span class="schedule-label">개강일</span>
          <span class="schedule-value">2025-02-01</span>
        </div>
        <div class="schedule-row">
          <span class="schedule-label">종료일</span>
          <span class="schedule-value">2025-02-01</span>
        </div>
      </div>

      <!-- Enrollment -->
      <div class="enroll-section">
        <div class="price-info">
          <div class="price-original">150,000원</div>
          <div class="price-current">120,000원</div>
        </div>
        <button class="enroll-btn">수강 신청</button>
      </div>
    </div>
  </div>
</div>

<script>
  // Day selection functionality
  document.querySelectorAll('.day-number').forEach(day => {
    day.addEventListener('click', function() {
      document.querySelectorAll('.day-number').forEach(d => d.classList.remove('day-selected'));
      this.classList.add('day-selected');
    });
  });

  /*// Category checkbox toggle
  document.querySelectorAll('.category-item').forEach(item => {
    item.addEventListener('click', function() {
      const checkbox = this.querySelector('.category-checkbox');
      checkbox.classList.toggle('checked');
    });
  });*/

  // Enroll button
  document.querySelector('.enroll-btn').addEventListener('click', function() {
    alert('수강 신청이 완료되었습니다!');
  });

  // Wishlist button
  document.querySelector('.wishlist-btn').addEventListener('click', function() {
    const heart = this.textContent.includes('♡') ? '♥' : '♡';
    this.innerHTML = heart + ' 찜하기';
  });
</script>
<script>
  // 강의 상세 페이지에서 JS 내에 있는 경우 courseSeq는 서버에서 변수로 전달받는다고 가정
  const courseSeq = ${course.courseSeq}; // EL 표현식으로 전달

  function loadCourses(cPage = 1) {
    fetch(`${path}/course/reviews`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        courseSeq: courseSeq,
        cPage: cPage,
        numPerPage: 3 // 페이지당 리뷰 수
      })
    })
            .then(res => res.json())
            .then(data => {
              const container = document.getElementById('curriculum-list');
              const pageBar = document.getElementById('review-page-bar');
              container.innerHTML = "";

              if (!data || !data.reviews || data.reviews.length === 0) {
                container.innerHTML = "<p>리뷰가 없습니다.</p>";
                pageBar.innerHTML = "";
                return;
              }

              data.reviews.forEach(r => {
                const date = new Date(r.reviewDate);
                const formattedDate = `${date.getFullYear()}년 ${date.getMonth() + 1}월 ${date.getDate()}일`;

                const reviewHtml = `
          <div class="curriculum-item">
            <div class="review-item">
              <div class="review-header">
                <div class="review-avatar">\${r.memberProfile)}</div>
                <div class="review-meta">
                  <h5>\${r.memberName}</h5>
                </div>
                <div class="review-date">\${formattedDate}</div>
              </div>
              <div class="stars">\${'★'.repeat(r.reviewRate)}\${'☆'.repeat(5 - r.reviewRate)}</div>
              <div class="review-content">\${r.reviewContent}</div>
            </div>
          </div>
        `;
                container.insertAdjacentHTML("beforeend", reviewHtml);
              });

              pageBar.innerHTML = data.pageBar || "";
            })
            .catch(() => alert("리뷰 로딩 실패"));
  }

  // 페이징 링크 클릭 시 호출
  function fn_paging(pageNo) {
    loadCourses(pageNo);
  }

  // 첫 로딩 시 호출
  document.addEventListener("DOMContentLoaded", () => loadCourses(1));

</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
