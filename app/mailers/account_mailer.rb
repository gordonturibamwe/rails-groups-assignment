class UserMailer < ApplicationMailer
  default from: 'no-reply@zoficash.com'

  def welcome_email
    # @user = params[:user]
    # @url  = 'http://example.com/login'
    # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    mail(to: "turibamwegordon@gmail.com", subject: "Welcome to Zofi Cash.")
    # mail(to: "Paul Kirungi <pkirungi2012@gmail.com>", subject: "Finally working. Zofi Cash Notice")
    # mail(to: 'pkirungi@zoficash.com', subject: 'Zofi Cash Notice')
    # mail(to: 'gturibamwe@zoficash.com', subject: 'Zofi Cash Notice')
  end

  def custom_email
    # @user = params[:user]
    # @url  = 'http://example.com/login'
    # @message = params[:message]
    # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    mail(to: 'turibamwegordon@gmail.com', subject: 'Zofi Cash Notice')
    mail(to: 'pkirungi2012@gmail.com', subject: 'Zofi Cash Notice')
    mail(to: 'pkirungi@zoficash.com', subject: 'Zofi Cash Notice')
    mail(to: 'gturibamwe@zoficash.com', subject: 'Zofi Cash Notice')
  end
end
