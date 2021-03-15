require 'rails_helper'

RSpec.describe Game, type: :model do
  it { is_expected.to validate_presence_of(:mode) }
  it { is_expected.to define_enum_for(:mode).with_values({ pvp: 1, pve: 2, both: 3 }) }
  it { is_expected.to validate_presence_of(:release_date) }
  it { is_expected.to validate_presence_of(:developer) }
  
  it { is_expected.to belong_to :system_requirement }
  it { is_expected.to have_one :product }
  it { is_expected.to have_many :licenses }

  it_has_behavior_of "like searchable concern", :game, :developer

  it "#ship! must schedule job AlocateLicenseJob sending Line Item" do
    subject.product = create(:product)
    line_item = create(:line_item, product: subject.product)
    expect do
      subject.ship!(line_item)
    end.to have_enqueued_job(Admin::AlocateLicenseJob).with(line_item)
  end
end
