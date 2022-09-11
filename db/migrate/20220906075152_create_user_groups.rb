class CreateUserGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :user_groups, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :group, null: false, foreign_key: true, type: :uuid
      t.boolean :is_admin, default: false
      t.boolean :is_member, default: false
      t.boolean :request_accepted, default: false
      t.boolean :secret_group_invitation, default: false

      t.timestamps
    end
  end
end
