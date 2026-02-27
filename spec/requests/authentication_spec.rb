require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "POST /sign_up" do
    it "creates a user and returns the expected payload" do
      expect {
        post "/sign_up", params: {
          email: "newuser@example.com",
          password: "passwordpassword",
          password_confirmation: "passwordpassword"
        }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body.keys).to contain_exactly("id", "email", "verified")
      expect(body["email"]).to eq("newuser@example.com")
    end
  end

  describe "POST /sign_in" do
    let!(:user) { create(:user, password: "passwordpassword", password_confirmation: "passwordpassword") }

    it "sets a signed cookie and returns user data" do
      post "/sign_in", params: { email: user.email, password: "passwordpassword" }

      expect(response).to have_http_status(:created)
      expect(response.headers["Set-Cookie"]).to include("session_token=")

      body = JSON.parse(response.body)
      expect(body).to include(
        "id" => user.id,
        "email" => user.email,
        "verified" => user.verified
      )
    end
  end

  describe "GET /current_user" do
    let!(:user) { create(:user, password: "passwordpassword", password_confirmation: "passwordpassword") }

    it "returns 401 without a session" do
      get "/current_user"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the signed-in user when a session cookie is present" do
      post "/sign_in", params: { email: user.email, password: "passwordpassword" }
      cookie = response.headers["Set-Cookie"]

      get "/current_user", headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        "id" => user.id,
        "email" => user.email,
        "verified" => user.verified
      )
    end
  end

  describe "DELETE /sign_out" do
    let!(:user) { create(:user, password: "passwordpassword", password_confirmation: "passwordpassword") }

    it "destroys the current session and clears the cookie" do
      post "/sign_in", params: { email: user.email, password: "passwordpassword" }
      cookie = response.headers["Set-Cookie"]

      expect(Session.count).to eq(1)

      delete "/sign_out", headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:no_content)
      expect(Session.count).to eq(0)
      expect(response.headers["Set-Cookie"]).to include("session_token=")
    end
  end
end
