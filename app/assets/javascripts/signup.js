$(document).ready(function() {  
  $('.initial-signup-button').click(function(e) {
    e.preventDefault();

    $.ajax({
      url: '/users',
      method: 'post',
      dataType: 'json',
      data: { email: $('#initial-email').val(), city: $("#all-airports").val() }
    })
    .done(function(data) {
      $('.flash').text("");
      $('.flash').removeClass("alert alert-errors");
      $('.flash').removeClass("hide");
      if (data.noCity) {
        $('.flash').text(data.email + data.message);
      }
      else {
        $('.flash').text(data.email + data.message + " " + data.city_msg + data.city + ".");
      }
    })
    .fail(function(data) {
      $('.flash').text("");
      $('.flash').removeClass("hide");
      $('.flash').addClass("alert alert-errors");
      $('.flash').html(data.responseText.replace("<BR>", ", "));
    })
  });
});