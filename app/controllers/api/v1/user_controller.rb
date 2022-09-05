class Api::V1::UserController < ApplicationController
  before_action :authorized, except: [:user_registration, :user_login, :reset_user_password, :verify_user_with_id]
  include Api::V1::UserHelper

  def current_user
    puts "---"
    puts "--- #{request.headers.inspect}"
    respond_to do |format|
      format.json {render status: :ok}
    end
  end

  def user_registration
    # Registering user user method
    # POST ~> '/api/v1/registration-login'
    # @param [http params ~> {:phone_number or :email, :password, :repeat_password, :roles}]
    # @return [json data]
    puts "--- #{request.headers.inspect}"
    respond_to do |format|
      begin
        user = User.new(user_params)
        user.last_login_ip = request.ip
        raise 'Email address is invalid. Please update your email address.' if !is_email_valid(params[:email]) if Rails.env.production?
        if user.save && user.valid?
          token = encode_token({user_id: user.id}) # Encode user_id
          response.headers["Authorization"] = "Bearer #{token}" # Add token to response
          @user = user
          format.json {render status: :ok}
        else
          puts user.errors.inspect
          format.json {
            render status: :unprocessable_entity,
            json: error_response_messages(user.errors.messages)
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def user_login
    # Loging in user user method
    # POST ~> '/api/v1/user-login'
    # @param [http params ~> {:phone_number or :email or :username, :password}]
    # @return [json data]
    respond_to do |format|
      # begin
        user = User.find_by_email(params[:email]) if params[:email].present?
        user ||= User.find_by_username(params[:username]) if params[:username].present?
        raise 'User with provided logins does not exist.' if user.nil?
        raise "User is locked." if user.is_user_locked
        is_user_authenticated = user.authenticate(user_params[:password])
        token = encode_token({user_id: user.id}) # Encode user_id
        user.update(
          last_login_ip: request.ip,
          valid_token: token.split('.')[2],
          password_failed_attempts: 0
        )
        @user = user
        # response.headers["X-Auth-Token"] = token # Add token to response
        response.headers["Authorization"] = "Bearer #{token}"
        format.json {render status: :ok}
      # rescue => exception
      #   puts "=+++ #{exception.inspect}"
      #   format.json {
      #     render status: :unprocessable_entity,
      #     json: error_response_messages({error: [exception.message]})
      #   }
      # end
    end
  end

  def logout_user
    # Loging out user
    # DELETE ~> '/api/v1/logout'
    # @param [http params ~> <Bearer 'token'>]
    # @return [response status]
    respond_to do |format|
      begin
        raise 'Failed to logout' if @user.nil?
        if @user && @user.update(valid_token: '')
          log_action(action_by: @user.id, action_on: @user.id, description: 'User logout.', action: 'logout_user', action_controller: 'User')
          format.json {
            render status: :ok,
            json: success_response_messages({success: ["User Logged out successfully."]})
          }
        else
          format.json {
            render status: :unprocessable_entity,
            json: error_response_messages({error: ["User not logged out."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def verify_user_with_id
    # Verify user after registration. Verification link with ID is sent to the email user address
    # GET ~> '/api/v1/verify-user-with-id/:verification_id'
    # @param [http params ~> {:verification_id}]
    # @return [response status]
    respond_to do |format|
      begin
        puts params[:verification_id]
        user = User.find_by(verification_id: params[:verification_id])
        raise 'Verification ID is either invalid or User has already been verified.' if user.nil?
        format.json {
          render status: :ok,
          json: success_response_messages({success: ["User already verified."]})
        } if user.is_user_verified
        if user && user.update(
            verification_id: nil,
            verification_expiration: nil,
            verification_sent_to: [],
            is_user_verified: true,
            verification_otp: ""
          )
          log_action(action_by: user.id, action_on: user.id, description: 'Verified user with ID.', action: 'verify_user_with_id', action_controller: 'User')
          format.json {
            render status: :ok,
            json: success_response_messages({success: ["User verified successfully."]})
          }
        else
          format.json {
            render status: :unprocessable_entity,
            json: error_response_messages({error: ["User not verified. Please try again."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def verify_user_with_otp
    # Verify user after registration using the 6 digit short code sent to mobile phones.
    # POST ~> '/api/v1/verify-user-with-otp'
    # @param [http params ~> {:otp}]
    # @return [response status]
    respond_to do |format|
      begin
        raise 'OTP is missing.' if params[:otp].nil?
        puts @user.inspect
        raise 'User does not exist. Contact support team for help.' if @user.nil?
        format.json {
          render status: :ok,
          json: success_response_messages({success: ["OTP is either invalid or User has already been verified."]})
        } if @user.is_user_verified
        raise 'OTP has expired. Please contact support team.' if @user.verification_expiration < DateTime.now
        raise "OTP is invalid" if @user.verification_otp != params[:otp]
        if @user && @user.update(
            verification_id: nil,
            verification_expiration: nil,
            verification_sent_to: [],
            is_user_verified: true,
            verification_otp: ""
          )
          log_action(action_by: @user.id, action_on: @user.id, description: 'Verified user with OTP.', action: 'verify_user_with_otp', action_controller: 'User')
          format.json {
            render status: :ok,
            json: success_response_messages({success: ["User verified successfully."]})
          }
        else
          format.json {
            render status: :unprocessable_entity,
            json: error_response_messages({error: ["User not verified. Please try again."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def reset_user_password
    # Reseting user password
    # POST ~> '/api/v1/reset-user-password/:reset_password_id' # Get called to post answer to the security_question
    #   - @param [http params ~> {:reset_password_id, :security_answer, :password, :repeat_password}]
    #   - @return [response status]
    # GET ~> '/api/v1/reset-user-password/:reset_password_id' # This gets called to show the user their security_question
    #   - @param [http params ~> {:reset_password_id}]
    #   - @return [response security_question]
    # @param [http params]
    respond_to do |format|
      begin
        raise 'Security question, answer & password are required to reset password.' if user_params.empty?
        @user = User.find_by(reset_password_id: params[:reset_password_id])
        raise 'Reset password token does not exist. Contact support team for help.' if @user.nil?
        raise 'You do not have security question setup. Please contact support team for help.' if @user.security_question.nil?
        raise 'You do not have security question setup. Please contact support team for help.' if @user.security_question.security_question.nil?
        raise 'You do not have security answer setup. Please contact support team for help.' if @user.security_question.security_answer.nil?
        @security_question = @user.security_question
        if request.get? # will return with @security_question.security_question
          format.json {render status: :ok}
        else
          raise 'Password is missing' if params[:password].nil?
          raise 'Password does not match' if params[:password] != params[:repeat_password]
          raise 'Security answer invalid.' if @security_question.security_answer.downcase != params[:security_answer].downcase
          # is_user_authenticated = @user.authenticate(user_params[:password])
          @user.password = user_params[:password]
          if @user.valid? && @user.update(
              reset_password_id: nil,
              reset_password_expiration: nil,
              is_user_locked: false,
              password_failed_attempts: 0,
              user_locked_on: nil
            )
            # TODO: Create email templates for each case of the anticipated communication
            log_action(action_by: @user.id, action_on: @user.id, description: 'Reseting user password after user has been locked.', action: 'reset_user_password', action_controller: 'User')
            send_user_messages(user: @user, message: "Your user password has been reset successfuly.")
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User password reset successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["Password not reset"]})
            }
          end
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def update_user
    # Update user. Only staff and user owner can update user
    # PATCH ~> '/api/v1/update-user/:user_id'
    # @param [http params ~> {:user_id} or <Bearer 'token'>]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          raise 'Phone number is invalid. Please update your phone number.' if !is_phone_number_valid(format_phone_number(params[:phone_number])) if !params[:phone_number].nil?
          raise 'Email address is invalid. Please update your email address.' if !is_email_valid(params[:email]) if !params[:email].nil?
          if user.update(permit_attrs_staff_can_only_change)
            log_action(action_by: @user.id, action_on: user.id, description: 'Staff Updating user"s user.', action: 'update_user', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User updated successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not updated."]})
            }
          end
        else
          if @user.update(permit_attrs_customer_can_only_change)
            log_action(action_by: @user.id, action_on: @user.id, description: 'Updating owners user.', action: 'update_user', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User updated successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not updated."]})
            }
          end
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def reset_verification
    # Deactive user. User wont be able to access user. Only staff can deactive user
    # POST ~> '/api/v1/reset-verification/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          verification_id = SecureRandom.uuid
          verification_otp = SecureRandom.random_number(999999)
          '10101' + SecureRandom.random_number(9).to_s if verification_otp.to_s.length < 6
          if user.update(
              verification_id: verification_id,
              verification_otp: verification_otp,
              verification_expiration: User.set_verification_expiration,
              is_user_verified: false,
              valid_token: ""
            )
            log_action(action_by: @user.id, action_on: user.id, description: "Staff resetting user's user verification.", action: 'reset_verification', action_controller: 'User')
            send_user_messages(user: @user, message: "Verify your user with OTP: #{user.verification_otp}.")
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["Verification reset successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["Verification not reset"]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def deactivate_user
    # Deactive user. User wont be able to access user. Only staff can deactive user
    # POST ~> '/api/v1/deactivate-user/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          if user.update(is_user_active: false)
            log_action(action_by: @user.id, action_on: user.id, description: "Staff de-activating user's user.", action: 'deactivate_user', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User deactivated successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not deactivated."]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def activate_user
    # Deactive user. User wont be able to access user. Only staff can deactive user
    # POST ~> '/api/v1/activate-user/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          if user.update(is_user_active: true)
            log_action(action_by: @user.id, action_on: user.id, description: "Staff activating user's user.", action: 'activate_user', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User activated successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not activated."]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def remove_from_waitlist
    # Remove user from waitlist. Removing user user from waitlist.
    # POST ~> '/api/v1/remove-from-waitlist/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          if user.update(is_on_waitlist: false)
            log_action(action_by: @user.id, action_on: user.id, description: "Staff removing user user from waitlist.", action: 'remove_from_waitlist', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User removed from waitlist successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not removed from waitlist."]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def add_to_waitlist
    # Add user to waitlist. Adding user user to waitlist.
    # POST ~> '/api/v1/add-to-waitlist/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          if user.update(is_on_waitlist: true)
            log_action(action_by: @user.id, action_on: user.id, description: "Staff adding user user to waitlist.", action: 'add_to_waitlist', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User added to waitlist successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not added to waitlist."]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def lock_user
    # Unlock user. User user will be locked.
    # POST ~> '/api/v1/lock-user/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          if user.update(
              is_user_locked: true,
              user_locked_on: DateTime.now,
              remember_me: false,
              remember_me_expiration: nil,
              valid_token: ""
            )
            log_action(action_by: @user.id, action_on: user.id, description: "Staff locking user user.", action: 'lock_user', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User locked successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not locked."]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def unlock_user
    # Unlock user. Metod to unlock user. Only staff trigger this action.
    # POST ~> '/api/v1/unlock-user/:user_id'
    # @param [http params ~> {:user_id}]
    # @return [response status]
    respond_to do |format|
      begin
        if user_is_staff_admin
          user = User.find(params[:user_id]) rescue nil
          raise 'User does not exist' if user.nil?
          if user.update(
              is_user_locked: false,
              remember_me: false,
              remember_me_expiration: nil,
              valid_token: ""
            )
            log_action(action_by: @user.id, action_on: user.id, description: "Staff unlocking user user.", action: 'unlock_user', action_controller: 'User')
            format.json {
              render status: :ok,
              json: success_response_messages({success: ["User unlocked successfully."]})
            }
          else
            format.json {
              render status: :unprocessable_entity,
              json: error_response_messages({error: ["User not unlocked."]})
            }
          end
        else
          format.json {
            render status: :unauthorized,
            json: error_response_messages({error: ["Access denied."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def update_user_roles
    # Update user roles. Action to update all user roles.
    # POST ~> '/api/v1/update-user-roles/:user_id'
    # @param [http params ~> {:user_id, :roles}] # :role => 'business,employee,employer,...'
    # @return [response status]
    respond_to do |format|
      begin
        raise 'Roles is missing' if params[:roles].nil?
        user = User.find(params[:user_id]) if user_is_staff_admin
        user = @user if @user.is_customer
        raise 'User does not exist' if user.nil?
        user = set_user_roles(user, params[:roles])
        if user.update(user_params.except(params[:roles]))
          log_action(action_by: @user.id, action_on: user.id, description: "Staff updating user user roles.", action: 'update_user_roles', action_controller: 'User')
          format.json {
            render status: :ok,
            json: success_response_messages({success: ["User updated roles successfully."]})
          }
        else
          format.json {
            render status: :unauthorized,
            json: success_response_messages({success: ["User roles not updated."]})
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def register_new_staff_user
    # Register new staff. Action for staff to create new staff.
    # POST ~> '/api/v1/register-new-staff-user'
    # @param [http params ~> <Bearer token>]
    # @return [response status]
    respond_to do |format|
      begin
        puts "++++ -----"
        raise 'Phone_number or email and password are required.' if user_params.empty?
        raise 'Access denied' if @user.nil?
        raise 'Access denied' if !@user.is_staff
        raise 'Phone number is invalid. Please update your phone number.' if !is_phone_number_valid(format_phone_number(params[:phone_number])) if !params[:phone_number].nil?
        raise 'Email address is invalid. Please update your email address.' if !is_email_valid(params[:email]) if !params[:email].nil?
        raise 'User roles missing.' if params[:roles].nil?
        user = User.new(permit_attrs_staff_can_only_change)
        user.verification_id = SecureRandom.uuid
        user.verification_otp = SecureRandom.random_number(999999)
        user.verification_otp = '10101' + SecureRandom.random_number(9).to_s if user.verification_otp.length < 6
        user.password = SecureRandom.hex(3)
        user = set_staff_roles(user, params[:roles]) # located in user_helper.rb
        puts "++++ #{user.inspect}"
        if user.save && user.valid?
          log_action(action_by: @user.id, action_on: user.id, description: "Staff registering new staff user.", action: 'register_new_staff_user', action_controller: 'User')
          send_user_messages(user: user, message: "Hello Zofi Cash Staff, Your OTP: #{user.verification_otp}. Temporary Password: #{user.password}. Reset your password.")
          format.json {
            render status: :ok,
            json: success_response_messages({success: ["Staff user registered successfully."]})
          }
        else
          format.json {
            render status: :unprocessable_entity,
            json: error_response_messages(user.errors.messages)
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  def register_new_customer_user
    # Register new customer. Action for staff to create new customer.
    # POST ~> '/api/v1/register-new-staff-user'
    # @param [http params ~> <Bearer token>]
    # @return [response status]
    respond_to do |format|
      begin
        raise 'Phone_number or email and password are required.' if user_params.empty?
        raise 'Access denied' if @user.nil?
        raise 'Access denied' if !user_is_staff_admin
        raise 'User roles missing.' if params[:roles].nil?
        raise 'Phone number is invalid. Please update your phone number.' if !is_phone_number_valid(format_phone_number(params[:phone_number])) if !params[:phone_number].nil?
        raise 'Email address is invalid. Please update your email address.' if !is_email_valid(params[:email]) if !params[:email].nil?
        user = User.new(permit_attrs_customer_can_only_change)
        user.verification_id = SecureRandom.uuid
        user.verification_otp = SecureRandom.random_number(999999)
        user.verification_otp = '10101' + SecureRandom.random_number(9).to_s if user.verification_otp.length < 6
        user.password = SecureRandom.hex(3)
        user = set_customer_roles(user, params[:roles]) # located in user_helper.rb
        if user.save && user.valid?
          log_action(action_by: @user.id, action_on: user.id, description: "Staff registering new customer user.", action: 'register_new_staff_user', action_controller: 'User')
          send_user_messages(user: user, message: "Welcome to Zofi Cash, Your OTP is: #{user.verification_otp}. Password is: #{user.password}. Reset your password.")
          format.json {
            render status: :ok,
            json: success_response_messages({success: ["Customer user registered successfully."]})
          }
        else
          format.json {
            render status: :unprocessable_entity,
            json: error_response_messages(user.errors.messages)
          }
        end
      rescue => exception
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [exception.message]})
        }
      end
    end
  end

  private
  def update_user_on_failed_login_attempts(user)
    # Updates when ever the login password has failed
    # @param [Object User]
    # @return [integer reached_max_attepts]
    reached_max_attepts = ((user.max_password_failed_attempts - 1) == user.password_failed_attempts)
    user.update(
      password_failed_attempts: user.password_failed_attempts += 1,
      is_user_locked: reached_max_attepts ? true : false,
      user_locked_on: reached_max_attepts ? DateTime.now : nil,
      reset_password_id: reached_max_attepts ? SecureRandom.uuid : nil,
      reset_password_expiration: reached_max_attepts ? DateTime.now : nil,
      remember_me: false,
      remember_me_expiration: nil,
      valid_token: ""
    )
    return reached_max_attepts
  end

  def permit_attrs_customer_can_only_change
    # Returns attributes a user can change about their user.
    user_params.except(:password,:valid_token,:reset_password_id,:verification_id,:password_failed_attempts,:is_user_verified,:user_locked_on,:verification_otp,:user_roles,:is_on_waitlist,:is_user_active,:is_superuser,:is_staff,:last_login_ip,:logged_in_ips,:login_count)
  end

  def permit_attrs_staff_can_only_change
    # Returns attributes a staff can change about the a users user.
    user_params.except(:password,:valid_token,:reset_password_id,:verification_id,:password_failed_attempts,:user_locked_on,:last_login_ip,:logged_in_ips,:verification_expiration,:verification_otp,:reset_password_id,:reset_password_expiration)
  end

  def user_params
    params.permit(
      :username,
      :email,
      :phone_number,
      :password,
      :last_login_at,
      :last_login_ip,
      :logged_in_ips,
      :is_user_active,
      :valid_token,
      :is_superuser,
      :is_staff,
      :is_customer,
      :staff_roles,
      :customer_roles,
      :verification_id,
      :verification_expiration,
      :verification_sent_to,
      :is_user_verified,
      :verification_otp,
      :reset_password_id,
      :reset_password_expiration,
      :remember_me,
      :remember_me_expiration,
      :max_password_failed_attempts,
      :password_failed_attempts,
      :is_user_locked,
      :user_locked_on,
      :is_on_waitlist,
    )
  end
end

# Your user has been locked because of several failed login attempts.
