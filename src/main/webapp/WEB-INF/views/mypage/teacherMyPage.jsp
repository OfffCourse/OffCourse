<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<link rel="stylesheet" href="${path}/resources/css/teacherMypage.css"/>
<!-- Main Container -->
<div class="main-container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="user-profile">
            <div class="profile-image">박</div>
            <div class="user-name">박강사</div>
            <div class="user-level">Pro 강사</div>
        </div>

        <ul class="sidebar-menu">
            <li><a href="${path}/mypage/teacher?section=create-course" class="menu-item ${section == 'create-course' ? 'active' : ''}" data-section="create-course">
                <span class="icon">➕</span>
                <span>강의 개설</span>
            </a></li>
            <li><a href="${path}/mypage/teacher?section=manage-courses" class="menu-item ${section == 'manage-courses' ? 'active' : ''}" data-section="manage-courses">
                <span class="icon">📚</span>
                <span>강의 정보 수정</span>
            </a></li>
            <li><a href="${path}/mypage/teacher?section=settlement" class="menu-item ${section == 'settlement' ? 'active' : ''}" data-section="settlement">
                <span class="icon">💰</span>
                <span>강의 정산 신청</span>
            </a></li>
            <li><a href="#" class="menu-item" data-section="profile">
                <span class="icon">👤</span>
                <span>개인정보 수정</span>
            </a></li>
            <li><a href="#" class="menu-item" data-section="settings">
                <span class="icon">⚙️</span>
                <span>설정</span>
            </a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- 강의 개설 Section -->
        <div class="section ${section == 'create-course' ? 'active' : ''}" id="create-course">
            <div class="page-header">
                <h1 class="page-title">강의 개설</h1>
                <p class="page-subtitle">새로운 강의를 개설하고 학생들에게 지식을 전달하세요</p>
            </div>

            <div class="course-form">
                <form action="${pageContext.request.contextPath}/course/insert" method="post" onsubmit="return validateEpisodeCount();">

                    <!-- 강의명 -->
                    <div class="mb-3">
                        <label class="form-label">강의명</label>
                        <input type="text" class="form-control" name="courseName" required>
                    </div>

                    <!-- 카테고리 선택 -->
                    <div class="mb-3">
                        <label class="form-label">카테고리 선택</label>
                        <div class="category-container">

                            <!-- 백엔드 -->
                            <div class="category-group">
                                <div class="parent-category" data-target="backend-sub">백엔드 ▼</div>
                                <div class="sub-category" id="backend-sub" style="display: none;">
                                    <div><input type="radio" name="categoryType" id="java" value="Java" required><label for="java">Java</label></div>
                                    <div><input type="radio" name="categoryType" id="python" value="Python"><label for="python">Python</label></div>
                                </div>
                            </div>

                            <!-- 프론트엔드 -->
                            <div class="category-group">
                                <div class="parent-category" data-target="frontend-sub">프론트엔드 ▼</div>
                                <div class="sub-category" id="frontend-sub" style="display: none;">
                                    <div><input type="radio" name="categoryType" id="react" value="React"><label for="react">React</label></div>
                                    <div><input type="radio" name="categoryType" id="vue" value="Vue.js"><label for="vue">Vue.js</label></div>
                                </div>
                            </div>

                            <!-- 비즈니스 -->
                            <div class="category-group">
                                <div class="parent-category" data-target="business-sub">비즈니스 ▼</div>
                                <div class="sub-category" id="business-sub" style="display: none;">
                                    <div><input type="radio" name="categoryType" id="marketing" value="Marketing"><label for="marketing">마케팅</label></div>
                                    <div><input type="radio" name="categoryType" id="startup" value="Startup"><label for="startup">스타트업</label></div>
                                </div>
                            </div>

                            <!-- 디자인 -->
                            <div class="category-group">
                                <div class="parent-category" data-target="design-sub">디자인 ▼</div>
                                <div class="sub-category" id="design-sub" style="display: none;">
                                    <div><input type="radio" name="categoryType" id="ux" value="UX/UI"><label for="ux">UX/UI</label></div>
                                    <div><input type="radio" name="categoryType" id="photoshop" value="Photoshop"><label for="photoshop">Photoshop</label></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 커리큘럼 -->
                    <div class="mb-3">
                        <label class="form-label">커리큘럼</label>
                        <textarea class="form-control" name="courseCurriculum" rows="3"></textarea>
                    </div>

                    <!-- 주소 -->
                    <!-- 주소 입력 -->
                    <div class="mb-3">
                        <label class="form-label">주소</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="courseAddress" name="courseAddress" placeholder="주소를 검색해주세요" readonly required>
                            <button type="button" class="btn btn-outline-secondary" onclick="execDaumPostcode()">주소 검색</button>
                        </div>
                    </div>

                    <!-- 상세 주소 입력 -->
                    <div class="mb-3">
                        <label class="form-label">상세 주소</label>
                        <input type="text" class="form-control" id="courseDetailAddress" name="courseDetailAddress" placeholder="상세 주소 입력">
                    </div>


                    <!-- 시작일/종료일 -->
                    <div class="row mb-3">
                        <div class="col">
                            <label class="form-label">시작일</label>
                            <input type="date" id="startDate" class="form-control" name="courseStartDate" required>
                        </div>
                        <div class="col">
                            <label class="form-label">종료일</label>
                            <input type="date" id="endDate" class="form-control" name="courseEndDate" required>
                        </div>
                    </div>

                    <!-- 가격/할인 -->
                    <div class="row mb-3">
                        <div class="col">
                            <label class="form-label">가격</label>
                            <input type="number" class="form-control" name="coursePrice" value="0" required>
                        </div>
                        <div class="col">
                            <label class="form-label">할인률 (%)</label>
                            <input type="number" class="form-control" name="courseDiscount" value="0">
                        </div>
                    </div>

                    <!-- QA 링크 -->
                    <div class="mb-3">
                        <label class="form-label">Q&A 링크(오픈 카카오톡)</label>
                        <input type="url" class="form-control" name="courseQaLink">
                    </div>

                    <!-- 정원 -->
                    <div class="mb-3">
                        <label class="form-label">수강 정원</label>
                        <input type="number" class="form-control" name="courseSize" required>
                    </div>

                    <!-- 카테고리 & 회원 번호는 임시로 숨김 -->
                    <input type="hidden" name="memberSeq" value="1"/>
                    <%--<input type="hidden" name="categorySeq" value="1"/>--%>

                    <!-- 요일 선택 -->
                    <div class="mb-3">
                        <label class="form-label">강의 요일</label>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="6" id="sun">
                            <label class="form-check-label" for="sun">일</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="0" id="mon">
                            <label class="form-check-label" for="mon">월</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="1" id="tue">
                            <label class="form-check-label" for="tue">화</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="2" id="wed">
                            <label class="form-check-label" for="wed">수</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="3" id="thu">
                            <label class="form-check-label" for="thu">목</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="4" id="fri">
                            <label class="form-check-label" for="fri">금</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="checkbox" name="dayList" value="5" id="sat">
                            <label class="form-check-label" for="sat">토</label>
                        </div>
                    </div>
                    <button type="button" class="btn btn-primary" onclick="episodeCount()">회차 수 계산</button>
                    <button type="submit" class="btn btn-primary">강의 등록</button>
                </form>
                <!-- 회차 수 -->
                <%--<div class="mb-3">
                    <label class="form-label">총 회차 수</label>
                    <div class="input-group">
                        <input type="number" id="episodeCount" class="form-control" name="episodeCount" readonly>
                        <button type="button" class="btn btn-outline-secondary" onclick="episodeCount()">계산</button>
                    </div>
                </div>--%>
            </div>
        </div>

        <!-- 강의 정보 수정 Section -->
        <div class="section ${section == 'manage-courses' ? 'active' : ''}" id="manage-courses">
            <div class="page-header">
                <h1 class="page-title">강의 정보 수정</h1>
                <p class="page-subtitle">내 강의 목록을 확인하고 관리하세요</p>
            </div>

            <div class="course-list">
                <c:if test="${not empty myPageResponses}">
                    <c:forEach var="m" items="${myPageResponses}">
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>${m.courseName}</h3>
                                    <div class="course-meta">
                                        <span>📅 ${m.courseStartDate} ~ ${m.courseEndDate}</span>
                                        <%--<span>⏰ 평일 19:00-22:00</span>--%>
                                        <span>📍 ${m.courseAddress}</span>
                                        <span>👥 수강생 ${courseSize}명</span>
                                    </div>
                                </div>
                                <div class="course-status status-progress">진행중</div>
                            </div>
                            <div class="course-actions">
                                <button class="btn btn-primary btn-sm" onclick="openEditModal(this)"
                                        data-course-name="${m.courseName}"
                                        data-course-curriculum="${m.courseCurriculum}"
                                        data-course-address="${m.courseAddress}"
                                        data-course-detail-address="${m.courseDetailAddress}"
                                        data-course-discount="${m.courseDiscount}"
                                        data-course-qalink="${m.courseQaLink}"
                                        data-course-seq="${m.courseSeq}">강의 정보 수정</button>
                                <button class="btn btn-danger btn-sm" onclick="openDeleteModal(this)"
                                        data-course-name="${m.courseName}"
                                        data-course-seq="${m.courseSeq}">강의 삭제 신청</button>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>
            </div>
            <c:if test="${section == 'manage-courses'}">
                <div id="pageBar">${pageBar}</div>
            </c:if>
        </div>

        <!-- 강의 정산 신청 Section -->
        <div class="section ${section == 'settlement' ? 'active' : ''}" id="settlement">
            <div class="page-header">
                <h1 class="page-title">강의 정산 신청</h1>
                <p class="page-subtitle">완료된 강의에 대한 정산을 신청하세요</p>
            </div>

            <div class="course-list">
                <c:if test="${not empty myPageResponses}">
                    <c:forEach var="m" items="${myPageResponses}">
                        <div class="course-item">
                            <div class="course-header">
                                <div class="course-info">
                                    <h3>${m.courseName}</h3>
                                    <div class="course-meta">
                                        <span>📅 ${m.courseStartDate} ~ ${m.courseEndDate}</span>
                                        <span>👥 수강생 32명</span>
                                        <span>💰 정산 예정금액: ₩2,400,000</span>
                                    </div>
                                </div>
                                <div class="course-status status-completed">완료</div>
                            </div>
                            <div class="course-actions">
                                <button class="btn btn-primary btn-sm" onclick="openSettlementModal(this)"
                                        data-course-name="${m.courseName}"
                                        data-account-price="${m.accountPrice}"
                                        data-course-seq="${m.courseSeq}">정산 신청</button>

                            </div>
                        </div>
                    </c:forEach>
                </c:if>
            </div>
            <c:if test="${section == 'settlement'}">
                <div id="pageBar">${pageBar}</div>
            </c:if>
        </div>

        <!-- 개인정보 수정 Section -->
        <div class="section" id="profile">
            <div class="page-header">
                <h1 class="page-title">개인정보 수정</h1>
                <p class="page-subtitle">개인정보를 안전하게 관리하세요</p>
            </div>

            <form class="profile-form">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">이름</label>
                        <input type="text" class="form-input" value="박강사" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">생년월일</label>
                        <input type="date" class="form-input" value="1985-06-20">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">이메일</label>
                    <input type="email" class="form-input" value="instructor@example.com" required>
                </div>

                <div class="form-group">
                    <label class="form-label">휴대폰 번호</label>
                    <input type="tel" class="form-input" value="010-9876-5432" required>
                </div>

                <div class="form-group">
                    <label class="form-label">전문 분야</label>
                    <input type="text" class="form-input" value="웹 개발, 프론트엔드, JavaScript">
                </div>

                <button type="submit" class="btn btn-primary">저장하기</button>
            </form>
        </div>

        <!-- 설정 Section -->
        <div class="section" id="settings">
            <div class="page-header">
                <h1 class="page-title">설정</h1>
                <p class="page-subtitle">알림 및 계정 설정을 관리하세요</p>
            </div>

            <div class="empty-state">
                <div class="icon">⚙️</div>
                <h3>설정 기능 준비중</h3>
                <p>곧 다양한 설정 옵션이 추가됩니다.</p>
            </div>
        </div>
    </main>
