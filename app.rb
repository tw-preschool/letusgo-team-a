# encoding: UTF-8
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'rack/contrib'
require 'active_record'
require 'json'

require './models/product'
require './models/user'

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
                            :unit => params[:productUnit])
        puts "#{params[:productName]}"

        # if product.save
        #     [201, {:message => "products/#{product.id}"}.to_json]
        # else
        #     halt 500, {:message => "create product failed"}.to_json
        # end
        product.save
        redirect to('/admin'), 303
    end

    get '/admin' do
        user_id = session[:user_id]
        redirect to('/login'), 303 if user_id.nil?
        user = User.where("id = ?", user_id).first #rescue nil
        if user
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
        }
        product.save
        puts "#{product.unit}"
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
        username = params[:username]
        password = params[:password]
        if username.nil? || username.empty? || password.nil? || password.empty?
          content_type :html
          erb :login, locals:{error_text: "用户名和密码不能为空!"}
        end
        user = User.where("username = ? AND password = ?", username, password).first #rescue nil
        if user
            session[:user_id] = user.id
            # session[:username] = username
            # session[:password] = password
            redirect to('/admin')
        else
            content_type :html
            erb :login, locals:{error_text:"用户名或密码错误!"}
        end
    end
    after do
        ActiveRecord::Base.connection.close
    end
end
