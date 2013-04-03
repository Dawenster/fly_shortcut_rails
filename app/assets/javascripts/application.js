$(document).ready(function() {
	$(function() {
    $('#datetimepicker4').datetimepicker({
      maskInput: true,           // disables the text input mask
		  pickDate: true,            // disables the date picker
		  pickTime: false,           // disables de time picker
		  pick12HourFormat: false,   // enables the 12-hour format time picker
		  pickSeconds: true,         // disables seconds in the time picker
		  startDate: new Date(),     // set a minimum date
		  endDate: new Date() + 7    // set a maximum date
    });
  });

  $(function() {
    var availableTags = [
      "San Francisco International, CA (SFO)"
    ];
    $("#origin").autocomplete({
      source: availableTags,
    });
  });

  $(function() {
    var availableTags = [
      "New York John F Kennedy International, NY (JFK)",
      "Houston George Bush Intercntl, TX (IAH)",
      "Chicago O'Hare, IL (ORD)"
    ];
    $("#destination").autocomplete({
      source: availableTags
    });
  });



  $('.form-inline').submit(function(e) {
  	e.preventDefault();
  	var regex = /\(([^\)]+)\)/;
  	var origin = "";
  	var destination = "";
  	var date = "";
  	var concat = "";

  	if ($('#origin').val() != "") {
  		origin = '.origin' + regex.exec($('#origin').val())[1];
  		concat = origin;
  	}

  	if ($('#destination').val() != "") {
  		destination = '.destination' + regex.exec($('#destination').val())[1];
  		concat = concat + destination
  	}

  	if ($('#date').val() != "") {
  		date = '.' + $('#date').val();
  		concat = concat + date
  	}

  	if (concat == "") {
  		concat = '.hero-unit';
  	}

  	$('.hero-unit').show().effect('fade');
  	$(concat).hide().effect('fade');


  // 	$.ajax({
  // 		url: '/' + origin + destination + date,
  // 		method: 'post',
  // 		data: {origin: origin, destination: destination, date: date}
  // 	})
  });
});










