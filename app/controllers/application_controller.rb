class ApplicationController < ActionController::Base
	layout :is_devise
	before_action :authenticate_user!

	def is_devise
		if devise_controller?
			"devise_layout"
		end
	end
end
