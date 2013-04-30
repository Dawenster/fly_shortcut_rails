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
  var from = []
  var to = []
  var dates = []
	var regex = /\(([^\)]+)\)/;
  
  $.ajax({
    url: '/flights',
    method: 'get',
    dataType: 'json'
  })
  .done(function(data) {
    combinations = data.combinations;
    from = data.from;
    to = data.to;
    dates = data.dates;
  })

  $("#from-dropdown").change(function() {
    var selected = $(this);
    $("#to-dropdown option").remove();
    $("#dates-dropdown option").remove();

    if (selected.val() == "Any") {
      for (i = 0; i < to.length; i++ ) {
        $("#to-dropdown").append("<option value=" + regex.exec(to[i]) + ">" + to[i] + "</option>");
      }
      for (i = 0; i < dates.length; i++ ) {
        $("#dates-dropdown").append("<option value=" + regex.exec(dates[i]) + ">" + dates[i] + "</option>");
      }
    }
    else {
      var toArray = [];
      var datesArray = [];

      $("#to-dropdown").append("<option value='Any'>Any</option>");
      $("#dates-dropdown").append("<option value='Any'>Any</option>");

      // Change date format

      for (i = 0; i < combinations.length; i++ ) {
        if (combinations[i][0] == selected.val()) {
          if ($.inArray(combinations[i][1], toArray) == -1) {
            toArray.push(combinations[i][1]);
          }
          if ($.inArray(combinations[i][2], datesArray) == -1) {
            datesArray.push(combinations[i][2]);
          }
        }
      }

      toArray = toArray.sort();
      datesArray = datesArray.sort();

      for (i = 0; i < toArray.length; i++ ) {
        $("#to-dropdown").append("<option value=" + regex.exec(toArray[i]) + ">" + toArray[i] + "</option>");
      }
      for (i = 0; i < datesArray.length; i++ ) {
        $("#dates-dropdown").append("<option value=" + regex.exec(datesArray[i]) + ">" + datesArray[i] + "</option>");
      }
    }
  });

  $('.form-inline').submit(function(e) {
    e.preventDefault();
  	var origin = "";
  	var destination = "";
  	var date = "";
  	var concat = "";

  	if ($('#from-dropdown').val() != "Any") {
  		origin = '.origin' + regex.exec($('#from-dropdown').val())[1];
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
