$(document).ready(function() {
  setTimeout(function() {
    swal({
      title: "We're taking a break :)",
      text: "Sorry for the inconvenience...",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "Sign up for alerts",
      cancelButtonText: "How come?!",
      closeOnConfirm: false,
      closeOnCancel: false,
      allowOutsideClick: true
    }, 
    function(isConfirm){
      var url = ""
      if (isConfirm) {
        url = "/blog";
      } else {
        url = "http://www.bloomberg.com/news/2014-11-18/united-orbitz-sue-travel-site-over-hidden-city-ticketing-1-.html";
      }
      window.location = url;
    });
  }, 500);

  $('.let-me-proceed').click(function(e){
    e.preventDefault();
    var text = "Sorry for the inconvenience..."
    swal({
      title: "We're taking a break :)",
      text: text,
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "Sign up for alerts",
      cancelButtonText: "How come?!",
      closeOnConfirm: false,
      closeOnCancel: false,
      allowOutsideClick: true
    }, 
    function(isConfirm){
      var url = ""
      if (isConfirm) {
        url = "/blog";
      } else {
        url = "http://www.bloomberg.com/news/2014-11-18/united-orbitz-sue-travel-site-over-hidden-city-ticketing-1-.html";
      }
      window.location = url;
    });
  });
});