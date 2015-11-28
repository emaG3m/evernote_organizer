class User < ActiveRecord::Base
  validates :username, presence: :true
  validates :password, presence: :true
  validates_uniqueness_of :username

  has_many :notes
  has_many :tags
end
