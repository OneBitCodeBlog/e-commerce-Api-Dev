FactoryBot.define do
  factory :game do
    mode { %i(pvp pve both).sample }
    release_date { 5.days.ago }
    developer { Faker::Company.name }
    system_requirement
  end
end
