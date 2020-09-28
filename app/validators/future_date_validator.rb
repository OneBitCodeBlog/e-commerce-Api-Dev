class FutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value <= Time.zone.now
      message = options[:message] || :future_date
      record.errors.add(attribute, message)
    end
  end
end