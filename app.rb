# encoding: UTF-8
require 'sinatra'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'rack/contrib'
require 'sinatra/flash'
require 'active_record'
require 'action_mailer'
require 'json'

Dir["./models/*.rb"].each {|file| require file }

require_relative 'mailer'

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
		if (admin = get_session :admin)
			erb :index, locals:{admin: admin}
		elsif (user = get_session :user)
			erb :index, locals:{user: user}
		else
			erb :index
		end
	end

	get '/products' do
		begin
			products = Product.get_all
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
				item_list.push Product.find_by_id(id)
			rescue ActiveRecord::RecordNotFound => e
				puts e.message.to_s
			end
		end
		item_list.to_json
	end

	get '/products/:id' do
		begin
			product = Product.find_by_id params[:id]
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
		products = Product.get_all
		if (admin = get_session :admin)
			return erb :'admin/product_management', locals:{products:products, admin: admin} 
		else
			session[:user_id] = nil
			flash.next[:warning] = '请登录后台并继续操作...'
			redirect to('/login'), 303
		end
	end

	get '/items' do
		content_type :html
		products = Product.get_all.where("stock > 0")
		if (user = get_session :user)
			erb :items, locals:{products: products, user: user}
		else
			erb :items, locals:{products: products}
		end
	end

	get '/cart' do
		if (user = get_session :user)
			content_type :html
			erb :cart, locals:{user: user}
		else
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end
	end

	get '/my_orders' do
		if (user = get_session :user)
			content_type :html
			if(params["id"])
				begin
				order = user.orders.find_by(order_id: params["id"].to_s)
				erb :'order_detail', locals:{order: order, user: user}
				rescue
					flash.next[:warning] = '无此订单!'
					redirect to('/my_orders'), 303
				end
			else
				erb :'order_list', locals:{orders: user.orders.order("created_at DESC"), user: user}
			end
		else
			flash.next[:warning] = '请登录后继续操作...'
			redirect to('/login'), 303
		end
	end

	get '/cart/cart_data' do
		content_type :json
		if user = get_session(:user)
			return user.shopping_cart.get_cart_data.to_json
		else
			return {}.to_json
		end
	end

	post '/cart/cart_data' do
		cart_data = JSON.parse params[:cart_data]
		if (user = get_session(:user))
			user.shopping_cart.update_with cart_data
			return user.shopping_cart.get_cart_data.to_json
		else
			return [404, "Error: no user info."]
		end
	end

	post '/edit/:id' do
		if (admin = get_session(:admin))
			product = Product.find_by_id params[:id]
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
	end

	get '/delete/:id' do
		if (admin = get_session(:admin))
			product = Product.find_by_id params[:id]
			product.is_deleted = true
			product.save
			redirect to('/admin/product_management'), 303
		end
	end

	put '/products' do
		if (admin = get_session(:admin))
			product = Product.find_by_id params[:id]
			product.promotion = params[:promotion]
			if product.save
				[201, {:message => "update success!"}.to_json]
			else
				halt 500, {:message => "update failed!"}.to_json
			end
		end
	end

	get '/admin/order_management' do
		if ( admin = get_session :admin )
			content_type :html
			if(params["id"])
				erb :'admin/order_detail', locals:{order:Order.where(order_id:params["id"]).first, admin: admin}
			else
				orders = Order.order("created_at DESC") rescue ActiveRecord::RecordNotFound
				erb :'admin/order_management', locals:{orders: orders, admin: admin}
			end		else
			session[:user_id] = nil
			flash.next[:warning] = '请登录后台并继续操作...'
			redirect to('/login'), 303
		end
	end

	post '/payment' do
		if user = get_session(:user)
			begin
				cart_data = JSON.parse params[:cart_data]
				order = Order.new
				order.init_with_data cart_data
				order.update_price
				# order.save
				user.orders << order
				content_type :html
				erb :payment, locals:{order: order, user: user}
			rescue
				flash.next[:error] = '抱歉，购买出错了！请重新购买！'
				redirect '/cart'
			end
		end
	end

	get '/login' do
		session[:user_id] = nil
		session[:admin_id] = nil
		content_type :html
		erb :login
	end

	post '/login' do
		session[:user_id] = nil
		session[:admin_id] = nil
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

	get '/logout' do
		session[:user_id] = nil
		session[:admin_id] = nil
		redirect '/'
	end

	get '/register' do
		content_type :html
		erb :register
	end

	post '/register' do
		session[:user_id] = nil
		session[:admin_id] = nil
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
 			Mailer.contact(user).deliver_now rescue nil
 			redirect '/'
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
