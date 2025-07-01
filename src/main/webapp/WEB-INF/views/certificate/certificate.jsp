<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy-MM-dd" var="today"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<link rel="preload" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" as="style">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">


<style>
    @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap');

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #f1f5f9 100%);
        min-height: 100vh;
        color: #334155;
        overflow-x: hidden;
    }

    #certificateArea {
        width: 794px; /* A4 width at 96dpi */
        height: 1123px; /* A4 height at 96dpi */
        background-color: white;
        font-family: 'Noto Sans KR', sans-serif; /* 웹폰트 or 기본폰트 지정 */
        padding: 40px;
    }

    .header {
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        padding: 20px 0;
        border-bottom: 1px solid #e2e8f0;
        position: fixed;
        width: 100%;
        top: 0;
        z-index: 1000;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }

    .header-content {
        max-width: 1400px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 40px;
    }

    .logo {
        font-size: 32px;
        font-weight: bold;
        color: #162D43;
        letter-spacing: -0.5px;
    }

    .header-info {
        display: flex;
        gap: 30px;
        align-items: center;
    }

    .server-status {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        color: #64748b;
    }

    .status-dot {
        width: 8px;
        height: 8px;
        background: #10B981;
        border-radius: 50%;
        animation: pulse-dot 2s infinite;
    }

    @keyframes pulse-dot {
        0% {
            opacity: 1;
        }
        50% {
            opacity: 0.5;
        }
        100% {
            opacity: 1;
        }
    }

    .main-container {
        margin-top: 100px;
        max-width: 1400px;
        margin-left: auto;
        margin-right: auto;
        padding: 40px;
        display: grid;
        grid-template-columns: 450px 1fr;
        gap: 40px;
        min-height: calc(100vh - 100px);
    }

    .form-section {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 40px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        height: fit-content;
    }

    .section-title {
        font-size: 24px;
        color: #1e293b;
        margin-bottom: 30px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .form-group {
        margin-bottom: 25px;
    }

    .form-group label {
        display: block;
        margin-bottom: 10px;
        font-weight: 600;
        color: #334155;
        font-size: 15px;
    }

    .form-group input {
        width: 100%;
        padding: 15px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 16px;
        background: #ffffff;
        transition: all 0.3s ease;
    }

    .form-group input:focus {
        outline: none;
        border-color: #162D43;
        box-shadow: 0 0 0 3px rgba(22, 45, 67, 0.1);
    }

    .form-group input::placeholder {
        color: #94a3b8;
    }

    .btn-group {
        display: flex;
        flex-direction: column;
        gap: 15px;
        margin-top: 40px;
    }

    .btn {
        width: 100%;
        padding: 15px 20px;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
    }

    .btn-primary {
        background: #162D43;
        color: white;
        box-shadow: 0 2px 4px rgba(22, 45, 67, 0.2);
    }

    .btn-primary:hover {
        background: #1e3a56;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(22, 45, 67, 0.3);
    }

    .btn-success {
        background: #10B981;
        color: white;
        box-shadow: 0 2px 4px rgba(16, 185, 129, 0.2);
    }

    .btn-success:hover {
        background: #065f46;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
    }

    .certificate-preview {
        background: linear-gradient(145deg, #ffffff 0%, #f8fafc 100%);
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        padding: 60px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        position: relative;
        min-height: 800px;
    }

    .certificate-preview::before {
        content: '';
        position: absolute;
        top: 15px;
        left: 15px;
        right: 15px;
        bottom: 15px;
        border: 2px solid #162D43;
        border-radius: 12px;
    }

    .certificate-preview::after {
        content: '';
        position: absolute;
        top: 25px;
        left: 25px;
        right: 25px;
        bottom: 25px;
        border: 1px solid #64748b;
        border-radius: 8px;
    }

    .certificate-header {
        text-align: center;
        margin-bottom: 40px;
        position: relative;
        z-index: 2;
    }

    .certificate-badge {
        display: inline-block;
        background: linear-gradient(45deg, #162D43, #1e3a56);
        color: white;
        padding: 12px 24px;
        border-radius: 30px;
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(22, 45, 67, 0.2);
    }

    .certificate-title {
        font-size: 48px;
        font-weight: bolder;
        color: #162D43;
        margin-bottom: 20px;
        text-shadow: 0 2px 4px rgba(22, 45, 67, 0.1);
        font-family: 'Courier New', monospace;
    }

    .student-name {
        font-size: 36px;
        font-weight: 600;
        color: #162D43;
        margin: 40px 0;
        text-decoration: underline;
        text-decoration-color: #64748b;
        text-underline-offset: 10px;
    }

    .certificate-content {
        text-align: center;
        line-height: 2;
        font-size: 18px;
        color: #334155;
        margin-bottom: 40px;
        position: relative;
        z-index: 2;
    }

    .course-name {
        font-size: 24px;
        font-weight: 600;
        color: #162D43;
        margin: 20px 0;
        padding: 15px;
        border: 2px solid #e2e8f0;
        border-radius: 8px;
        background: #f8fafc;
    }

    .certificate-info {
        margin: 40px 0;
        font-size: 16px;
        color: #64748b;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        position: relative;
        z-index: 2;
    }

    .info-item {
        text-align: center;
        padding: 20px;
        background: #f8fafc;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
    }

    .info-label {
        font-weight: 600;
        color: #334155;
        margin-bottom: 8px;
    }

    .info-value {
        color: #162D43;
        font-weight: 500;
    }

    .certificate-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 60px;
        padding-top: 30px;
        border-top: 1px solid #e2e8f0;
        position: relative;
        z-index: 2;
    }

    .issue-date {
        font-size: 16px;
        color: #64748b;
        font-weight: 500;
    }

    .signature-area {
        text-align: center;
    }

    .signature-title {
        font-weight: 600;
        color: #162D43;
        margin-bottom: 15px;
        font-size: 18px;
    }

    .signature-line {
        width: 150px;
        height: 2px;
        background: #162D43;
        margin: 15px auto;
    }

    .seal {
        width: 70px;
        height: 70px;
        border: 3px solid #162D43;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        font-weight: bold;
        color: #162D43;
        margin: 15px auto;
        background: #f8fafc;
    }

    .placeholder {
        color: #94a3b8;
        font-style: italic;
    }

    .loading {
        display: none;
        text-align: center;
        padding: 20px;
        margin-top: 20px;
        background: #f8fafc;
        border-radius: 8px;
        border: 1px solid #e2e8f0;
    }

    .spinner {
        border: 3px solid #e2e8f0;
        border-top: 3px solid #162D43;
        border-radius: 50%;
        width: 30px;
        height: 30px;
        animation: spin 1s linear infinite;
        margin: 0 auto 15px;
    }

    @keyframes spin {
        0% {
            transform: rotate(0deg);
        }
        100% {
            transform: rotate(360deg);
        }
    }

    .loading-text {
        color: #64748b;
        font-size: 14px;
        font-weight: 500;
    }

    .form-info {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 20px;
        margin-top: 30px;
    }

    .info-title {
        font-size: 16px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 15px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .info-list {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    .info-list li {
        color: #64748b;
        font-size: 14px;
        line-height: 1.6;
        margin: 8px 0;
        padding-left: 20px;
        position: relative;
    }

    .info-list li::before {
        content: '•';
        color: #162D43;
        font-weight: bold;
        position: absolute;
        left: 0;
    }

    @media (max-width: 1024px) {
        .main-container {
            grid-template-columns: 1fr;
            gap: 30px;
            padding: 20px;
        }

        .certificate-preview {
            padding: 40px 30px;
        }

        .certificate-title {
            font-size: 36px;
        }

        .student-name {
            font-size: 28px;
        }

        .certificate-info {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 768px) {
        .header-content {
            padding: 0 20px;
        }

        .logo {
            font-size: 24px;
        }

        .header-info {
            gap: 15px;
        }

        .certificate-preview {
            padding: 30px 20px;
        }

        .certificate-title {
            font-size: 28px;
        }

        .student-name {
            font-size: 24px;
        }

        .certificate-content {
            font-size: 16px;
        }

        .course-name {
            font-size: 20px;
        }
    }
</style>
<div class="main-container">
    <div class="form-section">
        <h2 class="section-title">📋 수료증 정보 입력</h2>

        <div class="form-group">
            <label for="studentName">수강생 이름</label>
            <input type="text" id="studentName" placeholder="예: 홍길동" value="${studentName}" readonly>
        </div>

        <div class="form-group">
            <label for="courseName">강의명</label>
            <input type="text" id="courseName" placeholder="예: 웹 개발 기초 과정" value="${courseName}" readonly>
        </div>

        <div class="form-group">
            <label for="startDate">교육 시작일</label>
            <input type="date" id="startDate" value="${courseStartDate}" readonly>
        </div>

        <div class="form-group">
            <label for="endDate">교육 종료일</label>
            <input type="date" id="endDate" value="${courseEndDate}" readonly>
        </div>

        <div class="form-group">
            <label for="institution">교육기관명</label>
            <input type="text" id="institution" placeholder="예: 한국IT교육원" value="Off Course">
        </div>

        <div class="btn-group">
            <button class="btn btn-success" onclick="downloadPDF()">
                📥 PDF 다운로드
            </button>
        </div>

        <div class="loading" id="loading">
            <div class="spinner"></div>
            <div class="loading-text">PDF를 생성하고 있습니다...</div>
        </div>

        <div class="form-info">
            <div class="info-title">💡 이용 안내</div>
            <ul class="info-list">
                <li>PDF 다운로드 전에 정보를 다시 한 번 확인해주세요</li>
                <li>생성된 수료증은 공식 문서로 사용 가능합니다</li>
                <li>문제 발생 시 페이지를 새로고침해주세요</li>
            </ul>
        </div>
    </div>

    <div class="certificate-preview" id="certificateArea">
        <div class="certificate-header">
            <div class="certificate-badge">CERTIFICATE</div>
            <div class="certificate-title">수료증</div>
        </div>

        <div class="student-name" id="previewStudentName">
            <span class="placeholder">${studentName}</span>
        </div>

        <div class="certificate-content">
            위 사람은 본 기관에서 실시한
            <div class="course-name" id="previewCourseName">
                <span class="placeholder">${courseName}</span>
            </div>
            과정을 성공적으로 이수하였기에 이 증서를 수여합니다.
        </div>

        <div class="certificate-info">
            <div class="info-item">
                <div class="info-label">교육기간</div>
                <div class="info-value" id="previewPeriod">
                    <span class="placeholder">${courseStartDate} ~ ${courseEndDate}</span>
                </div>
            </div>
            <div class="info-item">
                <div class="info-label">교육기관</div>
                <div class="info-value" id="previewInstitution">
                    <span class="placeholder">Off Course</span>
                </div>
            </div>
        </div>

        <div class="certificate-footer">
            <div class="issue-date">
                발급일: <span id="issueDate">${today}</span>
            </div>
            <div class="signature-area">
                <div class="signature-title">기관장</div>
                <div class="signature-line"></div>
                <div class="seal"><img src="${path}/resources/images/donue_signature.png" height="40" width="60"></div>
            </div>
        </div>
    </div>
</div>

<script>
    async function downloadPDF() {
        const {jsPDF} = window.jspdf;
        const doc = new jsPDF('p', 'mm', 'a4');

        const element = document.getElementById("certificateArea");

        const canvas = await html2canvas(element, {
            scale: 3,          // 해상도 향상
            useCORS: true,     // 외부 폰트/이미지 허용
            logging: true
        });

        const imgData = canvas.toDataURL("image/png");

        const pdfWidth = doc.internal.pageSize.getWidth();
        const pdfHeight = (canvas.height * pdfWidth) / canvas.width;

        doc.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight);
        doc.save(`${studentName}_${courseName}_certificate.pdf`);
    }

</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>