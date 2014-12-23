$( document ).ready( function () {
	$( "#user" ).focusout( function () {
		IsEmail( "#user" );
	} );
	$( ".logOn" ).click( function () {
		IsEmail( "#user" );
	} );
	$( "#newUser" ).focusout( function () {
		IsEmail( "#newUser" );
	} );
	$( "#newPhone" ).focusout( function () {
		IsPhone( "#newPhone" );
	} );
	$( "#pwd" ).focusout( function () {
		IsPwd( "#pwd" );
	} );
	$( ".logOn" ).click( function () {
		IsPwd( "#pwd" );
	} );
	$( "#newPwd" ).focusout( function () {
		IsPwd( "#newPwd" );
	} );
	$( "#newName" ).focusout( function () {
		IsName( "#newName" );
	} );
	$( ".newLogOn" ).click( function () {
		validation( "#newUser", "#newPhone", "#newPwd", "#newName" );
	} );
} );

function validation( id1, id2, id3, id4 ) {
	if ( IsEmail( id1 ) && IsPhone( id2 ) && IsPwd( id3 ) && IsName( id4 ) ) {
		return true;
	} else {
		return false;
	}
}

function IsEmail( id ) {
	var str = $( id ).val();
	var Exp = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
	if ( !Exp.test( str ) ) {
		$( ".tip1" ).attr( 'style', 'color:red' );
		$( ".tip1" ).text( "请填写正确的邮箱!" ).show();
		return false;
	} else {
		$( ".tip1" ).hide();
		return true;
	}
}

function IsPhone( id ) {
	var str = $( id ).val();
	var Exp = /^1[3|4|5|8][0-9]\d{5,8}$/;
	if ( !Exp.test( str ) ) {
		$( ".tip2" ).attr( 'style', 'color:red' );
		$( ".tip2" ).text( "请填写正确的手机号!" ).show();
		return false;
	} else {
		$( ".tip2" ).hide();
		return true;
	}
}

function IsPwd( id ) {
	var str = $( id ).val();
	var Exp = /^\w{6,}$/;
	if ( !Exp.test( str ) ) {
		$( ".tip3" ).attr( 'style', 'color:red' );
		$( ".tip3" ).text( "请填写正确的密码,至少六位!" ).show();
		return false;
	} else {
		$( ".tip3" ).hide();
		return true;
	}
}

function IsName( id ) {
	var str = $( id ).val();
	var Exp = /^[a-zA-Z\u4E00-\u9FA5]+$/;
	if ( !Exp.test( str ) ) {
		$( ".tip4" ).attr( 'style', 'color:red' );
		$( ".tip4" ).text( "请填写正确的用户名,字母或汉字" ).show();
		return false;
	} else {
		$( ".tip4" ).hide();
		return true;
	}
}