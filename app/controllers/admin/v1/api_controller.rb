module Admin::V1
  class ApiController < ApplicationController
    class ForbiddenAccess < StandardError; end

    include Authenticatable

    rescue_from ForbiddenAccess do 
      render_error(message: "Forbidden access", status: :forbidden)
    end

    before_action :restrict_access_for_admin!

    def render_error(message: nil, fields: nil, status: :unprocessable_entity)
      errors = {}
      errors['fields'] = fields if fields.present?
      errors['message'] = message if message.present?
      render json: { errors: errors }, status: status
    end

    private

    def restrict_access_for_admin!
      raise ForbiddenAccess unless current_user.admin?
    end
  end
end