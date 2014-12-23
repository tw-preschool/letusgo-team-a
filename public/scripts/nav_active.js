(function nav_active() {
	page = window.location.pathname;
	nav_li = $(".navbar a[href='"+page+"']").parents("li");
	nav_li.addClass("active");
})();