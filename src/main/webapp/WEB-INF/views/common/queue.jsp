<%--
  Created by IntelliJ IDEA.
  User: poj23
  Date: 25. 6. 23.
  Time: 오후 2:28
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<head>
  <title>대기열 시스템 - Off Course</title>
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
      <div class="status-badge" id="status-badge">대기 중</div>
      <h1 class="queue-title" id="queue-title">대기열에서 순서를 기다리고 있습니다</h1>
      <p class="queue-subtitle" id="queue-subtitle">잠시만 기다려주세요. 곧 서비스를 이용하실 수 있습니다.</p>
    </div>

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
      <button class="btn btn-secondary" onclick="window.open('https://open.kakao.com/o/scWgCCzh','OffCourse 고객센터','_blank')">
        도움말
      </button>
    </div>

    <div class="footer-info">
      세션 ID: <strong class="highlight" id="session-id">${sessionId}</strong> |
      연결 시간: <strong class="highlight" id="connect-time"></strong>
    </div>
  </div>

  <div class="sidebar">
    <div class="info-card">
      <div class="card-title">📊 실시간 대기열 정보</div>
      <div class="info-item">
        <span class="info-label">예상 대기시간</span>
        <span class="info-value" id="estimated-time">계산 중</span>
      </div>
      <div class="info-item">
        <span class="info-label">전체 대기자</span>
        <span class="info-value" id="total-waiting">-</span>
      </div>
      <div class="info-item">
        <span class="info-label">현재 이용자</span>
        <span class="info-value" id="active-users">-</span>
      </div>
      <div class="info-item">
        <span class="info-label">마지막 업데이트</span>
        <span class="info-value" id="last-update">-</span>
      </div>
    </div>

    <div class="info-card tips-card">
      <div class="card-title">📋 이용 안내</div>
      <ul class="tips-list">
        <li>이 페이지를 닫거나 새로고침하지 마세요</li>
        <li>대기 중에는 다른 탭을 사용하셔도 됩니다</li>
        <li>순서가 되면 자동으로 메인 페이지로 이동합니다</li>
        <li>문제 발생 시 새로고침 버튼을 눌러주세요</li>
        <li>대기시간은 서버 상황에 따라 변동될 수 있습니다</li>
      </ul>
    </div>

    <div class="info-card">
      <div class="card-title">⚙️ 시스템 현황</div>
      <div class="system-stats">
        <div class="stat-item">
          <span class="stat-value" id="system-waiting">-</span>
          <span class="stat-label">전체 대기</span>
        </div>
        <div class="stat-item">
          <span class="stat-value" id="system-active">-</span>
          <span class="stat-label">현재 이용</span>
        </div>
        <div class="stat-item">
          <span class="stat-value" id="max-capacity">-</span>
          <span class="stat-label">최대 수용</span>
        </div>
        <div class="stat-item">
          <span class="stat-value" id="available-slots">-</span>
          <span class="stat-label">여유 자리</span>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
  let isRefreshing = false;
  let autoRefreshInterval;
  let heartbeatInterval; // Heartbeat용 인터벌 추가
  let heartbeatFailCount = 0; // 연속 실패 카운트
  const MAX_HEARTBEAT_FAILS = 3; // 최대 실패 허용 횟수


  (function() {
    // URL에서 세션 관련 파라미터 제거
    const cleanUrl = () => {
      const url = new URL(window.location);

      // sessionId 파라미터 제거
      url.searchParams.delete('sessionId');
      url.searchParams.delete('jsessionid');

      // URL에 ;jsessionid= 패턴이 있으면 제거
      let cleanPath = url.pathname.replace(/;jsessionid=[^?\/]*/g, '');

      // URL이 변경되었으면 히스토리 교체
      if (url.pathname !== cleanPath || url.searchParams.has('sessionId') || url.searchParams.has('jsessionid')) {
        const newUrl = cleanPath + (url.search ? url.search : '');
        window.history.replaceState({}, document.title, newUrl);
      }
    };

    // 페이지 로드 시 실행
    cleanUrl();

    // 모든 링크에 대해 세션 파라미터 제거
    document.addEventListener('click', function(e) {
      const link = e.target.closest('a');
      if (link && link.href) {
        const url = new URL(link.href);
        if (url.searchParams.has('sessionId') || url.searchParams.has('jsessionid')) {
          e.preventDefault();
          url.searchParams.delete('sessionId');
          url.searchParams.delete('jsessionid');
          window.location.href = url.toString();
        }
      }
    });
  })();

  // 페이지 로드 시 초기화
  $(document).ready(function() {
    console.log('대기열 페이지 초기화 시작');

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

    console.log('대기열 페이지 초기화 완료');
  });

  // Heartbeat 시작
  function startHeartbeat() {
    if (heartbeatInterval) {
      clearInterval(heartbeatInterval);
    }

    // 30초마다 heartbeat 전송
    heartbeatInterval = setInterval(sendHeartbeat, 30000);
    console.log('Heartbeat 시작 (30초 간격)');
  }

  // Heartbeat 중지
  function stopHeartbeat() {
    if (heartbeatInterval) {
      clearInterval(heartbeatInterval);
      heartbeatInterval = null;
      console.log('Heartbeat 중지');
    }
  }

  // Heartbeat 전송
  function sendHeartbeat() {
    fetch("${pageContext.request.contextPath}/queue/heartbeat", {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      signal: AbortSignal.timeout(30000)
    })
            .then(response => response.json())
            .then(queueData => {
              console.log('Heartbeat 성공:', queueData.status);
              heartbeatFailCount = 0; // 성공 시 실패 카운트 리셋

              // 대기열 상태가 변경되었으면 즉시 새로고침
              if (queueData.queueStatus === 'ALLOW') {
                console.log('서비스 이용 가능! 메인 페이지로 이동');
                window.location.href = '${pageContext.request.contextPath}/';
              } else if (queueData.queueStatus === 'WAITING') {
                // 순번 변동이 있으면 화면 업데이트
                refreshQueue();
              }
            })
            .catch(error => {
              heartbeatFailCount++;
              console.warn(`Heartbeat 실패 (${heartbeatFailCount}/${MAX_HEARTBEAT_FAILS}):`, error.message);

              if (heartbeatFailCount >= MAX_HEARTBEAT_FAILS) {
                console.error('Heartbeat 연속 실패! 상태 새로고침 시도');
                refreshQueue();
                heartbeatFailCount = 0; // 리셋
              }
            });
  }

  // 페이지 언로드 시 정리
  window.addEventListener('unload', function() {
    stopAutoRefresh();
  });
  // 현재 시간 업데이트
  function updateCurrentTime() {
    const now = new Date();
    document.getElementById('current-time').textContent =
            now.toLocaleTimeString('ko-KR', { hour12: false });
  }

  // 대기열 상태 새로고침
  function refreshQueue() {
    if (isRefreshing) return;

    isRefreshing = true;
    const spinner = document.getElementById('spinner');
    const btn = document.querySelector('.btn-primary');

    spinner.style.display = 'inline-block';
    btn.style.opacity = '0.7';

    fetch("${pageContext.request.contextPath}/queue/status", {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    })
            .then(async response => {
              if (!response.ok) {
                if (response.status === 403) {
                  const errorData = await response.json();
                  updateQueueDisplay(errorData);
                }
                throw new Error('응답 오류');
              }
              return response.json();
            })
            .then(queueData => {
              console.log('대기열 상태:', queueData);
              updateQueueDisplay(queueData);
              showUpdateIndicator();
            })
            .catch(error => {
              console.error('상태 확인 오류:', error);
            })
            .finally(() => {
              spinner.style.display = 'none';
              btn.style.opacity = '1';
              isRefreshing = false;
            });

    // 시스템 상태도 함께 업데이트
    updateSystemStatus();
  }

  // 시스템 전체 상태 업데이트
  function updateSystemStatus() {
    fetch("${pageContext.request.contextPath}/queue/admin/status", {
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    })
            .then(response => response.json())
            .then(systemData => {
              console.log('시스템 상태:', systemData);
              document.getElementById('system-waiting').textContent = systemData.waitingCount || 0;
              document.getElementById('system-active').textContent = systemData.activeCount || 0;
              document.getElementById('max-capacity').textContent = systemData.maxProcessingCount || 0;
              document.getElementById('available-slots').textContent = systemData.availableSlots || 0;
              document.getElementById('total-waiting').textContent = systemData.waitingCount || 0;
              document.getElementById('active-users').textContent = systemData.activeCount || 0;
            })
            .catch(() => {
              console.log('시스템 상태 업데이트 실패');
            });
  }

  // 대기열 표시 업데이트
  function updateQueueDisplay(queueData) {
    const statusBadge = document.getElementById('status-badge');
    const queueTitle = document.getElementById('queue-title');
    const queueSubtitle = document.getElementById('queue-subtitle');
    const position = document.getElementById('position');
    const estimatedTime = document.getElementById('estimated-time');
    const progressFill = document.getElementById('progress-fill');
    const progressPercent = document.getElementById('progress-percent');

    if (queueData.status === 'ALLOW') {
      // 서비스 이용 가능 상태
      statusBadge.textContent = '입장 가능';
      statusBadge.style.background = 'linear-gradient(45deg, #10B981, #065f46)';
      queueTitle.textContent = '서비스 이용이 가능합니다!';
      queueSubtitle.textContent = '메인 페이지로 자동 이동합니다.';

      position.textContent = '0';
      estimatedTime.textContent = '즉시 이용';

      progressFill.style.width = '100%';
      progressPercent.textContent = '100%';

      // 2초 후 메인 페이지로 이동
      setTimeout(() => {
        window.location.href = '${pageContext.request.contextPath}/';
      }, 2000);

    } else if (queueData.status === 'WAITING') {
      // 대기 중 상태
      statusBadge.textContent = '대기 중';
      statusBadge.style.background = 'linear-gradient(45deg, #162D43, #1e3a56)';
      queueTitle.textContent = '대기열에서 순서를 기다리고 있습니다';
      queueSubtitle.textContent = '잠시만 기다려주세요. 곧 서비스를 이용하실 수 있습니다.';

      if (queueData.position) {
        position.textContent = queueData.position;

        // 예상 대기 시간 계산 및 표시
        if (queueData.estimatedWaitTime !== null && queueData.estimatedWaitTime !== undefined) {
          const minutes = Math.ceil(queueData.estimatedWaitTime / 60);
          estimatedTime.textContent = minutes > 0 ? '약 ' + minutes + '분' : '1분 이내';
        } else {
          estimatedTime.textContent = '계산 중';
        }

        // 진행률 계산
        const maxPosition = Math.max(100, queueData.position * 2);
        const progress = Math.max(0, Math.min(100, ((maxPosition - queueData.position) / maxPosition) * 100));
        progressFill.style.width = progress + '%';
        progressPercent.textContent = Math.round(progress) + '%';
      } else {
        position.textContent = '-';
        estimatedTime.textContent = '계산 중';
        progressFill.style.width = '0%';
        progressPercent.textContent = '0%';
      }
    }

    // 마지막 업데이트 시간
    const now = new Date();
    document.getElementById('last-update').textContent = now.toLocaleTimeString('ko-KR', { hour12: false });
  }

  // 업데이트 표시기
  function showUpdateIndicator() {
    const indicator = document.getElementById('update-indicator');
    indicator.classList.add('show');
    setTimeout(() => {
      indicator.classList.remove('show');
    }, 2000);
  }

  // 자동 새로고침 시작/중지
  function startAutoRefresh() {
    if (autoRefreshInterval) {
      clearInterval(autoRefreshInterval);
    }
    autoRefreshInterval = setInterval(refreshQueue, 30000); // 30초마다
  }

  function stopAutoRefresh() {
    if (autoRefreshInterval) {
      clearInterval(autoRefreshInterval);
      autoRefreshInterval = null;
    }
  }

  // 페이지 가시성 변경 처리
  document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
      stopAutoRefresh();
      stopHeartbeat(); // 탭이 숨겨지면 heartbeat 중지
    } else {
      refreshQueue();
      startAutoRefresh();
      startHeartbeat(); // 탭이 다시 보이면 heartbeat 재시작
    }
  });

  // 페이지 이탈 경고 / 브라우저 종료/탭 닫기 감지
  window.addEventListener('beforeunload', function(e) {
    if (navigator.sendBeacon) {
      navigator.sendBeacon("${pageContext.request.contextPath}/queue/leave", "");
      console.log('대기열 탈퇴 요청 전송');
    }else{
      e.preventDefault();
    }
  });

  // 디버그용 함수들
  window.debugQueue = {
    refreshQueue: refreshQueue,
    updateSystemStatus: updateSystemStatus,
    startAutoRefresh: startAutoRefresh,
    stopAutoRefresh: stopAutoRefresh,

    // 관리자 전용 기능들
    adminProcessQueue: function() {
      $.ajax({
        url: '${pageContext.request.contextPath}/queue/admin/process',
        type: 'POST',
        success: function(response) {
          console.log('수동 처리 결과:', response);
          alert(response.message);
          refreshQueue();
        },
        error: function() {
          alert('권한이 없거나 처리 중 오류가 발생했습니다.');
        }
      });
    },

    adminCleanup: function() {
      $.ajax({
        url: '${pageContext.request.contextPath}/queue/admin/cleanup',
        type: 'POST',
        success: function(response) {
          console.log('정리 결과:', response);
          alert(response.message);
          refreshQueue();
        },
        error: function() {
          alert('권한이 없거나 정리 중 오류가 발생했습니다.');
        }
      });
    },

    adminCleanAll: function() {
      $.ajax({
        url: '${pageContext.request.contextPath}/queue/admin/clear',
        type: 'POST',
        success: function(response) {
          console.log('정리 결과:', response);
          refreshQueue();
        },
        error: function() {
          alert('권한이 없거나 정리 중 오류가 발생했습니다.');
        }
      });
    },

    adminRemoveUser: function(sessionId) {
      if (!sessionId) {
        sessionId = prompt('제거할 세션 ID를 입력하세요:');
        if (!sessionId) return;
      }

      if (confirm('사용자 ' + sessionId + '를 강제로 제거하시겠습니까?')) {
        $.ajax({
          url: '${pageContext.request.contextPath}/queue/admin/remove',
          type: 'POST',
          data: { targetSessionId: sessionId },
          success: function(response) {
            console.log('사용자 제거 결과:', response);
            alert(response.message);
            refreshQueue();
          },
          error: function() {
            alert('권한이 없거나 제거 중 오류가 발생했습니다.');
          }
        });
      }
    }
  };
</script>
</body>