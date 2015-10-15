$(document).on 'click', 'label[for="user_avatar"]', () ->
  $('#avatar_save').css('display', 'block')

$(document).on 'ready page:load', () ->
  $('#calendar').fullCalendar(
    header:
      right: 'prev,next today'
      left: 'title'
      center: 'month agendaWeek agendaDay'
    timeFormat: 'h(:mm)a'
    events:
      url: '/profile/events.json'
      error: () ->
        alert('There was an error while fetching events!')
    eventClick: (calEvent) ->
      window.location.href = '/profile/events?id=' + calEvent.id
  )