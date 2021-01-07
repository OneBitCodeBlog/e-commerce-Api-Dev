require "rails_helper"

describe Admin::ModelLoadingService do
  context "when #call" do
    let!(:system_requirements) { create_list(:system_requirement, 15) }
    
    context "when params are present" do
      let!(:search_system_requirements) do
        system_requirements = []
        15.times do |n| 
          system_requirements << create(:system_requirement, name: "Search #{n + 1}", video_board: "GeForce")
        end
        system_requirements
      end

      let!(:unexpected_system_requirements) do
        system_requirements = []
        15.times do |n| 
          system_requirements << create(:system_requirement, name: "Search #{n + 16}")
        end
        system_requirements
      end

      let(:params) do
        { search: { name: "Search", video_board: "GeFor" }, order: { name: :desc }, page: 2, length: 4 }
      end

      it "performs right :length following pagination" do
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.records.count).to eq 4
      end

      it "do right search, order and pagination" do
        search_system_requirements.sort! { |a, b| b[:name] <=> a[:name] }
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expected_system_requirements = search_system_requirements[4..7]
        expect(service.records).to contain_exactly *expected_system_requirements
      end

      it "sets right :page" do
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.pagination[:page]).to eq 2
      end

      it "sets right :length" do
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.pagination[:length]).to eq 4
      end

      it "sets right :total" do
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.pagination[:total_pages]).to eq 4
      end

      it "does not return unenexpected records" do
        params.merge!(page: 1, length: 50)
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.records).to_not include *unexpected_system_requirements
      end
    end

    context "when params are not present" do
      it "returns default :length pagination" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.records.count).to eq 10
      end

      it "returns first 10 records" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expected_system_requirements = system_requirements[0..9]
        expect(service.records).to contain_exactly *expected_system_requirements
      end

      it "sets right :page" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:page]).to eq 1
      end

      it "sets right :length" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:length]).to eq 10
      end

      it "sets right :total" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "sets right :total_pages" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:total_pages]).to eq 2
      end
    end
  end
end