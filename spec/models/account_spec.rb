require 'rails_helper'

RSpec.describe User, type: :model do

  describe "with 2 or more comments" do
    after(:all) do
      User.destroy_all  # Cleanup all models and their automatically created associations like tags
    end

    it {should have_one(:security_question)}
    it {should have_many(:user_logs)}

    it {should allow_value(nil, '3434343434').for(:phone_number)}
    it {should validate_length_of(:phone_number_length)}
    it {should allow_value(nil, 'd@g.com').for(:email)}
    it {should validate_presence_of(:password)}
    it {should have_secure_password(:password)}
    it {should validate_length_of(:password).is_at_least(6).on(:save)}
    it {should_not validate_presence_of(:staff_roles)}
    it {should_not validate_presence_of(:customer_roles)}

    it "is invalid without required attributes" do
      expect(User.new).not_to be_valid
    end

    it "is valid with required attributes" do
      user = User.new(
        phone_number: '+16175806322',
        password: '111111',
        customer_roles: ['employee'],
      )
      expect(user).to be_valid
    end

    it "is invalid without password" do
      user = User.new(
        phone_number: '+16175806322',
        password: '',
        customer_roles: ['employee'],
      )
      expect(user).not_to be_valid
    end

    it "is valid without user roles" do
      user = User.new(
        phone_number: '+16175806322',
        password: '111111',
        customer_roles: [],
      )
      expect(user).not_to be_valid
    end

    it "security question association should be available after user creation" do
      user = User.create(
        phone_number: '+16175806322',
        password: '111111',
        staff_roles: ['admin'],
      )
      expect(user.security_question).not_to be(nil)
    end

    it "security question attribute should nil after user creation" do
      user = User.create(
        phone_number: '+16175806322',
        password: '111111',
        staff_roles: ['admin'],
      )
      expect(user.security_question).not_to eq(nil)
    end

    it "No user with the same phone_number or email address" do
      user = User.create(
        phone_number: '+16175806322',
        password: '111111',
        staff_roles: ['admin'],
      )
      user2 = User.create(
        phone_number: '+16175806322',
        password: '111111',
        customer_roles: ['business-api'],
      )
      expect(user2).not_to be_valid
    end

    it "user creation should be valid" do
      user = User.create(
        phone_number: '16175806322',
        password: '111111',
        staff_roles: ['admin'],
      )
      expect(user.is_on_waitlist).to be_truthy
      expect(user.is_user_active).to be_truthy
      expect(user.is_user_locked).to be_falsey
      expect(user.is_user_verified).to be_falsey
      expect(user.phone_number).to include('+')
      expect(user.login_count).to be > 0
      expect(user.verification_expiration).to be_truthy
    end


  end
end
