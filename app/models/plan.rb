class Plan
  include Mongoid::Document

  field :name,              type: String, default: ""
  field :limit_to_buy, type: Integer, default: "1"
  field :duration, type: String, default: ""
end
