class User < ActiveRecord::Base
  before_create { generate_token(:auth_token) }
  # :lockable, :timeoutable and :omniauthable
  attr_accessible :display_name, :name, :real_name, :mobile_number, :status, :credits, :sales, 
              :bonus_credits,:avatar,:email,:block, :session_update,:encrypted_password,:auth_token,:devicetoken, :devicetype,:daily_message
  has_attached_file :avatar, styles: { medium: "65x65#", small: "40x40#" },
                             default_url: 'avatar3.png',
                             path: ":rails_root/public/system/:class/avatar/:id/:style",
                             url: "/system/:class/avatar/:id/:style"
  has_many  :chat_messages, :dependent => :destroy      
  has_many  :rates, :dependent => :destroy
  has_many  :notes, :dependent => :destroy      
  has_many  :sessions, :dependent => :destroy      
  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true
  validates :devicetoken, :presence => true, :uniqueness => true
  validates :devicetype, :presence => true
  validates :email, :presence => true, :uniqueness => true, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  serialize :favor_ops, Array
  def send_password_reset
    password = SecureRandom.urlsafe_base64
    self.encrypted_password = Digest::MD5.hexdigest(password)
    self.save(:validate=>false)
    UserMailer.password_reset(self,password).deliver
  end  
  def last_chat_agent
    last_chat = self.chat_messages.where(:direction=>false).last
    unless last_chat.nil?
      return last_chat.operator
    else
      return nil
    end
  end
  def recentoperators(root_url,t = DateTime.now)
    op_ids = Session.select(:operator_id).uniq.where("user_id = ?",self.id)#.order("created_at ASC")
    recent_operators = []
    op_ids.each do |op_id|
      operator = Operator.find(op_id.operator_id)
      recent_operators.push operator.info(root_url)
    end
    return recent_operators
  end  
  def self.daily_messages(message)
    users = User.where(:block=>false, :daily_message=>false)
    android_tokens = []
    ios_users = []
    users.each do | user |
      if user.devicetype == "android" 
        android_tokens.push user.devicetoken 
      else
        ios_users.push user
      end
    end
    data = Hash.new          
    data['message'] = message
    send_all_push(ios_users, android_tokens, data)
  end
  def self.send_all_push(ios_users, android_tokens, msgarr=[],type='1001', msg='You have received notification')
    if android_tokens.count>0
      send_android_notifications(android_tokens, msgarr, type)
    end
    if ios_users.count>0
      ios_users.each do |user|
        user.send_ios_push(msgarr.to_json, {},type)
      end
    end
  end 
  def self.send_android_notifications(msg,type='1002', format='json')
    api_key =Rails.application.config.android
    if format == 'json'
      headers = {"Content-Type" => "application/json",
                  "Authorization" => "key=#{api_key}"}
      data = Hash.new          
      data['data'] = Hash.new
      data['data']['msg'] = msg 
      data['data']['type'] = type 
      data['registration_ids'] = tokens
      data = data.to_json
    else   #plain text format
      headers = {"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
                  "Authorization" => "key=#{api_key}"}
    end

    url_string = "https://android.googleapis.com/gcm/send"
    url = URI.parse url_string
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    resp, dat = http.post(url.path, data, headers)

    return {:code => resp.code.to_i, :message => dat,:body=>resp.body }    
  end
  def send_android_notification(msg,type='1002', format='json')
    api_key =Rails.application.config.android
    tokens = []
    tokens[0] = self.devicetoken
    if format == 'json'
      headers = {"Content-Type" => "application/json",
                  "Authorization" => "key=#{api_key}"}
      data = Hash.new          
      data['data'] = Hash.new
      data['data']['msg'] = msg 
      data['data']['type'] = type 
      data['registration_ids'] = tokens
      data = data.to_json
    else   #plain text format
      headers = {"Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8",
                  "Authorization" => "key=#{api_key}"}
    end

    url_string = "https://android.googleapis.com/gcm/send"
    url = URI.parse url_string
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    resp, dat = http.post(url.path, data, headers)

    return {:code => resp.code.to_i, :message => dat,:body=>resp.body }
  end 
  def send_ios_push(msg, data={}, type='1002')
    token = self.devicetoken
    apple_open do |conn, sock|
      payload = Hash.new
      payload['aps'] = {'alert' => msg, 'badge' => 0, 'data'=>data,'sound' => 'default', 'type' => type}
      push = payload.to_json
      token = token.gsub(" ", "")
      #message = "\0\0 #{[token.delete(' ')].pack('H*')}\0#{push.length.chr}#{push}"
      the_byte_token =[token].pack("H*")
      message = [0, 0, 32, the_byte_token, 0, push.length, push].pack("ccca*cca*")
      conn.write(message)
      conn.flush
      if IO.select([conn], nil, nil, 1)
        error = conn.read(6)
        if error
          error = error.unpack("ccN")
          puts "ERROR: #{error}"
        else
          puts "NO ERROR"
        end
      end      
    end
  end
  def current_session
    current_session = self.sessions.last
    unless current_session.nil?
      return current_session if current_session.check_status
    end
    return nil
  end
  def getlastmessage(op)
    s = Session.where("user_id = ? and operator_id = ?",self.id, op.id).last
    return s
  end
  def last_message(op)
    s = getlastmessage(op)
    if s.nil?
      return nil
    else
      return s.chat_messages.last
    end
  end
  private
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end  
  def apple_open(options = {}, &block) # :nodoc:
    options = { :cert => Rails.application.config.apn['cert'],
                :passphrase => Rails.application.config.apn['passphrase'],
                :host => Rails.application.config.apn['host'],
                :port => Rails.application.config.apn['port']}.merge(options)
    cert = File.read(options[:cert])
    #cert = options[:cert]
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.key = OpenSSL::PKey::RSA.new(cert, options[:passphrase])
    ctx.cert = OpenSSL::X509::Certificate.new(cert)

    sock = TCPSocket.new(options[:host], options[:port])
    ssl = OpenSSL::SSL::SSLSocket.new(sock, ctx)
    ssl.sync = true
    ssl.connect
    yield ssl, sock if block_given?
    ssl.close
    sock.close
  end  
end
