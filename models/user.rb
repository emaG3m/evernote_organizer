require 'bcrypt'

class User < ActiveRecord::Base
  validates :email, presence: :true
  validates :password, presence: :true
  validates_uniqueness_of :email

  has_many :notes
  has_many :tags

  def self.authenticate(email, password)
    user = find_by_email!(email)
    (user && user.password == password) ? user : nil
  end

  def password
    @password ||= BCrypt::Password.new(password_hash)
  end

  def password=(password)
    @password = BCrypt::Password.create(password)
    self.password_hash = @password
  end
end
