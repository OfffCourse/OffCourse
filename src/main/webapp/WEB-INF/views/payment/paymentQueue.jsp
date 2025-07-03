<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<head>
  <title>결제 대기열 - Off Course</title>
  <script src="${pageContext.request.contextPath}/resources/js/jquery-3.7.1.min.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/queue.css"></link>
</head>
<body>
<div class="header">
  <div class="header-content">
    <a href="${pageContext.request.contextPath}/" class="logo">
      <img src="${pageContext.request.contextPath}/resources/images/logo.png" alt="Off Course" width="50" height="50">
      Off Course
    </a>
    <div class="header-info">
      <div class="server-status">
        <div class="status-dot"></div>
        서버 상태: 정상
      </div>
      <div class="server-status">
        현재 시간: <span id="current-time"></span>
      </div>
    </div>
  </div>
</div>

<div class="main-container">
  <div class="queue-main">
    <div class="update-indicator" id="update-indicator">업데이트됨</div>

    <div class="queue-status-header">
      <div class="status-badge payment-queue" id="status-badge">결제 대기</div>
      <h1 class="queue-title" id="queue-title">
        결제 대기열에서 순서를 기다리고 있습니다
      </h1>
      <p class="queue-subtitle" id="queue-subtitle">
        수강 인원 초과로 결제 대기 중입니다. 취소된 수강자가 있으면 자동으로 결제 페이지로 이동합니다.
      </p>
    </div>

    <!-- 강의 정보 카드 -->
    <c:if test="${course != null}">
      <div class="course-info-card">
        <div class="card-title">🎓 수강 신청 강의</div>
        <div class="course-details">
          <div class="course-name">${course.courseName}</div>
          <div class="course-meta">
            <div class="meta-item">
              <span class="meta-label">수강 기간:</span>
              <span class="meta-value">
                <fmt:formatDate value="${course.courseStartDate}" pattern="yyyy-MM-dd"/> ~
                <fmt:formatDate value="${course.courseEndDate}" pattern="yyyy-MM-dd"/>
              </span>
            </div>
            <div class="meta-item">
              <span class="meta-label">현재 인원:</span>
              <span class="meta-value" id="current-enrollment">
                ${course.courseCurrentSize}/${course.courseSize}명
              </span>
            </div>
            <div class="meta-item">
              <span class="meta-label">결제 금액:</span>
              <span class="meta-value payment-price">
                <fmt:formatNumber value="${paymentPrice}" pattern="#,##0"/>원
              </span>
            </div>
          </div>
        </div>
      </div>
    </c:if>

    <div class="queue-position-display">
      <div class="position-label">현재 대기 순번</div>
      <div style="display: flex; align-items: baseline; justify-content: center;">
        <span class="queue-position" id="position">-</span>
        <span class="position-suffix">번째</span>
      </div>
    </div>

    <div class="progress-section">
      <div class="progress-header">
        <span class="progress-title">예상 진행률</span>
        <span class="progress-percentage" id="progress-percent">0%</span>
      </div>
      <div class="progress-bar">
        <div class="progress-fill" id="progress-fill"></div>
      </div>
    </div>

    <div class="queue-actions">
      <button class="btn btn-primary" onclick="refreshQueue()">
        <span class="loading-spinner" id="spinner" style="display: none;"></span>
        상태 새로고침
      </button>
      <button class="btn btn-secondary" onclick="cancelPaymentQueue()">
        수강 신청 취소
      </button>
      <button class="btn btn-info" onclick="window.open('https://open.kakao.com/o/scWgCCzh','OffCourse 고객센터','_blank')">
        고객 센터
      </button>
    </div>

    <div class="footer-info">
      세션 ID: <strong class="highlight" id="session-id">${sessionId}</strong> |
      연결 시간: <strong class="highlight" id="connect-time"></strong>
    </div>
  </div>

  <div class="sidebar">
    <div class="info-card">
      <div class="card-title">📊 실시간 결제 대기열 정보</div>
      <div class="info-item">
        <span class="info-label">예상 대기시간</span>
        <span class="info-value" id="estimated-time">계산 중</span>
      </div>
      <div class="info-item">
        <span class="info-label">결제 대기자</span>
        <span class="info-value" id="total-waiting">-</span>
      </div>
      <div class="info-item">
        <span class="info-label">결제 진행 중</span>
        <span class="info-value" id="active-payments">-</span>
      </div>
      <div class="info-item">
        <span class="info-label">마지막 업데이트</span>
        <span class="info-value" id="last-update">-</span>
      </div>
    </div>

    <div class="info-card tips-card">
      <div class="card-title">📋 결제 대기 안내</div>
      <ul class="tips-list">
        <li>⚠️ 이 페이지를 닫거나 새로고침하지 마세요</li>
        <li>취소자가 발생하면 자동으로 결제 페이지로 이동합니다</li>
        <li>결제 시간 제한: 10분 (제한 시간 초과 시 페이지 이탈)</li>
        <li>결제 완료 전까지는 수강 등록이 확정되지 않습니다</li>
        <li>문제 발생 시 새로고침 버튼을 눌러주세요</li>
      </ul>
    </div>

    <div class="info-card">
      <div class="card-title">🎯 강의 현황</div>
      <div class="course-status-grid">
        <div class="status-item">
          <span class="status-value" id="course-current">-</span>
          <span class="status-label">현재 수강</span>
        </div>
        <div class="status-item">
          <span class="status-value" id="course-max">-</span>
          <span class="status-label">최대 정원</span>
        </div>
        <div class="status-item">
          <span class="status-value" id="available-spots">-</span>
          <span class="status-label">여유 자리</span>
        </div>
        <div class="status-item">
          <span class="status-value" id="payment-processing">-</span>
          <span class="status-label">결제 진행</span>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  /* 결제 대기열 전용 스타일 */
  .payment-queue {
    background: linear-gradient(45deg, #FF6B6B, #4ECDC4) !important;
  }

  .course-info-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 25px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.1);
  }

  .course-info-card .card-title {
    font-size: 1.2rem;
    font-weight: bold;
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .course-name {
    font-size: 1.4rem;
    font-weight: bold;
    margin-bottom: 15px;
    color: #fff;
  }

  .course-meta {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .meta-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid rgba(255,255,255,0.2);
  }

  .meta-item:last-child {
    border-bottom: none;
  }

  .meta-label {
    font-weight: 500;
    color: rgba(255,255,255,0.9);
  }

  .meta-value {
    font-weight: bold;
    color: #fff;
  }

  .payment-price {
    font-size: 1.1rem;
    color: #FFE066 !important;
  }

  .course-status-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
    margin-top: 15px;
  }

  .status-item {
    text-align: center;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 8px;
    border: 2px solid #e9ecef;
    transition: all 0.3s ease;
  }

  .status-item:hover {
    border-color: #007bff;
    transform: translateY(-2px);
  }

  .status-value {
    display: block;
    font-size: 1.5rem;
    font-weight: bold;
    color: #007bff;
    margin-bottom: 5px;
  }

  .status-label {
    font-size: 0.9rem;
    color: #6c757d;
    font-weight: 500;
  }

  /* 반응형 대응 */
  @media (max-width: 768px) {
    .course-meta {
      gap: 12px;
    }

    .meta-item {
      flex-direction: column;
      align-items: flex-start;
      gap: 4px;
    }

    .course-status-grid {
      grid-template-columns: 1fr;
      gap: 10px;
    }
  }
