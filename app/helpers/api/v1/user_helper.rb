module Api::V1::UserHelper
  def is_email_valid(email)
    # Verifying email. Checking to see the deliverability of the email addresss.
    # @param [email [String]]
    # @return [boolean]
    return true if Rails.env.test?
    uri = URI("https://emailvalidation.abstractapi.com/v1/?api_key=d4ead8c4bedb4db793fd1fae6fb39aa3&email=#{email}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request =  Net::HTTP::Get.new(uri)
    response = http.request(request)
    puts "Status code: #{response.code}"
    puts "Response body: #{response.body}"
    JSON.parse(response.body)['deliverability'].downcase == 'DELIVERABLE'.downcase ? true : false
  rescue StandardError => error
    puts "Error (#{error.message})"
    false
  end
end
