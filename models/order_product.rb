class OrderProduct < ActiveRecord::Base
	self.table_name = "order_products"
	belongs_to :order, :foreign_key => "order_id", :class_name => "Order" 
end
