class Product < ActiveRecord::Base
	has_many :trade_associations, class_name: "TradeAssociation", dependent: :destroy
	has_many :relative_orders, through: :trade_associations

	has_many :trade_promotion_associations, class_name: "TradePromotionAssociation", dependent: :destroy
	has_many :relative_promotion_orders, through: :trade_promotion_associations

	attr_accessor :kindred_price, :amount, :discount_amount
	@kindred_price = 0
	@amount = 0
	@discount_amount = 0
	validates :name, :price, :unit, :stock, presence: true
	validates :name, length: { maximum: 128 }
	validates :price, numericality: true
	validates :stock, :numericality => { :greater_than_or_equal_to => 0 }
end
