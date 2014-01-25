require 'spec_helper'

describe "Static pages" do

  let(:base_title) { "Rails base" }

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_content('Home page') }
    it { should have_title("#{base_title}") }
    it { should_not have_title('|') }
  end

end
