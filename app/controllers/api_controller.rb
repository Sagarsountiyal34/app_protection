class ApiController < ActionController::API
	# We depend on our auth_token module here.
	
	require 'request_apis'
  	protected

		def render500(message="Something went wrong. Please try again after sometime.")
			render status: "500", json: {
				success: false,
				message: message
			}
		end

		def render404(message="Not Found")
			render status: "404", json: {
				success: false,
				message: message 
			}
		end

		def render409(job_id, message="Record already exists")
			render status: "409", json: {
				job_id: job_id,
				message: message
			}
		end
end