</div>

<!-- 강의 정보 수정 Modal -->
<div id="editModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title">강의 정보 수정</h2>
            <button class="close" onclick="closeModal('editModal')">&times;</button>
        </div>
        <form id="editForm" action="${pageContext.request.contextPath}/course/update" method="post">
            <div class="form-group">
                <label class="form-label">강의명</label>
                <input type="text" class="form-input" id="editCourseName" name="courseName" required>
            </div>

            <div class="form-group">
                <div class="mb-3">
                    <label class="form-label">커리큘럼</label>
                    <textarea class="form-control" name="courseCurriculum" rows="3"></textarea>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">주소</label>
                <div class="input-group">
                    <input type="text" class="form-control" id="editCourseAddress" name="courseAddress" placeholder="주소를 검색해주세요" readonly required>
                    <button type="button" class="btn btn-outline-secondary" onclick="execDaumPostcodeForEditModal()">주소 검색</button>
                </div>
                <label class="form-label">상세 주소</label>
                <input type="text" class="form-control" id="editCourseDetailAddress" name="courseDetailAddress" placeholder="상세 주소 입력">

            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">할인률 (%)</label>
                    <input type="number" class="form-control" name="courseDiscount" value="0">
                </div>
                <div class="form-group">
                    <label class="form-label">Q&A 링크</label>
                    <input type="url" class="form-control" name="courseQaLink">
                </div>
            </div>
            <%--<input type="hidden" name="memberSeq" value="1"/>--%>
            <input type="hidden" name="courseSeq"/>
            <div class="course-actions">
                <button type="button" class="btn btn-outline" onclick="closeModal('editModal')">취소</button>
                <button type="submit" class="btn btn-primary">수정하기</button>
            </div>
        </form>
    </div>
