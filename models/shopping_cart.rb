class ShoppingCart < ActiveRecord::Base
	has_many :cart_products, class_name: "CartProductAssociation", foreign_key: "cart_id", dependent: :destroy
	# has_many :products, through: :cart_products, source: :product
	belongs_to :user, class_name: "User", foreign_key: "user_id"

	# attr_reader :products
	validates :user_id, presence: true

	def append_product product_id, amount = 1
		self.validate
		return unless (product = Product.find_by_id product_id) && (amount = amount.to_i) > 0
		if cart_product = cart_products.find_by(product: product)
			cart_product.amount += amount
			cart_product.save
		else
			cart_products.create product: product, amount: amount
		end
	end

	def update_product product_id, amount
		self.validate
		return nil unless (product = Product.find_by_id product_id) && (amount = amount.to_i) >= 0
		if cart_product = cart_products.find_by(product: product)
			if amount == 0
				cart_product.destroy
			else
				cart_product.amount = [ amount, product.stock ].min
				cart_product.save
			end
		else
			return unless amount > 0
			cart_products.create product: product, amount: amount
		end
		cart_products.reload
	end

	def remove_product product_id, amount = 1
		self.validate
		return unless (product = Product.find_by_id product_id) && (amount = amount.to_i) > 0
		return unless cart_product = cart_products.find_by(product: product)
		if cart_product.amount > amount
			cart_product.amount -= amount
			cart_product.save
		else
			cart_product.destroy
		end
	end

	def update_with cart_data
		self.validate
		return unless cart_data && cart_data.is_a?(Hash)
		self.clear_cart
		cart_data.each do |id, amount|
			next unless id.to_i.to_s == id.to_s && amount.to_i.to_s == amount.to_s && (amount = amount.to_i) > 0
			next unless product = Product.find_by_id(id.to_i)
			self.update_product product.id, amount
		end
		return self.get_cart_data
	end

	def get_cart_data
		self.validate
		cart_data = {}
		cart_products.each do |cart_product|
			cart_data[cart_product.product.id.to_s] = cart_product.amount
		end
		return cart_data
	end

	def update
		cart_products.each do |cart_product|
			if cart_product.product.is_deleted
				cart_product.destroy
				next
			end
			if cart_product.amount > cart_product.product.stock
				cart_product.amount = cart_product.product.stock
				cart_product.save
			end
		end
	end

	def clear_cart
		cart_products.clear
	end
end
