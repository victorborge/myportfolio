$(document).on 'ready page:load', ->
  $('.chosen-select').chosen
    allow_single_deselect: true
    no_results_text: 'No results found'

$(document).on 'click', '.see-more', (e) ->
  e.preventDefault()
  $.get($(this).attr('href'), (data) ->
    $('#item-modal-content').html(data)
  )
  $('#item-modal-title').html($(this).parents('.post-container').data('title'))
  $('#item-modal').modal('show')


$(document).on 'change', '#items_per_page', ->
  $(this).parents('form').submit()