<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path"    value="${pageContext.request.contextPath}" />
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
  // PortOne 가맹점 식별코드 (imp 코드)
  IMP.init("${impCode}");

  function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
  }
  function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
  }

  // 결제 요청
  function requestPay() {
    showLoading();
    IMP.request_pay({
      pg: "kakaopay.TC0ONETIME",
      // pay_method: "card",
      merchant_uid: "${orderId}",
      name: "강의 결제",
      amount: ${paymentPrice},
      buyer_email: "test@example.com",
      buyer_name: "홍길동",
      buyer_tel: "010-1234-5678"
    }, function (rsp) {
      hideLoading();
      if (rsp.success) {
        // 서버로 결제 성공 데이터 전송 (POST)
        const form = document.createElement("form");
        form.method = "post";
        form.action = "${path}/payment/process";

        const fields = {
          impUid:     rsp.imp_uid,
          orderId:    rsp.merchant_uid,
          courseSeq:  "${courseSeq}",
          memberSeq:  "${memberSeq}",
          paymentPrice: "${paymentPrice}"
        };

        for (const key in fields) {
          const input = document.createElement("input");
          input.type  = "hidden";
          input.name  = key;
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

<div class="container mt-4">
  <!-- 2. 단계별 진행 표시 -->
  <ul class="payment-steps d-flex list-unstyled mb-4">
    <li class="flex-fill text-center text-muted">1. 정보 확인</li>
    <li class="flex-fill text-center font-weight-bold">2. 결제 진행</li>
    <li class="flex-fill text-center text-muted">3. 완료</li>
  </ul>
  <style>
    .payment-steps li + li::before {
      content: "›";
      margin: 0 10px;
      color: #ccc;
    }
  </style>

  <!-- 4. 플래시 메시지 -->
  <c:if test="${not empty msg}">
    <div class="alert alert-info">${msg}</div>
  </c:if>

  <!-- 1. 결제 정보 요약 카드 -->
  <div class="card mb-4">
    <div class="card-header">결제 정보 확인</div>
    <div class="card-body">
      <p><strong>강의명:</strong> ${course.courseName}</p>
      <p><strong>기간:</strong>
        <fmt:formatDate value="${course.courseStartDate}" pattern="yyyy-MM-dd"/>
        ~
        <fmt:formatDate value="${course.courseEndDate}"   pattern="yyyy-MM-dd"/>
      </p>
      <p><strong>인원:</strong> ${course.courseCurrentSize}/${course.courseSize}명</p>
      <hr/>
      <p>
        <del><fmt:formatNumber value="${course.coursePrice}" pattern="#,##0"/>원</del>
        →
        <strong><fmt:formatNumber value="${paymentPrice}"       pattern="#,##0"/>원</strong>
      </p>
    </div>
  </div>

  <!-- 결제 버튼 영역 -->
  <div class="form-group">
    <button type="button" class="btn btn-primary btn-block" onclick="requestPay()">
      결제하기
    </button>
    <a href="${path}/course/view?courseSeq=${courseSeq}"
       class="btn btn-outline-secondary btn-block mt-2">
      취소
    </a>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
