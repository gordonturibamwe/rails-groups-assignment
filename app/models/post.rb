class Posts < ApplicationRecord
  validates_presence_of :title, message: "must be be present"
  belongs_to :group
  belongs_to :user
  has_many_attached :images, dependent: :destroy
end
