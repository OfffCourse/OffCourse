<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- 로딩 오버레이 -->
<div id="loadingOverlay" style="
     display: none; position: fixed; top: 0; left: 0;
     width: 100%; height: 100%; background: rgba(255,255,255,0.7);
     z-index: 9999; justify-content: center; align-items: center;">
  <div class="spinner-border text-primary" role="status">
    <span class="sr-only">Loading...</span>
  </div>
</div>

<!-- 시간 경고 - footer 위치로 변경 -->
<div id="timeWarning" class="alert alert-warning" style="
     display: none; position: fixed; bottom: 20px; left: 50%;
     transform: translateX(-50%); z-index: 1000; min-width: 300px;
     text-align: center;">
  <strong>⏰ 결제 시간 제한</strong><br>
  <span id="timeRemaining">10:00</span> 후 자동으로 페이지 이동됩니다.<br>
  여유 인원이 있으면 → 강의 목록으로 이동<br>
  정원이 초과되면 → 대기열로 이동
</div>

<!-- 인원 마감 경고 -->
<div id="capacityWarning" class="alert alert-danger" style="display: none;">
  <strong>⚠️ 수강 인원 마감</strong><br>
  수강 인원이 마감되어 결제를 진행할 수 없습니다.
</div>

<!-- PortOne 스크립트를 먼저 로드 -->
<script src="https://cdn.iamport.kr/v1/iamport.js"></script>

<div class="container mt-4">
  <!-- 단계별 진행 표시 -->
  <ul class="payment-steps d-flex list-unstyled mb-4">
    <li class="flex-fill text-center text-muted">1. 정보 확인</li>
    <li class="flex-fill text-center font-weight-bold">2. 결제 진행</li>
    <li class="flex-fill text-center text-muted">3. 완료</li>
  </ul>

  <!-- 플래시 메시지 -->
  <c:if test="${not empty msg}">
    <div class="alert alert-info">${msg}</div>
  </c:if>

  <!-- 🙋 회원 정보 -->
  <div class="card mb-4">
    <div class="card-header bg-secondary text-white">
      <i class="fas fa-user"></i> 회원 정보
    </div>
    <div class="card-body">
      <p><strong>이름:</strong> ${loginMember.memberName}</p>
      <p><strong>이메일:</strong> ${loginMember.memberEmail}</p>
      <p><strong>연락처:</strong> ${loginMember.memberPhone}</p>
    </div>
  </div>

  <!-- 결제 정보 요약 -->
  <div class="card mb-4">
    <div class="card-header text-white bg-secondary d-flex justify-content-between align-items-center">
      <span>결제 정보 확인</span>
      <span id="capacityInfo" class="text-muted">
        현재 접속 인원: <span id="activePaymentUsers">-</span>명
      </span>
    </div>
    <div class="card-body">
      <p><strong>강의명:</strong> ${course.courseName}</p>
      <p><strong>기간:</strong>
        <fmt:formatDate value="${course.courseStartDate}" pattern="yyyy-MM-dd"/> ~
        <fmt:formatDate value="${course.courseEndDate}" pattern="yyyy-MM-dd"/>
      </p>
      <p><strong>정원:</strong>
        <span id="capacityStatus" class="badge badge-info">${course.courseCurrentSize}/${course.courseSize}명</span>
      </p>
      <hr/>
      <p>
        <del><fmt:formatNumber value="${course.coursePrice}" pattern="#,##0"/>원</del>
        → <strong><fmt:formatNumber value="${paymentPrice}" pattern="#,##0"/>원</strong>
      </p>

      <!-- 결제 주의사항 -->
      <div class="alert alert-info mt-3">
        <h6><i class="fas fa-info-circle"></i> 결제 주의사항</h6>
        <ul class="mb-0">
          <li>결제 시간 제한: <strong>10분</strong></li>
          <li>제한 시간 초과 시:
            <ul>
              <li>여유 인원이 있으면 → 강의 목록으로 이동</li>
              <li>정원이 초과되면 → 대기열로 이동</li>
            </ul>
          </li>
          <li>다른 사용자의 결제로 인원이 마감될 수 있습니다</li>
          <li>결제 완료 전까지는 수강 등록이 확정되지 않습니다</li>
        </ul>
      </div>
    </div>
  </div>

  <!-- 결제 버튼 영역 -->
  <div class="form-group text-center">
    <p class="mb-2">
      <img src="${path}/resources/images/kakaopay.png" alt="카카오페이" style="height:40px;">
    </p>
    <p class="text-muted" style="font-size:0.9em;">카카오페이 제휴사</p>

    <button type="button" id="paymentButton" class="btn btn-warning btn-block"
            style="background-color:#FEEB00; border:none; color:#3C1E1E; font-weight:bold;">
      <img src="${path}/resources/images/kakaopay.png" alt="카카오페이"
           style="height:24px; vertical-align:middle; margin-right:8px;">
      카카오페이로 결제하기
    </button>

    <button type="button" class="btn btn-outline-secondary btn-block mt-2" onclick="cancelPayment()">
      결제 취소
    </button>
  </div>
