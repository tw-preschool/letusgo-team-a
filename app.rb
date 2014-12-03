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
        product = Product.create(:name => params[:name],
                            :price => params[:price],
                            :unit => params[:unit])

        if product.save
            [201, {:message => "products/#{product.id}"}.to_json]
        else
            halt 500, {:message => "create product failed"}.to_json
        end
    end

    get '/admin' do
        username = session[:username]
        password = session[:password]
        redirect to('/login'), 303 if username.nil? || username.empty? || password.nil? || password.empty?
        user = User.find(:first, :conditions => ["username = ? and password = ?", username, password])
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

    post '/login' do
        @error_text = nil
        username = params[:username]
        password = params[:password]
        if username.nil? || username.empty? || password.nil? || password.empty?
          content_type :html
          @error_text = "用户名和密码不能为空!"
          erb :login
        end
        user = User.find(:first, :conditions => ["username = ? and password = ?", username, password])
        if user
            session[:username] = username
            session[:password] = password
            redirect to('/admin')
        else
            content_type :html
            @error_text = "用户名或密码错误!"
            puts @error_text
            erb :login
        end
    end

    after do
        ActiveRecord::Base.connection.close
    end
end
