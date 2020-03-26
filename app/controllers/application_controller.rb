class ApplicationController < ActionController::API
  def ping
    render json: { success: true }
  end
end
