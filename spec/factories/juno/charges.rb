FactoryBot.define do
  factory :juno_charge, class: 'Juno::Charge' do
    key { "chr_#{Faker::Lorem.characters(number: 20) }" }
    code { Faker::Number.number(digits: 20) }
    sequence(:number) { |n| n }
    amount { Faker::Commerce.price(range: 40..100) }
    status { "ACTIVE" }
    billet_url { Faker::Internet.url(host: 'pay.juno.com') }
    order
  end
end