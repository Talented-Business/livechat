class Operator < ActiveRecord::Base
  rolify
  delegate :can?, :cannot?, :to => :ability
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  attr_accessible :display_name, :name,:country,:short_bio,:long_bio, :avatar,:display_avatar,:block,:mobile_number,:real_name ,:session_update#, :credit, :credit_bonus
  has_and_belongs_to_many :skills, :join_table => :operators_skills
  validates :password, :confirmation => true,    :unless => Proc.new { |a| a.password.blank? }
  validates :name, :presence => true, :uniqueness => true
  has_attached_file :avatar, styles: { medium: "65x65#", small: "40x40#" },
                             default_url: 'avatar3.png',
                             path: ":rails_root/public/system/:class/avatar/:id/:style",
                             url: "system/:class/avatar/:id/:style"
  has_attached_file :display_avatar, styles: { medium: "65x65#", small: "40x40#" },
                             default_url: 'avatar2.png',
                             path: ":rails_root/public/system/:class/display/:id/:style",
                             url: "system/:class/display/:id/:style"
  has_many  :topics, :dependent => :destroy
  has_many  :chat_messages, :dependent => :destroy
  has_many  :rates, :dependent => :destroy
  has_many  :notes, :dependent => :destroy      
  has_one   :permission,:dependent => :destroy
  has_many  :sessions, :dependent => :destroy      
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  attr_accessible :display_name, :name, :real_name,:languages
  serialize :languages
  scope :senders, lambda{ self.where(:block =>false).order(:name => :asc)  }
  def ability
    @ability ||= Ability.new(self)
  end
  def self.admins
    Operator.with_all_roles({:name => :admin})
  end
  def self.senders(operator)
    Operator.where("block = false and id !=? ", operator.id ).order(:name => :asc)
  end
  def self.operators
    operators = Operator.where(:block => false)
    admin_operators = Operator.with_all_roles({:name => :admin})
    superadmin_operators = Operator.with_all_roles({:name => :superadmin})
    return (operators - admin_operators - superadmin_operators)
  end
  def info(root_url)
    login_name = self.name
    login_name = "" if login_name.nil?
    login_display_name = self.display_name
    login_display_name = "" if login_display_name.nil?
    login_short_bio = self.short_bio
    login_short_bio = "" if login_short_bio.nil?
    login_languages = self.languages
    login_languages = [] if login_languages.nil?
    rates = self.rate_overall
    return {
      "operator_login_number" =>login_name,
      "operator_name"         =>login_display_name,
      "short_bio"=>login_short_bio,
      "online_offline"=>true,
      "avatar"=>root_url+self.display_avatar.url(:small, false),
      "language"=>self.languages,
      "rate"=>(rates[0] + rates[1] +rates[2] + rates[3])/4
    }
  end
  def get_chat_users_count(t = DateTime.now)
    ChatMessage.select(:user_id).uniq.where("created_at >= ? and operator_id = ?",t-10.minutes,self.id).count
  end
  def skills_array
    s = []
    self.skills.each do |skill|
      s.push skill.name
    end
    return s
  end
  def rate_overall
    i = 0 
    skill = 0.0
    communication =0.0
    friendliness = 0.0
    recommend = 0.0
    if self.rates.count >0
      self.rates.each do | rate |
        i +=1
        skill += rate.skill.to_f
        communication += rate.communication.to_f
        friendliness += rate.friendliness.to_f
        recommend += rate.recommend.to_f
      end
      return [skill/i,communication/i,friendliness/i,recommend/i]
    else
      return [skill,communication,friendliness,recommend]
    end 
  end
  def get_permission
    if self.permission.nil?
      self.permission = Permission.new
      self.permission.operator = self
      if self.has_role? :admin
        self.permission.editable_profile_admin = Systemmeta.get_setting("editable_profile_admin") 
        self.permission.character_profile_admin = Systemmeta.get_setting("character_profile_admin")
        self.permission.mass_sending_admin = Systemmeta.get_setting("mass_sending_admin")
        self.permission.kickop_admin = Systemmeta.get_setting("kickop_admin") 
        self.permission.editable_note_admin = Systemmeta.get_setting("editable_note_admin") 
      else  
        self.permission.notes = Systemmeta.get_setting("notes_op") 
        self.permission.outside_shift = Systemmeta.get_setting("outsite_shift_op")
        self.permission.idle_time = Systemmeta.get_setting("idle_time_op")
        self.permission.schedule = Systemmeta.get_setting("schedule_op") 
        if Systemmeta.get_setting("schedule_start_date_op").nil? || Systemmeta.get_setting("schedule_start_date_op") == ""
          self.permission.start_date = nil
        else
          self.permission.start_date = Date.strptime(Systemmeta.get_setting("schedule_start_date_op"), '%m/%d/%Y')
        end
        if Systemmeta.get_setting("schedule_end_date_op").nil? || Systemmeta.get_setting("schedule_end_date_op") == ""
          self.permission.end_date = nil
        else
          self.permission.end_date = Date.strptime(Systemmeta.get_setting("schedule_end_date_op"), '%m/%d/%Y')
        end
      end  
    else
      if self.has_role? :admin
        if self.permission.editable_profile_admin.nil?
          self.permission.editable_profile_admin = Systemmeta.get_setting("editable_profile_admin") 
          self.permission.character_profile_admin = Systemmeta.get_setting("character_profile_admin")
          self.permission.mass_sending_admin = Systemmeta.get_setting("mass_sending_admin")
          self.permission.kickop_admin = Systemmeta.get_setting("kickop_admin") 
          self.permission.editable_note_admin = Systemmeta.get_setting("editable_note_admin") 
        end
      else
        if self.permission.notes.nil?
          self.permission.notes = Systemmeta.get_setting("notes_op") 
          self.permission.outside_shift = Systemmeta.get_setting("outsite_shift_op")
          self.permission.idle_time = Systemmeta.get_setting("idle_time_op")
          self.permission.schedule = Systemmeta.get_setting("schedule_op") 
          if Systemmeta.get_setting("schedule_start_date_op").nil? || Systemmeta.get_setting("schedule_start_date_op") == ""
            self.permission.start_date = nil
          else
            self.permission.start_date = Date.strptime(Systemmeta.get_setting("schedule_start_date_op"), '%m/%d/%Y')
          end
          if Systemmeta.get_setting("schedule_end_date_op").nil? || Systemmeta.get_setting("schedule_end_date_op") == ""
            self.permission.end_date = nil
          else
            self.permission.end_date = Date.strptime(Systemmeta.get_setting("schedule_end_date_op"), '%m/%d/%Y')
          end
        end        
      end
    end    
    return self.permission
  end
  def check_sessions
    self.active_sessions.each do |s|
      s.check_status
    end
  end
  def active_sessions
    self.sessions.where(:end =>nil)
  end
  private
  def add_role_record(record)
    #user.add_role :operator unless user.has_role? :operator or user.has_role? :admin or user.has_role? :super_admin
  end  
end
