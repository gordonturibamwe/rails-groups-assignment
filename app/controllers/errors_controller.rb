class ErrorsController < ApplicationController
  before_action :authorized, except: [:error_404]
  
  def error_404
    respond_to do |format|
      format.json {
        render status: :bad_request, 
        json: error_response_messages({error: ["URL address with '#{request_method(request)}' method. Check your url address please."]})
      }
    end
  end

  def request_method(request)
    if request.get?
      'GET'
    elsif request.post?
      'POST'
    elsif request.put?
      'PUT'
    elsif request.patch?
      'PATCH'
    elsif request.delete?
      'DELETE'
    else
      'UNKOWN'
    end
  end
end
