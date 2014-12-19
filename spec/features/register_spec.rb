#encoding=UTF-8
require_relative '../spec_helper'

feature 'register' do
  scenario 'should with correct email', :js => true do
    visit '/register'
    fill_in 'newUser', :with => 'wrong@gamil'

    click_on '确定'

    expect(page).to have_content('请填写正确的邮箱!')
  end

  scenario 'should with password more than 6 characters', :js => true do
    visit '/register'
    fill_in 'newUser', :with => 'user@email.com'
    fill_in 'newPwd', :with => '1234'

    click_on '确定'

    expect(page).to have_content('请填写正确的密码,至少六位!')
  end

  scenario 'should with valid username', :js => true do
    visit '/register'
    fill_in 'newUser', :with => 'user@email.com'
    fill_in 'newPwd', :with => '123456'
    fill_in 'newName', :with => '123'

    click_on '确定'

    expect(page).to have_content('请填写正确的用户名,字母或汉字')
  end

  scenario 'should with valid phone number', :js => true do
    visit '/register'
    fill_in 'newUser', :with => 'user@email.com'
    fill_in 'newPwd', :with => '123456'
    fill_in 'newName', :with => 'lllqqq'
    fill_in 'newAddress', :with => 'hkhkhkh'

    click_on '确定'

    expect(page).to have_content('请填写正确的手机号!')
  end

end
