require 'spec_helper'

describe "schedules/new.html.erb" do
  before(:each) do
    assign(:schedule, stub_model(Schedule,
      :callback_url => "MyString",
      :cron => "MyString",
      :callback_params => "MyText",
      :timing => "MyText"
    ).as_new_record)
  end

  it "renders new schedule form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => schedules_path, :method => "post" do
      assert_select "input#schedule_callback_url", :name => "schedule[callback_url]"
      assert_select "input#schedule_cron", :name => "schedule[cron]"
      assert_select "textarea#schedule_callback_params", :name => "schedule[callback_params]"
      assert_select "textarea#schedule_timing", :name => "schedule[timing]"
    end
  end
end
