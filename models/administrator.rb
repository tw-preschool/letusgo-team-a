class Administrator < ActiveRecord::Base
  validates :name, :password, presence: true
  validates :name, uniqueness: true
  validates :name,:password, length: { maximum: 128 }
end
