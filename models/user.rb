class User < ActiveRecord::Base
  validates :username, :password, :is_admin, presence: true
  validates :username, uniqueness: true
  validates :username,:password, length: { maximum: 128 }
end
