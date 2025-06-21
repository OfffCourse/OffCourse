<%--
  Created by IntelliJ IDEA.
  User: heebu
  Date: 2025-06-20
  Time: 오후 4:51
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script>
    // 알림 연결 시작
    const eventSource = new EventSource("/notifications/subscribe");

    // 알림 수신 시 동작
    eventSource.addEventListener("notification", function (event) {
        const data = JSON.parse(event.data);
        console.log("🔔 알림 수신:", data);

        // 예시: 알림 UI로 출력
        const notificationArea = document.getElementById("notification-area");
        const msg = document.createElement("div");
        msg.innerHTML = `<a href="${data.msgReplaceLocation}">${data.msgContent}</a>`;
        notificationArea.prepend(msg);
    });

    // 오류 발생 시 (예: 서버 끊김)
    eventSource.onerror = function (err) {
        console.warn("⚠️ SSE 연결 끊김 또는 오류 발생:", err);
        // 자동 재연결을 브라우저가 시도함
    };

    const eventSource = new EventSource("/offcourse/notifications/subscribe");

    eventSource.onmessage = function(e) {
        const data = JSON.parse(e.data);
        alert(data.msgContent); // 사용자에게 알림
    };

    $.ajax({
        url: "/notification/read-select",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify([101, 102, 103]),
        success: function(response) {
            alert(response); // "알림이 정상적으로 읽음 처리되었습니다."
        },
        error: function(xhr) {
            alert("읽음 처리 중 오류 발생: " + xhr.responseText);
        }
    });
</script>

<!-- 알림 표시 영역 -->
<div id="notification-area"></div>