</div>

<!-- 강의 삭제 신청 Modal -->
<div id="deleteModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title">강의 삭제 신청</h2>
            <button class="close" onclick="closeModal('deleteModal')">&times;</button>
        </div>
        <form id="deleteForm" action="${path}/mypage/deleterequest" method="post">
            <div class="alert alert-error">
                <strong>⚠️ 주의:</strong> 강의 삭제는 신중히 결정해주세요. 삭제된 강의는 복구할 수 없습니다.
            </div>

            <div class="form-group">
                <label class="form-label">강의명 확인</label>
                <input type="text" class="form-input" id="deleteCourseName" readonly>
            </div>

            <div class="form-group">
                <label class="form-label">삭제 사유</label>
                <textarea name="deleteRequestContent" class="form-textarea" id="deleteReason" placeholder="강의를 삭제하려는 사유를 상세히 입력해주세요" required></textarea>
            </div>

            <div class="form-group">
                <label class="form-label">확인용 강의명 입력</label>
                <input type="text" class="form-input" id="confirmCourseName" placeholder="위 강의명을 정확히 입력하세요" required>
            </div>
            <input type="hidden" name="courseSeq" id="deleteCourseSeq"/>
            <input type="hidden" name="deleteRequestStatus" value="0"/>
            <div class="course-actions">
                <button type="button" class="btn btn-outline" onclick="closeModal('deleteModal')">취소</button>
                <button type="submit" class="btn btn-danger">삭제 신청</button>
            </div>
        </form>
    </div>
