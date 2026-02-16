require "rails_helper"

RSpec.describe "Admin access", type: :request do
  describe "GET /admin" do
    it "redirects guests to root" do
      get "/admin"

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end

    it "redirects signed-in non-admin users to root" do
      user = create(:user, password: "passwordpassword", password_confirmation: "passwordpassword")

      post "/sign_in", params: { email: user.email, password: "passwordpassword" }
      cookie = response.headers["Set-Cookie"]

      get "/admin", headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end

    it "allows signed-in admins" do
      admin = create(:user, :admin, password: "passwordpassword", password_confirmation: "passwordpassword")

      post "/sign_in", params: { email: admin.email, password: "passwordpassword" }
      cookie = response.headers["Set-Cookie"]

      get "/admin", headers: { "Cookie" => cookie }

      expect(response).to have_http_status(:ok)
    end
  end
end
