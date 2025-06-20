<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>

<div style="max-width: 400px; margin: 100px auto;">
  <h2 style="text-align: center;">로그인</h2>

  <!-- 🔴 에러 메시지 -->
  <c:if test="${not empty param.error}">
    <p style="color:red; text-align:center;">아이디 또는 비밀번호가 올바르지 않습니다.</p>
  </c:if>

  <form action="${path}/member/login" method="post" id="loginForm">
    <div class="form-group">
      <label for="memberId">아이디</label>
      <input type="text" id="memberId" name="memberId" class="form-control" required>
    </div>

    <div class="form-group" style="position: relative;">
      <label for="memberPwd">비밀번호</label>
      <input type="password" id="memberPwd" name="memberPwd" class="form-control" required>
      <button type="button" id="togglePwd" style="position: absolute; top: 32px; right: 10px; border: none; background: none;">
        👁
      </button>
    </div>

    <div class="form-group">
      <input type="checkbox" id="saveId">
      <label for="saveId">아이디 저장</label>
    </div>

    <div class="form-group" style="text-align: center;">
      <button type="submit" class="btn btn-primary">로그인</button>
    </div>
  </form>
</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
  // 👁 비밀번호 보기 토글
  document.getElementById('togglePwd').addEventListener('click', function () {
    const pwdField = document.getElementById('memberPwd');
    pwdField.type = pwdField.type === 'password' ? 'text' : 'password';
  });

  // ✅ 아이디 저장 기능 (localStorage 사용)
  const memberIdInput = document.getElementById('memberId');
  const saveIdCheckbox = document.getElementById('saveId');

  // 페이지 로드 시 저장된 아이디 불러오기
  window.addEventListener('DOMContentLoaded', () => {
    const savedId = localStorage.getItem('savedMemberId');
    if (savedId) {
      memberIdInput.value = savedId;
      saveIdCheckbox.checked = true;
    }
  });

  // 로그인 시 아이디 저장 체크여부 확인
  document.getElementById('loginForm').addEventListener('submit', () => {
    if (saveIdCheckbox.checked) {
      localStorage.setItem('savedMemberId', memberIdInput.value);
    } else {
      localStorage.removeItem('savedMemberId');
    }
  });
</script>