</div>

<!-- 정산 신청 Modal -->
<div id="settlementModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title">강의 정산 신청</h2>
            <button class="close" onclick="closeModal('settlementModal')">&times;</button>
        </div>
        <form id="settlementForm" action="${path}/mypage/account" method="post">
            <div class="form-group">
                <label class="form-label">강의명</label>
                <input type="text" class="form-input" id="settlementCourseName" readonly>
            </div>

            <div class="form-group">
                <label class="form-label">정산 예정 금액</label>
                <input name="accountPrice" type="text" class="form-input" id="settlementAmount" readonly>
            </div>

            <div class="form-group">
                <label class="form-label">은행명</label>
                <select name="accountBankName" class="form-select" id="bankName" required>
                    <option value="">은행을 선택하세요</option>
                    <option value="KB국민은행">KB국민은행</option>
                    <option value="신한은행">신한은행</option>
                    <option value="우리은행">우리은행</option>
                    <option value="하나은행">하나은행</option>
                    <option value="기업은행">기업은행</option>
                    <option value="농협은행">농협은행</option>
                    <option value="카카오뱅크">카카오뱅크</option>
                    <option value="토스뱅크">토스뱅크</option>
                    <option value="기타">기타</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">계좌번호</label>
                <input name="accountBankNumber" type="text" class="form-input" id="accountNumber" placeholder="계좌번호를 입력하세요 (- 없이)" required>
            </div>

            <div class="form-group">
                <label class="form-label">본인 계좌만 가능합니다</label>
            </div>

            <div class="alert alert-success">
                <strong>ℹ️ 안내:</strong> 정산 신청 후 3-5 영업일 내에 검토 후 입금됩니다.
            </div>
            <input type="hidden" name="courseSeq" id="settleCourseSeq"/>
            <div class="course-actions">
                <button type="button" class="btn btn-outline" onclick="closeModal('settlementModal')">취소</button>
                <button type="submit" class="btn btn-primary">정산 신청</button>
            </div>
        </form>
    </div>
