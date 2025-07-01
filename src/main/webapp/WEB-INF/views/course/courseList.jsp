<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<link rel="stylesheet" href="${path}/resources/css/courseList.css"/>
<style>
    .filter-header {
        display: flex;
        justify-content: space-between; /* 오른쪽 정렬은 flex-end, 간격 두려면 space-between */
        align-items: center;
        margin-bottom: 1rem;
    }

</style>
<!-- Search Results -->
<div class="search-results">
    <!-- Sidebar -->
    <aside class="sidebar">
        <!-- 필터 헤더 영역 -->
        <div class="filter-header">
            <h3>필터</h3>
            <button id="searchBtn" class="search-btn btn btn-hero btn-hero-primary">검색</button>
        </div>
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
                        <input type="checkbox" id="java" value="Java" data-category-seq="5">
                        <label for="java">Java</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="python" value="Python" data-category-seq="6">
                        <label for="python">Python</label>
                    </div>
                </div>

                <!-- 프론트엔드 -->
                <div class="filter-option parent-category" data-target="frontend-sub">
                    <span>프론트엔드 ▼</span>
                </div>
                <div class="sub-category" id="frontend-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="react" value="React" data-category-seq="7">
                        <label for="react">React</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="vue" value="Vue.js" data-category-seq="8">
                        <label for="vue">Vue.js</label>
                    </div>
                </div>

                <!-- 비즈니스 -->
                <div class="filter-option parent-category" data-target="business-sub">
                    <span>비즈니스 ▼</span>
                </div>
                <div class="sub-category" id="business-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="marketing" value="Marketing" data-category-seq="9">
                        <label for="marketing">마케팅</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="startup" value="Startup" data-category-seq="10">
                        <label for="startup">스타트업</label>
                    </div>
                </div>

                <!-- 디자인 -->
                <div class="filter-option parent-category" data-target="design-sub">
                    <span>디자인 ▼</span>
                </div>
                <div class="sub-category" id="design-sub" style="display: none; padding-left: 1em;">
                    <div class="filter-option">
                        <input type="checkbox" id="ux" value="UX/UI" data-category-seq="11">
                        <label for="ux">UX/UI</label>
                    </div>
                    <div class="filter-option">
                        <input type="checkbox" id="photoshop" value="Photoshop" data-category-seq="12">
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
    function getQueryParams() {
        const urlParams = new URLSearchParams(window.location.search);
        return {
            courseTitle: urlParams.get("courseTitle") || "",
            cPage: parseInt(urlParams.get("cPage")) || 1,
            numPerPage: 4,
            categoryList: urlParams.get("categoryList")?.split(",") || []
        };
    }

    window.addEventListener("DOMContentLoaded", () => {
        const q = getQueryParams();

        // courseTitle 값 반영
        document.getElementById("courseTitle").value = q.courseTitle;

        // ✅ 카테고리 번호 체크박스 자동 체크
        q.categoryList.forEach(seq => {
            const checkbox = document.querySelector(`input[type="checkbox"][data-category-seq="\${seq}"]`);
            if (checkbox) checkbox.checked = true;
        });

        loadCourses(q.cPage);
    });


</script>
<script>
    window.addEventListener('DOMContentLoaded', () => {
        document.querySelector('.sort-select').addEventListener('change', () => loadCourses(1));
        document.getElementById('searchBtn').addEventListener('click', () => {
            history.replaceState({}, '', location.pathname);  // URL 쿼리스트링 제거
            loadCourses(1);
        });
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
        if (document.getElementById('java').checked) categoryList.push("5");  // 백엔드 seq
        if (document.getElementById('python').checked) categoryList.push("6"); // 프론트엔드 seq
        if (document.getElementById('react').checked) categoryList.push("7");
        if (document.getElementById('vue').checked) categoryList.push("8");
        if (document.getElementById('marketing').checked) categoryList.push("9");
        if (document.getElementById('startup').checked) categoryList.push("10");
        if (document.getElementById('ux').checked) categoryList.push("11");
        if (document.getElementById('photoshop').checked) categoryList.push("12");

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
        /*const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get("courseTitle")) {
            params.courseTitle = urlParams.get("courseTitle");
        }*/
        const inputTitle = document.getElementById('courseTitle').value;
        params.courseTitle = inputTitle || getQueryParams().courseTitle || "";
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
                    const date = new Date(c.courseStartDate);
                    const date2 = new Date(c.courseEndDate);
                    const formatted = `\${date.getFullYear()}/\${(date.getMonth()+1).toString().padStart(2, '0')}-\${date.getDate().toString().padStart(2, '0')}`;
                    const formatted2 = `\${(date2.getMonth()+1).toString().padStart(2, '0')}-\${date2.getDate().toString().padStart(2, '0')}`;
                    const rating = c.averageRating;
                    const ratingText = rating ? `⭐${rating}` : '';
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