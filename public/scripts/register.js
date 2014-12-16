$(document).ready(function(){
  $(".register").click(function(){
    $("#register").fadeIn();
  });
  $(".logOn").click(IsEmail);
});

function IsEmail() {
  var user = $("#user").text();
  var Exp = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
  if(!Exp.test(user)) {
    
  }
}
