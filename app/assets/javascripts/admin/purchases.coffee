$(document).on 'ready page:load', ->
  $('[data-toggle="tooltip"]').tooltip()

$(document).on 'change keyup mousewheel', '#new_purchase input', ->
  unit_price = $('#purchase_price').data('amount')
  user_points = $('#purchase_points').data('user_points')
  points = $('#purchase_points').val()
  quantity = $('#purchase_quantity').val()
  subtotal = unit_price * quantity
  total = subtotal - points

  $('#purchase_points').attr('max', Math.min(user_points, subtotal))
  $('#purchase_subtotal').html('$' + subtotal + '.00')
  $('#purchase_total').html('$' + total + '.00')
  $('#purchase_button').val(if total > 0 then 'Checkout with PayPal' else 'Checkout')


$(document).on 'click', '#cod_button', (e) ->
  e.preventDefault()
  $('#purchase_using_cod').val(true)
  $('#new_purchase').submit()