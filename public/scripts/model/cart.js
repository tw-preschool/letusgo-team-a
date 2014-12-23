$( document ).ready( function () {
	cart = new ShoppingCart( cartStorage );
	$( '#pay_btn' ).click( function () {
		if ( cart.getCartCount() <= 0 ) {
			alert( "请先选购商品吧!" );
			window.location = '/items';
			return false;
		}
		var postForm = document.createElement( "form" );
		postForm.action = '/payment';
		postForm.method = 'post';
		postForm.enctype = 'multipart/form-data';
		postForm.style.display = 'none';
		var postText = document.createElement( "textarea" );
		postText.name = "cart_data";
		postText.value = window.sessionStorage.itemCount;
		postForm.appendChild( postText );
		document.body.appendChild( postForm );
		postForm.submit();
		window.sessionStorage.clear();
		return false;
	} );
} );

function ShoppingCart( cartStorage ) {
	var itemList = [];
	var cartCount = 0;
	initial( cartStorage );
	this.getCartCount = function () {
		return cartCount;
	};

	function renderProductsByitemList() {
		$.each( itemList, function ( index, item ) {
			var row = $( '<tr><td>' + item.name + '</td>' + '<td>' + item.price.toFixed( 2 ) +
				'</td>' + '<td>' + item.unit + '</td>' +
				'<td><form class="form-inline" role="form"><div class="input-group">' +
					'<span class="input-group-btn"><button class="btn btn-primary" type="button">-</button></span>' +
					'<input data-id="' + item.id + '" class="form-control" type="text" value="' + item.count + '" placeholder="1">' +
					'<span class="input-group-btn"><button class="btn btn-primary" type="button">+</button></span>' +
				'</div></form></td>' +
				'<td><span class="real-price">' + item.realPrice() + '</span></td></tr>' );
			if ( item.count == item.stock ) row.find( "button" ).last().attr( "disabled", true );
			row.find( "button" ).first().click( function () {
				var tr = $( this ).parents( "tr" ).first();
				var itemId = tr.find( "input" ).get( 0 ).dataset.id;
				var item = _.find( itemList, function ( item ) {
					return item.id == itemId;
				} );
				if ( item.count == 1 ) {
					if ( confirm( "您真的要从购物车中移除 << " + item.name + " >> 吗？" ) ) {
						$( this ).parents( "tr" ).first().remove();
						item.count -= 1;
						cartStorage.setItemWithCount( item.id, item.count );
						showTotalPrice();
						updateCartCount();
					}
				} else {
					item.count -= 1;
					cartStorage.setItemWithCount( item.id, item.count );
					tr.find( "input" ).val( item.count );
					tr.find( ".real-price" ).text( item.realPrice() );
					showTotalPrice();
					updateCartCount();
				}
				if ( item.count < item.stock ) {
					tr.find( "button" ).last().attr( "disabled", false );
				}
			} );
			row.find( "button" ).last().click( function () {
				var tr = $( this ).parents( "tr" ).first();
				var itemId = tr.find( "input" ).get( 0 ).dataset.id;
				var item = _.find( itemList, function ( item ) {
					return item.id == itemId;
				} );
				if ( item.count < item.stock ) {
					item.count += 1;
					cartStorage.setItemWithCount( item.id, item.count );
					tr.find( "input" ).val( item.count );
					tr.find( ".real-price" ).text( item.realPrice() );
					showTotalPrice();
					updateCartCount();
				}
				if ( item.count == item.stock ) {
					$( this ).attr( "disabled", true );
				}
			} );
			$( "#item_list tbody" ).append( row );
			showTotalPrice();
			updateCartCount();
		} );
	}

	function getProductsByIdList( itemIdList, itemCountList ) {
		$.ajax( {
			url: '/products/query',
			type: 'post',
			dataType: 'json',
			data: {
				"item_id_list": JSON.stringify( itemIdList )
			},
			success: function ( data ) {
				$.each( data, function ( index, item ) {
					var count = itemCountList[ item.id ];
					if ( count > 0 && item.stock > 0) {
						if ( parseInt( count ) <= parseInt( item.stock ) ) {
							itemList.push( new Item( item, count ) );
						} else {
							itemList.push( new Item( item, item.stock ) );
							cartStorage.setItemWithCount( item.id, item.stock );
						}
					}
				} );
				renderProductsByitemList();
			},
			error: function ( request, status ) {
				console.log( status );
			}
		} );
	}

	function showTotalPrice() {
		var totalPrice = 0;
		$.each( itemList, function ( index, item ) {
			totalPrice += parseFloat( item.realPrice() );
		} );
		$( '#totalPrice' ).text( totalPrice.toFixed( 2 ) );
	}

	function initial( cartStorage ) {
		var itemIdList = [];
		$.each( cartStorage.getAllItemCounts(), function ( index, item ) {
			itemIdList.push( index );
		} );
		getProductsByIdList( itemIdList, cartStorage.getAllItemCounts() );
	}

	function updateCartCount() {
		cartCount = 0;
		$.each( cartStorage.getAllItemCounts(), function ( id, count ) {
			var item = _.find( itemList, function ( item ) {return item.id == id;} );
			if(item != null)
				cartCount += item.count;
			else
				cartStorage.setItemWithCount(id, 0);
		} );

		$( '#count' ).text( cartCount );
		sessionStorage.count = cartCount;
	}
}
