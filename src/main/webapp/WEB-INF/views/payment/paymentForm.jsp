<%--// 4) 버튼 매핑 예시: commonCourseView.jsp--%>
<%--<c:url var="paymentUrl" value="${path}/payment/form">--%>
<%--  <c:param name="courseSeq" value="${course.courseSeq}"/>--%>
<%--  <c:param name="memberSeq" value="${user.memberSeq}"/>--%>
<%--  <c:param name="paymentPrice" value="${course.discountedPrice}"/>--%>
<%--</c:url>--%>
<%--<a href="${paymentUrl}">수강신청</a>--%>
<%-- 저렇게 된 상황에서 결제 화면으로 넘어오는 것 --%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<c:set var="impCode" value="${impCode}" />
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- PortOne JS SDK -->
<script src="https://cdn.iamport.kr/v1/iamport.js"></script>
<script>
  // PortOne 가맹점 식별코드 (imp 코드)
  IMP.init("${impCode}");
  function requestPay() {
    IMP.request_pay({
      pg: "tosspay.tosstest",         // 테스트용 PG사: 토스 테스트
      pay_method: "card",
      merchant_uid: "offcourse_order_id_" + new Date().getTime(),     // 주문번호
      name: "강의 결제",
      amount: ${paymentPrice},       // 결제 금액
    }, function (rsp) {
      if (rsp.success) {
        // 서버로 결제 성공 데이터 전송 (POST)
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

<div class="container">
  <div class="page-header">
    <h1 class="page-title">강의 결제</h1>
    <p class="page-subtitle">결제 정보를 확인하고 결제를 진행하세요</p>
  </div>

  <!-- 더 이상 form 제출이 아닌 JS 결제 요청 방식 -->
  <div class="form-group">
    <label class="form-label">결제 금액</label>
    <p class="form-text">${paymentPrice}원</p>
  </div>

  <div class="form-group">
    <button type="button" class="btn btn-primary" onclick="requestPay()">결제하기</button>
    <a href="${path}/course/view?courseSeq=${courseSeq}" class="btn btn-outline">취소</a>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
