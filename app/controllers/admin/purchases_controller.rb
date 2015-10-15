class Admin::PurchasesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_purchase, only: [:claim, :paid]
  layout 'admin'

  def index
    @purchases = Purchase.joins(:user, :item).search(params[:search]).order(created_at: :desc).page(params[:page]).per(10)
  end

  def claim
    Purchase.transaction do
      @purchase.update(claimed_at: Time.now)

      if @purchase.errors.empty?
        @purchase.award_parent_points
        flash[:success] = 'Purchase successfully marked as claimed.'
      else
        flash[:error] = @purchase.errors.full_messages.join('. ')
      end
    end

    redirect_to admin_purchases_path
  end

  def paid
    @purchase.update(paid_at: Time.now)

    if @purchase.errors.empty?
      flash[:success] = 'Purchase successfully marked as paid through COD.'
    else
      flash[:error] = @purchase.errors.full_messages.join('. ')
    end

    redirect_to admin_purchases_path
  end


  private

  def set_purchase
    @purchase = Purchase.find(params[:purchase_id])
  end
end
