$(document).ready(function() {  
  $('#epic-button').popover({
    'placement': "bottom",
    'trigger': 'hover'
  });

  $('.book-button').popover({
    'placement': "bottom",
    'trigger': 'hover'
  });

  $('.close-pay-modal').popover({
    'placement': "right",
    'trigger': 'hover'
  });

  $('#signup-link').popover({
    'placement': "top",
    'trigger': 'hover'
  });

  $('.contact-us').popover({
    'placement': "bottom",
    'trigger': 'hover',
    'title': 'Contact us',
    'content': "We'd love to hear to your comments, suggestions, and travel stories!"
  });

  $('.dates-label').popover({
    'placement': "top",
    'trigger': 'hover',
    'title': 'Available dates',
    'content': "For now, we only have data for the next three months. We're working on it though!"
  });

  $('.actual-destination').popover({
    'placement': "right",
    'trigger': 'hover'
  });

  $('.returning-filters').popover({
    'title': "Returning flight",
    'content': "Please select a city to go to first.",
    'placement': "bottom",
    'trigger': 'hover'
  });
});