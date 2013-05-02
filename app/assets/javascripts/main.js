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
  var combinations = [];
  var from = [];
  var to = [];
  var dates = [];
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
    readable_dates = data.readable_dates;
  })

  var selectedFrom = "Any";
  var selectedTo = "Any";
  var selectedDate = "Any";

  $("#from-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      index: 0,
      otherTag1: "#to-dropdown",
      otherTag2: "#dates-dropdown",
      otherArr1: to,
      otherArr2: dates,
      otherArr3: readable_dates
    }
    dynamicDropdown(opts);
  });

  $("#to-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      index: 0,
      otherTag1: "#from-dropdown",
      otherTag2: "#dates-dropdown",
      otherArr1: from,
      otherArr2: dates,
      otherArr3: readable_dates
    }
    dynamicDropdown(opts);
  });

  $("#dates-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      index: 0,
      otherTag1: "#from-dropdown",
      otherTag2: "#to-dropdown",
      otherArr1: from,
      otherArr2: to,
      otherArr3: to
    }
    dynamicDropdown(opts);
  });

  // $("#from-dropdown").change(function() {
  //   selectedFrom = $(this);
  //   $("#to-dropdown option").remove();
  //   $("#dates-dropdown option").remove();

  //   if (selectedFrom.val() == "Any") {
  //     for (i = 0; i < to.length; i++ ) {
  //       $("#to-dropdown").append("<option value=" + regex.exec(to[i]) + ">" + to[i] + "</option>");
  //     }
  //     for (i = 0; i < readable_dates.length; i++ ) {
  //       $("#dates-dropdown").append("<option value=" + regex.exec(dates[i]) + ">" + readable_dates[i] + "</option>");
  //     }
  //   }
  //   else {
  //     var toArray = [];
  //     var datesArray = [];
  //     var readableDatesArray = []

  //     $("#to-dropdown").append("<option value='Any'>Any</option>");
  //     $("#dates-dropdown").append("<option value='Any'>Any</option>");

  //     for (i = 0; i < combinations.length; i++ ) {
  //       if (combinations[i][0] == selectedFrom.val()) {
  //         if ($.inArray(combinations[i][1], toArray) == -1) {
  //           toArray.push(combinations[i][1]);
  //         }
  //         if ($.inArray(combinations[i][2], datesArray) == -1) {
  //           datesArray.push(combinations[i][2]);
  //           readableDatesArray.push(combinations[i][3]);
  //         }
  //       }
  //     }

  //     toArray = toArray.sort();
  //     datesArray = datesArray.sort();
  //     readableDatesArray = readableDatesArray.sort();

  //     for (i = 0; i < toArray.length; i++ ) {
  //       $("#to-dropdown").append("<option value=" + regex.exec(toArray[i]) + ">" + toArray[i] + "</option>");
  //     }
  //     for (i = 0; i < datesArray.length; i++ ) {
  //       $("#dates-dropdown").append("<option value=" + regex.exec(datesArray[i]) + ">" + readableDatesArray[i] + "</option>");
  //     }
  //   }
  // });

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

  var dynamicDropdown = function(opts){
    thisSelection = opts['thisSelection'];
    index = opts['index'];
    otherTag1 = opts['otherTag1'];
    otherTag2 = opts['otherTag2'];
    otherArr1 = opts['otherArr1'];
    otherArr2 = opts['otherArr2'];
    otherArr3 = opts['otherArr3'];

    var index3 = 3;

    if (index == 0) {
      var index1 = 1;
      var index2 = 2;
    }
    else if (index == 1) {
      var index1 = 0;
      var index2 = 2;
    }
    else if (index == 2) {
      var index1 = 0;
      var index2 = 1;
    }

    $(otherTag1 + " option").remove();
    $(otherTag2 + " option").remove();

    if (thisSelection == "Any") {
      for (i = 0; i < to.length; i++ ) {
        $(otherTag1).append("<option value=" + regex.exec(otherArr1[i]) + ">" + otherArr1[i] + "</option>");
      }
      for (i = 0; i < readable_dates.length; i++ ) {
        $(otherTag2).append("<option value=" + regex.exec(otherArr2[i]) + ">" + otherArr3[i] + "</option>");
      }
    }
    else {
      var arr1 = [];
      var arr2 = [];
      var arr3 = [];

      $(otherTag1).append("<option value='Any'>Any</option>");
      $(otherTag2).append("<option value='Any'>Any</option>");

      for (i = 0; i < combinations.length; i++ ) {
        if (combinations[i][index] == thisSelection) {
          if ($.inArray(combinations[i][index1], arr1) == -1) {
            arr1.push(combinations[i][index1]);
          }
          if ($.inArray(combinations[i][index2], arr2) == -1) {
            arr2.push(combinations[i][index2]);
            arr3.push(combinations[i][index3]);
          }
        }
      }

      arr1 = arr1.sort();
      arr2 = arr2.sort();
      arr3 = arr3.sort();

      for (i = 0; i < arr1.length; i++ ) {
        $(otherTag1).append("<option value=" + regex.exec(arr1[i]) + ">" + arr1[i] + "</option>");
      }
      for (i = 0; i < arr2.length; i++ ) {
        $(otherTag2).append("<option value=" + regex.exec(arr2[i]) + ">" + arr3[i] + "</option>");
      }
    }
  }
});
