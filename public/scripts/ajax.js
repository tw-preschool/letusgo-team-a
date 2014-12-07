(function() {
	$.ajax({
		url: '/products',
		success: function(data) {
			$(data).each(function(index, product) {
				var s = index + 1;
				var check = product.promotion? "checked":"";//开关由"checked"决定
				var add = '<button class="btn btn-sm btn-success addCart">加入购物车</button>';
				var promotion = '<div class="bootstrap-switch bootstrap-switch-small" id='+product.id+'><input type="checkbox" name="my-checkbox" 				 		'+check+'></div>';
				var row = '<tr><td>' + product.name + '</td><td>' + product.price + '</td><td>' +
					product.unit + '</td><td>' + add + '</td></tr>';
				$('.item-table').append(row);
				$("#inline-promotion" + s ).append(promotion);
				$("#"+product.id).on('click',{msg:product.id},isPromotion);
			});
			$("[name='my-checkbox']").bootstrapSwitch();
			//$('.addCart').click(storeItems);
		},
		type: 'GET'
	});
})();
function isPromotion(event) {
	$.ajax({
	        url: '/products',
	        data: {
	            id: event.data.msg,
	            promotion: $(this).find("input")[0].checked
	        },
	        success: function(data) {
	        	alert(data.message);
	        },
	        type: 'PUT'
	});
}
/*function storeItems() {
	var s = $(this).tagName;
	alert(s);
}*/
