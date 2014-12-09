var cartStorage = (function() {
    return {
        setCount: function(key) {
            sessionStorage[key] = this.getCount(key) + 1;
        },
        getCount: function(key) {
            return parseInt(sessionStorage[key]) || 0;
        },
        setItemCount: function(key) {
        	var allItemCounts = this.getAllItemCounts();

        	if (allItemCounts[key]) {
        		allItemCounts[key] = this.getItemCount(key) + 1;
        	} else {
        		allItemCounts[key] = 1;
        	}

        	sessionStorage.setItem("itemCount", JSON.stringify(allItemCounts));
        },
        setItemWithCount: function(key, count){
            var allItemCounts = this.getAllItemCounts();

            allItemCounts[key] = count;

            sessionStorage.setItem("itemCount", JSON.stringify(allItemCounts));
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
        	return JSON.parse(sessionStorage.getItem("itemCount")) || {};
        }
    };
})();
