class Notebook < ActiveRecord::Base
  belongs_to :user
  has_many :notes
end
