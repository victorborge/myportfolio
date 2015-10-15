class AdminMailer < ApplicationMailer
  default from: '"Reign Global" <notifications@reignglobal.com.sg>', to: 'admin@reignglobal.com.sg'

  def new_user_email(user)
    @user = user
    mail(subject: '[Reign Global] New User Signed Up')
  end

  def new_purchase_email(purchase)
    @purchase = purchase
    mail(subject: '[Reign Global] New Item Purchased')
  end
end
