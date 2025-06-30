<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

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

<div class="container mt-5">
  <!-- 페이지 타이틀 -->
  <h2 class="mb-4">환불 신청</h2>

  <!-- flash message -->
  <c:if test="${not empty msg}">
    <div class="alert alert-info alert-dismissible fade show" role="alert">
        ${msg}
      <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
  </c:if>

  <div class="row">

    <!-- 📝 강의 정보 -->
    <div class="col-md-8">
      <div class="card mb-4">
        <div class="card-header bg-primary text-white">
          강의 정보
        </div>
        <div class="card-body">
          <h5 class="card-title">${course.courseName}</h5>
          <p>
            <strong>기간:</strong>
            <fmt:formatDate value="${course.courseStartDate}" pattern="yyyy-MM-dd"/>
            ~
            <fmt:formatDate value="${course.courseEndDate}" pattern="yyyy-MM-dd"/><br>
            <strong>인원:</strong>
            ${course.courseCurrentSize}/${course.courseSize}명
          </p>
        </div>
      </div>

      <!-- 📝 회원 정보 -->
      <div class="card mb-4">
        <div class="card-header bg-secondary text-white">
          회원 정보
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
          환불 정보
        </div>
        <div class="card-body">
          <form id="refundForm" action="${path}/payment/refund" method="post">
            <input type="hidden" name="paymentSeq" value="${paymentSeq}" />
            <input type="hidden" name="enrSeq" value="${enrSeq}" />
            <input type="hidden" name="impUid" value="${impUid}" />
            <input type="hidden" name="amount" value="${amount}" />

            <ul class="list-group list-group-flush mb-3">
              <li class="list-group-item">
                <strong>환불 금액:</strong>
                <span style="font-size: 1.2em;">
                  <fmt:formatNumber value="${amount}" pattern="#,##0"/>원
                </span>
              </li>
            </ul>

            <!-- 환불 사유 입력 -->
            <div class="form-group">
              <label for="reason"><strong>환불 사유</strong></label>
              <textarea name="reason" id="reason" class="form-control" rows="3" placeholder="환불 사유를 입력해주세요." required></textarea>
            </div>

            <!-- 카카오페이 표시 -->
            <div class="text-center mb-3">
              <img src="${path}/resources/images/kakaopay.png"
                   alt="카카오페이"
                   style="height:40px;">
              <p class="text-muted" style="font-size:0.9em;">
                카카오페이 연동 환불 처리
              </p>
            </div>

            <!-- 환불 버튼 -->
            <button type="button" class="btn btn-danger btn-block mb-2" onclick="submitRefundForm()">
              환불 신청
            </button>

            <!-- 취소 버튼 -->
            <a href="${path}/mypage/student" class="btn btn-outline-secondary btn-block">
              취소
            </a>
          </form>
        </div>
      </div>
    </div>

  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
