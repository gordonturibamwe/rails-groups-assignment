class Post < ApplicationRecord
  validates_presence_of :title, message: "Title must be be present"
  validates_presence_of :content, message: "Content must be be present"
  belongs_to :group
  belongs_to :user
  has_many_attached :images, dependent: :destroy

  before_save do
    self.last_activity = DateTime.now
  end
end
