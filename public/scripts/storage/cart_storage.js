var cartStorage = (function() {
    return {
        setCount: function(key) {
            localStorage[key] = this.getCount(key) + 1;
        },
        getCount: function(key) {
            return parseInt(localStorage[key]) || 0;
        },
        setItemCount: function(key) {
        	var allItemCounts = this.getAllItemCounts();

        	if (allItemCounts[key]) {
        		allItemCounts[key] = this.getItemCount(key) + 1;
        	} else {
        		allItemCounts[key] = 1;
        	}

        	localStorage.setItem("itemCount", JSON.stringify(allItemCounts));
        },
        getItemCount: function(key) {
        	var allItemCounts = this.getAllItemCounts();

        	if (allItemCounts[key]) {
        		return parseInt(allItemCounts[key]);
        	} else {
        		return 0;
        	}
        },
        getAllItemCounts: function() {
        	return JSON.parse(localStorage.getItem("itemCount")) || {};
        }
    }
})();