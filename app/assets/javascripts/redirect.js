// $(document).ready(function() {
//   $('.redirect-link').click(function(e) {
//     e.preventDefault();

//     $('#overlay').removeClass('hide');
//     $('.redirect-box').removeClass('hide');

//     var flightID = $(this).parent().attr("data-flight-id");
//     var type = $(this).attr("type");

//     $.ajax({
//       url: '/offsite_flight/' + flightID,
//       method: 'get',
//       dataType: 'json',
//       data: { type: type }
//     })
//     .done(function(data) {
//       debugger
//     })
//   });
// });