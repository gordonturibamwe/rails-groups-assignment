class WelcomeController < ApplicationController
  include Api::V1::UserHelper
  before_action :authorized, except: [:welcome, :custom_domain, :custom_domain_about]

  def welcome
    respond_to do |format|
      format.html {}
      format.json {
        render status: :ok,
        json: success_response_messages({error: ["Welcome to Groups."]})
      }
    end
  end
end

    # validate_phone_number('+16175806317')
    # validate_email('g@ggg.com')
      # UserMailer.with(user: @user, message: message).custom_email
      # UserMailer.with(order: @order).new_order_email.deliver_later
      # puts "--- #{request.inspect} #{request.referrer}"
      # mailer = UserMailer.with(user: User.first, message: "I am astonished by your service delivery. Thank you.").welcome_email.deliver_now
      # puts mailer.inspect
