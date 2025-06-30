<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />
<c:set var="impCode" value="${impCode}" />

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
      hideLoading();
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
        alert("결제에 실패했습니다: " + rsp.error_msg);
      }
    });
  }
</script>

<div class="container mt-5">
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

    <!-- 💳 결제 정보 -->
    <div class="col-md-4">
      <div class="card mb-4">
        <div class="card-header bg-success text-white">
          결제 정보
        </div>
        <div class="card-body">
          <ul class="list-group list-group-flush mb-3">
            <li class="list-group-item">
              <strong>원래 가격:</strong>
              <span class="text-muted" style="text-decoration: line-through;">
                <fmt:formatNumber value="${course.coursePrice}" pattern="#,##0"/>원
              </span>
            </li>
            <li class="list-group-item">
              <strong>결제 금액:</strong>
              <span style="font-size: 1.2em;">
                <fmt:formatNumber value="${paymentPrice}" pattern="#,##0"/>원
              </span>
            </li>
          </ul>

          <!-- 카카오페이 결제 버튼 -->
          <button type="button" class="btn btn-warning btn-block mb-2"
                  onclick="requestPay()"
                  style="background-color:#FEE500; border:none; color:#3C1E1E; font-weight:bold;">
            <img src="${path}/resources/images/kakaopay.png"
                 alt="카카오페이"
                 style="height:24px; vertical-align:middle; margin-right:8px;">
            카카오페이로 결제하기
          </button>

          <!-- 취소 버튼 -->
          <a href="${path}/course/view?courseSeq=${courseSeq}"
             class="btn btn-outline-secondary btn-block">
            취소
          </a>
        </div>
      </div>
    </div>

  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
