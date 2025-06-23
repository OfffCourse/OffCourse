<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Off Course - 오프라인 강의 예약</title>
    <!-- jQuery library -->
    <script src="${pageContext.request.contextPath}/resources/js/jquery-3.7.1.min.js"></script>

    <!-- Popper JS -->
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>

    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css">

    <!-- Latest compiled JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="${path}/resources/css/style.css"/>
</head>
<body>
<!-- Header -->
<header class="header">
    <div class="header-container">
        <a href="${path}" class="logo"><img src="${path}/resources/images/logo.png" alt="Off Course" width="50px" height="50px">Off Course</a>
        <!-- Search Section -->
        <section class="search-section">
            <div class="search-container">
                <form id="headerSearchForm" class="search-form" action="${pageContext.request.contextPath}/course/listpage" method="GET">
                    <input type="text" name="courseTitle" class="search-input" placeholder="관심있는 강의를 검색해보세요">
                    <button type="submit" class="search-btn btn btn-hero btn-hero-primary">검색</button>
                </form>
            </div>
        </section>
        <nav>
            <ul class="nav-menu">
                <li><a href="#courses">강의</a></li>
                <li><a href="#bootcamp">국비지원</a></li>
            </ul>
        </nav>

        <!-- 로그인 상태에 따른 헤더 표시 -->
        <div class="header-actions">
            <c:choose>
                <%-- 로그인 안 된 경우 --%>
                <c:when test="${empty loginMember}">
                    <a href="${path}/member/loginform" class="btn btn-primary">로그인</a>
                    <a href="${path}/member/enroll/select" class="btn btn-outline">회원가입</a>
                </c:when>

                <%-- 로그인 된 경우 --%>
                <c:otherwise>
                    <span class="welcome-msg font-weight-bold mr-2">${loginMember.memberNickname}님, 환영합니다!</span>
                    <c:choose>
                        <%-- 일반과 강사회원의 마이페이지 주소 다르게 --%>
                        <c:when test="${loginMember.memberType == '0'}">
                            <a href="${path}/member/mypage/student" class="btn btn-primary mr-2">마이페이지</a>
                        </c:when>
                        <c:when test="${loginMember.memberType == '1'}">
                            <a href="${path}/member/mypage/teacher" class="btn btn-primary mr-2">마이페이지</a>
                        </c:when>
                    </c:choose>
                    <%--<a href="${path}/member/logout" class="text-muted small align-self-center"
                       style="margin-top: 4px;">로그아웃</a>
                    <c:set var="_csrf" value="${_csrf}" />--%>
                    <form id="logoutForm" action="${path}/member/logout" method="post" style="display:inline;">
<%--
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        csrf 를 끄면 get 방식으로도 로그아웃이 되긴 되지만, 추후에 csrf 기능도 키려면,
                        post 방식으로 로그아웃을 보내야 security-context 에서도 받아내고 로그아웃을 시켜줌
--%>
                        <button type="submit" class="btn btn-link text-muted small align-self-center"
                                style="padding: 0; margin-top: 4px;">로그아웃</button>
                    </form>

                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>

