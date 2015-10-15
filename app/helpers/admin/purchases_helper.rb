module Admin::PurchasesHelper
  def action_button(purchase)
    if purchase.paid_at && !purchase.claimed_at
      link_to 'Mark as Collected', admin_purchase_claim_path(purchase),
            data: { confirm: 'Are you sure? This will permanently mark the item as collected by member.' },
            method: :post, class: 'btn btn-info btn-xs'
    elsif !purchase.paid_at && !purchase.paypal_id
      link_to 'Mark as Paid', admin_purchase_paid_path(purchase),
              data: { confirm: 'Are you sure? This will permanently mark the item as paid by member through COD.' },
              method: :post, class: 'btn btn-warning btn-xs'
    elsif purchase.paid_at && purchase.claimed_at
      "<a class='btn btn-success btn-xs' href='#!'>Collected</a>".html_safe
    end
  end
end
