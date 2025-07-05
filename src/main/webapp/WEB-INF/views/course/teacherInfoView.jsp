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
      <h2>강사   ${teacher.memberName}</h2>

      <button class="portfolio-btn"
              onclick="location.assign('${path}/downloadattach?type=portfolio&rename=${teacher.portfolioFileName}')">
        📄 포트폴리오 다운로드
      </button>

      <div class="instructor-bio">
        <h3>강사 소개</h3>
        <p>
          ${teacher.memberEmail}
        </p>
      </div>
    </div>
  </aside>

  <!-- Main Content -->
  <main class="main-content">
    <div id="course-list-container">
      <div class="course-grid" id="courseGrid">
        <!-- Course 1 -->
        <c:if test="${not empty courselist}">
          <c:forEach var="c" items="${courselist}">
            <div class="course-card">

            </div>
          </c:forEach>
        </c:if>
      </div>
      <div id="pageBar" style="margin-top:20px;">
        ${pageBar}
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
</script>
<script>
  function loadCourses(cPage) {
    const params ={sort: document.querySelector('.sort-select')?.value || 'latest'};
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get("courseTitle")) {
      params.courseTitle = urlParams.get("courseTitle");
    }
    params.cPage = cPage;
    params.numPerPage = 4;
    params.memberSeq= ${teacher.memberSeq};


    fetch(`${path}/course/teacherajax`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(params)
    })
            .then(res => res.json())
            .then(data => {
              const container = document.getElementById('courseGrid');
              const pageBar = document.getElementById('pageBar');
              container.innerHTML = "";

              if (!data || !data.courses || data.courses.length === 0) {
                container.innerHTML = "<p>강의가 없습니다.</p>";
                pageBar.innerHTML = "";
                return;
              }

              data.courses.forEach(c => {
                const discounted = Math.round(c.coursePrice * (1 - c.courseDiscount / 100));
                const date = new Date(c.courseStartDate);
                const date2 = new Date(c.courseEndDate);
                const formatted = `\${date.getFullYear()}/\${(date.getMonth()+1).toString().padStart(2, '0')}-\${date.getDate().toString().padStart(2, '0')}`;
                const formatted2 = `\${(date2.getMonth()+1).toString().padStart(2, '0')}-\${date2.getDate().toString().padStart(2, '0')}`;
                const rating = c.averageRating;
                let ratingText;
                if(rating){
                  ratingText= "⭐"+c.averageRating.toFixed(1);
                }else{
                  ratingText='';
                }
                let priceHtml = '';

                if (c.courseDiscount == null || c.courseDiscount === 0) {
                  // 할인 없음
                  priceHtml = `
                        <div class="price-info">
                          <div class="price-current">\${c.coursePrice.toLocaleString()}원</div>
                        </div>
                      `;
                } else {
                  // 할인 있음
                  const discounted = Math.round(c.coursePrice * (100 - c.courseDiscount) / 100);
                  priceHtml = `
                        <div class="price-info">
                          <div class="price-original">
                            <del>\${c.coursePrice.toLocaleString()}원</del>
                          </div>
                          <div class="price-current">\${discounted.toLocaleString()}원</div>
                        </div>
                      `;
                }

                const courseCard = `
                      <div class="course-card" onclick="location.assign('<%=request.getContextPath()%>/course/view?courseSeq='+\${c.courseSeq})">
                        <div class="course-image">
                            \${c.courseName}
                        </div>
                        <div class="course-content">
                            <div class="course-meta">
                                <span>👨‍💻 \${c.courseCategory.fullCategoryName}</span>
                                <span>\${ratingText}</span>
                                <span>\${c.courseCurrentSize}/\${c.courseSize}명 수강</span>
                            </div>
                            <h3 class="course-title">\${c.courseName}</h3>
                            <p class="course-instructor">\${c.memberName} 강사</p>
                            <div class="course-schedule">
                                <div class="schedule-row">
                                    <span class="schedule-label">기간</span>
                                    <span class="schedule-value">\${formatted}~\${formatted2}</span>
                                </div>
                                <div class="schedule-row">
                                    <span class="schedule-label">일시</span>
                                    <span class="schedule-value">\${c.courseDays.map(d => d.dayName).join(", ")}</span>
                                </div>
                                <div class="schedule-row">
                                    <span class="schedule-label">장소</span>
                                    <span class="schedule-value">\${c.courseAddress}</span>
                                </div>
                            </div>
                            <div class="course-footer">
                                \${priceHtml}
                                <button class="btn-enroll">수강 신청</button>
                            </div>
                        </div>
                      </div>`;

                container.insertAdjacentHTML("beforeend", courseCard);
              });

              pageBar.innerHTML = data.pageBar || "";
            })
            .catch(() => alert("강의 로딩 실패"));
  }

  window.addEventListener('DOMContentLoaded', () => loadCourses(1));

  function fn_paging(pageNo) {
    if (typeof loadCourses === 'function') {
      loadCourses(pageNo);
    } else {
      console.error("loadCourses is not defined");
    }
  }
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>