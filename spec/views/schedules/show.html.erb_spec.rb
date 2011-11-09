require 'spec_helper'

describe "schedules/show.html.erb" do
  before(:each) do
    @schedule = assign(:schedule, stub_model(Schedule,
      :callback_url => "Callback Url",
      :cron => "Cron",
      :callback_params => "MyText",
      :timing => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Callback Url/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Cron/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
