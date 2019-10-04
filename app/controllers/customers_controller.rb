class CustomersController < ApplicationController
	before_action :set_desired_field
	def set_desired_field
		if params[:id].present?
        	@customer = User.includes(:active_plans).find(params[:id])
      	end
      	if params[:cust_plan_id].present?
      		@cust_plan = ActivePlan.find(params[:cust_plan_id])
      	end
      	if params[:plan_id].present?
      		@plan = Plan.find(params[:plan_id])
      	end
	end

	def index
		@customer = User.new
	end

	def list
		get_details_of_customers
	end

	def show
		get_details_for_customer_page
	end

	def activate_plan
		license_key = get_license_key
		active_plan = @customer.get_active_plan
		if active_plan.present?
			start_date = active_plan.end_date
			end_date = @plan.get_end_date_from_active_plan(active_plan)
			activated_plan = @customer.active_plans.create(:plan_id => params['plan_id'], :plan_name => @plan.name, :license_key => license_key, :status => 'future_plan', :start_date => start_date, :end_date => end_date) rescue nil
		else
			start_date = Time.now
			end_date = @plan.get_end_date_from_now
			activated_plan = @customer.active_plans.create(:plan_id => params['plan_id'], :plan_name => @plan.name, :license_key => license_key, :status => 'active', :start_date => start_date, :end_date => end_date) rescue nil
		end
		if @plan.present? and activated_plan.present?
			if activated_plan.status == 'future_plan' or  params['origin'] == 'future'
				@customer = User.includes(:active_plans).find(params[:id])
				get_details_for_customer_page
				render partial: 'customers/partial/customer_plan'
			else
				render json: {message: true, license_key: license_key, plan_id: activated_plan.id.to_s}, status: 200
			end
		else
			render json: { message: false }, status: 500
		end
	end

	def send_license_key_to_email
		error = nil
		if @customer.present? and @cust_plan.present?
			begin
				GmailMailer.license_key_email(@customer, @cust_plan.license_key).deliver
				@cust_plan.update_attribute('is_key_sent', true)
			rescue Exception => e
				error = "Please try Again." + e.message
			end
		else
			error = "User does not have a plan.activate any plan first"
		end
		if error.present? == false
			render json: { message: true, plan_id: @cust_plan.id.to_s }.to_json, status: 200
		else
			render json: { message: error }.to_json, status: 500
		end
	end

	def suspend_resume_plan
		status =  to_boolean(params[:is_active]) ? 'suspend' : 'active' 
		if @cust_plan.present? and @cust_plan.update_attribute('status', status)
			if params['origin'] == 'customer_page'
				@customer = User.includes(:active_plans).find(params[:id])
				get_details_for_customer_page
				render partial: 'customers/partial/customer_plan'
			else
				get_details_of_customers
				render partial: 'customers/partial/customers'
			end
		else
			render json: { message: false }.to_json, status: 200
		end
	end

	def change_plan_validity
		if @customer.get_future_plan.present?
			render json: { message: "Customer has future plan setup.validity can't be extend.", status: false }.to_json, status: 200
		elsif (Time.now.to_date - @cust_plan.start_date.to_date).to_i > 30
			render json: { message: "Validity can't be changed after one month of activating plan..", status: false }.to_json, status: 200
		else
			end_date = @plan.get_end_date_for_change_validity(@cust_plan)
			if @cust_plan.update_attributes(:plan_name => @plan.name, :plan_id => @plan.id.to_s, :end_date => end_date)
				@customer = User.includes(:active_plans).find(params[:id])
				get_details_for_customer_page
				render partial: 'customers/partial/customer_plan'
			else
				render json: { message: "Please try Again.", status: false }.to_json, status: 200
			end
		end
	end

	private
	def to_boolean(str)
  		str == 'true'
	end

	def get_license_key
		alphabet = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
		license_key = (0...32).map { alphabet[rand(alphabet.length)] }.join
	end

	def get_details_for_customer_page
		@plans = Plan.all
		@active_plan = @customer.get_active_plan
		@future_plan = @customer.get_future_plan
		@suspend_plan = @customer.get_suspend_plan
	end

	def get_details_of_customers
		@customers = User.where(role: 'customer')
		@plans = Plan.all
	end
end
