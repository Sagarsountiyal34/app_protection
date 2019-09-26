class ActivePlan
  include Mongoid::Document

  belongs_to :user
  field :plan_name, type: String, default: ""
  field :plan_id, type: String, default: ""
  field :license_key, type:String, default: ""
  field :mac_address, type: String, default: ""
  field :is_active_plan, type: Boolean, default: false
  field :is_key_sent, type:Boolean, default: false

end
