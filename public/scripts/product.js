$(document).ready(function () {
	$('#addProduct').on('click', addProduct);
	loadProducts();

	function addProduct() {
		$.ajax({
	        url: '/products',
	        data: {
	            name: $('#productName').val(),
	            price: $('#productPrice').val(),
	            unit: $('#productUnit').val()
	        },
	        success: function(data) {
	        	appendProductByUrl(data.message);
	        },
	        type: 'POST'
	    });
	}

	function appendProductByUrl(url) {
		$.ajax({
			url: url,
			success: function(data){
				appendProduct(data);
			},
			type: 'GET'
		});
	}

	function loadProducts() {
		$.ajax({
			url: '/products',
			success: function(data) {
				$(data).each(function(index, value) {
					appendProduct(value);
				});
			},
			type: 'GET'
		});
	}

	function appendProduct(product) {
		var row = '<tr><td>' + product.name + '</td><td>' + product.price + '</td><td>' + product.unit + '</td></tr>';
		$('#item-table').append(row);
	}
});