<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- 🔄 로딩 오버레이 -->
<div id="loadingOverlay" style="
     display: none; position: fixed; top: 0; left: 0;
     width: 100%; height: 100%; background: rgba(255,255,255,0.7);
     z-index: 9999; justify-content: center; align-items: center;">
  <div class="spinner-border text-danger" role="status">
    <span class="sr-only">Loading...</span>
  </div>
</div>

<div class="container mt-4">

  <!-- 단계별 진행 표시 -->
  <ul class="payment-steps d-flex list-unstyled mb-4">
    <li class="flex-fill text-center text-muted">1. 정보 확인</li>
    <li class="flex-fill text-center font-weight-bold">2. 환불 진행</li>
    <li class="flex-fill text-center text-muted">3. 완료</li>
  </ul>

  <!-- 플래시 메시지 -->
  <c:if test="${not empty msg}">
    <div class="alert alert-info mb-4">${msg}</div>
  </c:if>

  <!-- 🙋 회원 정보 -->
  <div class="card mb-4">
    <div class="card-header bg-secondary text-white">
      <i class="fas fa-user"></i> 회원 정보
    </div>
    <div class="card-body">
      <p><strong>이름:</strong> ${loginMember.memberName}</p>
      <p><strong>이메일:</strong> ${loginMember.memberEmail}</p>
      <p><strong>연락처:</strong> ${loginMember.memberPhone}</p>
    </div>
  </div>

  <!-- 💳 환불 정보 확인 -->
  <div class="card mb-4">
    <div class="card-header text-white bg-secondary d-flex justify-content-between align-items-center">
      <span>환불 정보 확인</span>
    </div>
    <div class="card-body">
      <form id="refundForm" action="${path}/payment/refund" method="post">
        <input type="hidden" name="paymentSeq" value="${paymentSeq}" />
        <input type="hidden" name="enrSeq"     value="${enrSeq}" />
        <input type="hidden" name="memberSeq"  value="${memberSeq}" />
        <input type="hidden" name="impUid"     value="${impUid}" />
        <input type="hidden" name="amount"     value="${amount}" />

        <!-- 강의 기본 정보 -->
        <p><strong>강의명:</strong> ${course.courseName}</p>
        <p>
          <strong>기간:</strong>
          <fmt:formatDate value="${course.courseStartDate}" pattern="yyyy-MM-dd"/> ~
          <fmt:formatDate value="${course.courseEndDate}"   pattern="yyyy-MM-dd"/>
        </p>
        <hr/>

        <!-- 환불 금액 -->
        <ul class="list-group list-group-flush mb-3">
          <li class="list-group-item">
            <strong>환불 금액:</strong>
            <span style="font-size: 1.3em; color: #d9534f;">
              <fmt:formatNumber value="${amount}" pattern="#,##0"/>원
            </span>
          </li>
        </ul>

        <!-- 환불 사유 -->
        <div class="form-group">
          <label for="reason">✏️ <strong>환불 사유</strong></label>
          <textarea name="reason" id="reason" class="form-control" rows="3"
                    placeholder="필수 입력 사항" required></textarea>
        </div>

        <!-- 버튼 그룹 -->
        <div class="form-group text-center mb-4">
          <p class="mb-2">
            <img src="${path}/resources/images/kakaopay.png"
                 alt="카카오페이" style="height:40px;">
          </p>
          <p class="text-muted" style="font-size:0.9em;">카카오페이 제휴사</p>

          <button type="button" class="btn btn-warning btn-block"
                  style="background-color:#FEEB00; border:none; color:#3C1E1E; font-weight:bold;"
                  onclick="submitRefundForm()">
            <img src="${path}/resources/images/kakaopay.png"
                 alt="카카오페이"
                 style="height:24px; vertical-align:middle; margin-right:8px;">
            카카오페이로 환불받기
          </button>

          <a href="${path}/mypage/student"
             class="btn btn-outline-secondary btn-block mt-2">
            ❌ 환불 취소
          </a>
        </div>
      </form>
    </div>
  </div>

</div>

<!-- 공통 스타일 -->
<style>
  /* 단계 표시 */
  .payment-steps {
    margin-top: 200px;
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 25px;
  }
  .payment-steps li + li::before {
    content: "›";
    margin: 0 10px;
    color: #ccc;
  }

  /* 버튼 비활성화 */
  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>

<!-- 환불 스크립트 -->
<script>
  function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
  }
  function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
  }
  function submitRefundForm() {
    const form = document.getElementById('refundForm');
    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }
    if (confirm('정말 환불을 신청하시겠습니까?')) {
      showLoading();
      form.submit();
    }
  }
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
