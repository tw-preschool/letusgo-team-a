# encoding: UTF-8
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'rack/contrib'
require 'active_record'
require 'json'

require './models/product'
require './models/administrator'
require './models/order'

class POSApplication < Sinatra::Base
    configure do
        helpers Sinatra::ContentFor
        use Rack::Session::Pool, :expire_after => 60 * 60 * 24 * 30
    end

    dbconfig = YAML.load(File.open("config/database.yml").read)

    configure :development do
        require 'sqlite3'
        ActiveRecord::Base.establish_connection(dbconfig['development'])
    end

    configure :test do
        require 'sqlite3'
        ActiveRecord::Base.establish_connection(dbconfig['test'])
    end

    use Rack::PostBodyContentTypeParser

    before do
        content_type :json
    end

    get '/' do
        content_type :html
        File.open('public/index.html').read
    end

    get '/add' do
        content_type :html
        File.open('public/add.html').read
    end

    get '/products' do
        begin
            products = Product.all || []
            products.to_json
        rescue ActiveRecord::RecordNotFound => e
            [404, {:message => e.message}.to_json]
        end
    end

    post '/products/query' do
        begin
            item_list = []
            item_id_list = JSON.parse params["item_id_list"]
            raise "query input error" unless item_id_list && item_id_list.is_a?(Array)
            item_id_list.each do |id|
                item_list.push Product.find(id)
            end
            item_list.to_json
        rescue ActiveRecord::RecordNotFound => e
            [404, {:message => e.message}.to_json]
        end
    end

    get '/products/:id' do
        begin
            product = Product.find(params[:id])
            product.to_json
        rescue  ActiveRecord::RecordNotFound => e
            [404, {:message => e.message}.to_json]
        end
    end

    post '/products' do
        product = Product.create(:name => params[:productName],
                            :price => params[:productPrice],
                            :unit => params[:productUnit],
                            :stock => params[:productStock],
                            :detail => params[:productDetail])

        product.save
        redirect to('/admin'), 303
    end

    get '/admin' do
        admin_id = session[:admin_id]
        redirect to('/login'), 303 if admin_id.nil?
        admin = Administrator.where("id = ?", admin_id).first #rescue nil
        if admin
          content_type :html
          erb :admin
        else
          redirect to('/login'), 303
        end
    end

    get '/login' do
        @error_text = nil
        content_type :html
        erb :login
    end

    get '/edit/:id' do
        @product = Product.find(params[:id])
        content_type :html
        erb :edit
    end

    post '/edit/:id' do
        product = Product.find(params[:id])
        product.attributes ={
            :name => params[:productName],
            :price => params[:productPrice],
            :unit => params[:productUnits],
            :stock => params[:productStock],
            :detail => params[:productDetail]
        }
        product.save
        redirect to('/admin'), 303
    end

    get '/delete/:id' do
        product = Product.find(params[:id])
        product.destroy
        redirect to('/admin'), 303
    end

    put '/products' do
	    product = Product.find(params[:id])
	    product.promotion = params[:promotion]
        if product.save
            [201, {:message => "update success!"}.to_json]
        else
            halt 500, {:message => "update failed!"}.to_json
        end
    end

    post '/login' do
        admin_name = params[:adminname]
        password = params[:password]
        if admin_name.nil? || admin_name.empty? || password.nil? || password.empty?
          content_type :html
          erb :login, locals:{error_text: "用户名和密码不能为空!"}
        end
        admin = Administrator.where("name = ? AND password = ?", admin_name, password).first #rescue nil
        if admin
            session[:admin_id] = admin.id
            redirect to('/admin')
        else
            content_type :html
            erb :login, locals:{error_text:"用户名或密码错误!"}
        end
    end

    post '/payment' do
        cart_data = JSON.parse params[:cart_data]
        @order = Order.new()
        @order.init_with_data cart_data
        @order.update_price

        content_type :html
        erb :'/payment'
    end

    after do
        ActiveRecord::Base.connection.close
    end
end
