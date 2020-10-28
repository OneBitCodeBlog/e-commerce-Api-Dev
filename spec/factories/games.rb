FactoryBot.define do
  factory :game do
    mode { %i(pvp pve both).sample }
    release_date { '2020-06-01' }
    developer { Faker::Company.name }
    system_requirement
  end
end
