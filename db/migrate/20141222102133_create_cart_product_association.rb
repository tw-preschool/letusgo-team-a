class CreateCartProductAssociation < ActiveRecord::Migration
	def change
  	 	create_table "cart_product_associations" do |t|
  	 		t.integer :cart_id, null: false
 			t.integer :product_id, null: false
 			t.integer :amount, :default => 0
		end
	end
end
