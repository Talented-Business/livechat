require 'spec_helper'

describe "chat_messages/show.html.erb" do
  before(:each) do
    @chat_message = assign(:chat_message, stub_model(ChatMessage))
  end

  it "renders attributes in <p>" do
    render
  end
end
