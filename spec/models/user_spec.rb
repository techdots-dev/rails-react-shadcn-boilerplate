require "rails_helper"

RSpec.describe User, type: :model do
  it "requires an email" do
    user = User.new(password: "passwordpassword")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to be_present
  end

  it "requires a valid email format" do
    user = User.new(email: "invalid-email", password: "passwordpassword")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to be_present
  end

  it "requires a unique email" do
    create(:user, email: "unique@example.com")
    user = User.new(email: "unique@example.com", password: "passwordpassword")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to be_present
  end

  it "requires a long enough password" do
    user = User.new(email: "short@example.com", password: "short")

    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end
end
