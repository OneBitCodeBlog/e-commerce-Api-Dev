class CpfCnpjValidator < ActiveModel::EachValidator
  DENY_LIST = %w[ 
    00000000000 11111111111 22222222222 33333333333 44444444444 55555555555 66666666666
    77777777777 88888888888 99999999999 12345678909 01234567890 00000000000000 11111111111111
    22222222222222 33333333333333 44444444444444 55555555555555 66666666666666 77777777777777
    88888888888888 99999999999999
  ].freeze

  CPF_SIZE = 11
  CNPJ_SIZE = 14

  def validate_each(record, attribute, value)
    return unless value.present?
    elements = value.gsub(/[^\d]/, '').chars.map(&:to_i)
    if DENY_LIST.include?(value) || (!is_valid_cpf?(elements) && !is_valid_cnpj?(elements))
      record.errors.add(attribute, :invalid_cpf_cnpj)
    end
  end

  private

  def is_valid_cpf?(elements)
    return false if elements.size != CPF_SIZE
    validate_first_cpf_verifier(elements) && validate_second_cpf_verifier(elements)
  end

  def is_valid_cnpj?(elements)
    return false if elements.size != CNPJ_SIZE
    elements.reverse!
    validate_first_cnpj_verifier(elements) && validate_second_cnpj_verifier(elements)
  end

  def validate_first_cpf_verifier(elements)
    multiplied = elements[0...9].map.with_index { |number, index| number * (10 - index) }
    mod = multiplied.sum % 11
    expected_digit = mod < 2 ? 0 : (11 - mod)
    expected_digit == elements[9]
  end

  def validate_second_cpf_verifier(elements)
    multiplied = elements[0...10].map.with_index { |number, index| number * (11 - index) }
    mod = multiplied.sum % 11
    expected_digit = mod < 2 ? 0 : (11 - mod)
    expected_digit == elements[10]
  end

  def validate_first_cnpj_verifier(elements)
    multiplied = elements[2...10].map.with_index { |number, index| number * (index + 2) }
    multiplied = multiplied + elements[10..-1].map.with_index { |number, index| number * (index + 2) }
    mod = multiplied.sum % 11
    expected_digit = mod < 2 ? 0 : (11 - mod)
    expected_digit == elements[1]
  end

  def validate_second_cnpj_verifier(elements)
    multiplied = elements[1...9].map.with_index { |number, index| number * (index + 2) }
    multiplied = multiplied + elements[9..-1].map.with_index { |number, index| number * (index + 2) }
    mod = multiplied.sum % 11
    expected_digit = mod < 2 ? 0 : (11 - mod)
    expected_digit == elements[0]
  end
end