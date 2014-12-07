var Item = function(id, name, unit, price, count) {
    this.id = id;
    this.name = name;
    this.unit = unit;
    this.price = price || 0.00;
    this.count = count || 1;
}

Item.prototype.isPromoted = function () {
  if (this.count < 2) {
    return false;
  }

  // var id = this.id;
  // var promotions = loadPromotions().filter(function(promotion) {
  //   return promotion.ids.contains(id);
  // });

  return promotions && promotions.length ? true : false;
}

Item.prototype.realPrice = function() {
  return (this.price * this.realCount()).toFixed(2);
}

Item.prototype.realCount = function() {
  return this.isPromoted() ? (Math.ceil(this.count / 2)) : this.count;
}

Array.prototype.contains = function(id) {
  return this.indexOf(id) > -1;
}