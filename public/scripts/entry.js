$(document).ready(function(){
  $("#user").focusout(function(){IsEmail("#user");});
  $(".logOn").click(function(){IsEmail("#user");});
  $("#newUser").focusout(function(){IsEmail("#newUser");});
  $("#newPhone").focusout(function(){IsPhone("#newPhone");});
  $(".newLogOn").click(function(){validation("#newUser","#newPhone");});
});

function validation(id1,id2) {
  if(IsEmail(id1) && IsPhone(id2)) {
    return true;
  } else {
    return false;
  }
}

function IsEmail(id) {
  var str = $(id).val();
  var Exp = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
  if(!Exp.test(str)) {
    $(".tip1").attr('style','color:red');
    $(".tip1").text("请填写正确的邮箱!").show();
    return false;
  } else {
    $(".tip1").hide();
    return true;
  }
}

function IsPhone(id) {
  var str = $(id).val();
  var Exp = /^1[3|4|5|8][0-9]\d{8}$/;
  if(!Exp.test(str)) {
      $(".tip2").attr('style','color:red');
      $(".tip2").text("请填写正确的手机号!").show();
      return false;
    } else {
      $(".tip2").hide();
      return true;
    }
}
