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
        /* font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, Roboto, 'Helvetica Neue', 'Segoe UI', 'Apple SD Gothic Neo', 'Noto Sans KR', 'Malgun Gothic', sans-serif;*/
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

    /* Search Header */
    .search-header {
        background: white;
        padding: 30px 0;
        border-bottom: 1px solid #e5e5e5;
    }

    .search-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }

    .search-form {
        display: flex;
        gap: 15px;
        margin-bottom: 20px;
    }

    .search-input {
        flex: 1;
        padding: 15px 20px;
        border: 2px solid #e9ecef;
        border-radius: 8px;
        font-size: 16px;
        background: #f8f9fa;
    }

    .search-input:focus {
        outline: none;
        border-color: #162D43;
        background: white;
    }

    .search-btn {
        padding: 15px 30px;
        background: #162D43;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s;
    }

    .search-btn:hover {
        background: #0f1f2f;
    }

    .search-filters {
        display: flex;
        gap: 15px;
        flex-wrap: wrap;
        align-items: center;
    }

    .filter-select {
        padding: 10px 15px;
        border: 1px solid #dee2e6;
        border-radius: 6px;
        background: white;
        cursor: pointer;
        font-size: 14px;
    }

    .filter-select:focus {
        outline: none;
        border-color: #162D43;
    }

    .filter-tags {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }

    .filter-tag {
        background: #162D43;
        color: white;
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .filter-tag .remove {
        cursor: pointer;
        opacity: 0.7;
    }

    .filter-tag .remove:hover {
        opacity: 1;
    }

    /* Search Results */
    .search-results {
        max-width: 1200px;
        margin: 0 auto;
        padding: 30px 20px;
        display: grid;
        grid-template-columns: 250px 1fr;
        gap: 30px;
    }

    /* Left Sidebar */
    .sidebar {
        background: white;
        border-radius: 12px;
        padding: 24px;
        height: fit-content;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .sidebar h3 {
        color: #162D43;
        margin-bottom: 16px;
        font-size: 18px;
    }

    .filter-group {
        margin-bottom: 24px;
    }

    .filter-group h4 {
        color: #333;
        margin-bottom: 12px;
        font-size: 14px;
        font-weight: 600;
    }

    .filter-options {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .filter-option {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 4px 0;
        cursor: pointer;
    }

    .filter-option input[type="checkbox"] {
        accent-color: #162D43;
    }

    .filter-option label {
        cursor: pointer;
        font-size: 14px;
        color: #666;
    }

    .filter-option:hover label {
        color: #162D43;
    }

    .price-range {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        margin-top: 8px;
    }

    .price-input {
        flex: 1;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 12px;
    }

    /* Main Content */
    .main-content {
        background: white;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .results-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e5e5e5;
    }

    .results-info {
        color: #666;
        font-size: 14px;
    }

    .results-info strong {
        color: #162D43;
        font-weight: 600;
    }

    .sort-options {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .sort-select {
        padding: 8px 12px;
        border: 1px solid #ddd;
        border-radius: 6px;
        font-size: 14px;
        cursor: pointer;
    }

    .view-toggle {
        display: flex;
        border: 1px solid #ddd;
        border-radius: 6px;
        overflow: hidden;
    }

    .view-btn {
        padding: 8px 12px;
        background: white;
        border: none;
        cursor: pointer;
        font-size: 12px;
        transition: all 0.2s;
    }

    .view-btn.active {
        background: #162D43;
        color: white;
    }

    /* Course Grid */
    .course-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
        gap: 24px;
    }

    .course-grid.list-view {
        grid-template-columns: 1fr;
    }

    .course-card {
        background: white;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
        transition: all 0.3s;
        cursor: pointer;
        border: 1px solid #f0f0f0;
    }

    .course-card:hover {
        transform: translate(-5px, -5px) rotate(-1deg);
        box-shadow: 13px 13px 0 rgba(0, 0, 0, 0.1);
    }

    .course-card.list-view {
        display: flex;
        overflow: visible;
    }

    .course-image {
        width: 100%;
        height: 180px;
        background: linear-gradient(135deg, #162D43, #264058);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 20px;
        font-weight: bold;
        position: relative;
    }

    .course-card.list-view .course-image {
        width: 200px;
        height: 140px;
        flex-shrink: 0;
    }

    .course-badge {
        position: absolute;
        top: 12px;
        left: 12px;
        background: rgba(255, 255, 255, 0.9);
        color: #162D43;
        padding: 4px 8px;
        border-radius: 8px;
        font-size: 10px;
        font-weight: 600;
    }

    .course-content {
        padding: 20px;
        flex: 1;
    }

    .course-meta {
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 8px;
        font-size: 12px;
        color: #666;
    }

    .course-title {
        font-size: 16px;
        font-weight: 600;
        margin-bottom: 8px;
        color: #333;
        line-height: 1.4;
    }

    .course-instructor {
        font-size: 13px;
        color: #666;
        margin-bottom: 12px;
    }

    .course-schedule {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 12px;
        margin-bottom: 16px;
        font-size: 12px;
    }

    .schedule-row {
        display: flex;
        justify-content: space-between;
        margin-bottom: 4px;
    }

    .schedule-row:last-child {
        margin-bottom: 0;
    }

    .schedule-label {
        color: #666;
    }

    .schedule-value {
        font-weight: 500;
        color: #333;
    }

    .course-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .course-price {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
    }

    .price-original {
        font-size: 12px;
        color: #999;
        text-decoration: line-through;
    }

    .price-current {
        font-size: 18px;
        font-weight: 700;
        color: #162D43;
    }

    .btn-enroll {
        background: #162D43;
        color: white;
        padding: 8px 16px;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s;
        font-size: 12px;
    }

    .btn-enroll:hover {
        background: #0f1f2f;
    }

    /* Pagination */
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 8px;
        margin-top: 40px;
        padding-top: 24px;
        border-top: 1px solid #e5e5e5;
    }

    .page-btn {
        padding: 8px 12px;
        border: 1px solid #ddd;
        background: white;
        color: #666;
        cursor: pointer;
        border-radius: 6px;
        font-size: 14px;
        transition: all 0.2s;
    }

    .page-btn:hover {
        border-color: #162D43;
        color: #162D43;
    }

    .page-btn.active {
        background: #162D43;
        color: white;
        border-color: #162D43;
    }

    .page-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    /* No Results */
    .no-results {
        text-align: center;
        padding: 60px 20px;
        color: #666;
    }

    .no-results h3 {
        color: #333;
        margin-bottom: 12px;
        font-size: 20px;
    }

    .no-results p {
        margin-bottom: 24px;
        line-height: 1.6;
    }

    .search-suggestions {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        justify-content: center;
        margin-top: 20px;
    }

    .suggestion-tag {
        background: #f8f9fa;
        color: #162D43;
        padding: 6px 12px;
        border-radius: 16px;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .suggestion-tag:hover {
        background: #162D43;
        color: white;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .nav-menu {
            display: none;
        }

        .search-results {
            grid-template-columns: 1fr;
            gap: 20px;
        }

        .sidebar {
            order: 2;
        }

        .main-content {
            order: 1;
        }

        .results-header {
            flex-direction: column;
            gap: 16px;
            align-items: flex-start;
        }

        .course-grid {
            grid-template-columns: 1fr;
        }

        .course-card.list-view {
            flex-direction: column;
        }

        .course-card.list-view .course-image {
            width: 100%;
            height: 160px;
        }

        .search-form {
            flex-direction: column;
        }

        .search-filters {
            justify-content: center;
        }
    }

    /* Loading Animation */
    .loading {
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 40px;
    }

    .spinner {
        width: 40px;
        height: 40px;
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
</style>
<style>
    .main-content {
        font-size: 2rem;
    !important; /* 기본보다 크게 */
    }

    /* 카드 내부 폰트도 키우고 싶다면 */
    .course-card {
        font-size: 2rem;
    !important;
    }
</style>


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
                    <label for="weekday">평일 (20)</label>
                </div>
                <div class="filter-option">
                    <input type="checkbox" id="weekend">
                    <label for="weekend">주말 (15)</label>
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
            <div class="results-info">
                <strong>"React"</strong> 검색 결과 <strong>24</strong>개 강의
            </div>
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
                            <div class="course-image">
                                <span class="course-badge">HOT</span>
                                React & Node.js
                            </div>
                            <div class="course-content">
                                <div class="course-meta">
                                    <span>👨‍💻 ${c.courseCategory.fullCategoryName}</span>
                                    <span>⭐ 4.9 (234)</span>
                                </div>
                                <h3 class="course-title">${c.courseName}</h3>
                                <p class="course-instructor">${c.memberName} 강사</p>

                                <div class="course-schedule">
                                    <div class="schedule-row">
                                        <span class="schedule-label">시작일</span>
                                        <span class="schedule-value"></span>
                                    </div>
                                    <div class="schedule-row">
                                        <span class="schedule-label">일시</span>
                                        <span class="schedule-value">
                                        <c:forEach var="d" items="${c.courseDays}">
                                            <c:out value="${d.dayName}"/>
                                        </c:forEach>

                                    </span>
                                    </div>
                                    <div class="schedule-row">
                                        <span class="schedule-label">장소</span>
                                        <span class="schedule-value">${c.courseAddress}</span>
                                    </div>
                                </div>

                                <div class="course-footer">
                                    <div class="course-price">
                                    <span class="price-original">
                                        <fmt:formatNumber value="${c.coursePrice}" type="number" maxFractionDigits="0"/>원
                                    </span>
                                        <span class="price-current">
                                        <fmt:formatNumber value="${c.coursePrice * (1 - c.courseDiscount / 100.0)}"
                                                          type="number" maxFractionDigits="0"/>원
                                    </span>
                                    </div>
                                    <button class="btn-enroll">수강 신청</button>
                                </div>
                            </div>
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