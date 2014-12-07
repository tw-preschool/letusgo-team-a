$(document).ready(function () {
	$('#count').text(cartStorage.getCount('count'));

	var allItemCounts = cartStorage.getAllItemCounts();

	var totalPrice = 0;

	for (var key in allItemCounts) {
	  if (allItemCounts.hasOwnProperty(key)) {
	    var url = '/products/'+ key;
	    appendProductByUrl(url, allItemCounts[key]);
	  }
	}


	function appendProductByUrl(url, itemCount) {
		$.ajax({
			url: url,
		 	success: function(data) {
				appendItem(data, itemCount);
				console.log(data);
				showTotalPrice();
			},
			type: 'GET'
		});
	}

	function showTotalPrice(){
	    $('#totalPrice').text(totalPrice);
	}

	function appendItem(data, itemCount) {
		var item = new Item(data, itemCount);
		var row = $('<tr><td>' + data.name + '</td><td>' + data.price + '</td><td>' + data.unit + '</td><td>' + 
			appendButton(itemCount) + '</td><td>' + item.realPrice() + '</td></tr>');

		totalPrice += parseFloat(item.realPrice());
        
		$('#item_list').append(row);
	}

	function appendButton(itemCount) {
		var button ='<form class="form-inline" role="form">'+
          			'<div class="input-group">'+
            		'<span class="input-group-btn"><button class="btn btn-primary" type="button">-</button></span>' +
            		'<input class="form-control" type="text" '+'value="'+itemCount+'" placeholder="1">' +
            		'<span class="input-group-btn"><button class="btn btn-primary" type="button">+</button>' +
            		'</span></div></form>';
		return button;
	}


});