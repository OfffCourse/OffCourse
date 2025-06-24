<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>

<h2 style="text-align:center; margin-top:100px;">비밀번호 찾기</h2>

<form action="${path}/member/find-password" method="post" style="max-width:400px; margin: 30px auto;">
    <div class="form-group">
        <label for="memberId">아이디</label>
        <input type="text" id="memberId" name="memberId" class="form-control" required>
    </div>
    <div class="form-group">
        <label for="memberEmail">이메일</label>
        <input type="email" id="memberEmail" name="memberEmail" class="form-control" required>
    </div>
    <div style="text-align:center;">
        <button type="submit" class="btn btn-primary">임시 비밀번호 발송</button>
    </div>
</form>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
