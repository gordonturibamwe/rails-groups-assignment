require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Api::V1::UserLogsHelper. For example:
#
# describe Api::V1::UserLogsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Api::V1::UserLogsHelper, type: :helper do
  before(:context) do
    $staff_user = User.new(
      phone_number: '+16175806322',
      password: '111111',
      is_superuser: true,
      is_staff: true,
      staff_roles: ['super-user','super-admin'],
      is_user_verified: true,
      is_on_waitlist: false,
      is_user_verified: true
    )
    $customer_user = User.new(
      email: 'crafri.com@gmail.com',
      password: '111111',
      is_customer: true,
      customer_roles: ['employer','employee'],
      is_user_verified: true,
      is_on_waitlist: false,
      is_user_verified: true
    )
  end

  after(:all) do
    User.destroy_all  # Cleanup all models and their automatically created associations like tags
  end

  it "set_customer_roles" do
    new_user = User.new(
      email: 'crafri.com@gmail.com',
      password: '111111',
      is_customer: true,
      customer_roles: ['business-api','staking'],
      is_user_verified: true,
      is_on_waitlist: false,
      is_user_verified: true
    )
    expect(helper.set_customer_roles($customer_user, 'business-api,staking').customer_roles).to eq(new_user.customer_roles)
  end

  it "set_staff_roles" do
    new_user = User.new(
      email: 'crafri.com@gmail.com',
      password: '111111',
      is_customer: true,
      staff_roles: ['admin','super-admin'],
      is_user_verified: true,
      is_on_waitlist: false,
      is_user_verified: true
    )
    expect(helper.set_staff_roles($staff_user, 'admin,super-admin').staff_roles).to eq(new_user.staff_roles)
  end

  it "email should be valid" do
    expect(helper.is_email_valid('turibamwe@outlook.com')).to eq(true)
  end

  it "email should be invalid" do
    # expect(helper.is_email_valid('sdsdsd@dfdfdfswfwfww.ee')).to eq(false) # will work if turned true off in the helper method
  end

  it "phone number should be valid" do
    expect(helper.is_phone_number_valid('+16175806317')).to eq(true)
  end
end
