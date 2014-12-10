$(document).ready(function () {
	$('#count').text(cartStorage.getCount('count'));

	var allItemCounts = cartStorage.getAllItemCounts();

	var item_list = [];

	for (var key in allItemCounts) {
	  if (allItemCounts.hasOwnProperty(key)) {
	    var url = '/products/'+ key;
	    getProductByUrl(url, allItemCounts[key]);
	  }
	}

	$('#pay_btn').click( function() {
		var postForm = document.createElement("form");
        postForm.action = '/payment';
        postForm.method = 'post';
        postForm.enctype = 'multipart/form-data';
        postForm.style.display = 'none';
        var postText = document.createElement("textarea");
        postText.name = "cart_data";
        postText.value = window.sessionStorage.itemCount;
        postForm.appendChild(postText);
        document.body.appendChild(postForm);
        postForm.submit();
        return false;
	});

	function getProductByUrl(url, itemCount) {
		$.ajax({
			url: url,
		 	success: function(data) {
				var item = new Item(data, itemCount);
				console.log(data);
				appendItem(item);
				if(item != null)
					item_list.push(item);
				showTotalPrice();
			},
			type: 'GET'
		});
	}

	function showTotalPrice(){
		var totalPrice = 0;
		$.each(item_list, function(index, item) {
			totalPrice += parseFloat(item.realPrice());
		});
	    $('#totalPrice').text(totalPrice);
	}

	function appendItem(item) {
		var row = $('<tr><td>' + item.name + '</td><td>' + item.price + '</td><td>' + item.unit + '</td><td>' +
			appendButton(item.id, item.count) + '</td><td><span id="item_'+item.id+'_count">' + item.realPrice() + '</span></td></tr>');
		console.log("111");
		row.find(".item-count-minus").click(function(e){
			var item_form = $(e.target).parents("form").first();
			var item_id = item_form.get(0).dataset.id;
			var item_count = cartStorage.getItemCount(item_id);
			var item = _.find(item_list, function(item){ return item.id == item_id});
			if(item_count>0 && item != null) {
				if(item_count == 1)
					$(e.target).attr('disabled',true);
				item.count = item_count-1;
				cartStorage.setItemWithCount(item.id, item.count);
			}
			$("#item_"+item.id+"_count").text(item.realPrice());
			item_form.find(".item-count").val(item.count);
			showTotalPrice();
		});

		row.find(".item-count-add").click(function(e){
			var item_form = $(e.target).parents("form").first();
			var item_id = item_form.get(0).dataset.id;
			var item_count = cartStorage.getItemCount(item_id);
			var item = _.find(item_list, function(item){ return item.id == item_id});
			if(item != null) {
				if(item_count == 0)
					row.find(".item-count-minus").attr('disabled',false);
				item.count = item_count+1;
				cartStorage.setItemWithCount(item.id, item.count);
			}
			$("#item_"+item.id+"_count").text(item.realPrice());
			item_form.find(".item-count").val(item.count);
			showTotalPrice();
		});
		$('#item_list').append(row);
	}

	function appendButton(id, itemCount) {
		var button ='<form class="form-inline" role="form" data-id="'+id+'">' +
          			'<div class="input-group">' +
            		'<span class="input-group-btn"><button class="btn btn-primary item-count-minus" type="button">-</button></span>' +
            		'<input class="form-control item-count" type="text" '+'value="'+itemCount+'" placeholder="1">' +
            		'<span class="input-group-btn"><button class="btn btn-primary item-count-add" type="button">+</button>' +
            		'</span></div></form>';
		return button;
	}


});
