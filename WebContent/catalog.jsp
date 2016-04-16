<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="jess.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<jsp:useBean id="queryResult" type="java.util.Iterator" scope="request" />
<head>
<link rel="stylesheet" href="../css/bootstrap.css">
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Ordering for Tekmarkt.com</title>
</head>
<body>
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-7 col-md-push-3">
				<h1>Tekmart.com catalog</h1>
				<p>
					Customer id:
					<%=request.getParameter("customerId")%></p>
				<p>Select the items that you wish to buy from the following list</p>
				<form action="${pageContext.request.contextPath}/Order/recommend"
					method="post">
					<table class="table table-striped">
						<tr>
							<th>Name</th>
							<th>Catalog #</th>
							<th>Price</th>
							<th>Purchase?</th>
						</tr>

						<%
							while (queryResult.hasNext()) {
								Token token = (Token) queryResult.next();
								Fact fact = token.fact(1);
								String partNum = fact.getSlotValue("part-number").stringValue(
										null);
						%>
						<tr>
							<td><%=fact.getSlotValue("name").stringValue(null)%></td>
							<td><%=partNum%></td>
							<td><%=fact.getSlotValue("price").floatValue(null)%></td>
							<td><input type="checkbox" name="items"
								value=<%='"' + partNum + '"'%>></td>
						</tr>
						<%
							}
						%>
					</table>
					<button class="btn btn-primary" type="submit">Check order</button>
				</form>
			</div>
		</div>
	</div>
	<script src="../js/jquery.min.js"></script>
	<script src="../js/bootstrap.min.js"></script>
</body>
</html>