require 'spec_helper'

feature 'Commits' do
  context "in a public project" do
    context "#short_url_show with public project" do

      let(:commit) { Factory :commit, project: Factory(:public_project) }

      before do
        visit "/c/#{commit.id}"
      end

      it "should display commit" do
        page.should have_content commit.description
      end
    end
  end
end
