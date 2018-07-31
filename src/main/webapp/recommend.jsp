<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="jess.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<jsp:useBean id="queryResult" type="java.util.Iterator" scope="request" />
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css">
<title>Our recommendations</title>
</head>
<body>
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-8 col-md-push-2">
				<h1 style="font-style: italic;">Your recommendations</h1>
				<p>You may also wish to buy the following items:</p>
				<form action="${pageContext.request.contextPath}/Order/purchase" method="post">
				<table class="table table-striped">
					<tr>
						<th>Name</th>

						<th>Catalog #</th>

						<th>Because you bought...</th>

						<th>Price</th>


						<th>Purchase?</th>
					</tr>
					<%
						while (queryResult.hasNext()) {
							Token t = (Token) queryResult.next();
							Fact fact1 = t.fact(1);
							Fact fact2 = t.fact(2);

							String partNum = fact2.getSlotValue("part-number").stringValue(
									null);
					%>
					<tr>
						<td><%=fact2.getSlotValue("name").stringValue(null)%></td>

						<td><%=partNum%></td>

						<td>
							<%
								ValueVector vv = fact1.getSlotValue("because").listValue(null);
									for (int i = 0; i < vv.size(); i++) {
							%> <%=vv.get(i).stringValue(null)%> <%
 	}
 %>
						</td>
						<td><%=fact2.getSlotValue("price").floatValue(null) %></td>
						<td><input type="checkbox" name="items" value=<%='"' + partNum +'"'%>/></td>
					</tr>
					<%
						}
					%>
				</table>
				<button type="submit" class="btn btn-primary">Purchase</button>
				</form>
			</div>
		</div>
	</div>

	<script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
	<script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>
</body>
</html>