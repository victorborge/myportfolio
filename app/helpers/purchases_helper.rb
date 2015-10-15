module PurchasesHelper
  def max_points(purchase)
    [current_user.points, purchase.item.amount * purchase.quantity].min
  end
end
