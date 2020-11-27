require 'rails_helper'

RSpec.describe "Admin V1 System Requirements as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 10) }
    
    context "without any params" do
      it "returns 10 system_requirements" do
        get url, headers: auth_header(user)
        expect(body_json['system_requirements'].count).to eq 10
      end
      
      it "returns 10 first System Requirements" do
        get url, headers: auth_header(user)
        expected_system_requirements = system_requirements[0..9].as_json(
          only: %i(id name operational_system storage processor memory video_board)
        )
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "returns success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user) }
      end
    end

    context "with search[name] param" do
      let!(:search_name_system_requirements) do
        system_requirements = [] 
        15.times { |n| system_requirements << create(:system_requirement, name: "Search #{n + 1}") }
        system_requirements 
      end

      let(:search_params) { { search: { name: "Search" } } }

      it "returns only searched system_requirements limited by default pagination" do
        get url, headers: auth_header(user), params: search_params
        expected_system_requirements = search_name_system_requirements[0..9].map do |system_requirement|
          system_requirement.as_json(only: %i(id name operational_system storage processor memory video_board))
        end
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: search_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: search_params }
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: auth_header(user), params: pagination_params
        expect(body_json['system_requirements'].count).to eq length
      end
      
      it "returns system_requirements limited by pagination" do
        get url, headers: auth_header(user), params: pagination_params
        expected_system_requirements = system_requirements[5..9].as_json(
          only: %i(id name operational_system storage processor memory video_board)
        )
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: pagination_params }
      end
    end

    context "with order params" do
      let(:order_params) { { order: { name: 'desc' } } }

      it "returns ordered system_requirements limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        system_requirements.sort! { |a, b| b[:name] <=> a[:name]}
        expected_system_requirements = system_requirements[0..9].as_json(
          only: %i(id name operational_system storage processor memory video_board)
        )
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end
 
      it "returns success status" do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user), params: order_params }
      end
    end
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    
    context "with valid params" do
      let(:system_requirement_params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

      it 'adds a new SystemRequirement' do
        expect do
          post url, headers: auth_header(user), params: system_requirement_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it 'returns last added SystemRequirement' do
        post url, headers: auth_header(user), params: system_requirement_params
        expected_system_requirement = SystemRequirement.last.as_json(
          only: %i(id name operational_system storage processor memory video_board)
        )
        expect(body_json['system_requirement']).to eq expected_system_requirement
      end

      it 'returns success status' do
        post url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do 
        { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json
      end

      it 'does not add a new SystemRequirement' do
        expect do
          post url, headers: auth_header(user), params: system_requirement_invalid_params
        end.to_not change(SystemRequirement, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "GET /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    it "returns requested SystemRequirement" do
      get url, headers: auth_header(user)
      expected_system_requirement = system_requirement.as_json(
        only: %i(id name operational_system storage processor memory video_board)
      )
      expect(body_json['system_requirement']).to eq expected_system_requirement
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    context "with valid params" do
      let(:new_name) { 'My new SystemRequirement' }
      let(:system_requirement_params) { { system_requirement: { name: new_name } }.to_json }

      it 'updates SystemRequirement' do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expect(system_requirement.name).to eq new_name
      end

      it 'returns updated SystemRequirement' do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload
        expected_system_requirement = system_requirement.as_json(
          only: %i(id name operational_system storage processor memory video_board)
        )
        expect(body_json['system_requirement']).to eq expected_system_requirement
      end

      it 'returns success status' do
        patch url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do 
        { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json
      end

      it 'does not update SystemRequirement' do
        old_name = system_requirement.name
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        system_requirement.reload
        expect(system_requirement.name).to eq old_name
      end

      it 'returns error message' do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /system_requirements/:id" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    context "without an associated Game" do
      it 'removes SystemRequirement' do
        expect do  
          delete url, headers: auth_header(user)
        end.to change(SystemRequirement, :count).by(-1)
      end

      it 'returns success status' do
        delete url, headers: auth_header(user)
        expect(response).to have_http_status(:no_content)
      end

      it 'does not return any body content' do
        delete url, headers: auth_header(user)
        expect(body_json).to_not be_present
      end
    end

    context "with an associated Game" do
      before(:each) do
        create(:game, system_requirement: system_requirement)
      end

      it 'does not remove SystemRequirement' do
        expect do  
          delete url, headers: auth_header(user)
        end.to_not change(SystemRequirement, :count)
      end

      it 'returns unprocessable_entity status' do
        delete url, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error on :base key' do
        delete url, headers: auth_header(user)
        expect(body_json['errors']['fields']).to have_key('base')
      end
    end
  end
end
