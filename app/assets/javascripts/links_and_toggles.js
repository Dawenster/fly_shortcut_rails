$(document).ready(function() {  
  $('#signup-link').click(function() {
    $('#signup-link').toggle();
    $('#close-link').toggle();
    $('.email-signup').toggle();
    $('#initial-email').focus();
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

  if (Modernizr.touch) {
    $(".first-time-here").click(function() {
      $(".first-time-here-content").toggle();
    });

    $(".email-signup").click(function() {
      $(".initial-email-content").toggle();
    });
  }

  $('.learn-more-close').click(function() {
    $.ajax({
      url: '/visited'
    })
  });
});