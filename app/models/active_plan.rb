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
    # range  = self.start_date..(self.end_date)
    # is_valid = range === Time.now
    # self.update_attribute('status', 'expired') if !is_valid
    # return !is_valid
    self.status == 'expired'
  end

  def have_to_show_change_validity?
    (Time.now.to_date - self.start_date.to_date).to_i < 30
  end

  def is_active_plan_used?(mac_address)
    self.mac_address.present? and self.mac_address != mac_address
  end

  def is_mac_address_present?
    self.mac_address.present?
  end
end
