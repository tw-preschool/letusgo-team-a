# encoding: utf-8
require 'sinatra'
require 'rack/contrib'
require 'active_record'
require 'json'

require './models/product'

    dbconfig = YAML.load(File.open("config/database.yml").read)

    configure :development do
        require 'sqlite3'
        ActiveRecord::Base.establish_connection(dbconfig['development'])
    end
product = Product.create(:name => "方便面",
                            :price => "4.50",
                            :unit => "袋")
product.save
