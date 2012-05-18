require 'spec_helper'

describe "web", :type => :request do
  context "logging in" do
    context "with existing user foo" do
      before { @user = create(:user, :email => 'foo@example.com', :password => 'example') }

      it "should validate password" do
        visit "/users/sign_in"
        fill_in "Email", :with => "foo@example.com"
        fill_in "Password", :with => "oink"
        click_on "Sign in"
        page.should have_content "Invalid email or password"
        current_path.should == "/users/sign_in"
      end

      it "should log in with proper password" do
        visit "/users/sign_in"
        fill_in "Email", :with => "foo@example.com"
        fill_in "Password", :with => "example"
        click_on "Sign in"
        page.should have_content "Signed in successfully"
        current_path.should == "/"
      end

    end
  end
end
