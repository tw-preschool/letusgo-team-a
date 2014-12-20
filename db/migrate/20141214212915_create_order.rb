class CreateOrder < ActiveRecord::Migration
	def change
		create_table :orders do |t|
			t.float :sum_price, :default => 0.0
			t.float :sum_discount, :default => 0.0
			t.timestamps
		end
	end
end
