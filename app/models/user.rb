class User
  include Mongoid::Document
  attr_accessor :skip_password_validation
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time
  
  #custom attribute
  field :role, type: String, default: "customer"
  field :first_name, type: String, default: ""
  field :last_name, type: String, default: ""
  field :phone_number, type: String, default: ""
  field :address, type: String, default: ""
  field :city, type: String, default: ""
  field :country, type: String, default: ""
  field :gender, type: String, default: ""
  field :last_notification_sent_time, type: DateTime, default: ""
  has_many :active_plans, dependent: :destroy
  
  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  # field :sign_in_count,      type: Integer, default: 0
  # field :current_sign_in_at, type: Time
  # field :last_sign_in_at,    type: Time
  # field :current_sign_in_ip, type: String
  # field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  def get_active_plan
    # self.active_plans.where(:is_active_plan => true).first
    self.active_plans.where(:status => 'active').first
  end

  def get_future_plan
    # self.active_plans.where(:is_active_plan => true).first
    self.active_plans.where(:status => 'future_plan').first
  end

  def get_suspend_plan
    self.active_plans.where(:status => 'suspend').first
  end

  def is_today_notification_sent?
    # self
    last_time = user.last_notification_sent_time
    if last_time.present? 
      (last_time - Time.now.to_date).to_f.to_i == 0
    else
      return false
    end
  end

  def is_notification_sent_within_hour?(hour)
    (((Time.now) - self.last_notification_sent_time) / 1.hours).round < hour

  def is_notification_sent_within_minute?(minute)
    (((Time.now) - self.last_notification_sent_time) / 1.minutes).round < minute
  end

  protected
  def password_required?
    return false if skip_password_validation
    super
  end
end
