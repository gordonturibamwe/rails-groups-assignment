class Group < ApplicationRecord
  validates_presence_of :name, on: :create, message: "Group name must be be present"
  validates :name, uniqueness: {message: "Group name already exists. Please change or update name."}, format: {with: /[0-9a-zA-Z]/, on: :save}
  has_many :user_groups, dependent: :destroy, foreign_key: :group_id
  has_many :users, through: :user_groups
  # has_many :posts, dependent: :destroy
  belongs_to :user

  enum group_access: [:is_public, :is_private, :is_secret]

  before_create do
    self.increment(:total_members)
    self.last_activity = DateTime.now
  end

  after_create do
    user_group = UserGroup.create(
      is_member: true,
      is_admin: true,
      group_id: self.id,
      user_id: self.user_id,
      request_accepted: true
    )
  end
end





  # broadcasts_to ->(group) { [group.id, "groups"] }, inserts_by: :prepend
  # aftert_commit on: :create do
  #   broadcast_append_to(
  #     user,
  #     partial: 'groups/group',
  #     locals: {group: self},
  #     target: 'groups'
  #   )
  # end


  # broadcasts_to ->(group) {"groups"}, inserts_by: :prepend
  # after_create_commit -> { broadcast_prepend_later_to "groups" }
  # broadcasts_to ->(group) { :group_list }
  # broadcasts_to ->(group) { :group_list }, inserts_by: :prepend, target: 'groups'
  # broadcasts_to ->(group) { [group.user, "groups"] }, inserts_by: :prepend

  # after_create_commit -> { broadcast_replace_later_to("groups", locals: { user: current_user, group: self }) }
