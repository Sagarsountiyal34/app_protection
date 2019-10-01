module Api
	module V1
		class LicenseKeysController < ApiController
			
			def check_license_key_validity
				begin
					license_key = params[:license_key]
					mac_address = params[:mac_address]
					if license_key.present? and mac_address.present?
						active_plan = ActivePlan.find_by(:license_key => license_key)
						if active_plan.present? and active_plan.mac_address.present? and active_plan.mac_address != mac_address
							render_not_found("This key is already in used  by some other devise.")
						elsif active_plan.present?
							active_plan.mac_address = mac_address
							if active_plan.is_expired?
								render status: "200", json:{ message: "Plan has been expired.", status: false}
							elsif active_plan.save
								render status: "200", json: { message: "Success", status: true }
							else
								render_not_found
							end
						else
							render_not_found('Invalid Key.')
						end
					else
						render_not_found('Please Enter License Key and Mac Address.')
					end
				rescue Exception => e
					render500
				end
				
			end

			def render_not_found(message="Something is wrong.")
				render status: "200", json: { message: message, status: false }
			end

			def render500(message="Something went wrong. Please try again after sometime.")
				render status: "500", json: { message: message,status: false }
			end
		end
	end
end

