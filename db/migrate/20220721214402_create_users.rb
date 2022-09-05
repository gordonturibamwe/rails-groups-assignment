class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      ## Registered details
      t.integer :year, null: false, default: 0
      t.integer :month, null: false, default: 0
      t.string :month_in_words, null: false, default: ""

      ## User
      t.string :username, null: false, limit: 20, index: true, unique: true
      t.string :email, null: true, limit: 70, index: true, unique: true
      t.string :password_digest

      ## Trackable
      t.integer :login_count, null: false, default: 0
      t.datetime :last_login_at, null: false
      t.string :last_login_ip, null: false, default: ""
      t.text :logged_in_ips, array: true, default: []
      t.boolean :is_user_active, default: true
      t.string :valid_token, null: false, default: "" # Saves half of the token for velidation purposes

      ## Password resetable
      t.uuid :reset_password_id, index: true, unique: true
      t.datetime :reset_password_expiration

      ## Lockable
      t.integer  :max_password_failed_attempts, default: 6, null: false # if :max_failed_attempts is greator than 0
      t.integer  :password_failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.boolean  :is_user_locked, default: false
      t.datetime :user_locked_on

      t.timestamps
    end
  end
end

# t.boolean :verify_token, null: false, default: false # If true will verify token validity with :valid_token on each request
