require 'active_record'
require 'json'
require_relative './product'

class ShoppingCart
    attr_reader :shopping_list, :discount_list, :sum_price, :sum_discount
    def initialize
        @shopping_list = []
        @discount_list = []
        @sum_price = 0.0
        @sum_discount = 0.0
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
                @shopping_list.push db_item
            else
                raise "product id error"
            end
        end
    end

    def select_item item_name
        select_items = @shopping_list.select {|item| item.name === item_name}
        select_items.first
    end

    def add_item_count item_name, amount
        raise "product count error" if amount <= 0

        if amount > 0 && !item_name.empty?
            db_item = Product.where(name: item_name).first
            if db_item
                new_item = @shopping_list.select{|item| item.name === item_name}.first
                if new_item
                    new_item.amount += amount
                else
                    db_item.amount = amount
                    db_item.kindred_price = 0.0
                    db_item.discount_amount = 0
                    @shopping_list.push db_item
                end
            end
        end
    end

    def update_price
        @shopping_list.each do |item|
            if item.promotion
                discount_amount = (item.amount / 3).floor
                item.kindred_price = item.price * (item.amount - discount_amount)
                if discount_amount
                    item.discount_amount = discount_amount
                    @discount_list.push item
                    @sum_discount += item.price * item.discount_amount
                end
            else
                item.kindred_price = item.price * item.amount
            end
            @sum_price += item.kindred_price
        end
        @sum_price
    end

end
