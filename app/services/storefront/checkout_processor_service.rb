module Storefront
  class CheckoutProcessorService
    class InvalidParamsError < StandardError; end

    attr_reader :errors, :order

    def initialize(params)
      @params = params
      @order = nil
      @errors = {}
    end
      
    def call
      check_presence_of_items_param
      check_emptyness_of_items_param
      validate_coupon
      do_checkout
      raise InvalidParamsError if @errors.present?
    end

    private

    def check_presence_of_items_param
      unless @params.has_key?(:items)
        @errors[:items] = I18n.t('storefront/checkout_processor_service.errors.items.presence')
      end
    end

    def check_emptyness_of_items_param
      if @params[:items].blank?
        @errors[:items] = I18n.t('storefront/checkout_processor_service.errors.items.empty')
      end
    end
    
    def validate_coupon
      return unless @params.has_key?(:coupon_id)
      @coupon = Coupon.find(@params[:coupon_id])
      @coupon.validate_use!
    rescue Coupon::InvalidUse, ActiveRecord::RecordNotFound
      @errors[:coupon] = I18n.t('storefront/checkout_processor_service.errors.coupon.invalid') 
    end

    def do_checkout
      create_order
    rescue ActiveRecord::RecordInvalid => e
      @errors.merge! e.record.errors.messages
      @errors.merge!(address: e.record.address.errors.messages) if e.record.errors.has_key?(:address)
    end

    def create_order
      Order.transaction do
        @order = instantiate_order
        line_items = @params[:items].map { |line_item_params| instantiate_line_items(line_item_params) }
        save!(line_items)
      end
    rescue ArgumentError => e
      @errors[:base] = e.message
    end
    
    def instantiate_order
      order_params = @params.slice(:document, :payment_type, :installments, :card_hash, :coupon_id, :user_id)
      order = Order.new(order_params)
      order.address = Address.new(@params[:address])
      order
    end

    def instantiate_line_items(line_item_params)
      line_item = @order.line_items.build(line_item_params)
      line_item.payed_price = line_item.product.price if line_item.product.present?
      line_item.validate!
      line_item
    end
    
    def save!(line_items)
      @order.subtotal = line_items.sum(&:total).floor(2)
      @order.total_amount = (@order.subtotal * (1 - @coupon.discount_value / 100)).floor(2) if @coupon.present?
      @order.total_amount ||= @order.subtotal
      @order.save!
      line_items.each(&:save!)
    end
  end
end