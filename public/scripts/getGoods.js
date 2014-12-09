(function() {
	$.ajax({
		url: '/products',
		success: function(data) {
			$(data).each(function(index, product) {
				var check = product.promotion? "checked":"";				//开关由"checked"决定
				var promotion = '<div class="bootstrap-switch bootstrap-switch-small" id='+product.id
						+'><input type="checkbox" name="my-checkbox"'+check+'></div>';
				$("#inline-promotion" + product.id ).append(promotion);
				$("#"+product.id).on('click',{msg:product.id},isPromotion);
			});
			$("[name='my-checkbox']").bootstrapSwitch();
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
	        	
	        },
	        type: 'PUT'
	});
}
