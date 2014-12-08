$(document).ready(function(){

  var count = localStorage.getItem('count') || 0;
  $('#count').text(count);

});
