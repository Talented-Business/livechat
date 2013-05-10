require 'spec_helper'

describe "chat_messages/edit.html.erb" do
  before(:each) do
    @chat_message = assign(:chat_message, stub_model(ChatMessage))
  end

  it "renders the edit chat_message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => chat_messages_path(@chat_message), :method => "post" do
    end
  end
end
