class CreateTradePromotionAssociation < ActiveRecord::Migration
	def change
 		create_table "trade_promotion_associations" do |t|
 			t.integer :order_id, null: false
 			t.integer :product_id, null: false
			t.float :discount_price, :default => 0.0
			t.integer :discount_amount, :default => 0
 		end
	end
end
