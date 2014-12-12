#encoding=UTF-8
require_relative '../spec_helper'


describe 'Shopping cart model' do
    before :each do
        items = []
        items.push :name => '可口可乐', :unit => '瓶', :price => 3.00, :promotion => true, :stock => 20 ,:detail => '美国可口可乐公司生产'
        items.push :name => '雪碧', :unit => '瓶', :price => 3.00, :promotion => true, :stock => 20 ,:detail => '美国可口可乐公司生产'
        items.push :name => '苹果', :unit => '斤', :price => 5.50, :promotion => false, :stock => 20 ,:detail => '一种营养价值很高的水果'
        items.push :name => '荔枝', :unit => '斤', :price => 15.00, :promotion => false, :stock => 0 ,:detail => '顽固性呃逆及五更泻者的食疗佳品'
        items.push :name => '电池', :unit => '个', :price => 2.00, :promotion => false, :stock => 20 ,:detail => '南孚电池 一节更比六节强'
        items.push :name => '方便面', :unit => '袋', :price => 4.50, :promotion => false, :stock => 1 ,:detail => '康师傅老坛酸菜'
        items.each do |item|
            Product.create(item).to_json
        end
        @sample_item_coke = Product.all.where(name: '可口可乐').first
        @sample_item_apple = Product.all.where(name: '苹果').first
    end

    describe 'initalize method' do
        it 'should get an empty shopping list when initializing with empty cart data' do
            cart_data = {}
            shopping_cart = ShoppingCart.new()
            shopping_cart.init_with_data cart_data
            expect(shopping_cart.shopping_list.length).to eq(0)
        end

        it 'should raise a error when initializing with error data' do
            cart_data = {:name => '可口可乐', :unit => '瓶', :price => 3.00, :promotion => true, :stock => 20 ,:detail => '美国可口可乐公司生产'}
            shopping_cart = ShoppingCart.new()

            expect{shopping_cart.init_with_data cart_data}.to raise_error
        end

        it 'should raise a error when initializing data has unexist id' do
            cart_data = {"-1" => 3}
            shopping_cart = ShoppingCart.new()

            expect{shopping_cart.init_with_data cart_data}.to raise_error
        end

        it 'should raise a error when initializing data has wrong count number' do
            cart_data = {@sample_item_coke.id.to_s => -1}
            shopping_cart = ShoppingCart.new()

            expect{shopping_cart.init_with_data cart_data}.to raise_error
        end

        it 'should get correct item in shopping list when initializing with cart data' do
            cart_data = {@sample_item_coke.id.to_s => 3, @sample_item_apple.id.to_s => 3}
            shopping_cart = ShoppingCart.new()
            shopping_cart.init_with_data cart_data
            expect(shopping_cart.shopping_list[0].name).to eq(@sample_item_coke.name)
            expect(shopping_cart.shopping_list[1].name).to eq(@sample_item_apple.name)
        end
    end

    describe 'select item method' do
        before :each do
            cart_data = {@sample_item_apple.id.to_s => 3, @sample_item_coke.id.to_s => 5}
            @shopping_cart = ShoppingCart.new()
            @shopping_cart.init_with_data cart_data
        end

        it 'should get nil when giving a unexist item name ' do
            expect(@shopping_cart.select_item 'iPhone 6').to be_nil
        end

        it 'should get correct item when giving a exist item name' do
            apple = @shopping_cart.select_item(@sample_item_apple.name)
            expect(apple.price).to eq(@sample_item_apple.price)
            expect(apple.name).to eq(@sample_item_apple.name)
        end
    end


    describe 'add item count method' do
        before :each do
            cart_data = {@sample_item_apple.id.to_s => 3}
            @shopping_cart = ShoppingCart.new()
            @shopping_cart.init_with_data cart_data
        end

        it 'should get correct item count when giving a reasonable item name and additional count' do
            @shopping_cart.add_item_count @sample_item_apple.name, 3
            expect(@shopping_cart.shopping_list.first.amount).to eq(6)
        end

        it 'should do nothing when giving a unexist item name' do
            @shopping_cart.add_item_count 'iPhone 6', 3
            expect(@shopping_cart.shopping_list.first.amount).to eq(3)
        end
        it 'should raise error when giving a wrong additional count' do
            expect{@shopping_cart.add_item_count @sample_item_apple.name, -1}.to raise_error
        end
    end

    describe 'update price method' do
        it 'should given a correct sum price and discount price when given 1 apple and 1 coke' do
            cart_data = {@sample_item_apple.id.to_s => 1, @sample_item_coke.id.to_s => 1}
            shopping_cart = ShoppingCart.new()
            shopping_cart.init_with_data cart_data
            shopping_cart.update_price
            expect(shopping_cart.sum_price).to eq(8.5)
            expect(shopping_cart.sum_discount).to eq(0)
        end

        it 'should given a correct sum price and discount price when given 3 apple and 3 coke' do
            cart_data = {@sample_item_apple.id.to_s => 3, @sample_item_coke.id.to_s => 3}
            shopping_cart = ShoppingCart.new()
            shopping_cart.init_with_data cart_data
            shopping_cart.update_price
            expect(shopping_cart.sum_price).to eq(22.5)
            expect(shopping_cart.sum_discount).to eq(3)
        end
    end
end
