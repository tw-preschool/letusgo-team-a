$(document).ready(function () {
	loadProducts();

	$('#count').text(cartStorage.getCount('count'));


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
		console.log(product);
		var promotionInfo = product.promotion ? '买二赠一' : '无优惠';
		var addButton = '<button class="btn btn-sm btn-success addCart">加入购物车</button>';
		var row = $('<tr><td>' + product.name + '</td><td>' + product.price + '</td><td>' + product.unit + '</td><td>' + promotionInfo +'</td><td>'+addButton + '</td></tr>');

		$('button', row).click(function() {
			cartStorage.setCount('count');
			$('#count').text(cartStorage.getCount('count'));

			cartStorage.setItemCount((product.id).toString());
		});

		$('#item-table').append(row);
	}
});