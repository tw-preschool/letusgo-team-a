class Product < ActiveRecord::Base
	attr_accessor :kindred_price, :amount, :discount_amount
	@kindred_price = 0
	@amount = 0
	@discount_amount = 0
	validates :name, :price, :unit, :stock, presence: true
	validates :name, length: { maximum: 128 }
	validates :price, numericality: true
end
