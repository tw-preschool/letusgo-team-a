class Product < ActiveRecord::Base
	has_many :cart_product_associations, class_name: "CartProductAssociation", foreign_key: "product_id", dependent: :destroy
	# has_many :shopping_carts, through: :cart_product_associations, source: :shopping_cart

	attr_accessor :kindred_price, :amount, :discount_amount
	@kindred_price = 0
	@amount = 0
	@discount_amount = 0
	validates :name, :price, :unit, :stock, presence: true
	validates :name, length: { maximum: 128 }
	validates :price, numericality: true
	validates :stock, :numericality => { :greater_than_or_equal_to => 0 }

	def self.find_by_id id
		self.where("id = ? AND is_deleted = ?", id, false).first
	end

	def self.get_all
		self.where("is_deleted = ?", false)
	end
end
