function CartStorage( callback ) {
	var update_session_storage_from_server = function ( callback ) {
		$.get( '/cart/cart_data', function ( cart_data ) {
			sessionStorage.cart_data = JSON.stringify( cart_data );
			if ( callback != null ) callback();
		} );
	};
	var update_server_from_session_storage = function ( success_call_back, cart_data, error_call_back ) {
		if ( typeof ( cart_data ) != "string" ) cart_data = JSON.stringify( cart_data );
		$.ajax( {
			url: '/cart/cart_data',
			type: 'post',
			dataType: 'json',
			data: {
				"cart_data": cart_data || sessionStorage.cart_data || {}
			},
			success: function ( cart_data ) {
				sessionStorage.cart_data = JSON.stringify( cart_data );
				if ( success_call_back != null ) success_call_back();
			},
			error: function () {
				if ( error_call_back != null ) error_call_back();
			}
		} );
	};
	update_session_storage_from_server( callback );
	this.update = function () { 
		update_session_storage_from_server();
	};
	this.getSumCount = function () {
		cart_data = JSON.parse( sessionStorage.cart_data ) || {};
		var sum = 0;
		$.each( cart_data, function ( key, amount ) {
			sum += amount;
		} );
		return sum;
	};
	this.setItemCount = function ( id, success_call_back, error_call_back ) {
		var cart_data = this.getCartData();
		if ( cart_data[ id ] ) {
			cart_data[ id ] = this.getItemCount( id ) + 1;
		} else {
			cart_data[ id ] = 1;
		}
		update_server_from_session_storage( success_call_back, cart_data, error_call_back );
	};
	this.setItemWithCount = function ( id, count, success_call_back, error_call_back ) {
		var cart_data = this.getCartData();
		if ( parseInt( count ) <= 0 ) cart_data[ id ] = undefined;
		else cart_data[ id ] = count;
		update_server_from_session_storage( success_call_back, cart_data, error_call_back );
	};
	this.getItemCount = function ( id ) {
		var cart_data = this.getCartData();
		if ( cart_data[ id ] ) {
			return parseInt( cart_data[ id ] );
		} else {
			return 0;
		}
	};
	this.getCartData = function () {
		return JSON.parse( sessionStorage.cart_data || {} );
	};
	this.clear = function ( success_call_back, error_call_back ) {
		sessionStorage.cart_data = {};
		update_server_from_session_storage( success_call_back, {}, error_call_back );
	};
}