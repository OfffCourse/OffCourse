<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String filename = request.getParameter("filename");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>강의 영상</title>
</head>
<body>
<h2>강의 영상 시청</h2>
<video id="videoPlayer" controls width="800">
    <source src="${pageContext.request.contextPath}/resources/upload/lecture/video/<%=filename%>" type="video/mp4">
    브라우저가 video를 지원하지 않습니다.
</video>

<!-- 직접 제어할 JS (선택 사항) -->
<script>
    const video = document.getElementById('videoPlayer');

    // 예: 10초 앞으로
    function skipForward() {
        video.currentTime += 10;
    }

    // 예: 10초 뒤로
    function skipBackward() {
        video.currentTime -= 10;
    }
</script>

<button onclick="skipBackward()">⏪ 10초 뒤로</button>
<button onclick="skipForward()">⏩ 10초 앞으로</button>
</body>
</html>
