showItems();

function showItems() {
	var xmlhttp;
	if(window.XMLHttpRequest) {
		xmlhttp = new XMLHttpRequest();
	} else {
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.onreadystatechange = function() {
		if(xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			var add = '<button>加入购物车</button>';
			var response = JSON.parse(xmlhttp.responseText);
			for(var i = 0; i < response.length; i++) {
				var goods = $('<tr>\
						<td>' + response[i].name + '</td>\
						<td>' + response[i].price + '</td>\
						<td>' + response[i].unit + '</td>\
						<td>' + add + '</td>\
						</tr>');
				$("#item-table").append(goods);
			}
		}		
	}
	xmlhttp.open("GET","/products",true);
	xmlhttp.send();
}
