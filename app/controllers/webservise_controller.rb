require 'digest/md5'
class WebserviseController < ApplicationController
  before_filter :check_api_key,:only => [:login,
                                         :register,
                                         :forgotpassword]  
  before_filter :find_user,    :except => [:login,
                                         :register,
                                         :forgotpassword]  
  before_filter :find_operator, :only=> [ :unfavoriteoperator,
                                          :sendmessage,
                                          :getmessagelist,
                                          :setrate,
                                          :getoperatorinfo,
                                          :favoriteoperator]
  def login
    name = params[:username]
    if params.has_key?(:password) && params[:password] != ""
      password = params[:password]
      user = User.find_by_name(name)
      if user.nil? 
        render :json=>{"error"=>"Incorrect username.",:status =>401},:status =>200
      elsif user.encrypted_password == Digest::MD5.hexdigest(password)
        render :json=>{"auth_key"=>user.auth_token,:status =>200},:status =>200
      else
        render :json=>{"error"=>"Incorrect password.",:status =>401},:status =>200
      end
    else
      render :json=>{"error"=>"Please provide password.",:status =>400},:status =>200
    end
  end
  
  def register
    name = params[:username]
    password = params[:password]
    displayname = params[:displayname]
    email = params[:email]
    user = User.new
    user.name = name
    user.email = email
    user.display_name = displayname
    user.devicetoken = params[:devicetoken]
    user.devicetype = params[:devicetype]
    case user.devicetype
    when "android"
    when "iphone"  
    end
    
    user.encrypted_password = Digest::MD5.hexdigest(password)
    if user.save
      render :json=>{"auth_key"=>user.auth_token,:status =>200},:status =>200
    else
      render :json=>{"error"=>user.errors.messages,:status =>400},:status =>200
    end
  end
  
  def forgotpassword
    email = params[:email]
    begin
      user = User.find_by_email(email)
      user.send_password_reset
      render :json=>{"email"=>"Email address which be sent password",:status =>200},:status =>200
    rescue
      render :json=>{"error"=>"Cannot send password, please check email address.",:status =>400},:status =>200
    end
  end

  def getalloperators
    operators = Operator.all
    chat_operators = []
    operators.each do |o|
      chat_operators.push o.info(root_url)
    end
    render :json=>{"operators"=>chat_operators,:status =>200},:status =>200
  end

  def getrandomagent
    workable_ops = Schedule.workable_ops
    unless workable_ops.count == 0
      min = -1
      min_op = nil
      workable_ops.each do |schedule|
        op = schedule.operator
        c = op.get_chat_users_count
        if c < min || min == -1
          min = c
          min_op = op
        end
      end
      render :json=>{"operator"=>min_op.info(root_url),:status =>200},:status =>200
    else
      #superadmin
      superadmins = Operator.with_all_roles({:name => :superadmin})
      render :json=>{"operator"=>superadmins.first.info(root_url),:status =>200}, :status =>200
    end
  end

  def getlastagent
    render :json=>{"operator"=>@chat_user.last_chat_agent.info(root_url),:status =>200}, :status =>200
  end

  def getfavoriteoperators
    @chat_user.favor_ops = [] if @chat_user.favor_ops.nil?
    favor_operators = []
    @chat_user.favor_ops.each do |o|
      favor_operators.push Operator.find(o).info(root_url)
    end
    render :json=>{"operators"=>favor_operators,:status =>200},:status =>200
  end

  def getrecentoperators
    render :json=>{"operators"=>@chat_user.recentoperators(root_url),:status =>200},:status =>200
  end

  def getoperatorinfo    
    login_name = @operator.name
    login_name = "" if login_name.nil?
    login_display_name = @operator.display_name
    login_display_name = "" if login_display_name.nil?
    login_short_bio = @operator.short_bio
    login_short_bio = "" if login_short_bio.nil?
    login_languages = @operator.languages
    login_languages = [] if login_languages.nil?
    login_long_bio = @operator.long_bio
    login_long_bio = "" if login_long_bio.nil?
    render :json=>{"operator"=>{
        "operator_login_number"=>login_name,
        "operator_name"=>login_display_name,
        "short_bio"=>login_short_bio,
        "online_offline"=>true,
        "avatar"=>root_url+@operator.display_avatar.url(:small, false),
        "long_bio"=>login_long_bio,
        #"credit"=>@operator.credit,
        #"credit_bonus"=>@operator.credit_bonus,
        "rating_count"=>@operator.rates.count,
        "language"=>login_languages,
        "rate"=>{
          "rate_overall"=>(@operator.rate_overall[0]+@operator.rate_overall[1]+@operator.rate_overall[2]+@operator.rate_overall[3])/4,
          "rate_skills"=>@operator.rate_overall[0],
          "rate_communication"=>@operator.rate_overall[1],
          "rate_friendliness"=>@operator.rate_overall[2],
          "rate_recommend"=>@operator.rate_overall[3]
        },
        "skills"=>@operator.skills_array
      },:status =>200
      },:status =>200
  end

  def setusersetting
    name = params[:login_number]
    if params.has_key?(:old_password) && params[:old_password] != ""
      password = params[:old_password]
      if @chat_user.encrypted_password == Digest::MD5.hexdigest(password)
        data = {}
        data[:avatar] = params[:userfile] if params.has_key?(:userfile)
        data[:encrypted_password] = Digest::MD5.hexdigest(params[:new_password])
        if @chat_user.update_attributes(data)
          render :json=>{"result"=>"Successfully updated",:status =>200},:status =>200
        else
          render :json=>{"error"=>@chat_user.errors.messages,:status =>410},:status =>200
        end
      else
        render :json=>{"error"=>"Invalid Old Password.",:status =>410},:status =>200
      end
    else
      render :json=>{"error"=>"Please provide old password.",:status =>410},:status =>200
    end
  end
  def getuserinfo
    credit_count = ""
    credit_count = @chat_user.credits unless @chat_user.credits.nil?
    userinfo = {
      "user_name"=>@chat_user.name,
      "avatar"=>root_url+@chat_user.avatar.url(:small, false),
      "credit_count"=> credit_count
    }
    render :json=>{"user"=>userinfo,"status"=>"200"},:status =>200
  end
  def setusercredit
    @chat_user.bonus_credits = params[:credit]
    @chat_user.credits = params[:credit_bonus]
    @chat_user.save!
    render :json=>{"result"=>"Successfully updated",:status =>200},:status =>200
  end
  
  def setrate
    rate = Rate.where(:operator_id => @operator.id, :user_id => @chat_user.id).first_or_initialize
    rate.skill = params[:skill]
    rate.communication = params[:communication]
    rate.friendliness = params[:friendliness]
    rate.recommend = params[:recommend]
    rate.save
    render :json=>{"result"=>"Successfully updated",:status =>200},:status =>200
  end
  
  def favoriteoperator
    @chat_user.favor_ops = [] if @chat_user.favor_ops.nil?
    unless @chat_user.favor_ops.include?(@operator.id)
      @chat_user.favor_ops.push @operator.id 
      @chat_user.save
    end  
    render :json=>{"result"=>"Successfully favorited",:status =>200},:status =>200
  end

  def unfavoriteoperator
    @chat_user.favor_ops = [] if @chat_user.favor_ops.nil?
    @chat_user.favor_ops.delete @operator.id
    @chat_user.save
    render :json=>{"result"=>"Successfully unfavorited",:status =>200} ,:status =>200   
  end
  def endsession
    current_session = @chat_user.current_session
    unless current_session.nil?
      current_session.end_session
      render :json=>{"result"=>"Successfully session ended",:status =>200},:status =>200 and return
    end    
    render :json=>{"error"=>"Nothing current session ",:status =>403},:status =>200
  end
  def getmessagelist
    begin
      s = @chat_user.getlastmessage(@operator)
      unless s.nil?
        render :json=>{"messages"=>s.chat_history,:status =>200},:status =>200
      else
        render :json=>{"messages"=>[],:status =>200},:status =>200
      end
    rescue
      render :json=>{"error"=>@chat_user.to_json.to_s+@operator.to_json.to_s+"chat_messages query is invalid",:status =>410},:status =>200 and return
    end
  end

  def sendmessage
    current_session = @chat_user.current_session
    if current_session.nil?
      current_session = Session.new
      current_session.start = DateTime.now
      current_session.user = @chat_user
      current_session.operator = @operator
      current_session.save
    end
    chat_message = ChatMessage.new(:message=>params[:message])
    chat_message.direction = false
    chat_message.operator = @operator
    chat_message.user = @chat_user
    chat_message.session = current_session
    chat_message.remote_ip = get_remote_ip
    chat_message.save
    render :json=>{"result"=>"Successfully sent",:status =>200} ,:status =>200   
  end
  def sawdailymessage
    @chat_user.update_attribute(:daily_message, true)
    render :json=>{"result"=>"Successfully sent",:status =>200} ,:status =>200   
  end
  private 
  def check_api_key
    if params.has_key?(:api_key) 
      api_key = params[:api_key]
    else
      render :status => 200,:json=>{"error"=>"API key is missing.",:status => 403} and return
    end
    unless api_key == "avatar"
      render :status => 200,:json=>{"error"=>"Invalid API key.",:status => 401} and return
    end    
  end
  def find_user
    if params.has_key?(:auth_key) 
      @chat_user = User.find_by_auth_token(params[:auth_key])
      if @chat_user.nil?
        render :status => 200,:json=>{"error"=>"Invalid Auth key.",:status => 401} and return
      else
        @chat_user.update_attribute(:session_update, DateTime.now)
      end
    else
      render :status => 200,:json=>{"error"=>"Invalid Auth key.",:status => 401} and return
    end    
  end
  def find_operator
    if params.has_key?(:operator_login_number) 
      @operator = Operator.find_by_name(params[:operator_login_number])
      if @operator.nil?
        render :status => 200,:json=>{"error"=>"Invalid operator_login_number.",:status => 401} and return
      end
    else
      render :status => 200,:json=>{"error"=>"Invalid Operator Login Number.",:status => 411} and return
    end    
  end
  def get_remote_ip
    remote_ip = request.remote_ip
    return remote_ip
  end
end