</div>
<style>
  /* 결제 페이지 스타일 */
  .payment-steps {
    margin-top: 200px;
    background: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 25px;
  }

  .payment-steps li + li::before {
    content: "›";
    margin: 0 10px;
    color: #ccc;
  }

  /* 시간 경고창 - footer 위치 */
  #timeWarning {
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    border-radius: 8px;
    font-weight: 500;
  }

  /* 인원 마감 경고 */
  #capacityWarning {
    margin: 20px 0;
    border-radius: 8px;
    border-left: 4px solid #dc3545;
  }

  /* 인원 상태 배지 */
  .badge {
    padding: 5px 10px;
    font-size: 0.9rem;
  }

  @media (max-width: 768px) {
    #timeWarning {
      position: fixed !important;
      bottom: 10px !important;
      left: 10px !important;
      right: 10px !important;
      transform: none !important;
      min-width: auto !important;
      width: auto !important;
    }

    .payment-steps {
      font-size: 0.9rem;
    }

    .payment-steps li {
      padding: 0 5px;
    }
  }

  /* 로딩 스피너 */
  #loadingOverlay .spinner-border {
    width: 3rem;
    height: 3rem;
  }

  /* 버튼 비활성화 */
  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>

<script>
  // PortOne 초기화 및 전역 변수
  var IMP = window.IMP;
  IMP.init("${impCode}");

  // 전역 변수
  const courseSeq = "${courseSeq}";
  const memberSeq = "${memberSeq}";
  const paymentPrice = "${paymentPrice}";
  const courseSize = ${course.courseSize}; // 최대 인원

  let paymentStartTime = Date.now();
  let paymentTimeLimit = 10 * 60 * 1000; // 10분
  let heartbeatInterval, timeUpdateInterval;
  let heartbeatFailCount = 0;
  let isPageActive = true; // 페이지 활성 상태 추적
  let isPaymentInProgress = false; // 결제 진행 중 플래그
  const MAX_HEARTBEAT_FAILS = 3;

  // 현재 인원 정보 저장
  let currentCapacityInfo = {
    currentSize: ${course.courseCurrentSize},
    maxSize: ${course.courseSize},
    hasCapacity: true,
    activePaymentUsers: 0
  };

  // DOM이 로드된 후 실행
  document.addEventListener('DOMContentLoaded', function() {
    console.log('결제 페이지 초기화');

    // 결제 버튼 이벤트 리스너 추가
    document.getElementById('paymentButton').addEventListener('click', requestPay);

    // 페이지 가시성 이벤트 리스너
    document.addEventListener('visibilitychange', handleVisibilityChange);

    // 페이지 이탈 이벤트 리스너 (개선됨)
    window.addEventListener('beforeunload', handlePageUnload);
    window.addEventListener('pagehide', handlePageUnload);

    // 초기화
    startPaymentHeartbeat();
    startTimeDisplay();

    console.log('결제 페이지 초기화 완료');
  });

  // 로딩 표시/숨김
  function showLoading() {
    document.getElementById('loadingOverlay').style.display = 'flex';
  }

  function hideLoading() {
    document.getElementById('loadingOverlay').style.display = 'none';
  }

  // 결제 하트비트 시작 (개선됨)
  function startPaymentHeartbeat() {
    if (heartbeatInterval) clearInterval(heartbeatInterval);

    // 즉시 실행
    sendPaymentHeartbeat();

    // 10초마다 실행
    heartbeatInterval = setInterval(() => {
      if (isPageActive) {
        sendPaymentHeartbeat();
      }
    }, 10000);

    console.log('결제 하트비트 시작');
  }

  // 결제 하트비트 전송 (개선됨)
  function sendPaymentHeartbeat() {
    // 결제 진행 중이면 하트비트 중단
    if (isPaymentInProgress) {
      console.log('결제 진행 중으로 하트비트 스킵');
      return;
    }

    // AbortController를 사용한 타임아웃 처리
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10초 타임아웃

    fetch("${path}/payment/heartbeat", {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'courseSeq=' + encodeURIComponent(courseSeq),
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
              console.log('결제 하트비트 성공:', data);
              heartbeatFailCount = 0;

              // 인원 정보 업데이트
              if (data.currentSize !== undefined && data.maxSize !== undefined) {
                currentCapacityInfo.currentSize = data.currentSize;
                currentCapacityInfo.maxSize = data.maxSize;
                currentCapacityInfo.hasCapacity = data.canProceed;
                currentCapacityInfo.activePaymentUsers = data.activePaymentUsers || 0;
                updateCapacityInfo(data.currentSize, data.maxSize, data.activePaymentUsers || 0);
              }

              // 상태별 처리
              if (data.status === 'redirect_to_queue') {
                console.log('인원 마감으로 대기열 이동:', data.message);
                showCapacityWarning();
                setTimeout(() => {
                  checkQueueAndRedirect('CAPACITY_FULL');
                }, 3000);

              } else if (data.status === 'error') {
                console.warn('결제 상태 체크 오류:', data.message);
                heartbeatFailCount++;

              } else if (data.status === 'alive') {
                console.log('현재 인원 상태:', data.currentSize + '/' + data.maxSize,
                        '여유:', data.canProceed ? '있음' : '없음');
              }
            })
            .catch(error => {
              clearTimeout(timeoutId);
              heartbeatFailCount++;

              // AbortError는 의도적인 취소이므로 로그 레벨을 낮춤
              if (error.name === 'AbortError') {
                console.debug(`결제 하트비트 타임아웃 (${heartbeatFailCount}/${MAX_HEARTBEAT_FAILS})`);
              } else {
                console.warn(`결제 하트비트 실패 (${heartbeatFailCount}/${MAX_HEARTBEAT_FAILS}):`, error.message);
              }

              if (heartbeatFailCount >= MAX_HEARTBEAT_FAILS) {
                console.error('결제 하트비트 연속 실패! 대기열로 이동');
                checkQueueAndRedirect('HEARTBEAT_FAILED');
              }
            });
  }

  // 페이지 가시성 변경 처리 (개선됨)
  function handleVisibilityChange() {
    isPageActive = !document.hidden;

    console.log('페이지 가시성 변경:', isPageActive ? '활성' : '비활성');

    if (isPageActive) {
      // 페이지가 다시 활성화되면 즉시 하트비트 전송
      console.log('페이지 재활성화 - 즉시 하트비트 전송');
      sendPaymentHeartbeat();

      // 타이머 재시작
      if (!heartbeatInterval) {
        startPaymentHeartbeat();
      }
      if (!timeUpdateInterval) {
        startTimeDisplay();
      }
    } else {
      // 페이지가 비활성화되어도 하트비트는 계속 (백그라운드에서)
      console.log('페이지 비활성화 - 하트비트 유지');
    }
  }

  // 페이지 이탈 처리 (개선됨)
  function handlePageUnload(event) {
    console.log('페이지 이탈 감지:', event.type);

    // 결제 진행 중이면 이탈 처리 하지 않음
    if (isPaymentInProgress) {
      console.log('결제 진행 중으로 이탈 처리 스킵');
      return;
    }

    // 타이머 정리
    stopAllTimers();

    // 동기 요청으로 이탈 신호 전송 (sendBeacon 대신)
    try {
      // sendBeacon이 지원되면 사용
      if (navigator.sendBeacon) {
        const formData = new FormData();
        navigator.sendBeacon("${path}/payment/leave", formData);
        console.log('페이지 이탈 신호 전송 (sendBeacon)');
      } else {
        // sendBeacon이 지원되지 않으면 동기 XMLHttpRequest 사용
        const xhr = new XMLHttpRequest();
        xhr.open('POST', "${path}/payment/leave", false); // 동기 요청
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.send('');
        console.log('페이지 이탈 신호 전송 (동기 XHR)');
      }
    } catch (error) {
      console.warn('페이지 이탈 신호 전송 실패:', error);
    }
  }

  // 시간 표시 시작
  function startTimeDisplay() {
    if (timeUpdateInterval) {
      clearInterval(timeUpdateInterval);
    }

    updateTimeDisplay();
    timeUpdateInterval = setInterval(updateTimeDisplay, 1000);
  }

  // 시간 표시 업데이트
  function updateTimeDisplay() {
    const elapsed = Date.now() - paymentStartTime;
    const remaining = paymentTimeLimit - elapsed;

    if (remaining <= 0) {
      console.log('결제 시간 초과!');
      stopAllTimers();

      if (currentCapacityInfo.currentSize < currentCapacityInfo.maxSize) {
        console.log('여유 인원 있음 - 강의 목록으로 이동');
        redirectToCourseList('TIME_EXPIRED');
      } else {
        console.log('인원 마감 - 대기열 확인');
        checkQueueAndRedirect('TIME_EXPIRED');
      }
      return;
    }

    const minutes = Math.floor(remaining / 60000);
    const seconds = Math.floor((remaining % 60000) / 1000);
    const timeText = minutes + ':' + (seconds < 10 ? '0' : '') + seconds;

    const timeElement = document.getElementById('timeRemaining');
    if (timeElement) {
      timeElement.textContent = timeText;
    }

    // 시간 경고 표시
    if (remaining <= 60000) {
      showTimeWarning('danger');
    } else if (remaining <= 180000) {
      showTimeWarning('warning');
    } else if (remaining <= 420000) {
      showTimeWarning('primary');
    }
  }

  // 시간 경고 표시
  function showTimeWarning(level) {
    const warning = document.getElementById('timeWarning');
    if (warning) {
      warning.className = 'alert alert-' + level;
      warning.style.display = 'block';
    }
  }

  // 인원 정보 업데이트
  function updateCapacityInfo(currentSize, maxSize, activePaymentUsers) {
    const capacityInfo = document.getElementById('capacityInfo');
    const capacityStatus = document.getElementById('capacityStatus');
    const activePaymentUsersElement = document.getElementById('activePaymentUsers');

    if (capacityInfo && currentSize !== undefined && maxSize !== undefined) {
      // 기본 인원 정보 업데이트
      const currentAccessUsersElement = document.getElementById('currentAccessUsers');
      if (currentAccessUsersElement) {
        currentAccessUsersElement.textContent = currentSize;
      }

      // 결제 진행 중 인원 업데이트
      if (activePaymentUsersElement && activePaymentUsers !== undefined) {
        activePaymentUsersElement.textContent = activePaymentUsers;
      }

      // 인원 상태에 따른 스타일 적용
      if (currentSize >= maxSize) {
        capacityInfo.className = 'text-danger font-weight-bold';
        if (capacityStatus) capacityStatus.className = 'badge badge-danger';
      } else if (currentSize >= maxSize - 2) {
        capacityInfo.className = 'text-warning font-weight-bold';
        if (capacityStatus) capacityStatus.className = 'badge badge-warning';
      } else if (currentSize >= maxSize - 5) {
        capacityInfo.className = 'text-info font-weight-bold';
        if (capacityStatus) capacityStatus.className = 'badge badge-info';
      } else {
        capacityInfo.className = 'text-muted';
        if (capacityStatus) capacityStatus.className = 'badge badge-success';
      }

      console.log('인원 정보 업데이트:', currentSize + '/' + maxSize +
              ' (여유: ' + (maxSize - currentSize) + '명, 결제 진행 중: ' + activePaymentUsers + '명)');
    }
  }

  // 인원 마감 경고 표시
  function showCapacityWarning() {
    const warning = document.getElementById('capacityWarning');
    const capacityInfo = document.getElementById('capacityInfo');

    let currentInfo = '';
    if (capacityInfo) {
      currentInfo = capacityInfo.textContent;
    }

    if (warning) {
      warning.innerHTML =
              '<strong>⚠️ 수강 인원 마감</strong><br>' +
              '수강 인원이 마감되어 결제를 진행할 수 없습니다.<br>' +
              '<small class="text-muted">' + currentInfo + '</small><br>' +
              '<small>잠시 후 자동 이동합니다...</small>';

      warning.style.display = 'block';
    }
  }

  // 대기열 존재 여부 확인 후 리다이렉트
  function checkQueueAndRedirect(reason) {
    fetch("${path}/queue/status?courseSeq=" + courseSeq)
            .then(response => response.json())
            .then(data => {
              console.log('대기열 상태:', data);

              if (data.position && data.position > 0) {
                redirectToQueue(reason);
              } else {
                redirectToCourseList(reason);
              }
            })
            .catch(error => {
              console.error('대기열 확인 실패:', error);
              redirectToCourseList(reason);
            });
  }

  // 대기열로 리다이렉트
  function redirectToQueue(reason) {
    stopAllTimers();

    // Redis 상태 변경: 결제 진행 상태에서 대기열로 이동
    fetch("${path}/payment/moveToQueue", {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'courseSeq=' + encodeURIComponent(courseSeq) + '&reason=' + encodeURIComponent(reason)
    })
            .then(response => response.json())
            .then(data => {
              console.log('대기열 이동 처리 결과:', data);

              // 성공 여부에 관계없이 대기열 페이지로 이동
              const queueUrl = "${path}/queue/insert?reason=" + encodeURIComponent(reason) +
                      "&courseSeq=" + courseSeq;
              location.replace(queueUrl);
            })
            .catch(error => {
              console.error('대기열 이동 처리 실패:', error);

              // 실패해도 대기열 페이지로 이동
              const queueUrl = "${path}/queue/insert?reason=" + encodeURIComponent(reason) +
                      "&courseSeq=" + courseSeq;
              location.replace(queueUrl);
            });
  }

  // 강의 목록으로 리다이렉트
  function redirectToCourseList(reason) {
    stopAllTimers();

    // 결제 세션 정리
    fetch("${path}/payment/leave", { method: 'POST' })
            .then(() => {
              alert('결제 시간이 초과되었습니다. 강의 목록으로 이동합니다.');
              location.replace("${path}/course/view?courseSeq=" + courseSeq);
            })
            .catch(() => {
              alert('결제 시간이 초과되었습니다. 강의 목록으로 이동합니다.');
              location.replace("${path}/course/view?courseSeq=" + courseSeq);
            });
  }

  // 모든 타이머 중지
  function stopAllTimers() {
    console.log('모든 타이머 중지');

    if (heartbeatInterval) {
      clearInterval(heartbeatInterval);
      heartbeatInterval = null;
    }
    if (timeUpdateInterval) {
      clearInterval(timeUpdateInterval);
      timeUpdateInterval = null;
    }
  }

  // 결제 요청 (최종 인원 체크)
  function requestPay() {
    // 이미 결제 진행 중이면 중복 방지
    if (isPaymentInProgress) {
      console.log('이미 결제 진행 중');
      return;
    }

    fetch("${path}/payment/status?courseSeq=" + courseSeq)
            .then(response => response.json())
            .then(data => {
              console.log('결제 전 상태 체크:', data);

              // 최신 인원 정보 업데이트
              if (data.currentSize !== undefined && data.maxSize !== undefined) {
                currentCapacityInfo.currentSize = data.currentSize;
                currentCapacityInfo.maxSize = data.maxSize;
                updateCapacityInfo(data.currentSize, data.maxSize, data.activePaymentUsers || 0);
              }

              // 결제 진행 가능 여부 확인
              if (data.error) {
                alert('상태 확인 중 오류가 발생했습니다: ' + data.error);
                return;
              }

              if (!data.canProceed) {
                alert('수강 인원이 마감되어 결제를 진행할 수 없습니다.\n현재 인원: ' +
                        data.currentSize + '/' + data.maxSize + '명');
                checkQueueAndRedirect('CAPACITY_FULL');
                return;
              }

              // 인원에 여유가 있으면 결제 진행
              proceedWithPayment();
            })
            .catch(error => {
              console.error('결제 전 상태 확인 오류:', error);
              alert('결제 진행 중 오류가 발생했습니다.');
            });
  }

  // 실제 결제 진행
  function proceedWithPayment() {
    console.log('결제 진행 시작');

    isPaymentInProgress = true; // 결제 진행 플래그 설정
    showLoading();

    // 하트비트 중지 (결제 진행 중에는 불필요)
    if (heartbeatInterval) {
      clearInterval(heartbeatInterval);
      heartbeatInterval = null;
    }

    IMP.request_pay({
      pg: "kakaopay.TC0ONETIME",
      merchant_uid: "${orderId}",
      name: "강의 결제",
      amount: ${paymentPrice},
      buyer_email: "test@example.com",
      buyer_name: "홍길동",
      buyer_tel: "010-1234-5678"
    }, function (rsp) {
      hideLoading();
      isPaymentInProgress = false; // 결제 완료

      if (rsp.success) {
        console.log('결제 성공:', rsp);

        // 결제 성공 - 서버로 전송
        const form = document.createElement("form");
        form.method = "post";
        form.action = "${path}/payment/process";

        const fields = {
          impUid: rsp.imp_uid,
          orderId: rsp.merchant_uid,
          courseSeq: courseSeq,
          memberSeq: memberSeq,
          paymentPrice: paymentPrice
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
        stopAllTimers();

      } else {
        console.error('결제 실패:', rsp);
        alert("결제에 실패했습니다: " + rsp.error_msg);

        // 결제 실패 시 하트비트 재시작
        startPaymentHeartbeat();
      }
    });
  }

  // 결제 취소
  function cancelPayment() {
    if (confirm('결제를 취소하고 강의 페이지로 돌아가시겠습니까?')) {
      stopAllTimers();

      fetch("${path}/payment/leave", { method: 'POST' })
              .then(() => location.replace("${path}/course/view?courseSeq=" + courseSeq))
              .catch(() => location.replace("${path}/course/view?courseSeq=" + courseSeq));
    }
  }

  // 전역 함수로 노출 (HTML에서 호출 가능)
  window.cancelPayment = cancelPayment;

  console.log('결제 페이지 스크립트 로드 완료');
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>