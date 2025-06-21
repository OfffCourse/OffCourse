<%--
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 18.
  Time: 오후 7:24
  To change this template use File | Settings | File Templates.
--%>
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
                <form class="search-form" action="#" method="GET">
                    <input type="text" name="keyword" class="search-input" placeholder="관심있는 강의를 검색해보세요">
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
        <div class="header-actions">
            <a href="${path}/member/loginform" class="btn btn-outline">로그인</a>
            <a href="${path}/member/enroll/select" class="btn btn-primary">회원가입</a>
        </div>
    </div>
</header>

