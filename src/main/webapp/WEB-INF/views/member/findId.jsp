<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>

<h2 style="text-align:center; margin-top:100px;">아이디 찾기</h2>

<!-- 폼 구성은 추후 이메일 기반으로 -->
<form action="${path}/member/find-id" method="post" style="max-width:400px; margin: 30px auto;">
    <div class="form-group">
        <label for="memberEmail">가입 시 사용한 이메일</label>
        <input type="email" id="memberEmail" name="memberEmail" class="form-control" required>
    </div>
    <div style="text-align:center;">
        <button type="submit" class="btn btn-primary">아이디 찾기</button>
    </div>
</form>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
