(function() {
		$.ajax({
			url: '/products',
			success: function(data) {
				$(data).each(function(index, product) {
					var add = '<button class="btn btn-sm btn-success">加入购物车</button>';
					var row = '<tr><td>' + product.name + '</td><td>' + product.price + '</td><td>' 
						  + product.unit + '</td><td>' + add + '</td></tr>';
					$('#item-table').append(row);
				});
			},
			type: 'GET'
	});
})();
$.ajax({
	url:"/products",
	success:function(data){
		$(data).each(function(index,product){
			var add = '<button class = "btn btn-sm-success">加入购物车</button>';
			var row = '<tr><td>' + product.name + '</td><td>' + product.price + '</td><td>' +
				  product.unit + '</td><td>' + add + '</td></tr>';
			$('#item-table').append(row);		
		});
	},
	type:"GET"
});
