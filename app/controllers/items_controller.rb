class ItemsController < ApplicationController
  before_filter :authenticate_user!

  layout 'user'

  def index
    items_per_page = params[:items_per_page] || 10
    @items = Item.in_stock.order(created_at: :desc).page(params[:page]).per(items_per_page)
    @items = @items.joins(:categories).where(categories: { name: params[:category] }) if params[:category].present?
  end

  def show
    @item = Item.find(params[:id])
    render :show, layout: false
  end
end
