<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />
<c:set var="impCode" value="${impCode}" />

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
  <div class="spinner-border text-primary" role="status">
    <span class="sr-only">Loading...</span>
  </div>
</div>

<style>
  .payment-container {
    max-width: 1000px;
    margin: 50px auto;
    font-family: 'Cafe24Supermagic-Bold-v1.0', sans-serif;
  }
  .card-header i {
    margin-right: 8px;
  }
</style>

<script src="https://cdn.iamport.kr/v1/iamport.js"></script>
<script>
  IMP.init("${impCode}");

  function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
  }
  function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
  }

  function requestPay() {
    showLoading();
    IMP.request_pay({
      pg: "kakaopay.TC0ONETIME",
      merchant_uid: "${orderId}",
      name: "OFFCOURSE 강의 결제 - ${course.courseName}",
      amount: ${paymentPrice},
      buyer_email: "${loginMember.memberEmail}",
      buyer_name: "${loginMember.memberName}",
      buyer_tel: "${loginMember.memberPhone}"
    }, function (rsp) {
      if (rsp.success) {
        const form = document.createElement("form");
        form.method = "post";
        form.action = "${path}/payment/process";
        const fields = {
          impUid: rsp.imp_uid,
          orderId: rsp.merchant_uid,
          courseSeq: "${courseSeq}",
          memberSeq: "${memberSeq}",
          paymentPrice: "${paymentPrice}"
        };
        for (const key in fields) {
          const input = document.createElement("input");
          input.type = "hidden";
          input.name = key;
          input.value = fields[key];
          form.appendChild(input);
        }
        document.body.appendChild(form);
        form.submit();
      } else {
        hideLoading();
        alert("결제 실패: " + rsp.error_msg);
      }
    });
  }
</script>

<div class="container payment-container">
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

    <!-- 💳 결제 정보 -->
    <div class="col-md-4">
      <div class="card mb-4">
        <div class="card-header bg-success text-white">
          <i class="fas fa-credit-card"></i> 결제 정보
        </div>
        <div class="card-body text-center">
          <ul class="list-group list-group-flush mb-3">
            <li class="list-group-item">
              <strong>원래 가격:</strong>
              <span class="text-muted" style="text-decoration: line-through;">
                <fmt:formatNumber value="${course.coursePrice}" pattern="#,##0"/>원
              </span>
            </li>
            <li class="list-group-item">
              <strong>결제 금액:</strong>
              <span style="font-size: 1.3em; color: #d9534f;">
                <fmt:formatNumber value="${paymentPrice}" pattern="#,##0"/>원
              </span>
            </li>
          </ul>

          <button type="button" class="btn btn-warning btn-block mb-2" onclick="requestPay()"
                  style="background-color:#FEE500; border:none; color:#3C1E1E; font-weight:bold; padding: 14px 0;">
            <img src="${path}/resources/images/kakaopay.png" alt="카카오페이"
                 style="height:50px; vertical-align:middle; margin-right:12px;">
            카카오로 결제
          </button>

          <a href="${path}/course/view?courseSeq=${courseSeq}" class="btn btn-outline-secondary btn-block">
            ❌ 결제취소
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
