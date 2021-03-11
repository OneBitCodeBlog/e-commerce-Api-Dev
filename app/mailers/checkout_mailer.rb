class CheckoutMailer < ApplicationMailer
  def success
    mail(to: params[:order].user.email, subject: default_i18n_subject(order_number: params[:order].id))
  end

  def generic_error
    mail(to: params[:order].user.email, subject: default_i18n_subject(order_number: params[:order].id))
  end

  def payment_error(message)
    @message = message
    mail(to: params[:order].user.email, subject: default_i18n_subject(order_number: params[:order].id))
  end
end