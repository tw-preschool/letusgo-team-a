class Product < ActiveRecord::Base
	validates :name, :price, :unit, presence: true
	validates :name, length: { maximum: 128 }
	validates :price, numericality: true
end
