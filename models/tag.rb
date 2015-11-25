class Tag < ActiveRecord::Base
  validates_uniqueness_of :name, scope: :user_id

  belongs_to :user
  has_many :taggings
  has_many :notes, through: :taggings
end
