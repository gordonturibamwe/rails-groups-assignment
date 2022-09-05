module UserConcern
  extend ActiveSupport::Concern
  included do
    before_validation do
      # Format attributes before validations
      self.email = self.email.delete(' ') if !self.email.nil?
    end

    before_create do
      # Assigning attributes to values before user is created
      self.username = SecureRandom.hex(7) if self.username.nil?
      self.year = DateTime.now.year
      self.month = DateTime.now.month
      self.month_in_words = DateTime.now.strftime("%B")
      self.is_user_active = true
      self.last_login_at = DateTime.now
      self.logged_in_ips = self.logged_in_ips.push(self.last_login_ip).uniq
    end

    before_save do
      # Updating attributes before each record save
      self.login_count = self.login_count += 1
    end
  end
end






  # class_methods do
    # def self.users_with_phone_numbers
    #   # class method
    #   all.select(&:phone_number)
    # end
  # end
