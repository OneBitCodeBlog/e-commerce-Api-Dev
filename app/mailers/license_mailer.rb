class LicenseMailer < ApplicationMailer
  def send_license
    mail(to: params[:license].line_item.order.user.email)
  end
end