module Admin
  class AlocateLicensesService
    def initialize(line_item)
      @line_item = line_item
    end

    def call
      licenses = @line_item.product.productable.licenses.where(status: :available).take(@line_item.quantity)
      License.transaction { update_licenses(licenses) }
      send_licenses
      @line_item.update!(status: :delivered)
    end

    private

    def update_licenses(licenses)
      licenses.map { |license| license.attributes = { status: :in_use, line_item: @line_item } }
      licenses.each { |license| license.save! }
    end

    def send_licenses
      @line_item.licenses.each do |license|
        LicenseMailer.with(license: license).send_license.deliver_later
      end
    end
  end
end