class User < ApplicationRecord
  include UserConcern
  has_secure_password # For encrypting passwords
  validates :username, uniqueness: {message: "Username already taken. Choose another username."}
  validates :email, uniqueness: {message: "Email already registered."}, allow_blank: false, format: {with: /.+\@.+\..+/, on: :save}
	validates :password, presence: true, length: {in: 4..10, message: "Password is too short. Minimum 4 characters."}

  has_many :user_groups, dependent: :destroy, foreign_key: :user_id
  has_many :groups, through: :user_groups
  has_many :groups, dependent: :destroy
  has_many :posts, dependent: :destroy
end
