FactoryBot.define do
  factory :order do
    status { :processing_order }
    subtotal { Faker::Commerce.price(range: 200.00..400.00) }
    total_amount { subtotal }
    payment_type { :credit_card }
    installments { 5 }
    user

    trait :with_coupon do
      after :build do |order|
        coupon = create(:coupon, discount_value: 10)
        order.total_amout = order.subtotal * (1 - coupon.discount_value / 100)
      end
    end
  end
end