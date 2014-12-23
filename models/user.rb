class User < ActiveRecord::Base
	has_one :shopping_cart, class_name: "ShoppingCart", foreign_key: "user_id", dependent: :destroy

	validates :email, :name, :password, :address, :phone, presence: true
	validates :email, uniqueness: true
	validates :name,:password,:address, length: { maximum: 128 }

	after_create :create_shopping_cart

	def create_shopping_cart
		ShoppingCart.create user: self
	end
end
