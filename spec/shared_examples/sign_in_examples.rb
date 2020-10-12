shared_examples "sign in" do |email, password|
  let(:url) { '/auth/v1/user/sign_in' }
  
  context "when :email and :password are right" do
    it "retuns user tokens on header" do
      post url, params: { email: email, password: password }
      sign_in_headers = %W(access-token token-type client expiry uid)
      expect(response.headers).to include(*sign_in_headers)
    end

    it "returns :ok status" do
      post url, params: { email: email, password: password }
      expect(response).to have_http_status(:ok)
    end
  end

  context "with invalid credentials" do
    it "does not return token on header" do
      post url, params: { email: "", password: password }
      sign_in_headers = %W(access-token token-type client expiry uid)
      expect(response.headers).to_not include(*sign_in_headers)
    end

    it "returns :unauthenticated status" do
      post url, params: { email: "", password: password }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end