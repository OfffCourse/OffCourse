<%--<!-- studentMyPage.jsp 예시 -->--%>
<%--<c:forEach var="ph" items="${paymentList}">--%>
<%--  <!-- ... 결제 내역 표시 ... -->--%>
<%--  <c:url var="refundUrl" value="${path}/payment/refund-form">--%>
<%--    <c:param name="paymentSeq" value="${ph.paymentSeq}"/>--%>
<%--    <c:param name="enrSeq" value="${ph.enrSeq}"/>--%>
<%--  </c:url>--%>
<%--  <a href="${refundUrl}">환불 신청</a>--%>
<%--</c:forEach>--%>
<%-- 저렇게 된 상황에서 환불 화면으로 넘어오는 것 --%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container">
  <div class="page-header">
    <h1 class="page-title">환불 신청</h1>
    <p class="page-subtitle">환불 처리 전에 내용을 확인하세요</p>
  </div>

  <form action="${path}/payment/refund" method="post" class="form">
    <input type="hidden" name="paymentSeq" value="${paymentSeq}" />
    <input type="hidden" name="enrSeq" value="${enrSeq}" />
    <input type="hidden" name="impUid" value="${impUid}" />
    <input type="hidden" name="amount" value="${amount}" />

    <div class="form-group">
      <label class="form-label">환불 요청 강의</label>
      <p class="form-text">[강의명을 서버에서 조회하여 표시]</p>
    </div>

    <div class="form-group">
      <label class="form-label">환불 사유</label>
      <textarea name="reason" class="form-input form-textarea" placeholder="환불 사유를 입력하세요" required></textarea>
    </div>

    <div class="form-group">
      <button type="submit" class="btn btn-primary">환불 완료</button>
      <a href="${path}/mypage/student" class="btn btn-outline">취소</a>
    </div>
  </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>