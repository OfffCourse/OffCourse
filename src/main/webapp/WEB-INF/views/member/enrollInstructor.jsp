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

<div style="margin-top: 100px; max-width: 700px; margin: auto; padding: 20px;">
  <h2 style="text-align:center; margin-bottom:30px;">강사 회원가입</h2>

  <form action="${path}/member/enroll"
        method="post"
        enctype="multipart/form-data"
        id="instructorEnrollForm"
        onsubmit="return validateForm();">
    <input type="hidden" name="memberType" value="1"/>

    <!-- 에러 메시지 -->
    <c:if test="${not empty msg}">
      <div class="alert alert-danger" role="alert">${msg}</div>
    </c:if>

    <div class="form-group">
      <label>아이디</label>
      <input type="text"
             name="memberId"
             class="form-control"
             required minlength="4" maxlength="20"
             value="${member.memberId}"/>
    </div>

    <div class="form-group">
      <label>비밀번호</label>
      <div style="position: relative;">
        <input type="password"
               name="memberPwd"
               id="password"
               class="form-control"
               required
               title="영문자, 숫자, 특수문자를 포함한 8자 이상">
        <span class="toggle-password" onclick="togglePassword('password', this)">&#128065;</span>
      </div>
      <!-- 복합성 체크 -->
      <small id="pwdCriteria" style="color:red; margin-top:6px;">
        <ul style="list-style:none; padding:0;">
          <li id="crit-letter">• 영문자 사용</li>
          <li id="crit-number">• 숫자 사용</li>
          <li id="crit-special">• 특수문자 사용</li>
          <li id="crit-length">• 8자 이상</li>
        </ul>
      </small>
    </div>

    <div class="form-group">
      <label>비밀번호 확인</label>
      <div style="position: relative;">
        <input type="password"
               id="confirmPassword"
               class="form-control"
               required>
        <span class="toggle-password" onclick="togglePassword('confirmPassword', this)">&#128065;</span>
      </div>
      <small id="passwordMatch" style="color: red;"></small>
    </div>

    <div class="form-group">
      <label>이름</label>
      <input type="text"
             name="memberName"
             class="form-control"
             required
             value="${member.memberName}"/>
    </div>

    <div class="form-group">
      <label>닉네임</label>
      <input type="text"
             name="memberNickname"
             class="form-control"
             required
             value="${member.memberNickname}"/>
    </div>

    <div class="form-group">
      <label>이메일</label>
      <div style="display:flex; gap:8px; align-items:center;">
        <input type="email"
               name="memberEmail"
               id="memberEmail"
               class="form-control"
               required
               value="${member.memberEmail}"/>
        <button type="button"
                id="sendCodeBtn"
                class="btn btn-outline-secondary">인증번호요청</button>
      </div>
      <!-- 인증번호 입력 섹션 (초기엔 숨김) -->
      <div id="codeSection" style="display:none; margin-top:8px; gap:8px; align-items:center;">
        <input type="text"
               id="authCode"
               placeholder="6자리 인증번호"
               class="form-control"
               style="width:150px;"/>
        <button type="button"
                id="verifyCodeBtn"
                class="btn btn-outline-secondary">확인</button>
        <span id="timer">05:00</span>
      </div>
      <small id="emailMsg" class="form-text"></small>
    </div>

    <div class="form-group">
      <label>주소</label>
      <div style="display:flex; gap:10px;">
        <input type="text"
               id="postcode"
               placeholder="우편번호"
               readonly
               class="form-control"
               style="width:150px;">
        <button type="button"
                class="btn btn-outline"
                onclick="execDaumPostcode()">주소 찾기</button>
      </div>
      <input type="text"
             id="roadAddress"
             placeholder="도로명 주소"
             readonly
             class="form-control mt-2">
      <input type="text"
             name="memberAddress"
             id="memberAddress"
             placeholder="상세 주소를 입력해주세요"
             class="form-control mt-2"
             required
             value="${member.memberAddress}"/>
    </div>

    <div class="form-group">
      <label>전화번호</label>
      <input type="text"
             name="memberPhone"
             class="form-control"
             pattern="\d{10,11}"
             required
             value="${member.memberPhone}"/>
      <small class="form-text text-muted">숫자만 입력해주세요. 예: 01012345678</small>
    </div>

    <!-- 기본 프로필(hidden) -->
    <input type="hidden"
           name="memberProfile"
           value="default_profile_instructor.png"/>
    <div class="form-group">
      <label>프로필 이미지</label>
      <input type="file"
             name="profileFile"
             id="profileFile"
             class="form-control-file">
    </div>

    <div class="form-group">
      <label>포트폴리오 파일 </label>
      <input type="file"
             name="portfolioFile"
             id="portfolioFile"
             class="form-control-file"
             required>
    </div>

    <div class="form-group" style="text-align:center; margin-top:30px;">
      <button type="submit" class="btn btn-primary">회원가입</button>
    </div>
  </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
  function execDaumPostcode() {
    new daum.Postcode({
      oncomplete: function(data) {
        document.getElementById('postcode').value = data.zonecode;
        document.getElementById('roadAddress').value = data.roadAddress;
        document.getElementById('memberAddress').focus();
      }
    }).open();
  }

  // 비밀번호 확인
  document.getElementById("confirmPassword")
          .addEventListener("input", function() {
            const pwd     = document.getElementById("password").value;
            const confirm = this.value;
            const msg     = document.getElementById("passwordMatch");
            if (pwd !== confirm) {
              msg.textContent = "비밀번호가 일치하지 않습니다.";
              msg.style.color = "red";
            } else {
              msg.textContent = "비밀번호가 일치합니다.";
              msg.style.color = "green";
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

  // 최종 유효성 검사 + 주소 합치기
  function validateForm() {
    // ① 비밀번호 일치 체크
    const pwd     = document.getElementById("password").value;
    const confirm = document.getElementById("confirmPassword").value;
    if (pwd !== confirm) {
      alert("비밀번호가 일치하지 않습니다.");
      return false;
    }
    // ② 복합성 체크
    const ok = pwd.length>=8
            && /[A-Za-z]/.test(pwd)
            && /\d/.test(pwd)
            && /[!@#$%^&*()_+=-]/.test(pwd);
    if (!ok) {
      alert("비밀번호는 8자 이상, 영문자·숫자·특수문자를 최소 1개씩 포함해야 합니다.");
      return false;
    }
    // ③ 강사 포트폴리오 필수
    const portfolio = document.getElementById('portfolioFile').files;
    if (portfolio.length === 0) {
      alert('강사 회원은 포트폴리오 파일을 반드시 첨부해야 합니다.');
      return false;
    }
    // ④ 주소 합치기
    const road   = document.getElementById("roadAddress").value;
    const detail = document.getElementById("memberAddress").value;
    document.getElementById("memberAddress").value = road + " " + detail;
    return true;
  }

  document.getElementById('profileFile')
          .addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = function(evt) {
              document.getElementById('profilePreview').src = evt.target.result;
            };
            reader.readAsDataURL(file);
          });

  document.addEventListener('DOMContentLoaded', function() {
    const overlay = document.getElementById('loadingOverlay');
    document.getElementById('instructorEnrollForm').addEventListener('submit', function() {
      overlay.style.display = 'flex';
    });
  });

  // 비밀번호 입력 시 실시간 체크
  document.getElementById('password')
          .addEventListener('input', function() {
            const v = this.value;
            const checks = {
              'crit-length': v.length >= 8,
              'crit-letter': /[A-Za-z]/.test(v),
              'crit-number': /\d/.test(v),
              'crit-special': /[!@#$%^&*()_+=-]/.test(v)
            };
            for (let id in checks) {
              const el = document.getElementById(id);
              if (checks[id]) {
                el.style.color = 'green';
                el.style.textDecoration = 'none';
              } else {
                el.style.color = 'red';
                el.style.textDecoration = 'none';
              }
            }
          });

  document.addEventListener('DOMContentLoaded', function() {
    const path = '${path}';
    const overlay      = document.getElementById('loadingOverlay');
    const sendBtn    = document.getElementById('sendCodeBtn');
    const verifyBtn  = document.getElementById('verifyCodeBtn');
    const emailInput = document.getElementById('memberEmail');
    const codeInput  = document.getElementById('authCode');
    const emailMsg   = document.getElementById('emailMsg');
    const codeSection= document.getElementById('codeSection');
    const timerEl    = document.getElementById('timer');
    let timerInterval;

    // 1) 인증번호 전송
    sendBtn.addEventListener('click', function() {
      const email = emailInput.value.trim();
      if (!email) {
        alert('이메일을 입력해주세요.');
        return;
      }
      emailMsg.textContent = '';
      overlay.style.display = 'flex';

      fetch(path + '/member/sendAuthCode', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'email=' + encodeURIComponent(email)
      })
              .then(res => {
                overlay.style.display = 'none';
                if (!res.ok) throw new Error(res.status);
                return res.text();
              })
              .then(msg => {
                codeSection.style.display  = 'flex';
                emailInput.readOnly      = true;
                sendBtn.textContent = '재요청';
                startTimer(300);
              })
              .catch(err => {
                overlay.style.display = 'none';
                console.error(err);
                alert('인증번호 전송에 실패했습니다.');
              });
    });

    // 2) 인증번호 확인
    verifyBtn.addEventListener('click', function() {
      const code = codeInput.value;
      fetch(path + '/member/verifyAuthCode', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'code=' + encodeURIComponent(code)
      })
              .then(res => res.json())
              .then(data => {
                if (data.success) {
                  clearInterval(timerInterval);
                  emailMsg.textContent = '✅ 이메일 인증 완료';
                  emailInput.readOnly  = true;
                  codeInput.readOnly  = true;
                  sendBtn.disabled     = true;
                  verifyBtn.disabled   = true;
                } else {
                  emailMsg.textContent = data.error;
                }
              })
              .catch(err => {
                console.error(err);
                alert('인증번호 확인 중 오류가 발생했습니다.');
              });
    });

    // 3) 타이머 로직
    function startTimer(sec) {
      clearInterval(timerInterval);
      timerInterval = setInterval(function() {
        if (sec <= 0) {
          clearInterval(timerInterval);
          emailMsg.textContent = '⏰ 인증시간 만료. 다시 요청해주세요.';
          return;
        }
        sec--;
        const m = String(Math.floor(sec/60)).padStart(2,'0');
        const s = String(sec % 60).padStart(2,'0');
        timerEl.textContent = m + ':' + s;
      }, 1000);
    }

  });
</script>

<style>
  .toggle-password {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
    cursor: pointer;
    font-size: 18px;
  }
  #pwdCriteria {
    font-size: 0.3rem;  /* 16px 기준으로 약 9.6px */
  }
</style>
