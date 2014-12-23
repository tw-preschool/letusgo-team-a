$( document ).ready( function () {
	loadProducts();
	$( '#count' ).text( cartStorage.getSumCount() );

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
			if (product.stock == cartStorage.getItemCount( ( product.id ).toString() ))
				$( 'button', row ).attr( 'disabled', true );
			$( 'button', row ).click( function () {
				var btn = $( this );
				var product_count = cartStorage.getItemCount( product.id );
				if ( product_count < product.stock ) {
					btn.attr( 'disabled', true );
					cartStorage.setItemCount( ( product.id ).toString(), function () {
						$( '#count' ).text( cartStorage.getSumCount() );
						if ( cartStorage.getItemCount( ( product.id ).toString() ) >= product.stock ) btn.attr( 'disabled', true );
						else btn.attr( 'disabled', false );
					}, function() {
						btn.attr( 'disabled', false );
					} );
				}
			} );
			$( '#item-table' ).append( row );
		}
	}
} );