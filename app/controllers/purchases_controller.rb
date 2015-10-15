require 'paypal-sdk-rest'
class PurchasesController < ApplicationController
  include PurchasesHelper

  before_action :authenticate_user!
  before_action :set_item, only: [:new, :create]
  before_action :set_purchase, only: [:success, :cancel]

  layout 'user'

  # GET /purchases/new
  def new
    @purchase = @item.purchases.new
    @purchase.points = max_points(@purchase)
  end

  # POST /purchases
  # POST /purchases.json
  def create
    @purchase = @item.purchases.new(purchase_params.merge(user: current_user))

    if @purchase.save
      if !@purchase.using_cod && @purchase.amount - @purchase.points > 0
        @purchase.delay_for(1.hour).expire
        @payment = build_paypal_payment
        if @payment.create
          @purchase.update(paypal_id: @payment.id)
          redirect_to @payment.links.select { |link| link.rel == 'approval_url' }.first.href
        else
          redirect_to items_path, error: "Could not create PayPal payment. Please try again later. Error: #{@payment.error.inspect}"
        end
      else
        @purchase.complete
        redirect_to items_path, success: success_message
      end
    else
      render :new
    end
  end

  def success
    if params[:paymentId] != @purchase.paypal_id
      redirect_to items_path, error: "Invalid PayPal payment ID."
      return
    end

    payment = PayPal::SDK::REST::Payment.find(params[:paymentId])

    if payment.execute(payer_id: params[:PayerID])
      @purchase.complete
      redirect_to items_path, success: success_message
    else
      redirect_to items_path, error: "Could not complete PayPal payment. Please try again later. Error: #{@payment.error.inspect}"
    end
  end

  def cancel
    @purchase.destroy

    redirect_to items_path, alert: "Purchase cancelled."
  end

  private

  def build_paypal_payment
    items = [{ name: @purchase.item.name,
               sku: '%05d' % @purchase.item.id,
               price: '%.2f' % @purchase.item.amount,
               currency: "SGD",
               quantity: @purchase.quantity }]
    items << { name: 'CV Points',
               price: '%.2f' % -@purchase.points,
               currency: "SGD",
               quantity: 1 } if @purchase.points > 0

    PayPal::SDK::REST::Payment.new({
                                       intent: "sale",
                                       payer: {
                                           payment_method: "paypal",
                                       },
                                       transactions: [
                                           {
                                               item_list: {
                                                   items: items
                                               },
                                               amount: {
                                                   total: '%.2f' % @purchase.payment_amount,
                                                   currency: "SGD"
                                               },
                                               description: "Purchase of RG Products"
                                           }
                                       ],
                                       redirect_urls: {
                                           return_url: success_purchase_url(@purchase),
                                           cancel_url: cancel_purchase_url(@purchase)
                                       }
                                   })
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_purchase
    @purchase = Purchase.unscoped.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def purchase_params
    params.require(:purchase).permit(:quantity, :points, :using_cod)
  end

  def success_message
    'An email has been sent to you containing your purchase receipt. Please present this email when collecting your item from Reign Global.'
  end
end
