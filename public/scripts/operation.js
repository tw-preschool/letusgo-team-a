$(document).ready(function() {
  $(".modify").click(open);
});
function open() {
  var action = $(this).attr("title");
  $(".form1").attr("action",action);
  for(var i = 0; i < 5; i++) {
  	var value = $(this).parent().parent().children().eq(i).text();
        $(".input"+i).attr("value",value);
  }
  $("#hidden").fadeIn();
  var div = $("#modify").html();
  $("#bg").html(div);
}
