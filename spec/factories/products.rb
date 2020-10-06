FactoryBot.define do
  factory :product do
    name { Faker::Game.title }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 100.0..400.0) }
  end
end
