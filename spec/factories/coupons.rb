FactoryBot.define do
  factory :coupon do
    sequence(:name) { |n| "My Coupon #{n}" }
    code { Faker::Commerce.unique.promotion_code(digits: 4) }
    status { :active }
    discount_value { 25 }
    max_use { 1 }
    due_date { 3.days.from_now }
  end
end
