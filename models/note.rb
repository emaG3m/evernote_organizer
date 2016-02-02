class Note < ActiveRecord::Base
  belongs_to :notebook
  has_many :taggings
  has_many :tags, through: :taggings
end
