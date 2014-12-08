$(document).ready(function(){

  var count = sessionStorage.getItem('count') || 0;
  $('#count').text(count);

});
