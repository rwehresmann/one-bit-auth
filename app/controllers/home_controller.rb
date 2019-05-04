class HomeController < ApplicationController
  before_action :authenticate_user

  def index
    render json: "User #{current_user.email} is logged in."
  end
end