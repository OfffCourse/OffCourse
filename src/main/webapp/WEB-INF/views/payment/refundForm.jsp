<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- 🔄 로딩 오버레이 -->
<div id="loadingOverlay" style="
     display: none;
     position: fixed;
     top: 0; left: 0;
     width: 100%; height: 100%;
     background: rgba(255,255,255,0.7);
     z-index: 9999;
     justify-content: center;
     align-items: center;">
  <div class="spinner-border text-danger" role="status">
    <span class="sr-only">Loading...</span>
  </div>
</div>

<style>
  .refund-container {
    max-width: 800px;
    margin: 50px auto;
    font-family: 'Cafe24Supermagic-Bold-v1.0', sans-serif;
  }
  .card-header i {
    margin-right: 8px;
  }
</style>

<script>
  function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
  }
  function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
  }

  function submitRefundForm() {
    if(confirm("정말 환불을 신청하시겠습니까?")) {
      showLoading();
      document.getElementById("refundForm").submit();
    }
  }
</script>

<div class="container refund-container">
  <h2 class="mb-4">💸 환불 신청</h2>

  <div class="row">
    <!-- 📚 강의 정보 -->
    <div class="col-md-8">
      <div class="card mb-4">
        <div class="card-header bg-primary text-white">
          <i class="fas fa-book"></i> 강의 정보
        </div>
        <div class="card-body">
          <h5 class="card-title">🎓 ${course.courseName}</h5>
          <p>
            <strong>🗓 기간:</strong>
            <fmt:formatDate value="${course.courseStartDate}" pattern="yyyy-MM-dd"/> ~
            <fmt:formatDate value="${course.courseEndDate}" pattern="yyyy-MM-dd"/><br>
            <strong>👥 인원:</strong> ${course.courseCurrentSize}/${course.courseSize}명
          </p>
        </div>
      </div>

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
    </div>

    <!-- 💳 환불 정보 -->
    <div class="col-md-4">
      <div class="card mb-4">
        <div class="card-header bg-danger text-white">
          <i class="fas fa-undo"></i> 환불 정보
        </div>
        <div class="card-body">
          <form id="refundForm" action="${path}/payment/refund" method="post">
            <input type="hidden" name="paymentSeq" value="${paymentSeq}" />
            <input type="hidden" name="enrSeq" value="${enrSeq}" />
            <input type="hidden" name="memberSeq" value="${memberSeq}" />
            <input type="hidden" name="impUid" value="${impUid}" />
            <input type="hidden" name="amount" value="${amount}" />

            <ul class="list-group list-group-flush mb-3">
              <li class="list-group-item">
                <strong>환불 금액:</strong>
                <span style="font-size: 1.3em; color: #d9534f;">
                  <fmt:formatNumber value="${amount}" pattern="#,##0"/>원
                </span>
              </li>
            </ul>

            <div class="form-group">
              <label for="reason">✏️ <strong>환불 사유</strong></label>
              <textarea name="reason" id="reason" class="form-control" rows="3" placeholder="필수 입력 사항" required></textarea>
            </div>

            <div class="text-center mb-3">
              <button type="button"
                      class="btn btn-warning btn-block mb-2"
                      onclick="submitRefundForm()"
                      style="background-color:#FEE500; border:none; color:#3C1E1E; font-weight:bold; padding: 14px 0;">
                <img src="${path}/resources/images/kakaopay.png"
                     alt="카카오페이"
                     style="height:50px; vertical-align:middle; margin-right:12px;">
                카카오로 환불
              </button>
            </div>


            <a href="${path}/mypage/student" class="btn btn-outline-secondary btn-block">
              ❌ 환불취소
            </a>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
