class User < ActiveRecord::Base
  has_many :artists, through: :user_artists
end