</div>
<script>
    // 오늘 날짜를 yyyy-mm-dd 형식으로 반환
    const today = new Date().toISOString().split("T")[0];

    window.addEventListener("DOMContentLoaded", () => {
        document.getElementById("startDate").setAttribute("min", today);
        document.getElementById("endDate").setAttribute("min", today);
    });
</script>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                // 도로명 주소 또는 지번 주소
                var address = data.roadAddress ? data.roadAddress : data.jibunAddress;

                document.getElementById('courseAddress').value = address;

                // 상세주소로 focus 이동
                document.getElementById('courseDetailAddress').focus();
            }
        }).open();
    }
    function execDaumPostcodeForEditModal() {
        new daum.Postcode({
            oncomplete: function(data) {
                var address = data.roadAddress ? data.roadAddress : data.jibunAddress;
                document.getElementById('editCourseAddress').value = address;
                document.getElementById('editCourseDetailAddress').focus();
            }
        }).open();
    }

</script>

<script>
    document.querySelectorAll('.parent-category').forEach(parent => {
        parent.addEventListener('click', () => {
            const targetId = parent.getAttribute('data-target');
            const sub = document.getElementById(targetId);
            sub.style.display = (sub.style.display === 'none') ? 'block' : 'none';
        });
    });
</script>
<script>
    function validateEpisodeCount() {
        const start = new Date(document.getElementById('startDate').value);
        const end = new Date(document.getElementById('endDate').value);
        //const episodeCount = parseInt(document.getElementById('episodeCount').value, 10);|| isNaN(episodeCount

        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
            alert("시작일, 종료일을 모두 입력해주세요.");
            return false;
        }

        if (start > end) {
            alert("시작일은 종료일보다 빠를 수 없습니다.");
            return false;
        }

        const selectedDays = [...document.querySelectorAll('input[name="dayList"]:checked')]
            .map(cb => parseInt(cb.value));

        if (selectedDays.length === 0) {
            alert("요일을 최소 하나 이상 선택해야 합니다.");
            return false;
        }

        // 요일 변환 함수
        const toMondayStart = (day) => (day === 0 ? 6 : day - 1);

        // 날짜 범위 내에서 조건에 맞는 날짜 수 계산
        let validDates = 0;
        let matchDayExists = false;
        for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
            const jsDay = d.getDay();                // 일=0
            const customDay = toMondayStart(jsDay);  // 월=0
            if (selectedDays.includes(customDay)) {
                validDates++;
                matchDayExists = true;
            }
        }

        if (!matchDayExists) {
            alert("선택한 요일이 시작일과 종료일 사이에 포함되어 있지 않습니다.");
            return false;
        }

        /*if (episodeCount > validDates) {
            alert(`선택된 날짜 범위 내에서는 최대 \${validDates}회까지 등록 가능합니다.`);
            return false;
        }*/
        //alert(`선택된 날짜 범위 내에서는 최대 \${validDates}회까지 등록 가능합니다.`);
        return true;
    }
    function episodeCount(){
        const start = new Date(document.getElementById('startDate').value);
        const end = new Date(document.getElementById('endDate').value);
        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
            alert("시작일, 종료일을 모두 입력해주세요.");
            return false;
        }

        if (start > end) {
            alert("시작일은 종료일보다 빠를 수 없습니다.");
            return false;
        }

        const selectedDays = [...document.querySelectorAll('input[name="dayList"]:checked')]
            .map(cb => parseInt(cb.value));

        if (selectedDays.length === 0) {
            alert("요일을 최소 하나 이상 선택해야 합니다.");
            return false;
        }

        // 요일 변환 함수
        const toMondayStart = (day) => (day === 0 ? 6 : day - 1);

        // 날짜 범위 내에서 조건에 맞는 날짜 수 계산
        let validDates = 0;
        let matchDayExists = false;
        for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
            const jsDay = d.getDay();                // 일=0
            const customDay = toMondayStart(jsDay);  // 월=0
            if (selectedDays.includes(customDay)) {
                validDates++;
                matchDayExists = true;
            }
        }

        if (!matchDayExists) {
            alert("선택한 요일이 시작일과 종료일 사이에 포함되어 있지 않습니다.");
            return false;
        }
        alert(`총 \${validDates}회까지 등록됩니다.`);
    }
