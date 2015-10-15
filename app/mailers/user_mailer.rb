class UserMailer < ApplicationMailer
  default from: '"Reign Global" <notifications@reignglobal.com.sg>'

  def purchase_receipt_email(purchase)
    @purchase = purchase
    mail(subject: "Reign Global - Item ##{"%05d" % @purchase.item.id} Purchase", to: @purchase.user.email)
  end
end
