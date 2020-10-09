FactoryBot.define do
  factory :product do
    name { Faker::Game.unique.title }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 100.0..400.0) }
    
    after :build do |product|
      product.productable = create(:game)
    end
  end
end
