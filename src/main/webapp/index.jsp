<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="jess.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <jsp:useBean id="engine" class="jess.Rete" scope="request"/>
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css">
<title>Welcome to tekmarkt</title>
</head>
<body>
<div class="container-fluid">
		<div class="row">
			<div class="col-md-push-2 col-md-8">
				<h1>Welcome to TekMart.com</h1>

				<p>To get started, please enter your customer id: </p>		
			</div>
			<div class="col-md-push-2 col-md-5">
			<form action="${pageContext.request.contextPath}/Order/catalog" method="post">
				<div class="form-group">
					<label for="email">Customer id: </label>
					<input id="email" class="form-control" name="customerId">
				</div>
				<button type="submit" class="btn btn-default">Log in</button>
			</form>
			</div>
		</div>
	</div>
	
<script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/js/bootstrap.min.js"></script>	
</body>
</html>