class ChangeOrder < ActiveRecord::Migration
  def change
  	change_table :orders do |t|
  		t.string :order_id
  	end

  end
end
