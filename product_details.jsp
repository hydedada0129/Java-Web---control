<%@page import="www.bps.entity.Color"%>
<%@page import="www.bps.entity.SpecialOffer"%>
<%@page import="www.bps.service.ProductService"%>
<%@page import="www.bps.entity.Product"%>
<%@ page pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>產品明細</title>
		<link rel="stylesheet" type="text/css" href="css/vgb.css">
		<style>
			#photoImg{width:300px;vertical-align: top;}
			.listPrice{text-decoration: line-through;}
			.price{font-size: larger;color:blue}
			.productDesc {white-space: pre-wrap;width:80%;margin: auto}
 			.specDiv{display:none}
			.specDivShow{display:inline-block}
		</style>
		<script src="https://code.jquery.com/jquery-3.0.0.js" 
			integrity="sha256-jrPLZ+8vDxt2FnE1zvZXCkCcebI/C8Dt5xyaQBjxQIo=" 
			crossorigin="anonymous"></script>
		<script>
			$(init);			//$(init); is a JavaScript code snippet that typically indicates the initialization of a jQuery script.
			function init(){
// 				$("input[name='color']").on("change", changeOptionData);
				$("select[name='color']").on("change", changeColorOptionData);
				//$("input[name='spec']").on("change", changeSpecOptionData); //因為spec選項尚未用ajax帶入，所以改在ajax doneHandler註冊事件	
			}
			
			function changeColorOptionData(){
// 				console.log($(this).attr("value"));
// 				console.log($(this).attr("data-stock"));
// 				console.log($(this).attr("data-photo"));
				

// 				var colorName = $(this).attr("value");
// 				var stock = $(this).attr("data-stock");
// 				var photo = $(this).attr("data-photo");
				
				var colorName = $("select[name='color'] option:selected").attr("value");
				var stock = $("select[name='color'] option:selected").attr("data-stock");
				var photo = $("select[name='color'] option:selected").attr("data-photo");

				$("#colorStockSpan").text("("+colorName+ ": " + stock + "件)");
				$("input[name=quantity]").attr("max", stock);
				$("#photoImg").attr("src", photo);
//				$(".specDiv").hide()
//				$(".specDiv[data-color='"+colorName+"']").css("display", "inline-block");
				getSpecListByAjax(colorName);
				
			}
			
			function getSpecListByAjax(colorName){		
				var pId = $("input[name=productId]").val();
				$.ajax({
					url: 'get_spec_list.jsp?productId=' + pId +'&colorName=' + colorName,
					method: 'GET'
				}).done(getSpecListByAjaxDoneHandler);
				
				//alert('send Ajax already!...');				
			}
			
			function getSpecListByAjaxDoneHandler(result){
				//alert(result);
				//將result帶入畫面
				$(".specDiv").replaceWith(result);
				$("input[name='spec']").on("change", changeSpecOptionData);
			}
			
			function changeSpecOptionData(){
				console.log($(this).attr("value"));
 				console.log($(this).attr("data-stock"));
 				console.log($(this).attr("data-listPrice"));
 				console.log($(this).attr("data-price"));
//				console.log($(this).attr("data-photo"));
				
				var colorName = $(".specDivShow").attr("data-color");
				if(colorName.length>0) colorName+="/";
 				var specName = $(this).attr("value");
 				var listPrice = $(this).attr("data-listPrice");
 				var price = $(this).attr("data-price");
 				var stock = $(this).attr("data-stock");
 				var photo = $(this).attr("data-photo");		

				$(".listPrice").text(listPrice);
				$(".price").text(price);
 				$("#colorStockSpan").text("("+colorName +specName  + ": " + stock + "件)");
 				if(photo!=null && photo.length>0){ 					
 					$("#photoImg").attr("src", photo);
 				}
				$("input[name=quantity]").attr("max", stock);
			}
		</script>		
	</head>
	<body>
		<jsp:include page="./subviews/header.jsp">
			<jsp:param value="產品介紹" name="subheader"/>	
		</jsp:include>
		
		<%@include file="./subviews/nav.jsp" %>
		<%
			String productId = request.getParameter("productId");
			Product p = null;
			
			if(productId!=null){
				ProductService pService = new ProductService();
				p = pService.getProductById(productId);
			}
		%>
		<article><!-- content -->
			<% if(p==null) {%>
			<h2>查無此代號(<%= productId %>)的產品</h2>
			<%}else{ %>
			<div>
				<img id="photoImg" src="<%= p.getPhotoUrl() %>">
				<div style="display: inline-block; ">
					<h3><%= p.getName() %></h3>
					<div>出版日期：<%= p.getReleaseDate() %></div>
					<% if(p instanceof SpecialOffer) {%>
					<div>定價：<span class="listPrice"><%= ((SpecialOffer)p).getListPrice() %></span>元</div>
					<% } %>
					
					<div>優惠價: 
						<%=p instanceof SpecialOffer?((SpecialOffer)p).getDiscountString():""  %> 
						<span class="price"><%= p.getUnitPrice() %></span> 元</div>
					<div>庫存: 共<%= p.getStock() %> 件  <span id='colorStockSpan'></span></div>
					<div>分類: <a href='products_list.jsp?category=<%= p.getCategory() %>'><%= p.getCategory() %></a></div>
					<form action='add_cart.do' method='POST'>
						<input type="hidden" value="<%= p.getId() %>" name="productId">
						<% if(p.getColorMapSize()>0) {%>
						<div>
							<label>顏色:</label>
<%-- 							<% for(Color color:p.getColorList()){ %> --%>
<%-- 							<input type='radio' name='color' value='<%= color.getColorName() %>' required data-stock='<%=color.getStock() %>'  --%>
<%-- 								data-photo="<%= color.getPhotoUrl()%>"> --%>
<%-- 								<label><%= color.getColorName() %></label> --%>
<%-- 							<% } %> --%>
							<select name='color' required >
								<option value=''>請選擇....</option>
								<% for(Color color:p.getColorList()){ %>
								<option value='<%= color.getColorName()%>' data-stock='<%=color.getStock() %>' data-photo="<%= color.getPhotoUrl()%>"><%= color.getColorName()%></option>
								<%}%>
							</select>
						</div>
						<% } %>
						<% if(p.getSpecCount()>0){ %>
						<div>
							<label>Size/規格:</label>
							<div class='specDiv specDivShow' data-color=''>
								請先選擇顏色
							</div>							
						</div>
						<% } %>
						<div>
							<label>數量:</label>
							<input type="number" name="quantity" min="1" max="<%= p.getStock() %>">
						</div>
						<input type="submit" value="加入購物車">
					</form>
				</div>
			</div>
			<div class="productDesc">
				<hr><%= p.getDescription() %>
			</div>
			<% } %>
		</article>
		<%@include file="/subviews/footer.jsp" %>
		<script>
// 			var colorOptions = [
// 					{color:"綠", stock:3, photo:"https://im2.book.com.tw/image/getImage?i=https://www.books.com.tw/img/N01/142/02/N011420255.jpg&v=5b9f4e22k&w=348&h=348"},
// 					{color:"紅", stock:1, photo:"https://im2.book.com.tw/image/getImage?i=https://www.books.com.tw/img/N01/142/02/N011420245.jpg&v=5b9f4e22k&w=348&h=348"},
// 					{color:"黑", stock:1, photo:"https://im2.book.com.tw/image/getImage?i=https://www.books.com.tw/img/N01/142/02/N011420259.jpg&v=5b9f4e22k&w=348&h=348"}
// 			];
			<% if(p!=null && p.getColorMapSize()==0 && p.getSpecCount()>0 ){				
			%>
				getSpecListByAjax('');
			<% }%>

		</script>
	</body>
</html>
