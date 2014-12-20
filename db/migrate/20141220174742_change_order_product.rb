class ChangeOrderProduct < ActiveRecord::Migration
  def change
  	change_table 'order_products' do |t|
  		t.string :name
  		t.string :unit
  	end
  	remove_column 'order_products', :product_id
  end
end
