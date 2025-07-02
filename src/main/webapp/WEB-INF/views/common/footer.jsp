<%--
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 18.
  Time: 오후 7:44
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    /* Footer */
    .footer {
        background: #162D43;
        color: white;
        padding: 50px 0 30px;
        /*margin-top: 80px;*/
    }

    .footer-content {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 40px;
    }

    .footer-section h3 {
        margin-bottom: 20px;
        color: #84b3d3;
    }

    .footer-section p, .footer-section a {
        color: #adb5bd;
        text-decoration: none;
        line-height: 1.8;
    }

    .footer-section a:hover {
        color: white;
    }
</style>
<!-- Footer -->
<footer class="footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3>Off Course</h3>
            <p>전문가와 함께하는 오프라인 교육의 새로운 경험을 제공합니다.</p>
            <p>📧 info@educenter.com</p>
            <p>📞 02-1234-5678</p>
        </div>
        <div class="footer-section">
            <h3>강의 카테고리</h3>
            <p><a href="#">프로그래밍</a></p>
            <p><a href="#">디자인</a></p>
            <p><a href="#">비즈니스</a></p>
            <p><a href="#">외국어</a></p>
        </div>
        <div class="footer-section">
            <h3>고객 지원</h3>
            <p><a href="#">자주 묻는 질문</a></p>
            <p><a href="#">환불 정책</a></p>
            <p><a href="#">이용 약관</a></p>
            <p><a href="#">개인정보 처리방침</a></p>
        </div>
    </div>
</footer>
</body>
</html>