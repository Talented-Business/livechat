require 'net/https'
require 'uri'
module ApplicationHelper
  def compare_url(thepath)
    if request.path == thepath
      return "current"
    end
  end
  def get_setting(name)
    setting = Systemmeta.find_or_initialize_by_meta_key(name)
    return setting.meta_value
  end  
  def daily_messages(message)
    users = User.where(:block=>false)
    ios_tokens = []
    android_tokens = []
    users.each do | user |
      if user.devicetype == "android" 
        android_tokens.push user.devicetoken 
      else
        ios_tokens.push user.devicetoken 
      end
    end
    data = Hash.new          
    data['message'] = message
    send_all_push(ios_tokens, android_tokens, data)
  end
  def send_all_push(ios_tokens, android_tokens, msgarr=[],type='1001', msg='You have received notification')
    if android_tokens.count>0
      send_android_notifications(android_tokens, msgarr, type,Rails.application.config.android)
    end
    if ios_tokens.count>0
      ios_tokens.each do |token|
        send_ios_push(token, msgarr.to_json, {},type)
      end
    end
  end
  def send_android_notifications(tockens,msg,type='1002', api_key ='AIzaSyABuP87czQtCQrZJVHbeN3PqWDENtfzZLw' , format='json')
    if format == 'json'
      headers = {"Content-Type" => "application/json",
                  "Authorization" => "key=#{api_key}"}
      data = Hash.new          
      data['data'] = Hash.new
      data['data']['msg'] = msg 
      data['data']['type'] = type 
      data['registration_ids'] = tockens
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
  def send_ios_push(token, msg, data={}, type='1002')
    apple_open do |conn, sock|
      payload = Hash.new
      payload['aps'] = {'alert' => msg, 'badge' => 0, 'sound' => 'default', 'type' => type}
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
  def options_idle_times(val)
    options = [10,20,40]
    html = ''
    options.each do |option|
      if option == val.to_i
        selected = "selected"
      else
        selected = ""
      end
      html = html + "<option value='#{option}' #{selected}>#{option} minutes</option>"
    end
    return html.html_safe
  end
  def reminder_message(description)
    if description.mb_chars.length > 24
      description = description.mb_chars[0,24]+"..."
    else
      return description
    end
  end
  private 
end
