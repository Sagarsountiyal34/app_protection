class Plan
  include Mongoid::Document

  field :name,              type: String, default: ""
  field :limit_to_buy, type: Integer, default: "1"
  field :duration, type: String, default: ""

  def get_end_date_from_now
  	case self.duration
  	when '6 Months'
  		Time.now + 6.months
  	when '1 Year'
  		Time.now + 1.years
  	when '2 Year'
  		Time.now + 2.years
  	end
  end

  def get_end_date_from_active_plan(prev_plan)
    case self.duration
    when '6 Months'
      prev_plan.end_date + 6.months
    when '1 Year'
      prev_plan.end_date + 1.years
    when '2 Year'
      prev_plan.end_date + 2.years
    end
  end

  def get_end_date_for_change_validity(prev_plan)
    case self.duration
    when '6 Months'
      prev_plan.start_date + 6.months
    when '1 Year'
      prev_plan.start_date + 1.years
    when '2 Year'
      prev_plan.start_date + 2.years
    end
  end
end