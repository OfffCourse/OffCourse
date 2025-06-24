<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>

<div style="margin-top: 100px; text-align: center;">
  <h2>회원 유형을 선택해주세요</h2>
  <div style="display: flex; justify-content: center; gap: 40px; margin-top: 40px;">
    <a href="${path}/member/enroll/student" class="member-card">
      <div class="card">
        <img src="${path}/resources/images/student.png" alt="학생 아이콘" class="card-icon"/>
        <h3>일반 회원</h3>
        <p>수강생으로 가입합니다</p>
      </div>
    </a>
    <a href="${path}/member/enroll/instructor" class="member-card">
      <div class="card">
        <img src="${path}/resources/images/instructor.png" alt="강사 아이콘" class="card-icon"/>
        <h3>강사 회원</h3>
        <p>강사로 가입합니다</p>
      </div>
    </a>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<style>
  .member-card {
    text-decoration: none;
    color: inherit;
  }
  .card {
    width: 250px;
    height: 150px;
    border: 2px solid #ddd;
    border-radius: 12px;
    padding: 30px;
    transition: transform 0.3s, border-color 0.3s;
    display: flex;
    flex-direction: column;
    justify-content: center;
    background-color: #fff;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
  }
  .card:hover {
    transform: translateY(-5px);
    border-color: #162D43;
    cursor: pointer;
  }
  .card h3 {
    font-size: 22px;
    margin-bottom: 8px;
  }
  .card-icon {
    width: 60px;
    height: 60px;
    object-fit: contain;
  }
</style>