</style>
<script>
// ✅ 개선된 결제 대기열 JavaScript
let isRefreshing = false;
let autoRefreshInterval;
let heartbeatInterval;
let heartbeatFailCount = 0;
const MAX_HEARTBEAT_FAILS = 3;

// 상태 관리 변수
let currentQueueStatus = null;
let lastKnownPosition = null;
let lastSuccessfulUpdate = Date.now();

// 결제 대기열 관련 변수
const courseSeq = '${courseSeq}';
const memberSeq = '${memberSeq}';
const paymentPrice = '${paymentPrice}';

// 페이지 로드 시 초기화
$(document).ready(function() {
console.log('결제 대기열 페이지 초기화 시작');

// 연결 시간 표시
const connectTime = new Date().toLocaleTimeString('ko-KR', { hour12: false });
document.getElementById('connect-time').textContent = connectTime;

// 시간 업데이트 시작
updateCurrentTime();
setInterval(updateCurrentTime, 1000);

// 초기 상태 확인
refreshQueue();

// 자동 새로고침 시작
startAutoRefresh();

// Heartbeat 시작
startHeartbeat();

// 인원 상태 주기적 체크
setInterval(updateCourseStatus, 15000);
updateCourseStatus();

console.log('결제 대기열 페이지 초기화 완료');
});

