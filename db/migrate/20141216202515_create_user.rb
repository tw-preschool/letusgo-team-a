class CreateUser < ActiveRecord::Migration
  def change
	create_table :users do |t|
		t.string :email
		t.string :password
		t.string :name
		t.string :address
		t.integer :phone

		t.timestamps
	end
  end
end
