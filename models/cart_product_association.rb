class CartProductAssociation < ActiveRecord::Base
	attr_accessor :cart_id, :product_id
	self.table_name = "cart_product_associations"
	belongs_to :shopping_cart, class_name: "ShoppingCart", foreign_key: "cart_id"
	belongs_to :product, class_name: "Product", foreign_key: "product_id"
end