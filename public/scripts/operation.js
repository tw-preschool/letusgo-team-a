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
  $("[name='productPrice']").focusout(checkProductPrice);
  $("#editProduct").click(checkProductStock);
  $("#editProduct").click(checkProductPrice);
}

function add() {
  $("#hidden").fadeIn();
  var div = $("#add").html();
  $("#bg").html(div);
  $("[name='productStock']").focusout(checkProductStock);
  $("[name='productPrice']").focusout(checkProductPrice);
  $("#addProduct").click(checkProductStock);
  $("#addProduct").click(checkProductPrice);
}

function isProductStockValid() {
      return $("[name='productStock']").val() >= 0;
}

function isProductPriceValid() {
      return $("[name='productPrice']").val() >= 0;
}
  
function checkProductStock() {
  	if(!isProductStockValid()) {
		$('#stockErrorTip').attr('style','color:red');
  		$('#stockErrorTip').text('库存必须大于等于0').show();
  		return false;
    	} else {
    		$('#stockErrorTip').hide();
    		return true;
    		}
 }

 function checkProductPrice() {
    if(!isProductPriceValid()) {
    $('#priceErrorTip').attr('style','color:red');
      $('#priceErrorTip').text('价格必须大于等于0').show();
      return false;
      } else {
        $('#priceErrorTip').hide();
        return true;
        }
 }
