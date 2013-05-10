require 'spec_helper'

describe "chat_messages/index.html.erb" do
  before(:each) do
    assign(:chat_messages, [
      stub_model(ChatMessage),
      stub_model(ChatMessage)
    ])
  end

  it "renders a list of chat_messages" do
    render
  end
end
