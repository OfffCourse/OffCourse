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
<fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy-MM-dd" var="today"/>
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
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }

    .header-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .header-container a {
        text-decoration: none;
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
                <h1>${course.courseName}</h1>
                <div class="course-meta">
                    <span>👨‍💻 ${course.courseCategory.fullCategoryName}</span>
                    <span>⭐ ${course.averageRating}</span>
                    <span>📚 총 ${countEpisode}강</span>
                </div>
            </div>

            <!-- Course Categories -->
            <div class="course-section">
                <h2 class="section-title">강의 소개</h2>
                <div class="category-list">
                    <div class="category-item">
                        <div class="category-checkbox checked"></div>
                        <span class="category-text">커리큘럼</span>
                    </div>
                    <div class="category-item">
                        <span class="category-text">${course.courseCurriculum}</span>
                    </div>
                    <div class="category-item">
                        <div class="category-checkbox checked"></div>
                        <span class="category-text">Q&A 링크(오픈카카오톡)</span>
                    </div>
                    <div class="category-item">
                        <span class="category-text">${course.courseQaLink}</span>
                    </div>
                    <div class="category-item">
                        <div class="category-checkbox checked"></div>
                        <span class="category-text">상세 주소</span>
                    </div>
                    <div class="category-item">
                        <span class="category-text">${course.courseAddress}/${course.courseDetailAddress}</span>
                    </div>
                </div>
            </div>

            <!-- Curriculum -->
            <div class="course-section">
                <h2 class="section-title">강의 회차</h2>
                <div class="curriculum-list" id="episode-list">
                    <!-- JS로 렌더링 -->
                </div>
                <div id="episode-page-bar">
                    <!-- JS로 페이징 바 렌더링 -->
                </div>
            </div>
            <div class="course-section">
                <h2 class="section-title">수강생 리뷰</h2>
                <div class="curriculum-list" id="review-container">
                </div>
                <div id="review-page-bar"></div>

            </div>
        </div>

        <!-- Right Sidebar -->
        <div class="course-sidebar">
            <div class="course-schedule-info">
                <div class="schedule-row" id="teacherview"><%--seq추가--%>
                    <span class="schedule-label">강사</span>
                    <button class="action-btn btn-secondary"
                            onclick="location.assign('${path}/course/teacher?memberSeq='+${course.memberSeq})">${course.memberName}</button>
                </div>
                <div class="schedule-row">
                    <span class="schedule-label">개강일</span>
                    <span class="schedule-value">${course.courseStartDate}</span>
                </div>
                <div class="schedule-row">
                    <span class="schedule-label">종료일</span>
                    <span class="schedule-value">${course.courseEndDate}</span>
                </div>
                <div class="schedule-row">
                    <span class="schedule-label">정원</span>
                    <span class="schedule-value">${course.courseCurrentSize}/${course.courseSize}</span>
                </div>
            </div>
            <button class="action-btn" id="showAttendanceBtn" data-course-seq="${course.courseSeq}">출석 코드 보기</button>
        </div>
    </div>
</div>
<!-- 출석 코드 모달 -->
<div class="modal fade" id="attendanceCodeModal" tabindex="-1" role="dialog" aria-labelledby="attendanceCodeModalLabel"
     aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content text-center">
            <div class="modal-header">
                <h5 class="modal-title" id="attendanceCodeModalLabel">출석 코드</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="닫기">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>학생에게 공유할 출석 코드는 아래와 같습니다.</p>
                <h2 id="generatedCode" class="font-weight-bold">------</h2>
                <small class="text-muted" id="countdownText">※ 유효 시간: 10분</small>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>
<!-- 자료 업로드 모달 -->
<div class="modal fade" id="attachUploadModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <form method="post" enctype="multipart/form-data" action="${path}/uploadattach">
            <input type="hidden" name="episodeSeq" id="modal-episodeSeq">
            <input type="hidden" name="courseSeq" value="${course.courseSeq}">

            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">자료 업로드</h5>
                </div>

                <div class="modal-body">
                    <div class="input-group mb-3">
                        <div class="input-group-prepend">
                            <button type="button" class="btn btn-outline-dark" onclick="addFile()">추가</button>
                            <button type="button" class="btn btn-outline-danger" onclick="delFile()">삭제</button>
                        </div>
                    </div>

                    <div id="basic-file-form" class="input-group mb-3">
                        <div class="input-group-prepend">
                            <span class="input-group-text">첨부파일1</span>
                        </div>
                        <div class="custom-file">
                            <input type="file" class="custom-file-input" name="upFile" id="upFile1" required>
                            <label class="custom-file-label" for="upFile1">파일을 선택하세요</label>
                        </div>
                    </div>

                    <ul id="uploaded-files-list" class="mt-2"></ul>
                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">업로드</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
                </div>
            </div>
        </form>
    </div>
</div>
<!-- 녹화 모달 -->
<div class="modal fade" id="recordModal" tabindex="-1" role="dialog" aria-labelledby="recordModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content text-center">
            <div class="modal-header">
                <h5 class="modal-title">녹화 관리</h5>
                <div class="form-group text-center">
                    <label for="videoTitleInput">영상 제목</label>
                    <input type="text" class="form-control" id="videoTitleInput" placeholder="예: 1차시 - 변수 설명">
                </div>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="record-episodeSeq" />
                <button class="btn btn-primary" id="startRecordBtn">녹화 시작</button>
                <button class="btn btn-danger" id="stopRecordBtn">녹화 중지</button>
                <hr>
                <h5>녹화된 영상 목록</h5>
                <ul id="videoList" class="list-group"></ul>
            </div>
        </div>
    </div>
</div>

<script>
    $('#showAttendanceBtn').on('click', function () {
        const courseSeq = $(this).data('course-seq');
        const now = new Date();
        const availableMinTime = new Date();
        availableMinTime.setHours(9, 0, 0, 0);
        const availableMaxTime = new Date();
        availableMaxTime.setHours(9, 30, 0, 0);
        $.ajax({
            url: `${path}/present/\${courseSeq}`,
            method: 'GET',
            success: function (response) {
                console.log(response);
                $('#generatedCode').text(response);

                const now = new Date();
                const availableMinTime = new Date();
                availableMinTime.setHours(9, 0, 0, 0);
                const availableMaxTime = new Date();
                availableMaxTime.setHours(9, 30, 0, 0);

                if (now < availableMinTime || now > availableMaxTime) {
                    alert("출석 코드는 9시부터 9시 30분에만 조회가 가능합니다.");
                } else {
                    // 모달 표시
                    $('#attendanceCodeModal').modal('show');

                    // 기존 타이머가 있다면 제거
                    if (window.attendanceTimer) clearInterval(window.attendanceTimer);

                    // 매초 남은 시간 업데이트
                    window.attendanceTimer = setInterval(() => {
                        const now = new Date();
                        const remainingMs = availableMaxTime - now;

                        if (remainingMs <= 0) {
                            $('#countdownText').text(`※ 출석 가능 시간이 종료되었습니다.`);
                            clearInterval(window.attendanceTimer);
                            return;
                        }

                        const remainingMin = Math.floor(remainingMs / 60000);
                        const remainingSec = Math.floor((remainingMs % 60000) / 1000);
                        const paddedSec = remainingSec.toString().padStart(2, '0');

                        $('#countdownText').text(`※ 출석 가능 시간 남은 시간: \${remainingMin}분 \${paddedSec}초`);
                    }, 1000);
                }
            },
            error: function () {
                alert("출석 코드를 가져오는 데 실패했습니다.");
            }
        });
    });
</script>
<script>
    // 1. courseSeq 변수 선언을 함수 외부로 이동
    const courseSeq = "${course.courseSeq}";

    // 2. DOMContentLoaded 이벤트 리스너 수정
    document.addEventListener("DOMContentLoaded", function() {
        console.log("DOM 로드 완료, courseSeq:", courseSeq); // 디버깅용
        loadEpisodes(1);
        loadCourses(1);
    });

    // 3. 페이징 이벤트 리스너 수정 (jQuery와 vanilla JavaScript 혼용 문제 해결)
    document.addEventListener('DOMContentLoaded', function() {
        // jQuery 대신 vanilla JavaScript로 통일
        document.getElementById('episode-page-bar').addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                e.preventDefault();
                const page = e.target.getAttribute('data-page');
                if (page) {
                    loadEpisodes(parseInt(page));
                }
            }
        });
    });

    // 4. loadEpisodes 함수 수정 (에러 핸들링 추가)
    function loadEpisodes(cPage = 1) {
        console.log("loadEpisodes 호출됨, cPage:", cPage, "courseSeq:", courseSeq); // 디버깅용

        // courseSeq 유효성 검사
        if (!courseSeq || courseSeq === "" || courseSeq === "null") {
            console.error("courseSeq가 유효하지 않습니다:", courseSeq);
            document.getElementById('episode-list').innerHTML = "<p>강의 정보를 불러올 수 없습니다.</p>";
            return;
        }

        fetch(`${path}/course/episodes`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                courseSeq: parseInt(courseSeq), // 숫자로 변환
                cPage: cPage,
                numPerPage: 5
            })
        })
            .then(response => {
                console.log("응답 상태:", response.status); // 디버깅용
                if (!response.ok) {
                    throw new Error(`HTTP error! status: \${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log("받은 데이터:", data); // 디버깅용
                renderEpisodes(data);
            })
            .catch(error => {
                console.error("에러 발생:", error);
                document.getElementById('episode-list').innerHTML = "<p>데이터를 불러오는 중 오류가 발생했습니다.</p>";
            });
    }

    // 5. 렌더링 로직을 별도 함수로 분리
    function renderEpisodes(data) {
        const list = document.getElementById('episode-list');
        const pageBar = document.getElementById('episode-page-bar');

        if (!list || !pageBar) {
            console.error("필요한 DOM 요소를 찾을 수 없습니다.");
            return;
        }

        list.innerHTML = "";

        if (!data.episodes || data.episodes.length === 0) {
            list.innerHTML = "<p>등록된 회차가 없습니다.</p>";
            pageBar.innerHTML = "";
            return;
        }

        data.episodes.forEach(episode => {
            const showRecordBtns = (
                formatDate(episode.episodeDate).replace(/\D/g, '') ===
                formatDate(new Date()).replace(/\D/g, '')
            );

            // 녹화 버튼 HTML 생성
            let recordButtonsHtml = '';
            if (showRecordBtns) {
                recordButtonsHtml = `
                    <button class="action-btn record-modal-btn" data-episode="\${episode.episodeSeq}">녹화</button>
                `;

            }

            const episodeHtml = `
            <div class="curriculum-item">
                <span class="curriculum-number">\${episode.episodeCount}.</span>
                <div class="curriculum-content">

                    <div class="curriculum-date">\${formatDate(episode.episodeDate)}</div>
                </div>
                <div class="curriculum-actions">
                    \${recordButtonsHtml}
                    <button class="action-btn upload-attach-btn" data-episode="\${episode.episodeSeq}">자료업로드</button>
                </div>
            </div>
        `;
            list.insertAdjacentHTML("beforeend", episodeHtml);
        });

        pageBar.innerHTML = data.pageBar || "";

    }

    function loadCourses(cPage = 1) {
        console.log("loadCourse 시작")
        fetch(`${path}/course/reviews`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                courseSeq: courseSeq,
                cPage: cPage,
                numPerPage: 3 // 페이지당 리뷰 수
            })
        })
            .then(res => res.json())
            .then(data => {
                const container = document.getElementById('review-container');
                const pageBar = document.getElementById('review-page-bar');
                container.innerHTML = "";

                if (!data || !data.reviews || data.reviews.length === 0) {
                    container.innerHTML = "<p>리뷰가 없습니다.</p>";
                    pageBar.innerHTML = "";
                    return;
                }

                data.reviews.forEach(r => {
                    // 1. 날짜 처리
                    const date = new Date(r.reviewCreateTime); // ← 정확한 필드명
                    let formattedDate = '날짜 오류';
                    if (!isNaN(date)) {
                        formattedDate = `\${date.getFullYear()}년 \${date.getMonth() + 1}월 \${date.getDate()}일`;
                    }

                    // 2. 프로필 이미지 (없으면 기본 이미지 대체)
                    const profileImgUrl = r.memberProfile
                        ? `${path}/resources/upload/student/profile/\${r.memberProfile}`
                        : `${path}/resources/upload/student/profile/default_profile_student.png`;

                    const reviewHtml = `
                      <div class="curriculum-item">
                        <div class="review-item">
                            <div class="review-header">
                                <div class="review-avatar">
                                    <img src="\${profileImgUrl}" alt="프로필" style="width:40px; height:40px; border-radius:50%;">
                                </div>
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
    document.addEventListener('click', function(e) {
        // 자료 업로드 버튼
        if (e.target.classList.contains('upload-attach-btn')) {
            const epSeq = e.target.dataset.episode;
            document.getElementById('modal-episodeSeq').value = epSeq;

            fetch(`${path}/lecture/attachments?episodeSeq=\${epSeq}`)
                .then(res => res.json())
                .then(data => {
                    const list = document.getElementById('uploaded-files-list');
                    list.innerHTML = "";

                    data.forEach(file => {
                        const li = document.createElement('li');
                        li.innerHTML = `
                            \${file.attOriName}
                            <button class="btn btn-sm btn-danger" onclick="deleteAttachment(\${file.attSeq})">삭제</button>
                        `;
                        list.appendChild(li);
                    });
                });

            $('#attachUploadModal').modal('show');
        }

        if (e.target.classList.contains('record-modal-btn')) {
            const epSeq = e.target.dataset.episode;
            document.getElementById('record-episodeSeq').value = epSeq;
            loadVideoList(epSeq);
            $('#recordModal').modal('show');
        }

    });

    document.getElementById("startRecordBtn").onclick = () => {
        const epSeq = document.getElementById('record-episodeSeq').value;
        startRecording(epSeq);
    };
    document.getElementById("stopRecordBtn").onclick = stopRecording;
    let mediaRecorder;
    let chunks = [];
    let videoBlob;

    function startRecording(epSeq) {
        navigator.mediaDevices.getDisplayMedia({video: true, audio: true})
            .then(stream => {
                mediaRecorder = new MediaRecorder(stream);
                chunks = [];

                mediaRecorder.ondataavailable = (e) => chunks.push(e.data);

                mediaRecorder.onstop = async () => {
                    confirm("업로드 완료 알림창이 뜰 때까지 기다려주세요.");
                    videoBlob = new Blob(chunks, {type: 'video/webm'});
                    await uploadInChunks(videoBlob, epSeq);
                    alert("업로드 완료");
                    loadVideoList(epSeq);
                };

                mediaRecorder.start();
            });
    }

    function stopRecording() {
        if (mediaRecorder) {
            mediaRecorder.stop();
        }
    }

    async function uploadInChunks(blob, episodeSeq) {
        const CHUNK_SIZE = 5 * 1024 * 1024;
        const totalChunks = Math.ceil(blob.size / CHUNK_SIZE);
        const videoTitle = document.getElementById('videoTitleInput').value || '제목없음';
        for (let i = 0; i < totalChunks; i++) {
            const chunk = blob.slice(i * CHUNK_SIZE, (i + 1) * CHUNK_SIZE);
            const formData = new FormData();
            formData.append("chunk", chunk);
            formData.append("index", i);
            formData.append("total", totalChunks);
            formData.append("episodeSeq", episodeSeq);
            formData.append("courseSeq", courseSeq);
            formData.append("videoTitle", videoTitle);
            await fetch(`${path}/uploadChunk`, {
                method: "POST",
                body: formData
            });
        }
    }

    function loadVideoList(episodeSeq) {
        fetch(`${path}/lecture/videofile?episodeSeq=\${episodeSeq}`)
            .then(res => res.json())
            .then(data => {
                const list = document.getElementById('videoList');
                list.innerHTML = '';
                if (!data || data.length === 0) {
                    list.innerHTML = '<li class="list-group-item">등록된 영상이 없습니다.</li>';
                    return;
                }

                data.forEach(video => {
                    const li = document.createElement('li');
                    li.className = 'list-group-item d-flex justify-content-between align-items-center';
                    li.innerHTML = `
                    <a href="${path}/resources/upload/lecture/video/\${video.attRenamedName}" target="_blank">\${video.attOriName}</a>
                    <button class="btn btn-sm btn-danger" onclick="deleteVideo(\${video.attSeq}, \${episodeSeq})">삭제</button>
                `;
                    list.appendChild(li);
                });
            });
    }

    function deleteVideo(attSeq, episodeSeq) {
        confirm("삭제를 원하시면 확인을 눌러주세요")
        fetch(`${path}/lecture/attachment/\${attSeq}`, {method: 'DELETE'})
            .then(res => {
                if (res.ok) {
                    alert("삭제 완료");
                    loadVideoList(episodeSeq);
                } else {
                    alert("삭제 실패");
                }
            });
    }


</script>
<%--자료 업로드 스크립트--%>
<script>
    // 파일 선택 시 파일명 표시
    $(document).on("change", "input[type='file']", function (e) {
        const fileName = e.target.files[0]?.name || "파일을 선택하세요";
        $(e.target).next("label").text(fileName);
    });

    const addDelFileFunctions = (() => {
        let count = 2;
        const addFunc = () => {
            if (count <= 5) {
                const $form = $("#basic-file-form").clone(true);
                $form.find("span.input-group-text").text(`첨부파일${count}`);
                $form.find("label.custom-file-label")
                    .text("파일을 선택하세요")
                    .attr("for", `upFile${count}`);
                $form.find("input[type='file']")
                    .attr("id", `upFile${count}`)
                    .val('');
                count++;
                $("#uploaded-files-list").before($form);
            } else {
                alert("첨부파일은 최대 5개까지 가능합니다.");
            }
        };
        const delFunc = () => {
            if (count > 2) {
                $("#uploaded-files-list").prev(".input-group").remove();
                count--;
            }
        };
        return [addFunc, delFunc];
    })();

    const [addFile, delFile] = addDelFileFunctions;

    function deleteAttachment(attachSeq) {
        confirm("삭제를 원하시면 확인을 눌러주세요")
        fetch(`${path}/lecture/attachment/\${attachSeq}`, { method: 'DELETE' })
            .then(res => {
                if (res.ok) {
                    alert("삭제 완료");
                    location.reload();
                } else {
                    alert("삭제 실패");
                }
            });
    }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
