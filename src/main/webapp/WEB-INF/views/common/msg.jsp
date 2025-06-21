<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<script>
    alert("${msg}");
    location.replace("${pageContext.request.contextPath}${loc}");
</script>
</body>
</html>