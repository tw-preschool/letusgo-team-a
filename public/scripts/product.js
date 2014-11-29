$(document).ready(function () {
	$('#addProduct').on('click', addProduct);

	function addProduct() {
		$.ajax({
	        url: '/products',
	        data: {
	            name: $('#productName').val(),
	            price: $('#productPrice').val(),
	            unit: $('#productUnit').val()
	        },
	        success: function(data) {
	        	location.href = "/views/items.html";
	        },
	        type: 'POST'
	    });
	}
});