// 현재 시간 업데이트
function updateCurrentTime() {
const now = new Date();
const timeElement = document.getElementById('current-time');
if (timeElement) {
timeElement.textContent = now.toLocaleTimeString('ko-KR', { hour12: false });
}
}

// ✅ 개선된 상태 새로고침
function refreshQueue() {
if (isRefreshing) return;

isRefreshing = true;
showLoading(true);

// 캐시 방지를 위한 timestamp 추가
const statusUrl = "${pageContext.request.contextPath}/payment/status?courseSeq=" + courseSeq +
"&isQueuePage=true&_t=" + Date.now();

fetch(statusUrl, {
method: 'GET',
headers: {
'Accept': 'application/json',
'Cache-Control': 'no-cache'
}
})
.then(response => {
if (!response.ok) {
throw new Error(`HTTP ${response.status}: ${response.statusText}`);
}
return response.json();
})
.then(data => {
console.log('결제 대기열 상태 응답:', data);

if (!data || typeof data !== 'object') {
throw new Error('잘못된 응답 데이터');
}

// 성공적인 업데이트 시간 기록
lastSuccessfulUpdate = Date.now();

// 현재 상태 저장
currentQueueStatus = data.status || data.sessionStatus;

// 순번이 유효한 경우에만 업데이트
const newPosition = data.position || data.sessionPosition;
if (newPosition && newPosition > 0) {
// 순번이 급격히 변경되는 경우 경고
if (lastKnownPosition && Math.abs(newPosition - lastKnownPosition) > 10) {
console.warn('순번 급격한 변경 감지:', lastKnownPosition, '->', newPosition);
}
lastKnownPosition = newPosition;
}

// 표시 업데이트
updateQueueDisplay(data);
showUpdateIndicator();
})
.catch(error => {
console.error('상태 확인 오류:', error);

// 오류 발생 시 처리
const timeSinceLastUpdate = Date.now() - lastSuccessfulUpdate;
if (timeSinceLastUpdate < 30000) { // 30초 이내면 마지막 상태 유지
console.log('일시적 오류 - 마지막 상태 유지');
maintainLastKnownState();
} else {
showErrorState('상태 확인 중 오류가 발생했습니다');
}
})
.finally(() => {
showLoading(false);
isRefreshing = false;
});
}

