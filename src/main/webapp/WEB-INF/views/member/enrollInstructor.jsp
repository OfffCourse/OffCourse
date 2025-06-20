<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>

<div style="margin-top: 100px; max-width: 700px; margin-left: auto; margin-right: auto; padding: 20px;">
  <h2 style="text-align:center; margin-bottom:30px;">강사 회원가입</h2>
  <form action="${path}/member/enroll" method="post" enctype="multipart/form-data" id="instructorEnrollForm" onsubmit="return validateForm();">
    <input type="hidden" name="memberType" value="1"/>

    <div class="form-group">
      <label>아이디</label>
      <input type="text" name="memberId" class="form-control" required minlength="4" maxlength="20">
    </div>

    <div class="form-group">
      <label>비밀번호</label>
      <div style="position: relative;">

        <input type="password" name="memberPwd" id="password" class="form-control" required
               title="영문자, 숫자, 특수문자를 포함한 8자 이상">

        <span class="toggle-password" onclick="togglePassword('password', this)">&#128065;</span>
      </div>
    </div>

    <div class="form-group">
      <label>비밀번호 확인</label>
      <div style="position: relative;">
        <input type="password" id="confirmPassword" class="form-control" required>
        <span class="toggle-password" onclick="togglePassword('confirmPassword', this)">&#128065;</span>
      </div>
      <small id="passwordMatch" style="color: red;"></small>
    </div>

    <div class="form-group">
      <label>이름</label>
      <input type="text" name="memberName" class="form-control" required>
    </div>

    <div class="form-group">
      <label>닉네임</label>
      <input type="text" name="memberNickname" class="form-control" required>
    </div>

    <div class="form-group">
      <label>이메일</label>
      <input type="email" name="memberEmail" class="form-control" required>
    </div>

    <div class="form-group">
      <label>주소</label>
      <div style="display:flex; gap:10px;">
        <input type="text" id="postcode" placeholder="우편번호" readonly class="form-control" style="width:150px;">
        <button type="button" class="btn btn-outline" onclick="execDaumPostcode()">주소 찾기</button>
      </div>
      <input type="text" id="roadAddress" placeholder="도로명 주소" readonly class="form-control mt-2">
      <input type="text" name="memberAddress" id="memberAddress" placeholder="상세 주소를 입력해주세요" class="form-control mt-2" required>
    </div>

    <div class="form-group">
      <label>전화번호</label>
      <input type="text" name="memberPhone" class="form-control" pattern="\d{10,11}" required>
      <small class="form-text text-muted">숫자만 입력해주세요. 예: 01012345678</small>
    </div>

    <div class="form-group">
      <label>프로필 이미지</label>
      <input type="file" name="profileFile" class="form-control-file">
    </div>

    <div class="form-group">
      <label>포트폴리오 파일 (선택)</label>
      <input type="file" name="portfolioFile" class="form-control-file">
    </div>

    <div class="form-group" style="text-align:center; margin-top:30px;">
      <button type="submit" class="btn btn-primary">회원가입</button>
    </div>
  </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<!-- 🔍 주소 검색 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
  function execDaumPostcode() {
    new daum.Postcode({
      oncomplete: function (data) {
        document.getElementById('postcode').value = data.zonecode;
        document.getElementById('roadAddress').value = data.roadAddress;
        document.getElementById('memberAddress').focus();
      }
    }).open();
  }

  // 비밀번호 확인
  document.getElementById("confirmPassword").addEventListener("input", function () {
    const pwd = document.getElementById("password").value;
    const confirm = this.value;
    const msg = document.getElementById("passwordMatch");

    if (pwd !== confirm) {
      msg.style.color = "red";
      msg.textContent = "비밀번호가 일치하지 않습니다.";
    } else {
      msg.style.color = "green";
      msg.textContent = "비밀번호가 일치합니다.";
    }
  });

  // 비밀번호 토글
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

  // 최종 유효성 검사 + 주소 합치기 + 로그
  function validateForm() {
    const pwd = document.getElementById("password").value;
    const confirm = document.getElementById("confirmPassword").value;
    const road = document.getElementById("roadAddress").value;
    const detail = document.getElementById("memberAddress").value;

    if (pwd !== confirm) {
      alert("비밀번호가 일치하지 않습니다.");
      return false;
    }

    // 주소 합치기
    document.getElementById("memberAddress").value = road + " " + detail;

    // 디버깅용 로그
    console.log("📦 memberPwd:", pwd);
    return true;
  }
</script>

<style>
  .toggle-password {
    position: absolute;
    right: 12px;
    top: 50%;
    transform: translateY(-50%);
    cursor: pointer;
    font-size: 18px;
  }
</style>
