class UserGroup < ApplicationRecord
  validates :group_id, uniqueness: {scope: :user_id}, on: :save
  belongs_to :user
  belongs_to :group

end
