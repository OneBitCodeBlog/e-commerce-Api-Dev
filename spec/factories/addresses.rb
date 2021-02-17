FactoryBot.define do
  factory :address do
    street { Faker::Address.street_name }
    number { Faker::Address.building_number }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    post_code { Faker::Address.postcode }

    skip_create
    initialize_with { new(**attributes) }
  end
end