</script>

<script>
    // 메뉴 네비게이션
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', function(e) {
            //e.preventDefault();

            // 모든 메뉴 아이템에서 active 클래스 제거
            document.querySelectorAll('.menu-item').forEach(menu => {
                menu.classList.remove('active');
            });

            // 클릭된 아이템에 active 클래스 추가
            this.classList.add('active');

            // 모든 섹션 숨기기
            document.querySelectorAll('.section').forEach(section => {
                section.classList.remove('active');
            });

            // 선택된 섹션 보이기
            const sectionId = this.dataset.section;
            const section = document.getElementById(sectionId);
            if (section) {
                section.classList.add('active');
            }
        });
    });

    // 모달 열기/닫기 함수
    function openModal(modalId) {
        document.getElementById(modalId).style.display = 'block';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    // 강의 정보 수정 모달 열기
    function openEditModal(button) {
        document.getElementById('editCourseName').value = button.dataset.courseName;
        document.getElementById('courseAddress').value = button.dataset.courseAddress;
        document.getElementById('courseDetailAddress').value = button.dataset.courseDetailAddress;
        document.querySelector('textarea[name="courseCurriculum"]').value = button.dataset.courseCurriculum;
        document.querySelector('input[name="courseDiscount"]').value = button.dataset.courseDiscount;
        document.querySelector('input[name="courseQaLink"]').value = button.dataset.courseQalink;
        document.querySelector('input[name="courseSeq"]').value = button.dataset.courseSeq;

        openModal('editModal');
    }


    // 강의 삭제 모달 열기
    function openDeleteModal(button) {
        document.getElementById('deleteCourseName').value = button.dataset.courseName;
        document.getElementById('confirmCourseName').value = '';

        document.getElementById('deleteCourseSeq').value = button.dataset.courseSeq;
        openModal('deleteModal');

    }

    // 정산 신청 모달 열기
    function openSettlementModal(button) {

        document.getElementById('settlementCourseName').value = button.dataset.courseName;
        document.getElementById('settlementAmount').value = button.dataset.accountPrice;
        document.getElementById('settleCourseSeq').value = button.dataset.courseSeq;
        openModal('settlementModal');

    }

    // 모달 외부 클릭 시 닫기
    window.onclick = function(event) {
        const modals = document.querySelectorAll('.modal');
        modals.forEach(modal => {
            if (event.target === modal) {
                modal.style.display = 'none';
            }
        });
    }

    document.getElementById('deleteForm').addEventListener('submit', function(e) {
        const originalName = document.getElementById('deleteCourseName').value.trim();
        const confirmName = document.getElementById('confirmCourseName').value.trim();

        if (originalName !== confirmName) {
            showAlert('강의명이 일치하지 않습니다.', 'error');
            return;
        }
    });

    document.getElementById('settlementForm').addEventListener('submit', function(e) {
        const accountNumber = document.getElementById('accountNumber').value;

        // 계좌번호 유효성 검사 (간단한 예시)
        if (!/^\d{10,14}$/.test(accountNumber.replace(/-/g, ''))) {
            showAlert('올바른 계좌번호를 입력해주세요.', 'error');
            return;
        }
    });


    // 알림 표시 함수
    function showAlert(message, type = 'success') {
        const alertDiv = document.createElement('div');
        alertDiv.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 16px 24px;
                background: \${type === 'error' ? '#dc3545' : '#162D43'};
                color: white;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
                z-index: 10000;
                animation: slideIn 0.3s ease;
                max-width: 400px;
            `;
        alertDiv.textContent = message;

        document.body.appendChild(alertDiv);

        setTimeout(() => {
            alertDiv.remove();
        }, 3000);
    }

    // CSS 애니메이션 추가
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
        `;
    document.head.appendChild(style);
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>