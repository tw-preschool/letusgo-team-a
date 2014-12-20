class RenameTables < ActiveRecord::Migration
	def change
		rename_table 'trade_associations', 'order_products'
		rename_table 'trade_promotion_associations', 'order_promotion_products'
	end
end
