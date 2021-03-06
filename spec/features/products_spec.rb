# encoding: utf-8

require_relative '../spec_helper'

describe 'Products Application' do
  describe 'List all products' do
    before { get '/products' }

    it 'is successful' do
      expect(last_response.status).to eq 200
    end

    it 'is empty at the very begining' do
      list = JSON.parse(last_response.body)
      expect(list.length).to eq 0
    end
  end

  describe 'Create a Product' do
  	let(:body) { {:productName => "Mac Book Pro", :productPrice => 13456.89, :productUnit => "台", :productStock => 20 ,:productDetail => '需要描述吗？'} }

  	it 'create a product'  do
  		post '/products', body, {'Content-Type' => 'application/json'}
  		expect(last_response.status).to eq 303

  		get '/products'
  		created = JSON.parse(last_response.body)[0]

  		expect(created['name']).to eq "Mac Book Pro"
  		expect(created['price']).to eq 13456.89
      expect(created['unit']).to eq "台"
  	end

  end
end
