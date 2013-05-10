class ChatMessage < ActiveRecord::Base
  self.primary_key = "prihash"
  before_create { generate_token(:prihash) }
  belongs_to :operator
  belongs_to :user
  belongs_to :session
  attr_accessible :message, :direction, :remote_ip
  private
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while ChatMessage.exists?(column => self[column])
  end  

end
