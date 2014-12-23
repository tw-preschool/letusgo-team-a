class ChangeUser < ActiveRecord::Migration
  def change
  	change_column :users, :phone, :integer, limit: 5
  end
end
