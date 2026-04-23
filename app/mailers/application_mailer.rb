class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("TRACKLANE_MAIL_FROM", "Tracklane <no-reply@tracklane.dev>")
  layout "mailer"
end
