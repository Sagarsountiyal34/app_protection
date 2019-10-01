class ActivePlan
  include Mongoid::Document

  belongs_to :user
  field :plan_name, type: String, default: ""
  field :plan_id, type: String, default: ""
  field :license_key, type:String, default: ""
  field :mac_address, type: String, default: ""
  field :status, type: String, default: ""
  field :start_date, :type => DateTime, default: ""
  field :end_date, :type => DateTime, default: ""
  
  field :is_key_sent, type:Boolean, default: false

  validates :status, inclusion: { in: ['suspend', 'active', 'expired', 'future_plan'] }

  def is_expired?
    range  = self.start_date..(self.end_date)
    is_valid = range === Time.now
    self.update_attribute('status', 'expired') if !is_valid
    return !is_valid
  end
end
