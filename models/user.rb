class User < ActiveRecord::Base
  validates :name, presence: :true
  validates :password, presence: :true
  validates_uniqueness_of :name

  has_many :notes
  has_many :tags
end
