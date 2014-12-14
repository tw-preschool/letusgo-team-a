$(document).ready(function(){

  	$("[name='productStock']").on('focusout', checkProductStock);
  	$('#addProduct').on('click', addProduct);
  	$('#editProduct').on('click', addProduct);

  	var count = sessionStorage.getItem('count') || 0;
  	$('#count').text(count);

  	function isProductStockValid() {
  		return $("[name='productStock']").val() >= 0;
  	}
  
	function checkProductStock() {
  		if(!isProductStockValid()) {
  			$('#errorTip').text('库存必须大于等于0').show();
    	} else {
    		$('#errorTip').hide();
    	}
  	}

  	function addProduct() {
  		if(!isProductStockValid()) {
  			$('#errorTip').text('库存必须大于等于0');
  			return false;
    	} else {
    		return true;
    	}
  	}
});
