<%@page import="java.util.Iterator"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="jess.*"%>

<!DOCTYPE html >
<html>
<jsp:useBean id="queryResult" type="java.util.Iterator" scope="request" />
<head>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/bootstrap.css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Thanks for shopping!</title>
</head>
<body>
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-8 col-md-push-2">
				<div class="well-sm well">
					<h3 style="font-style: italic; color: firebrick;">Your final
						order:</h3>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-md-8 col-md-push-2">
				<table class="table table-striped">

					<tr>
						<th>Name</th>
						<th>Catalog #</th>
						<th>Price</th>
					</tr>
					<%
						double total = 0;
						while (queryResult.hasNext()) {
							Token t = (Token) queryResult.next();
							Fact fact = t.fact(2);
							double price = fact.getSlotValue("price").floatValue(null);
							total += price;
					%>

					<tr>
						<td><%=fact.getSlotValue("name").stringValue(null)%></td>
						<td><%=fact.getSlotValue("part-number").stringValue(null)%></td>
						<td><%=price%></td>
					</tr>

					<%
						}
					%>
				</table>
				<div style="font-style: italic; color: firebrick;"
					class="well well-sm">
					The grand total:
					<%=total%></div>
				<form action="${pageContext.request.contextPath}/" method="get">
					<button type="submit" class="btn btn-primary">Finish order</button>
				</form>
			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
	<script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>

</body>
</html>