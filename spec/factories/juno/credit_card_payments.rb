FactoryBot.define do
  factory :juno_credit_card_payment, class: 'Juno::CreditCardPayment' do
    key { "pay_#{Faker::Lorem.characters(number: 20) }" }
    release_date { 1.month.from_now }
    status { "CONFIRMED" }
    reason { nil }
    charge { association :juno_charge }
  end
end