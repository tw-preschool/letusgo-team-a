class ChangeOrderPromotionProduct < ActiveRecord::Migration
  def change
  	change_table 'order_promotion_products' do |t|
  		t.string :name
  	end
  	remove_column 'order_promotion_products', :product_id
  end
end
