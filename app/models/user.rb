class User < ActiveRecord::Base
  has_many :artists, through: :user_artists
  has_many :user_artists
end
