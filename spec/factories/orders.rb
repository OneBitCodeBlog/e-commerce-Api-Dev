FactoryBot.define do
  factory :order do
    status { :processing_order }
    subtotal { Faker::Commerce.price(range: 200.00..400.00) }
    total_amount { subtotal }
    payment_type { :credit_card }
    card_hash { Faker::Lorem.characters }
    installments { 5 }
    address { build(:address) }
    document { "03.000.050/0001-67" }
    user

    trait :with_items do
      after :build do |order|
        items = create_list(:line_items, 5, order: order)
        order.subtotal = items.sum(:payed_price)
        order.total_amount = order.subtotal
      end
    end

    trait :with_coupon do
      after :build do |order|
        coupon = create(:coupon, discount_value: 10)
        order.total_amout = order.subtotal * (1 - coupon.discount_value / 100)
      end
    end
  end
end