require 'spec_helper'

describe "schedules/index.html.erb" do
  before(:each) do
    assign(:schedules, [
      stub_model(Schedule,
        :callback_url => "Callback Url",
        :cron => "Cron",
        :callback_params => "MyText",
        :timing => "MyText"
      ),
      stub_model(Schedule,
        :callback_url => "Callback Url",
        :cron => "Cron",
        :callback_params => "MyText",
        :timing => "MyText"
      )
    ])
  end

  it "renders a list of schedules" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Callback Url".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Cron".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
