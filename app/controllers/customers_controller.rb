class CustomersController < ApplicationController
	def index
		@customer = User.new
	end

	def list_customer
		@customers = User.where(role: 'customer')
		# @users = User.includes(:active_plans).find_by(id: '5d8867ca58e53d38e2824ef1')
		@plans = Plan.all
	end

	def activate_plan
		# activate_plan
		# debugger
		plan = Plan.find(params['plan_id'])
		alphabet = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
		license_key = (0...16).map { alphabet[rand(alphabet.length)] }.join
		
		if plan.present? and User.find(params['customer_id']).active_plans.create(:plan_id => params['plan_id'], :plan_name => plan.name, :license_key => license_key, :is_active_plan => true)
			render json: {
				message: true,
				license_key: license_key
			}, status: 200
		else
			render json: {
				message: false
			}, status: 500
		end
		 # u=User.includes(:active_plans).find_by(id: '5d8867ca58e53d38e2824ef1')
	end

	def send_license_key_to_email
		debugger
		customer = User.find(params[:customer_id])
		active_plan = customer.get_active_plan rescue ""
		error = nil
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
			render json: {
				message: true
			}.to_json, status: 200
		else
			render json: {
				message: error
			}.to_json, status: 500
		end
	end

end
