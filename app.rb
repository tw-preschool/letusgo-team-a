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
require './models/order_product'
require './models/order_promotion_product'

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
		if get_session :user
			erb :index, locals:{msg:"已登录!"}
		else
			erb :index, locals:{msg:"登录"}
		end
	end

	get '/products' do
		begin
			products = Product.where(is_deleted: false)
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
				item_list.push Product.where("id = ? AND is_deleted = ?", id, false).first
			rescue ActiveRecord::RecordNotFound => e
				puts e.message.to_s
			end
		end
		item_list.to_json
	end

	get '/products/:id' do
		begin
			product = (Product.where("id = ? AND is_deleted = ?", params[:id], false).first rescue nil )
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
		redirect to('/admin/product_management'), 303
	end

	get '/admin/product_management' do
		content_type :html
		products = Product.where(is_deleted: false)
		return erb :'admin/product_management', locals:{products:products} if get_session :admin
		if get_session :user
			session[:user_id] = nil
		end
		flash.next[:warning] = '请登录后台并继续操作...'
		redirect to('/login'), 303
	end

	get '/items' do
		content_type :html
		if get_session :user
		  erb :items, locals:{msg:"已登录!"}
		else
		  erb :items, locals:{msg:"登录"}
		end
	end

	get '/cart' do
		if get_session :user
			content_type :html
			erb :cart, locals:{msg:"已登录!"}
		else
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end
	end

	post '/edit/:id' do
		product = (Product.where("id = ? AND is_deleted = ?", params[:id], false).first rescue nil )
		product.attributes ={
			:name => params[:productName],
			:price => params[:productPrice],
			:unit => params[:productUnits],
			:stock => params[:productStock],
			:detail => params[:productDetail]
		}
		product.save
		redirect to('/admin/product_management'), 303
	end

	get '/delete/:id' do
		product = (Product.where("id = ? AND is_deleted = ?", params[:id], false).first rescue nil )
		product.is_deleted = true
		product.save
		redirect to('/admin/product_management'), 303
	end

	put '/products' do
		product = (Product.where("id = ? AND is_deleted = ?", params[:id], false).first rescue nil )
		product.promotion = params[:promotion]
		if product.save
			[201, {:message => "update success!"}.to_json]
		else
			halt 500, {:message => "update failed!"}.to_json
		end
	end

	get '/admin/order_management' do
		if get_session :admin
			content_type :html
			if(params["id"])
				erb :'admin/order_detail', locals:{order:Order.where(order_id:params["id"]).first}
			else
				orders = Order.order("created_at DESC") rescue ActiveRecord::RecordNotFound
				erb :'admin/order_management', locals:{orders: orders}
			end
		else
			if get_session :user
				session[:user_id] = nil
			end
			flash.next[:warning] = '请登录后台并继续操作...'
			redirect to('/login'), 303
		end
	end

	post '/payment' do
		begin
			cart_data = JSON.parse params[:cart_data]
			order = Order.new
			order.init_with_data cart_data
			order.update_price
			order.save
			content_type :html
			erb :payment, locals:{order: order}
			# puts Order.last.products.to_json
		rescue
			flash.next[:error] = '抱歉，购买出错了！请重新购买！'
			redirect '/cart'
		end
	end

	get '/login' do
	  session[:user_id] = nil
	  content_type :html
	  erb :login
	end

	post '/login' do
		userEmail = params[:user]
		password = params[:pwd]
		if userEmail.nil? || userEmail.empty? || password.nil? || password.empty?
			flash.next[:error] = '用户名和密码不能为空, 请重新输入!'
			return redirect '/login'
		end
		admin = Administrator.where("name = ? AND password = ?", userEmail, password).first #rescue nil
		if admin
			session[:admin_id] = admin.id
			flash.next[:success] = '管理员登录成功!'
			return redirect '/admin/product_management'
		end
		user = User.where("email = ? AND password = ?", userEmail, password).first #rescue nil
		if user
			session[:user_id] = user.id
			flash.next[:success] = "登录成功! 欢迎回来, #{user.name}!"
			return redirect '/'
		end
		content_type :html
		flash.next[:error] = '用户名或密码错误, 请重新输入!'
		redirect '/login'
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

	def get_session role
		user_id = nil
		user = nil

		case role
			when :user then
				user_id = session[:user_id]
				user = User.where("id = ?", user_id).first rescue nil
			when :admin
				user_id = session[:admin_id]
				user = Administrator.where("id = ?", user_id).first rescue nil
			else
				user_id = nil
				user = nil
		end

		return user
	end
end
