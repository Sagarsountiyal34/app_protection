class GmailMailer < ApplicationMailer
	default from: "ashish@codegaragetech.com"

	def license_key_email(customer, license_key=nil)
    	@customer = customer
    	@license_key = license_key
    	mail(to: @customer.email, subject: 'Access Key of your application.')
  	end
end



# GmailMailer.sample_email(@user).deliver



  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #  :address => "smtp.gmail.com",
  #  :port => 587,
  #  :domain => "gmail.com",
  #  :user_name => "ashish@codegaragetech.com",
  #  :password => "Ashish$4444",
  #  :authentication => :plain,
  #  :enable_starttls_auto => true
  # }
