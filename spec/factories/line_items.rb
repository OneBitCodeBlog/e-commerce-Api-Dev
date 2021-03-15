FactoryBot.define do
  factory :line_item do
    quantity { 1 }
    payed_price { Faker::Commerce.price(range: 100.00..200.00) }
    status { :waiting_order }
    order
    product
  end
end
