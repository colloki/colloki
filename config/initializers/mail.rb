ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
	:address => "mail.icedlabs.com",
	:port => 26,
	:domain => "www.icedlabs.com",
	:authentication => :login,
	:user_name => "colloki+icedlabs.com",
	:password => "collokiMail"
}