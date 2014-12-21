class ChangeProduct < ActiveRecord::Migration
  def change
  	change_table :products do |t|
  		t.boolean :is_deleted, default: false
  	end
  end
end
