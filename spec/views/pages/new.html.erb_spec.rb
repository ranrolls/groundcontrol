require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/pages/new.html.erb" do
  include PagesHelper
  
  before(:each) do
    @page = mock_page_model()
    @page.stub!(:new_record?).and_return(true)
    assigns[:page] = @page
  end

  it "should render new form" do
    render "/pages/new.html.erb"
    response.should have_tag("form[action=?][method=post]", pages_path) do
      verify_form_for_page()
    end
  end
end


