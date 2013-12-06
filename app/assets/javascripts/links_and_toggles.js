$(document).ready(function() {  
  $('#signup-link').click(function() {
    $('#signup-link').toggle();
    $('#close-link').toggle();
    $('.email-signup').toggle();
  });

  $('#close-link').click(function() {
    $('.email-signup').toggle();
    $('#signup-link').toggle();
    $('#close-link').toggle();
  });

  $('.alert').bind('closed', function () {
    $('.email-signup').toggle();
    $('#signup-link').toggle();
    $('#close-link').toggle();
  })

  $('.close').click(function() {
    $('.email-signup').toggle();
    $('#signup-link').toggle();
    $('#close-link').toggle();
  });

  $('.learn-more-close').click(function() {
    $.ajax({
      url: '/visited'
    })
  });
});