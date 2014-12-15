$(document).ready(function() {
  $(".modify").click(open);
  $(".add").click(add);
});

function open() {
  var action = $(this).attr("title");
  $(".form1").attr("action",action);
  for(var i = 0; i < 5; i++) {
  	var value = $(this).parent().parent().children().eq(i).text();
        $(".input"+i).attr("value",value);
  }
  $("#hidden").fadeIn();
  var div = $("#modify").html();
  $("#bg").html(div);
  $("[name='productStock']").focusout(checkProductStock);
  $("#editProduct").click(checkProductStock);
}

function add() {
  $("#hidden").fadeIn();
  var div = $("#add").html();
  $("#bg").html(div);
  $("[name='productStock']").focusout(checkProductStock);
  $("#addProduct").click(checkProductStock);
}

function isProductStockValid() {
  		return $("[name='productStock']").val() >= 0;
}
  
function checkProductStock() {
  	if(!isProductStockValid()) {
		$('#errorTip').attr('style','color:red');
  		$('#errorTip').text('库存必须大于等于0').show();
  		return false;
    	} else {
    		$('#errorTip').hide();
    		return true;
    		}
 }
