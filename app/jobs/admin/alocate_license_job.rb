module Admin  
  class AlocateLicenseJob < ApplicationJob
    queue_as :default

    def perform(line_item)
      AlocateLicensesService.new(line_item).call
    end
  end
end