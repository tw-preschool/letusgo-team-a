# encoding: UTF-8
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'rack/contrib'
require 'sinatra/flash'
require 'active_record'
require 'json'

require './models/product'
require './models/administrator'
require './models/user'
require './models/order'
require './models/trade_association'
require './models/trade_promotion_association'

class POSApplication < Sinatra::Base
	configure do
		helpers Sinatra::ContentFor
		enable :sessions
		register Sinatra::Flash
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
		user_id = session[:user_id]
		user = User.where("id = ?", user_id).first #rescue nil
		if user
			erb :index, locals:{msg:"已登录!"}
		else
			erb :index, locals:{msg:"登录"}
		end
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
		item_list = []
		item_id_list = JSON.parse params["item_id_list"]
		raise "query input error" unless item_id_list && item_id_list.is_a?(Array)
		item_id_list.each do |id|
			begin
				item_list.push Product.find(id)
			rescue ActiveRecord::RecordNotFound => e
				puts e.message.to_s 
			end
		end
		item_list.to_json
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
		if admin_id.nil?
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end 
		admin = Administrator.where("id = ?", admin_id).first #rescue nil
		if admin
		  content_type :html
		  erb :admin
		else
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end
	end

	get '/login' do
		@error_text = nil
		content_type :html
		erb :login
	end

	get '/items' do
		content_type :html
		user_id = session[:user_id]
		user = User.where("id = ?", user_id).first #rescue nil
		if user
		  erb :items, locals:{msg:"已登录!"}
		else
		  erb :items, locals:{msg:"登录"}
		end
	end

	get '/cart' do
		user_id = session[:user_id]
		if user_id.nil?
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/entry'), 303 
		end
		user = User.where("id = ?", user_id).first #rescue nil
		if user
			content_type :html
			erb :cart, locals:{msg:"已登录!"}
		else
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/entry'), 303
		end
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
			flash.next[:error] = '用户名和密码不能为空, 请重新输入!'
			redirect '/login'
		else
			admin = Administrator.where("name = ? AND password = ?", admin_name, password).first #rescue nil
			if admin
				session[:admin_id] = admin.id
				flash.next[:success] = '管理员登录成功!'
				redirect '/admin'
			else
				flash.next[:error] = '用户名或密码错误, 请重新输入!'
				redirect '/login'
			end
		end
	end

	get '/order_admin' do
		admin_id = session[:admin_id]
		if admin_id.nil?
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end 
		admin = Administrator.where("id = ?", admin_id).first #rescue nil
		if admin
			content_type :html
			if(params["id"])
				erb :order_detail_admin, locals:{order:Order.where(id:params["id"].to_i).first}
			else
				orders = Order.find(:all, :order => "created_at DESC") rescue ActiveRecord::RecordNotFound
				erb :order_admin, locals:{orders: orders}
			end
		else
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end
	end

	post '/payment' do
		cart_data = JSON.parse params[:cart_data]
		order = Order.new
		order.init_with_data cart_data
		order.update_price
		order.save
		# puts Order.last.products.to_json
		content_type :html
		erb :payment, locals:{order: order}
	end

	get '/entry' do
	  session[:user_id] = nil
	  content_type :html
	  erb :entry
	end

	post '/entry' do
		userEmail = params[:user]
		password = params[:pwd]
		if userEmail.nil? || userEmail.empty? || password.nil? || password.empty?
			flash.next[:error] = '用户名和密码不能为空, 请重新输入!'
			redirect '/entry'
		else
			user = User.where("email = ? AND password = ?", userEmail, password).first #rescue nil
			if user
				session[:user_id] = user.id
				flash.next[:success] = "登录成功! 欢迎回来, #{user.name}!"
				redirect '/'
			else
				content_type :html
				flash.next[:error] = '用户名或密码错误, 请重新输入!'
				redirect '/entry'
			end
		end
	end

	get '/register' do
		content_type :html
		erb :register
	end

	post '/register' do
		oldUser = User.where("email = ?", params[:newUser]).first #rescue nil
		if oldUser.nil?
			 user = User.create(:email => params[:newUser],
				:password => params[:newPwd],
				:name => params[:newName],
				:address => params[:addr],
				:phone => params[:phone])

			 user.save
			 content_type :html
 			flash.next[:success] = '注册成功!'
			redirect to('/'), 303
		else
			content_type :html
			flash.next[:warning] = '用户名已被抢注过啦!'
			redirect to('register')
		end
	end

	after do
		ActiveRecord::Base.connection.close
	end
end
