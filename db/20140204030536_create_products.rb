class CreateProducts < ActiveRecord::Migration
    def change
        create_table :products do |t|
            t.string :name
            t.float :price
            t.string :unit
	        t.boolean :promotion
            t.integer :stock
            t.string :detail
            t.timestamps
        end
    end
end
