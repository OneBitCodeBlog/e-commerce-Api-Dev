require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:profile) }
  it { is_expected.to define_enum_for(:profile).with_values({ admin: 0, client: 1 }) }

  it_has_behavior_of "like searchable concern", :user, :name
  it_behaves_like "paginatable concern", :user
end