// ✅ 대기열 표시 업데이트 - 안정성 개선
function updateQueueDisplay(data) {
const statusBadge = document.getElementById('status-badge');
const queueTitle = document.getElementById('queue-title');
const queueSubtitle = document.getElementById('queue-subtitle');
const position = document.getElementById('position');
const estimatedTime = document.getElementById('estimated-time');
const progressFill = document.getElementById('progress-fill');
const progressPercent = document.getElementById('progress-percent');

console.log('대기열 표시 업데이트:', {
status: data.status,
sessionStatus: data.sessionStatus,
position: data.position,
sessionPosition: data.sessionPosition,
lastKnownPosition: lastKnownPosition,
waitingUsers: data.waitingPaymentUsers,
activeUsers: data.activePaymentUsers
});

// 결제 허용 상태 처리
if (data.status === 'ALLOW' || data.sessionStatus === 'ALLOW') {
console.log('결제 허용 상태 - 페이지 이동 준비');

if (statusBadge) {
statusBadge.textContent = '결제 가능';
statusBadge.style.background = 'linear-gradient(45deg, #10B981, #065f46)';
}
if (queueTitle) queueTitle.textContent = '결제를 진행하실 수 있습니다!';
if (queueSubtitle) queueSubtitle.textContent = '잠시 후 결제 페이지로 자동 이동됩니다.';

if (position) position.textContent = '-';
if (estimatedTime) estimatedTime.textContent = '즉시 결제';
if (progressFill) progressFill.style.width = '100%';
if (progressPercent) progressPercent.textContent = '100%';

// 인터벌 정리
clearInterval(autoRefreshInterval);
clearInterval(heartbeatInterval);

// 결제 페이지로 이동
setTimeout(() => {
const paymentUrl = "${pageContext.request.contextPath}/payment/form" +
"?courseSeq=" + courseSeq + "&memberSeq=" + memberSeq + "&paymentPrice=" + paymentPrice;
window.location.href = paymentUrl;
}, 2000);

return;
}

// ✅ 대기 상태 처리 - 순번 안정성 개선
if (data.status === 'WAITING' || data.sessionStatus === 'WAITING') {
if (statusBadge) {
statusBadge.textContent = '결제 대기';
statusBadge.style.background = 'linear-gradient(45deg, #FF6B6B, #4ECDC4)';
}
if (queueTitle) queueTitle.textContent = '결제 대기열에서 순서를 기다리고 있습니다';
if (queueSubtitle) queueSubtitle.textContent = '수강 인원 초과로 결제 대기 중입니다. 취소된 수강자가 있으면 자동으로 결제 페이지로 이동합니다.';

// ✅ 순번 결정 로직 개선
let displayPosition = null;

// 서버에서 받은 순번 확인
const serverPosition = data.position || data.sessionPosition;

if (serverPosition && serverPosition > 0) {
displayPosition = serverPosition;
lastKnownPosition = serverPosition;
} else if (lastKnownPosition && lastKnownPosition > 0) {
// 서버 순번이 없으면 마지막 알려진 순번 사용
console.log('서버 순번 없음 - 마지막 알려진 순번 사용:', lastKnownPosition);
displayPosition = lastKnownPosition;
} else {
// 둘 다 없으면 기본값
displayPosition = 1;
}

console.log('최종 순번 표시:', displayPosition);

// 순번 표시 애니메이션
if (position) {
const currentDisplayed = parseInt(position.textContent) || 0;
if (currentDisplayed !== displayPosition) {
position.style.transition = 'color 0.3s';
position.style.color = '#4ECDC4';
position.textContent = displayPosition;
setTimeout(() => {
position.style.color = '';
}, 300);
} else {
position.textContent = displayPosition;
}
}

// 예상 시간 계산
if (estimatedTime) {
if (data.estimatedWaitTime && data.estimatedWaitTime > 0) {
const minutes = Math.ceil(data.estimatedWaitTime / 60);
estimatedTime.textContent = minutes > 0 ? '약 ' + minutes + '분' : '1분 이내';
} else {
const estimatedMinutes = Math.max(1, displayPosition * 2);
estimatedTime.textContent = '약 ' + estimatedMinutes + '분';
}
}

// 진행률 계산
if (progressFill && progressPercent) {
const maxPosition = Math.max(20, displayPosition * 2);
const progress = Math.max(5, Math.min(95, ((maxPosition - displayPosition) / maxPosition) * 100));
progressFill.style.width = progress + '%';
progressPercent.textContent = Math.round(progress) + '%';
}

// 추가 정보 업데이트
updateQueueInfo(data);

} else {
// 알 수 없는 상태 처리
console.warn('알 수 없는 대기열 상태:', data.status, data.sessionStatus);
maintainLastKnownState();

// 재시도
setTimeout(() => refreshQueue(), 3000);
}

// 마지막 업데이트 시간
const lastUpdate = document.getElementById('last-update');
if (lastUpdate) {
lastUpdate.textContent = new Date().toLocaleTimeString('ko-KR', { hour12: false });
}
}

// 마지막 알려진 상태 유지
function maintainLastKnownState() {
const position = document.getElementById('position');
const statusBadge = document.getElementById('status-badge');
const queueTitle = document.getElementById('queue-title');

if (statusBadge) {
statusBadge.textContent = '상태 확인 중';
statusBadge.style.background = 'linear-gradient(45deg, #6c757d, #495057)';
}
if (queueTitle) queueTitle.textContent = '상태를 확인하고 있습니다';

if (position && lastKnownPosition) {
position.textContent = lastKnownPosition;
}
}

