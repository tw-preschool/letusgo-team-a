var Item = function(data, count) {
    this.id = data.id;
    this.name = data.name;
    this.unit = data.unit;
    this.price = data.price || 0.00;
    this.promotion = data.promotion || false;
    this.stock = data.stock || 0;
    this.detail = data.detail;
    if(count == null)
        count = 0;
    this.count = Math.max(count, 0);
};

Item.prototype.isPromoted = function () {
  if (this.count < 2) {
    return false;
  }
  return this.promotion;
};

Item.prototype.realPrice = function() {
  return (this.price * this.realCount()).toFixed(2);
};

Item.prototype.realCount = function() {
  return this.isPromoted() ? (this.count - Math.floor(this.count / 3)) : this.count;
};
