<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>

<div style="max-width: 400px; margin: 100px auto; text-align: center;">
    <h3>비밀번호 찾기 결과</h3>

    <p style="color: <c:out value='${msg.contains("전송") ? "green" : "red"}'/>;">
        ${msg}
    </p>

    <div style="margin-top: 30px;">
        <c:choose>
            <%-- 성공 메시지: '전송'이라는 단어가 포함된 경우 --%>
            <c:when test="${msg.contains('전송')}">
                <a href="${path}/member/loginform" class="btn btn-primary" style="margin: 5px;">
                    로그인 하러 가기
                </a>
            </c:when>

            <%-- 실패 메시지: 그 외의 경우 --%>
            <c:otherwise>
                <a href="${path}/member/find-password" class="btn btn-secondary" style="margin: 5px;">
                    비밀번호 다시 찾기
                </a>
                <a href="${path}/member/find-id" class="btn btn-secondary" style="margin: 5px;">
                    아이디 찾기
                </a>
            </c:otherwise>
        </c:choose>
    </div>


</div>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
