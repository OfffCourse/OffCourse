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
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container">
  <div class="page-header">
    <h1 class="page-title">강의 결제</h1>
    <p class="page-subtitle">결제 정보를 확인하고 결제를 진행하세요</p>
  </div>

  <form action="${path}/payment/process" method="post" class="form">
    <input type="hidden" name="courseSeq" value="${courseSeq}" />
    <input type="hidden" name="memberSeq" value="${memberSeq}" />
    <input type="hidden" name="paymentPrice" value="${paymentPrice}" />
    <input type="hidden" name="orderId" value="${orderId}" />

    <div class="form-group">
      <label class="form-label">결제 금액</label>
      <p class="form-text">${paymentPrice}원</p>
    </div>

    <!-- 카드 정보 등 실제 PG 필드 추가 영역 -->

    <div class="form-group">
      <button type="submit" class="btn btn-primary">결제 완료</button>
      <a href="${path}/course/view?courseSeq=${courseSeq}" class="btn btn-outline">취소</a>
    </div>
  </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>