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

<div style="max-width: 400px; margin: 100px auto;">
  <h2 style="text-align: center;">로그인</h2>

  <!-- 아이디/비번 오류 -->
  <c:if test="${loginError}">
    <p style="color:red; text-align:center;">
      아이디 또는 비밀번호가 올바르지 않습니다.
    </p>
  </c:if>

  <!-- 세션 만료 안내 -->
  <c:if test="${sessionExpired}">
    <p style="color:orange; text-align:center;">
      세션이 만료되었습니다.<br/>
      다른 곳에서 동일 계정으로 로그인하셨습니다.
    </p>
  </c:if>

  <form action="${path}/member/login" method="post" id="loginForm">
    <div class="form-group">
      <label for="memberId">아이디</label>
      <input type="text" id="memberId" name="memberId"
             value="${cookie.savedId.value}" class="form-control" required>
      <%--아이디 저장된 쿠키에서 값을 불러옴--%>
    </div>

    <div class="form-group">
      <label for="memberPwd">비밀번호</label>
      <div style="position: relative;">
        <input type="password" id="memberPwd" name="memberPwd" class="form-control" required>
        <span class="toggle-password" onclick="togglePassword('memberPwd', this)">&#128065;</span>
      </div>
    </div>
    <div class="form-group d-flex justify-content-between align-items-center" style="margin-bottom: 15px;">
      <div class="form-check">
        <%--사용자가 체크하면 서버에서 쿠키 저장 처리--%>
        <input type="checkbox" class="form-check-input" id="saveId" name="saveId"
               <c:if test="${not empty cookie.savedId}">checked</c:if>>
        <label class="form-check-label" for="saveId">아이디 저장</label>
      </div>
      <div class="form-check">
        <%--Spring Security의 remember-me 키로 자동 로그인 유지 기능 동작--%>
        <input type="checkbox" class="form-check-input" id="rememberMe" name="remember-me">
        <label class="form-check-label" for="rememberMe">로그인 유지</label>
      </div>
    </div>

    <div class="form-group" style="text-align: center; margin-bottom: 20px;">
      <a href="${path}/member/find-id" style="margin-right: 10px; color: #888;">아이디 찾기</a>
      <span style="color: #ccc;">|</span>
      <a href="${path}/member/find-password" style="margin-left: 10px; color: #888;">비밀번호 찾기</a>
    </div>

    <div class="form-group" style="text-align:center;">
      <button type="submit" class="hc-btn hc-btn-outline">로그인</button>
    </div>
  </form>

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    const overlay = document.getElementById('loadingOverlay');
    // 로그인 폼 제출 시 오버레이 보이기
    document.getElementById('loginForm').addEventListener('submit', function () {
      overlay.style.display = 'flex';
    });
  });

  function togglePassword(inputId, el) {
    const input = document.getElementById(inputId);
    if (input.type === "password") {
      input.type = "text";
      if (el) el.textContent = '👁';
    } else {
      input.type = "password";
      if (el) el.textContent = '👁';
    }
  }
</script>

<style>


  /* input 우측에 아이콘 공간 확보 */
  .position-relative .form-control {
    padding-right: 2.5rem;  /* 적당히 여유 주기 */
  }

  .toggle-password {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
    cursor: pointer;
  }

</style>