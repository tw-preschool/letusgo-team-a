$( document ).ready( function () {
	loadProducts();
	$( '#count' ).text( cartStorage.getCount( 'count' ) );

	function loadProducts() {
		$.ajax( {
			url: '/products',
			success: function ( data ) {
				$( data ).each( function ( index, value ) {
					appendProduct( value );
				} );
			},
			type: 'GET'
		} );
	}

	function appendProduct( product ) {
		console.log( product );
		if ( product.stock > 0 ) {
			var promotionInfo = product.promotion ? '买二赠一' : '无优惠';
			var addButton = '<button class="btn btn-sm btn-success addCart">加入购物车</button>';
			var row = $( '<tr><td>' + product.name + '</td><td>' + product.price + '</td><td>' + product.unit + '</td><td title="' + product.detail + '" class="nowarp">' + product.detail + '</td><td>' + promotionInfo + '</td><td>' + addButton + '</td></tr>' );
			$( 'button', row ).click( function () {
				var product_count = cartStorage.getItemCount( product.id );
				if ( product_count < product.stock ) {
					cartStorage.setCount( 'count' );
					$( '#count' ).text( cartStorage.getCount( 'count' ) );
					cartStorage.setItemCount( ( product.id ).toString() );
				}
				if ( cartStorage.getItemCount( ( product.id ).toString() ) >= product.stock ) $( this ).attr( 'disabled', true );
			} );
			$( '#item-table' ).append( row );
		}
	}
} );