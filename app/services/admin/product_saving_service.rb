module Admin  
  class ProductSavingService
    class NotSavedProductError < StandardError; end

    attr_reader :product, :errors

    def initialize(params, product = nil)
      @params = params.deep_symbolize_keys
      @errors = {}
      @product = product
      @product ||= Product.new
    end

    def call
      Product.transaction do
        @product.attributes = filter_from_params(@product.attribute_names)
        build_productable
      ensure
        save!
      end
    end

    def filter_from_params(attributes)
      attributes = attributes.map(&:to_sym)
      @params.select do |key, _|
        attributes.include?(key)
      end
    end
    
    def build_productable
      @product.productable ||= @params[:productable].camelcase.safe_constantize.new
      @product.productable.attributes = filter_from_params(@product.productable.attribute_names)
    end

    def save!
      save_record!(@product.productable) if @product.productable.present?
      save_record!(@product)
      raise NotSavedProductError if @errors.present?
    rescue => e
      raise NotSavedProductError
    end

    def save_record!(record)
      record.save!
    rescue ActiveRecord::RecordInvalid
      @errors.merge!(record.errors.messages)
    end
  end
end