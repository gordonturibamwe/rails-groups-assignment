class ApplicationController < ActionController::API
  include ApplicationHelper
  include ActionController::MimeResponds
  include Api::V1::UserHelper
  before_action :authorized

  def error_response_messages(error_message)
    # Looping through error messages. Called when request has an error.
    # @param [hash]
    # @return [array]
    message = {errors: []}
    error_message.each do |key, value|
      message[:errors].push "#{value[0]}"
    end
    return message
  end

  def success_response_messages(successful_message)
    # Looping through success messages. Called when request has been successful.
    # @param [hash]
    # @return [array]
    message = {success: []}
    successful_message.each do |key, value|
      message[:success].push "#{value[0]}"
    end
    return message
  end

  def current_user?
    # checks if user is logged by decoding the Bearer token
    # @param [headers['Authorization']]
    # @return [User object]
    begin
      user_id = decoded_token[0]['user_id']
      puts "------ #{user_id}"
      @user = User.find_by(id: user_id)
    rescue Exception => exception
      nil
    end
  end

  private
  def check_valid_saved_token(user)
    # checks if header bearer token is the same as the user saved :valid_token
    # @param [Object User]
    # @return [Boolean]
    begin
      return false if user.is_user_locked
      auth_header.split(' ')[1].split('.')[2] == user.valid_token
    rescue Exception => exception
      false
    end
  end

  def authorized
    puts "---"
    puts "--- #{request.headers['Authorization'].inspect}"
    render json: {errors: ['Please login.']}, status: :unauthorized unless current_user?
  end
end
