class CustomersController < ApplicationController
	def index
		@customer = User.new
	end

	def list_customer
		@customers = User.where(role: 'customer')
		# @users = User.includes(:active_plans).find_by(id: '5d8867ca58e53d38e2824ef1')
		@plans = Plan.all

	end

	def show
		get_details_for_customer_page
	end

	def activate_plan
		plan = Plan.find(params['plan_id'])
		customer = User.find(params['id'])
		license_key = get_license_key
		active_plan = customer.get_active_plan
		if active_plan.present?
			# message = customer.get_future_plan.present? ? 'Future Plan Already present' : ''
			start_date = active_plan.end_date
			end_date = plan.get_end_date_from_active_plan(active_plan)
			activated_plan = customer.active_plans.create(:plan_id => params['plan_id'], :plan_name => plan.name, :license_key => license_key, :status => 'future_plan', :start_date => start_date, :end_date => end_date) rescue nil
		else
			start_date = Time.now
			end_date = plan.get_end_date_from_now
			activated_plan = customer.active_plans.create(:plan_id => params['plan_id'], :plan_name => plan.name, :license_key => license_key, :status => 'active', :start_date => start_date, :end_date => end_date) rescue nil
		end
		if plan.present? and activated_plan.present? and end_date.present?
			if activated_plan.status == 'future_plan' or  params['origin'] == 'future'
				get_details_for_customer_page
				render partial: 'customers/partial/customer_plan'
			else
				render json: {message: true, license_key: license_key, plan_id: activated_plan.id.to_s}, status: 200
			end
		else
			render json: {
				message: false
			}, status: 500
		end
		 # u=User.includes(:active_plans).find_by(id: '5d8867ca58e53d38e2824ef1')
	end

	def send_license_key_to_email
		customer = User.find(params[:customer_id])
		active_plan = customer.get_active_plan rescue ""
		error = nil
		# also update status to suspend
		if customer.present? and active_plan.present?
			begin
				GmailMailer.license_key_email(customer, active_plan.license_key).deliver
				active_plan.update_attribute('is_key_sent', true)
			rescue Exception => e
				error = "Please try Again." + e.message
			end
		else
			error = "User does not have a active plan.activate plan first"
		end
		if error.present? == false
			render json: {	message: true,
				plan_id: active_plan.id.to_s
			}.to_json, status: 200
		else
			render json: {
				message: error
			}.to_json, status: 500
		end
	end

	def activate_deactivate_plan
		status =  to_boolean(params[:is_active]) ? 'suspend' : 'active' 
		if ActivePlan.find(params[:plan_id]).update_attribute('status', status)
			@customers = User.where(role: 'customer')
			# @users = User.includes(:active_plans).find_by(id: '5d8867ca58e53d38e2824ef1')
			@plans = Plan.all
			# render json: { message: true }.to_json, status: 200
			render partial: 'customers/partial/customers'
		else
			render json: { message: false }.to_json, status: 200
		end
	end

	def change_plan_validity
		customer = User.find(params[:id])
		if customer.get_future_plan.present?
			render json: { message: "Customer has future plan setup.validity can't be extend.", status: false }.to_json, status: 200
		else
			current_plan = ActivePlan.find(params[:current_plan_id])
			new_plan = Plan.find(params[:new_plan_id])
			end_date = new_plan.get_end_date_for_change_validity(current_plan)
			if current_plan.update_attributes(:plan_name => new_plan.name, :plan_id => new_plan.id.to_s, :end_date => end_date)
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
		@customer = User.includes(:active_plans).find(params[:id])
		@plans = Plan.all
		@active_plan = @customer.get_active_plan
		@future_plan = @customer.get_future_plan
	end
end
