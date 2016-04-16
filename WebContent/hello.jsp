<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="jess.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <jsp:useBean id="engine" class="jess.Rete" scope="request"/>
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css">
<title>Hello Jess!</title>
</head>
<body>
	<h1><%
		engine.addOutputRouter("page", out);
		engine.executeCommand("(printout page \" Hello, world from Jess! \"" +
							"crlf )\")");
	%></h1>


<script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>	
</body>
</html>