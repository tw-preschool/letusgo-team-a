class CreateTradeAssociation < ActiveRecord::Migration
	def change
 		create_table "trade_associations" do |t|
 			t.integer :order_id, null: false
 			t.integer :product_id, null: false
 			t.float :kindred_price, :default => 0.0
			t.float :unit_price, :default => 0.0
 			t.integer :amount, :default => 0
 			t.boolean :is_promotion, :default => false
 		end
	end
end
