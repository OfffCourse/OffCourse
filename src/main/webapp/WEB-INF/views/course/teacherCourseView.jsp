<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<link rel="stylesheet" href="${path}/resources/css/courseDetail.css"/>

<div class="course-detail-container">
    <!-- Sidebar -->
    <aside class="sidebar">
        <h2 class="course-title">${course.courseName}</h2>
        <p class="course-instructor">👨‍🏫 ${course.memberName} 강사</p>
        <p class="course-price">
            <del><fmt:formatNumber value="${course.coursePrice}" type="currency"/></del><br/>
            <strong><fmt:formatNumber value="${course.coursePrice * (1 - course.courseDiscount / 100.0)}" type="currency"/> 수강가</strong>
        </p>
        <form action="${path}/course/enroll" method="post">
            <input type="hidden" name="courseId" value="${course.courseId}"/>
            <button type="submit" class="btn btn-hero btn-hero-primary">수강 신청</button>
        </form>
    </aside>

    <!-- Main Content -->
    <main class="course-main">
        <!-- Course Info -->
        <section class="course-info">
            <h3>강의 정보</h3>
            <p>${course.courseDescription}</p>
        </section>

        <!-- Course Sessions -->
        <section class="course-sessions">
            <h3>회차별 강의</h3>
            <c:forEach var="s" items="${course.sessions}">
                <div class="session-item">
                    <button class="toggle-session-btn">${s.sessionTitle}</button>
                    <div class="session-content" style="display: none;">
                        <p><strong>자료:</strong>
                            <a href="${path}/resources/files/${s.materialFileName}" download>다운로드</a>
                        </p>
                        <p><strong>영상:</strong></p>
                        <video controls width="100%">
                            <source src="${path}/videos/${s.videoFileName}" type="video/mp4">
                            브라우저가 영상을 지원하지 않습니다.
                        </video>
                    </div>
                </div>
            </c:forEach>
        </section>

        <!-- Course Reviews -->
        <section class="course-reviews">
            <h3>수강생 리뷰</h3>
            <c:forEach var="r" items="${reviews}">
                <div class="review-item">
                    <p><strong>${r.memberName}</strong> (${r.reviewRate}점)</p>
                    <p>${r.reviewContent}</p>
                </div>
            </c:forEach>
        </section>
    </main>
</div>

<script>
    // 회차별 토글 버튼 동작
    document.querySelectorAll('.toggle-session-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const content = btn.nextElementSibling;
            content.style.display = content.style.display === 'none' ? 'block' : 'none';
        });
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
