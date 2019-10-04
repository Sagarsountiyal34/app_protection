module Api
	module V1
		class LicenseKeysController < ApiController
			
			def check_license_key_validity
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
								if !active_plan.is_mac_address_present?
									active_plan.mac_address = mac_address
									status = true if active_plan.save rescue false
								else
									status = true
								end
								if active_plan.is_expired?
									render_not_found('Plan has been expired.')
								elsif status
									render status: "200", json: { message: "Success", status: true }
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

			private
			def render_not_found(message="Something is wrong.")
				render status: 500, json: { message: message, status: false }
			end

			def render500(message="Something went wrong. Please try again after sometime.")
				render status: 500, json: { message: message,status: false }
			end

		end
	end
end

