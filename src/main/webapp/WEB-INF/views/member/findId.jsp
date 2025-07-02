<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<!-- 전체 화면 오버레이 스피너 -->
<div id="loadingOverlay" style="
     display: none;
     position: fixed;
     top: 0; left: 0;
     width: 100%; height: 100%;
     background: rgba(255,255,255,0.7);
     z-index: 9999;
     justify-content: center;
     align-items: center;
">
    <div class="spinner-border text-primary" role="status">
        <span class="sr-only">Loading...</span>
    </div>
</div>

<h2 style="text-align:center; margin-top:120px;">아이디 찾기</h2>

<!-- 폼 구성은 추후 이메일 기반으로 -->
<form action="${path}/member/find-id" method="post" id="findIdForm" style="max-width:400px; margin: 30px auto;">
    <div class="form-group">
        <label for="memberEmail">가입 시 사용한 이메일</label>
        <input type="email" id="memberEmail" name="memberEmail" class="form-control" required>
    </div>

    <div style="text-align:center;">
        <button type="submit" class="hc-btn hc-btn-outline">아이디 찾기</button>
    </div>
</form>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const overlay = document.getElementById('loadingOverlay');
        document.getElementById('findIdForm').addEventListener('submit', function() {
            overlay.style.display = 'flex';
        });
    });
</script>
