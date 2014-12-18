#encoding=UTF-8
require_relative '../spec_helper'

feature 'shopping cart page' do

    background :each do
        items = []
        items.push :name => '可口可乐', :unit => '瓶', :price => 3.00, :promotion => true, :stock => 20 ,:detail => '美国可口可乐公司生产'
        items.push :name => '雪碧', :unit => '瓶', :price => 3.00, :promotion => true, :stock => 20 ,:detail => '美国可口可乐公司生产'
        items.push :name => '苹果', :unit => '斤', :price => 5.50, :promotion => false, :stock => 20 ,:detail => '一种营养价值很高的水果'
        items.push :name => '荔枝', :unit => '斤', :price => 15.00, :promotion => false, :stock => 0 ,:detail => '顽固性呃逆及五更泻者的食疗佳品'
        items.push :name => '电池', :unit => '个', :price => 2.00, :promotion => false, :stock => 20 ,:detail => '南孚电池 一节更比六节强'
        items.push :name => '方便面', :unit => '袋', :price => 4.50, :promotion => false, :stock => 1 ,:detail => '康师傅老坛酸菜'
        items.each do |item| Product.create(item) end
        # page = Capybara::Session.new(Capybara.current_driver, Capybara.app)
        user = {email: 'test@test.com', password: Digest::SHA1.hexdigest('test'),
                name: 'test', address: 'test', phone: '13312345678'}
        User.create user
        page.set_rack_session user_id: User.last.id
    end

    feature 'given an empty cart' do
        scenario "should get correct shopping list and price when a user add 3瓶雪碧 and 3斤苹果 in cart and visit '/cart'", js: true do
            visit '/items'
            (1..3).each do page.find(:xpath, '//button[../../td[contains(.,"雪碧")]]').click end
            (1..3).each do page.find(:xpath, '//button[../../td[contains(.,"苹果")]]').click end
            visit '/cart'
            expect(page).to have_selector(:xpath, '//td[../td[contains(.,"雪碧")]][contains(.,"6.00")]')
            expect(page).to have_selector(:xpath, '//td[../td[contains(.,"苹果")]][contains(.,"16.50")]')
            expect(page).to have_selector('#totalPrice', text: '22.5')
        end
    end

    feature 'given an nonempty cart' do
        scenario "should get correct shopping list and price when a user continully add 3瓶雪碧 in nonempty cart and visit '/cart'", js: true do
            visit '/'
            page.execute_script 'sessionStorage.count=6; sessionStorage.itemCount=JSON.stringify({"2":3,"3":3});'
            visit '/items'
            (1..3).each do page.find(:xpath, '//button[../../td[contains(.,"雪碧")]]').click end
            visit '/cart'
            expect(page).to have_selector(:xpath, '//td[../td[contains(.,"雪碧")]][contains(.,"12.00")]')
            expect(page).to have_selector(:xpath, '//td[../td[contains(.,"苹果")]][contains(.,"16.50")]')
            expect(page).to have_selector('#totalPrice', text: '28.5')
        end

        scenario "cart should be empty when a user close browser then back to visit '/cart'", js: true do
            visit '/'
            page.execute_script 'sessionStorage.count=6; sessionStorage.itemCount=JSON.stringify({"2":3,"3":3});'
            # restart Selenium driver
            Capybara.send(:session_pool).delete_if { |key, value| key =~ /selenium/i }
            page.set_rack_session user_id: User.last.id
            visit '/cart'
            expect(page.find(:xpath, '//tbody[..[contains(@id,"item_list")]]').text).to eq("")
            expect(page).to have_selector('#totalPrice', text: '0.0')
        end

        scenario "sum price should change correspondingly when a user visit '/cart' and change the amount of 苹果 in nonempty cart", js: true do
            visit '/'
            page.execute_script 'sessionStorage.count=6; sessionStorage.itemCount=JSON.stringify({"2":3,"3":3});'
            visit '/cart'
            page.find(:xpath, '//button[contains(.,"+")][./ancestor::tr/td[contains(.,"雪碧")]]').click
            expect(page.find(:xpath, '//input[./ancestor::tr/td[contains(.,"雪碧")]]').value).to eq("4")
            expect(page).to have_selector('#totalPrice', text: '25.5')
            page.find(:xpath, '//button[contains(.,"-")][./ancestor::tr/td[contains(.,"雪碧")]]').click
            expect(page.find(:xpath, '//input[./ancestor::tr/td[contains(.,"雪碧")]]').value).to eq("3")
            expect(page).to have_selector('#totalPrice', text: '22.5')
        end
    end

    after :each do
        # restart Selenium driver
        Capybara.reset_sessions!
    end
end