// 대기열 정보 업데이트
function updateQueueInfo(data) {
updateElementIfExists('total-waiting', data.waitingPaymentUsers || '-');
updateElementIfExists('active-payments', data.activePaymentUsers || '-');

if (data.currentSize !== undefined && data.maxSize !== undefined) {
const totalOccupied = data.totalOccupied ||
(data.currentSize + (data.activePaymentUsers || 0));
updateElementIfExists('current-enrollment',
totalOccupied + '/' + data.maxSize + '명');
}
}

// 강의 상태 업데이트
function updateCourseStatus() {
fetch("${pageContext.request.contextPath}/payment/status?courseSeq=" + courseSeq +
"&isQueuePage=false&_t=" + Date.now())
.then(response => response.json())
.then(data => {
console.log('강의 상태 업데이트:', data);

updateElementIfExists('course-current', data.currentSize || '-');
updateElementIfExists('course-max', data.maxSize || '-');
updateElementIfExists('available-spots',
Math.max(0, (data.maxSize || 0) - (data.currentSize || 0) - (data.activePaymentUsers || 0)));
updateElementIfExists('payment-processing', data.activePaymentUsers || 0);

// 세션 상태가 ALLOW로 변경되면 즉시 리다이렉트
if (data.sessionStatus === 'ALLOW') {
console.log('강의 상태 체크에서 ALLOW 감지 - 즉시 이동');
const paymentUrl = "${pageContext.request.contextPath}/payment/form" +
"?courseSeq=" + courseSeq + "&memberSeq=" + memberSeq + "&paymentPrice=" + paymentPrice;
window.location.href = paymentUrl;
}
})
.catch(error => console.error('강의 상태 업데이트 오류:', error));
}

// ✅ 개선된 Heartbeat
function startHeartbeat() {
if (heartbeatInterval) clearInterval(heartbeatInterval);

sendHeartbeat();
heartbeatInterval = setInterval(sendHeartbeat, 30000);
console.log('결제 대기열 Heartbeat 시작');
}

function sendHeartbeat() {
const url = "${pageContext.request.contextPath}/payment/heartbeat?courseSeq=" + courseSeq +
"&isQueuePage=true";

const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 25000);

fetch(url, {
method: 'POST',
headers: {
'Accept': 'application/json',
'Content-Type': 'application/x-www-form-urlencoded'
},
signal: controller.signal
})
.then(response => {
clearTimeout(timeoutId);
if (!response.ok) {
throw new Error(`HTTP ${response.status}: ${response.statusText}`);
}
return response.json();
})
.then(data => {
console.log('Heartbeat 성공:', data.status, data.queueStatus);
heartbeatFailCount = 0;

if (data.queueStatus === 'ALLOW') {
console.log('Heartbeat에서 결제 가능 상태 감지!');
const paymentUrl = "${pageContext.request.contextPath}/payment/form" +
"?courseSeq=" + courseSeq + "&memberSeq=" + memberSeq + "&paymentPrice=" + paymentPrice;
window.location.href = paymentUrl;
}
})
.catch(error => {
clearTimeout(timeoutId);
heartbeatFailCount++;

if (error.name === 'AbortError') {
console.debug(`Heartbeat 타임아웃 (${heartbeatFailCount}/${MAX_HEARTBEAT_FAILS})`);
} else {
console.warn(`Heartbeat 실패 (${heartbeatFailCount}/${MAX_HEARTBEAT_FAILS}):`, error.message);
}

if (heartbeatFailCount >= MAX_HEARTBEAT_FAILS) {
console.error('Heartbeat 연속 실패! 상태 새로고침 시도');
refreshQueue();
heartbeatFailCount = 0;
}
});
}

