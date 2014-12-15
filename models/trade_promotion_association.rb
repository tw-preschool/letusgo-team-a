class TradePromotionAssociation < ActiveRecord::Base
	self.table_name = "trade_promotion_associations"
	belongs_to :product, :foreign_key => "product_id", :class_name => "Product" 
	belongs_to :order, :foreign_key => "order_id", :class_name => "Order" 
end
