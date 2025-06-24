<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<div style="max-width: 400px; margin: 100px auto; text-align: center;">
  <h3>아이디 찾기 결과</h3>

  <c:choose>
    <c:when test="${not empty foundId}">
      <p>회원님의 아이디는 <strong>${foundId}</strong>입니다.</p>
      <a href="${path}/member/loginform" class="btn btn-primary">로그인 하러 가기</a>
      <a href="${path}/member/find-password" class="btn btn-secondary" style="margin: 5px;">
        비밀번호 찾으러 가기
      </a>
    </c:when>
    <c:otherwise>
      <p style="color: red;">${msg}</p>
      <a href="${path}/member/find-id" class="btn btn-secondary">다시 시도</a>
    </c:otherwise>
  </c:choose>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