// 결제 대기열 취소
function cancelPaymentQueue() {
if (confirm('수강 신청을 취소하시겠습니까?')) {
if (autoRefreshInterval) clearInterval(autoRefreshInterval);
if (heartbeatInterval) clearInterval(heartbeatInterval);

const leaveUrl = "${pageContext.request.contextPath}/payment/leave";

fetch(leaveUrl, {
method: 'POST',
headers: {
'Accept': 'application/json',
'Content-Type': 'application/x-www-form-urlencoded'
}
})
.then(response => response.json())
.then(data => {
console.log('대기열 탈퇴 결과:', data);
alert('수강 신청이 취소되었습니다.');
window.location.href = "${pageContext.request.contextPath}/course/view?courseSeq=" + courseSeq;
})
.catch(error => {
console.error('취소 처리 중 오류:', error);
alert('취소 처리 중 오류가 발생했습니다.');
window.location.href = "${pageContext.request.contextPath}/course/view?courseSeq=" + courseSeq;
});
}
}

// 로딩 표시
function showLoading(show) {
const spinner = document.getElementById('spinner');
const button = document.querySelector('.btn-primary');

if (spinner) spinner.style.display = show ? 'inline-block' : 'none';
if (button) button.style.opacity = show ? '0.7' : '1';
}

// 오류 상태 표시
function showErrorState(message) {
const statusBadge = document.getElementById('status-badge');
const queueTitle = document.getElementById('queue-title');
const position = document.getElementById('position');

if (statusBadge) {
statusBadge.textContent = '오류';
statusBadge.style.background = 'linear-gradient(45deg, #dc3545, #721c24)';
}
if (queueTitle) queueTitle.textContent = message;
if (position && !lastKnownPosition) {
position.textContent = '?';
}
}

// 업데이트 표시기
function showUpdateIndicator() {
const indicator = document.getElementById('update-indicator');
if (indicator) {
indicator.classList.add('show');
setTimeout(() => indicator.classList.remove('show'), 2000);
}
}

// 자동 새로고침 - 동적 간격
function startAutoRefresh() {
if (autoRefreshInterval) clearInterval(autoRefreshInterval);

// 순번에 따라 새로고침 간격 조정
let refreshInterval = 15000; // 기본 15초

if (lastKnownPosition && lastKnownPosition > 10) {
refreshInterval = 20000; // 순번이 10 이상이면 20초
} else if (lastKnownPosition && lastKnownPosition <= 3) {
refreshInterval = 10000; // 순번이 3 이하면 10초
}

autoRefreshInterval = setInterval(() => {
refreshQueue();
}, refreshInterval);

console.log(`자동 새로고침 시작 (${refreshInterval/1000}초 간격)`);
}

// 페이지 가시성 변경 처리
document.addEventListener('visibilitychange', function() {
if (document.hidden) {
console.log('페이지 숨김 - 대기열 유지');
// 페이지가 숨겨져도 heartbeat는 계속 유지
} else {
console.log('페이지 재활성화 - 즉시 상태 갱신');
heartbeatFailCount = 0; // 실패 카운트 리셋
refreshQueue();
if (!autoRefreshInterval) startAutoRefresh();
if (!heartbeatInterval) startHeartbeat();
}
});

// 페이지 이탈 처리
window.addEventListener('beforeunload', function(e) {
console.log('페이지 이탈 감지');

const leaveUrl = "${pageContext.request.contextPath}/payment/leave";

if (navigator.sendBeacon) {
const formData = new FormData();
formData.append('sessionId', '${sessionId}');
navigator.sendBeacon(leaveUrl, formData);
console.log('페이지 이탈 신호 전송');
}
});

// 요소 업데이트 헬퍼 함수
function updateElementIfExists(elementId, value) {
try {
const element = document.getElementById(elementId);
if (element) {
const newValue = typeof value === 'number' ? value.toLocaleString() : value;
if (element.textContent !== newValue) {
element.textContent = newValue;
}
}
} catch (error) {
console.warn('요소 업데이트 실패:', elementId, error);
}
}

// 전역 함수로 노출
window.refreshQueue = refreshQueue;
window.cancelPaymentQueue = cancelPaymentQueue;

console.log('결제 대기열 개선 스크립트 로드 완료');
</script>
</body>