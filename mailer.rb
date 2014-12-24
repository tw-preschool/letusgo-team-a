# encoding: UTF-8
class Mailer < ActionMailer::Base
	default from: 'tw.letusgo@gmail.com'
	def contact user
		subject = "#{user.name}，欢迎加入Let's Go"
		email_body = "<p>尊敬的#{user.name}:</p><p style='text-indet:2em;'>感谢您注册Let's Go！</p><img src='#' alt='Let's Go logo'/>"
		mail(to: user.email, body: email_body, content_type: "text/html", subject: subject)
	end

	configure do
		ActionMailer::Base.delivery_method = :smtp
		ActionMailer::Base.smtp_settings = {
			:address            => "smtp.gmail.com",
			:domain            => "gmail.com",
			:port               => 587,
			:authentication     => "plain" ,
			:user_name          => 'tw.letusgo',
			:password           => 'letusgo-teama',
			:enable_starttls_auto => true
		}
		ActionMailer::Base.perform_deliveries = true
		ActionMailer::Base.raise_delivery_errors = true
	end
end