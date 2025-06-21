<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<link rel="stylesheet" href="${path}/resources/css/courseList.css"/>
<!-- Search Results -->
<div class="search-results">
    <!-- Sidebar -->
    <aside class="sidebar">
        <h3>필터</h3>
        <div class="filter-group">
            <h4>강의 제목</h4>
            <input type="text" id="courseTitle" class="price-input">
        </div>
        <div class="filter-group">
            <h4>카테고리</h4>
            <div class="filter-options">

                <!-- 백엔드 -->
                <div class="filter-option parent-category" data-target="backend-sub">
                    <span>백엔드 ▼</span>
                </div>
                <div class="sub-category" id="backend-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="java" value="Java">
                        <label for="java">Java</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="python" value="Python">
                        <label for="python">Python</label>
                    </div>
                </div>

                <!-- 프론트엔드 -->
                <div class="filter-option parent-category" data-target="frontend-sub">
                    <span>프론트엔드 ▼</span>
                </div>
                <div class="sub-category" id="frontend-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="react" value="React">
                        <label for="react">React</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="vue" value="Vue.js">
                        <label for="vue">Vue.js</label>
                    </div>
                </div>

                <!-- 비즈니스 -->
                <div class="filter-option parent-category" data-target="business-sub">
                    <span>비즈니스 ▼</span>
                </div>
                <div class="sub-category" id="business-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="marketing" value="Marketing">
                        <label for="marketing">마케팅</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="startup" value="Startup">
                        <label for="startup">스타트업</label>
                    </div>
                </div>

                <!-- 디자인 -->
                <div class="filter-option parent-category" data-target="design-sub">
                    <span>디자인 ▼</span>
                </div>
                <div class="sub-category" id="design-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="ux" value="UX/UI">
                        <label for="ux">UX/UI</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="photoshop" value="Photoshop">
                        <label for="photoshop">Photoshop</label>
                    </div>
                </div>
            </div>

        </div>

        <div class="filter-group">
            <h4>수업 요일</h4>
            <div class="filter-options">
                <div class="filter-option">
                    <input type="checkbox" id="weekday">
                    <label for="weekday">평일</label>
                </div>
                <div class="filter-option">
                    <input type="checkbox" id="weekend">
                    <label for="weekend">주말</label>
                </div>
            </div>
        </div>

        <div class="filter-group">
            <h4>가격 범위</h4>
            <div class="price-range">
                <input type="number" id="minPrice" class="price-input" placeholder="최소" min="0">
                <span>~</span>
                <input type="number" id="maxPrice" class="price-input" placeholder="최대" min="0">
            </div>
        </div>
        <button id="searchBtn" class="search-btn btn btn-hero btn-hero-primary">검색</button>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <div class="results-header">
            <div class="sort-options">
                <select class="sort-select">
                    <option value="latest">최신순</option>
                    <option value="popular">인기순</option>
                </select>
            </div>
        </div>
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
            <div id="pageBar">
                ${pageBar}
            </div>
        </div>

    </main>
</div>
<script>
    document.querySelectorAll(".parent-category").forEach(parent => {
        parent.addEventListener("click", function () {
            const targetId = this.dataset.target;
            const target = document.getElementById(targetId);
            if (target) {
                target.style.display = target.style.display === "none" ? "block" : "none";
            }
        });
    });
</script>
<script>
    // URL 파라미터에서 검색 조건 불러오기 (courseTitle 등)
    function getQueryParams() {
        const urlParams = new URLSearchParams(window.location.search);
        return {
            courseTitle: urlParams.get("courseTitle") || "",
            cPage: parseInt(urlParams.get("cPage")) || 1,
            numPerPage: 4
        };
    }

    // 검색어 input에 자동으로 반영
    window.addEventListener("DOMContentLoaded", () => {
        const q = getQueryParams();
        if (q.courseTitle) {
            document.getElementById("courseTitle").value = q.courseTitle;
        }
        loadCourses(q.cPage);
    });
</script>
<script>
    window.addEventListener('DOMContentLoaded', () => {
        document.querySelector('.sort-select').addEventListener('change', () => loadCourses(1));
        document.getElementById('searchBtn').addEventListener('click', () => loadCourses(1));
        loadCourses(1);
    });

    function getFilterParams() {
        const dayList = [];
        if (document.getElementById('weekday').checked) dayList.push('0');
        if (document.getElementById('weekday').checked) dayList.push('1');
        if (document.getElementById('weekday').checked) dayList.push('2');
        if (document.getElementById('weekday').checked) dayList.push('3');
        if (document.getElementById('weekday').checked) dayList.push('4');
        if (document.getElementById('weekend').checked) dayList.push('5');
        if (document.getElementById('weekend').checked) dayList.push('6');

        const categoryList = [];
        if (document.getElementById('java').checked) categoryList.push("자바");  // 백엔드 seq
        if (document.getElementById('python').checked) categoryList.push("파이썬"); // 프론트엔드 seq
        if (document.getElementById('react').checked) categoryList.push("리액트");
        if (document.getElementById('vue').checked) categoryList.push("vue");

        const minPriceValue = document.querySelector("#minPrice").value;
        const maxPriceValue = document.querySelector("#maxPrice").value;

        return {
            sort: document.querySelector('.sort-select')?.value || 'latest',
            courseTitle: document.getElementById('courseTitle')?.value || "",
            minPrice: minPriceValue !== "" ? Number(minPriceValue) : null,
            maxPrice: maxPriceValue !== "" ? Number(maxPriceValue) : null,
            categoryList: categoryList.length ? categoryList : [],
            dayList: dayList.length ? dayList : [],
        };
    }

    function loadCourses(cPage) {
        const params = getFilterParams();
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get("courseTitle")) {
            params.courseTitle = urlParams.get("courseTitle");
        }
        params.cPage = cPage;
        params.numPerPage = 4;

        fetch(`${path}/course/search`, {
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
                    const courseCard = `
                  <div class="course-card">
                      <div class="course-image">
                          <span class="course-badge">HOT</span>
                          \${c.courseName}
                      </div>
                      <div class="course-content">
                          <div class="course-meta">
                              <span>👨‍💻 \${c.courseCategory.fullCategoryName}</span>
                              <span>⭐\${c.averageRating} \${c.reviewCount}명 수강</span>
                          </div>
                          <h3 class="course-title">\${c.courseName}</h3>
                          <p class="course-instructor">\${c.memberName} 강사</p>
                          <div class="course-schedule">
                              <div class="schedule-row">
                                  <span class="schedule-label">시작일</span>
                                  <span class="schedule-value">\${new Date(c.courseStartDate).toISOString().slice(0, 10)}</span>
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
                              <div class="course-price">
                                  <span class="price-original">\${c.coursePrice.toLocaleString()}원</span>
                                  <span class="price-current">\${discounted.toLocaleString()}원</span>
                              </div>
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
</script>
<script>
    function fn_paging(pageNo) {
        if (typeof loadCourses === 'function') {
            loadCourses(pageNo);
        } else {
            console.error("loadCourses is not defined");
        }
    }
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>