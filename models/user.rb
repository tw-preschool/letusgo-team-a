class User < ActiveRecord::Base
  validates :email, :name, :password, :address, :phone, presence: true
  validates :email, uniqueness: true
  validates :name,:password,:address, length: { maximum: 128 }
end
