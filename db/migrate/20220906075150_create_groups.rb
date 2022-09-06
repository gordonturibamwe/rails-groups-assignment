class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :description
      t.integer :total_members, default: 0
      t.integer :total_posts, default: 0
      t.integer :group_access, default: 0
      t.datetime :last_activity, null: false
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
