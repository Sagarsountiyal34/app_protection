Rails.application.routes.draw do
	root to: "customers#list_customer"
	# devise_for :users
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    Rails.application.routes.draw do
    	devise_for :users, controllers: {
        	registrations: 'users/registrations',
        	sessions: 'users/sessions',
    		passwords: 'users/passwords'
    	}
        devise_scope :user do
            post 'users/create_customer', to: 'users/registrations#create_customer'
        end
    end

    get 'customers/list_customer', to: 'customers#list_customer'
    post 'activate_plan', to: 'customers#activate_plan'
    post 'activate_deactivate_plan', to: 'customers#activate_deactivate_plan'
    post 'change_plan_validity', to: 'customers#change_plan_validity'

    post 'send_license_key', to: 'customers#send_license_key_to_email'
    get 'customers/create_customer', to: 'customers#index'

    get 'customers/show/:id', to: 'customers#show', as:"customer_show"


    namespace 'api' do
        namespace 'v1' do
            post 'license_keys/check_license_key_validity', to: 'license_keys#check_license_key_validity'
        end
    end
    
end
