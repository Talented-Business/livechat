require 'spec_helper'

describe "chat_messages/new.html.erb" do
  before(:each) do
    assign(:chat_message, stub_model(ChatMessage).as_new_record)
  end

  it "renders new chat_message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => chat_messages_path, :method => "post" do
    end
  end
end
