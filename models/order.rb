require 'active_record'
require 'json'
require_relative './product'

class Order < ActiveRecord::Base
	has_many :products, class_name: "OrderProduct", dependent: :destroy
	has_many :promotion_products, class_name: "OrderPromotionProduct", dependent: :destroy
	validates :order_id, uniqueness: true
	before_create :set_order_id
	after_initialize :init

	attr_reader :product_list, :discount_list

	def init
		@product_list = []
		@discount_list = []
	end

	def init_with_data cart_data
		cart_data.each do |id, count|
			raise "initial data error" unless id.to_i.to_s == id.to_s && count.to_i.to_s == count.to_s
			raise "product count error" unless count.to_i >= 0
			next if count.to_i == 0
			db_item = Product.where(id: id).first
			if db_item
				db_item.amount = count
				db_item.kindred_price = 0.0
				db_item.discount_amount = 0;
				@product_list.push db_item
			else
				raise "product id error"
			end
		end
	end

	def select_item item_name
		select_items = @product_list.select {|item| item.name === item_name}
		select_items.first
	end

	def add_item_count item_name, amount
		raise "product count error" if amount <= 0

		if amount > 0 && !item_name.empty?
			db_item = Product.where(name: item_name).first
			if db_item
				new_item = @product_list.select{|item| item.name === item_name}.first
				if new_item
					new_item.amount += amount
				else
					db_item.amount = amount
					db_item.kindred_price = 0.0
					db_item.discount_amount = 0
					@product_list.push db_item
				end
			end
		end
	end

	def update_price
		@product_list.each do |item|
			if item.promotion
				discount_amount = (item.amount / 3).floor
				item.kindred_price = item.price * (item.amount - discount_amount)
				if discount_amount
					item.discount_amount = discount_amount
					@discount_list.push item
					self.sum_discount += item.price * item.discount_amount
				end
			else
				item.kindred_price = item.price * item.amount
			end
			self.sum_price += item.kindred_price
		end
		self.sum_price
	end

	def save
		@product_list.each do |product|
			self.products << OrderProduct.new( name: product.name,
				kindred_price: product.kindred_price,
				amount: product.amount,
				unit: product.unit,
				unit_price: product.price,
				is_promotion: product.promotion )
		end
		@discount_list.each do |product|
			self.promotion_products << OrderPromotionProduct.new( name: product.name,
				discount_amount: product.discount_amount,
				discount_price: product.discount_amount * product.price )
		end
		super
	end

	def set_order_id
		date_str = Time.now.strftime "%Y%m%d"
		loop do
			random_number = SecureRandom.random_number 0xFFFFFFFF
			self.order_id = date_str + random_number.to_s(16)
			break unless Order.find_by_order_id(self.order_id)
		end
	end
end

class <<Order
	undef :create
end
