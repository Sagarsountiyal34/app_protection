module Api
	module V1
		class LicenseKeysController < ApiController
			def check_license_key_validity #add month and add expiry date
				begin
					license_key = params[:license_key]
					mac_address = params[:mac_address]
					status = false
					if license_key.present? and mac_address.present?
						active_plan = ActivePlan.find_by(:license_key => license_key)
						if active_plan.present?
							if active_plan.is_active_plan_used?(mac_address)
								render_not_found("This key is already in used  by some other devise.")
							else
								no_of_days_left = (ActivePlan.last.end_date.to_date - Time.now.to_date).to_i
								if !active_plan.is_mac_address_present?
									active_plan.mac_address = mac_address
									if active_plan.save
										status = true
									end
								else
									status = true
								end
								message = no_of_days_left <= 15 ? "Plan will expire in #{no_of_days_left}" : "Plan have validity greater than 15 days.stay cool"
								if active_plan.is_expired?
									render status: "200", json: { message: "Plan has been expired.", status: false }
								elsif status
									render status: "200", json: { message: message, status: true, no_of_days_left: no_of_days_left, plan_name: active_plan.plan_name, expiry_date: active_plan.end_date.to_date }
								else
									render_not_found
								end
							end
						else
							render_not_found('Invalid Key.')
						end
					else
						render_not_found('Please send License Key and Mac Address.')
					end
				rescue Exception => e
					render500
				end
			end
			def notification_receive
				begin
					license_key = params[:license_key]
					if license_key.present?
						active_plan = ActivePlan.find_by(:license_key => license_key) rescue ""
						user =  User.find(active_plan.user_id) rescue ""
						if active_plan.present? and user.present?
							no_of_days_left = (active_plan.last.end_date.to_date - Time.now.to_date).to_i
							if no_of_days_left >= 15
								render status: "200", json: { have_to_show_message: false}
							elsif !user.is_today_notification_sent?
								user.update_attribute(:last_notification_sent_time => Time.now.to_date)
								render status: "200", json: { have_to_show_message: true, no_of_days_left: no_of_days_left, plan_name: active_plan.plan_name, expiry_date: active_plan.end_date.to_date }
							end
						else
							render_not_found('Invalid Key.')
						end
					else
						render_not_found('Please send License Key.')
					end
				rescue Exception => e
					render500
				end
			end

			private
			def render_not_found(message="Something is wrong.")
				render status: 404, json: { message: message, status: false }
			end

			def render500(message="Something went wrong. Please try again after sometime.")
				render status: 500, json: { message: message,status: false }
			end

		end
	end
end

