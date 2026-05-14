Rails.application.config.middleware.use OmniAuth::Builder do
 # provider :developer if Rails.env.development?
 # provider :google, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], scope: 'user:email'

  #  OmniAuth.config.allowed_request_methods = [:post, :get]
   # OmniAuth.config.silence_get_warning = true
end