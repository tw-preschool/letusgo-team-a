$( document ).ready( function () {
	var count = sessionStorage.getItem( 'count' ) || 0;
	$( '#count' ).text( count );
} );

function state() {
	var a = $( "#state" ).text();
	if ( a == "登录" ) {
		return true;
	} else {
		return confirm( 'are you sure?' );
	}
}
