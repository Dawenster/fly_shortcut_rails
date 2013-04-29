$(document).ready(function() {
	// $(function() {
 //    $('#datetimepicker4').datetimepicker({
 //      maskInput: true,           // disables the text input mask
	// 	  pickDate: true,            // disables the date picker
	// 	  pickTime: false,           // disables de time picker
	// 	  pick12HourFormat: false,   // enables the 12-hour format time picker
	// 	  pickSeconds: true,         // disables seconds in the time picker
	// 	  startDate: new Date(),     // set a minimum date
	// 	  endDate: new Date() + 7    // set a maximum date
 //    });
 //  });

  // $(function() {
  //   var availableTags = airports;
  //   $("#origin").autocomplete({
  //     source: availableTags,
  //   });
  // });

  // $(function() {
  //   var availableTags = airports;
  //   $("#destination").autocomplete({
  //     source: availableTags
  //   });
  // });
  var combinations = []
  
  $.ajax({
    url: '/flights',
    method: 'get',
    dataType: 'json'
  })
  .done(function(data) {
    combinations = data;
  })

  $("#from-dropdown").change(function() {
    var selected = $(this);

    $("#to-dropdown option").remove();
    $("#dates-dropdown option").remove();
    $("#to-dropdown").append("<option value='Any'>Any</option>");
    $("#dates-dropdown").append("<option value='Any'>Any</option>");

    // Still need to make sure that duplicates don't show up
    for (i = 0; i < combinations.length; i++ ) {
      if (combinations[i][0] == selected) {
        $("#to-dropdown").append("<option value=" + combinations[i][1] + ">" + combinations[i][1] + "</option>");
        $("#dates-dropdown").append("<option value=" + combinations[i][2] + ">" + combinations[i][2] + "</option>");
      }
    }
  });

  $('.form-inline').submit(function(e) {
  	e.preventDefault();
  	var regex = /\(([^\)]+)\)/;
  	var origin = "";
  	var destination = "";
  	var date = "";
  	var concat = "";

  	if ($('#from-dropdown').val() != "Any") {
  		origin = '.origin' + regex.exec(s$('#from-dropdown').val())[1];
  		concat = origin;
  	}

  	if ($('#to-dropdown').val() != "Any") {
  		destination = '.destination' + regex.exec($('#to-dropdown').val())[1];
  		concat = concat + destination
  	}

  	if ($('#dates-dropdown').val() != "Any") {
  		date = '.' + $('#dates-dropdown').val();
  		concat = concat + date
  	}

  	if (concat == "") {
  		concat = '.hero-unit';
  	}

  	$('.hero-unit').show().effect('fade');
  	$(concat).hide().effect('fade');
  });
});
