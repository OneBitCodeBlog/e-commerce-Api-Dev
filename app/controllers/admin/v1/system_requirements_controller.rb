module Admin::V1
  class SystemRequirementsController < ApiController
    before_action :load_system_requirement, only: [:show, :update, :destroy]

    def index
      permitted = params.permit({ search: :name }, { order: {} }, :page, :length)
      @loading_service = Admin::ModelLoadingService.new(SystemRequirement.all, permitted)
      @loading_service.call
    end

    def create
      @system_requirement = SystemRequirement.new
      @system_requirement.attributes = system_requirement_params
      save_system_requirement!
    end

    def show; end

    def update
      @system_requirement.attributes = system_requirement_params
      save_system_requirement!
    end

    def destroy
      @system_requirement.destroy!
    rescue
      render_error(fields: @system_requirement.errors.messages)
    end

    private

    def load_system_requirement
      @system_requirement = SystemRequirement.find(params[:id])
    end

    def system_requirement_params
      return {} unless params.has_key?(:system_requirement)
      params.require(:system_requirement).permit(:id, :name, :operational_system, :storage, 
                                                 :processor, :memory, :video_board)
    end

    def save_system_requirement!
      @system_requirement.save!
      render :show
    rescue
      render_error(fields: @system_requirement.errors.messages)
    end
  end
end
