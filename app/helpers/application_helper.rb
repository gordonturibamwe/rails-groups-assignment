module ApplicationHelper
  ###################
  # JWT ACCOUNT AUTHENTICATION
  def encode_token(payload) # encode token
    # Encoding user_id and expiration dates into an encrypted token
    # @param [Hash payload]
    # @return [String token]
    payload[:exp] = 7.days.from_now.to_i # expiration date
    JWT.encode(payload, Rails.env.production? ? ENV['JWT_SECRETE'] : '$2a$12$sMzX7Un5PdLxA7OiyBw1IeMAxiDKP5kqR4cTBXd2ifNNzR38y6IH.')
  end

  def auth_header # {Authorization: 'Bearer <token>'}
    # Auth headers.
    # @param [Headers [Authorization: 'Bearer <token>']]
    # @return [String 'Bearer <token>']
    request.headers['Authorization']
  end

  def decoded_token
    # Auth headers.
    # @param [String 'Bearer <token>']]
    # @return [Array({"user_id"=>"898c4fbf-a8a9-42a3-b835-08fb44a1056e", "exp"=>1659183189}, {"alg"=>"HS256"})]
    if auth_header
      begin
        token = auth_header.split(' ')[1] # header: {'Authorization': 'Bearer <token>'}
        JWT.decode(
          token,
          Rails.env.production? ? ENV['JWT_SECRETE'] : '$2a$12$sMzX7Un5PdLxA7OiyBw1IeMAxiDKP5kqR4cTBXd2ifNNzR38y6IH.',
          true,
          algorithm: 'HS256'
        )
      rescue JWT::DecodeError
        nil
      end
    end
  end
  ###################
end
