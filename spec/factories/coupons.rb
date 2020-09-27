FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    status { 1 }
    max_use { 1 }
    due_date { "2020-09-27 16:25:09" }
  end
end
