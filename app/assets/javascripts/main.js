$(document).ready(function() {
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
  })

  var selectedFrom = "Any";
  var selectedTo = "Any";
  var selectedDate = "Any";

  $("#from-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      selection1: $('#to-dropdown').val(),
      selection2: $('#dates-dropdown').val(),
      index: 0,
      otherTag1: "#to-dropdown",
      otherTag2: "#dates-dropdown",
      otherArr1: to,
      otherArr2: dates
    }
    dynamicDropdown(opts);
  });

  $("#to-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      selection1: $('#from-dropdown').val(),
      selection2: $('#dates-dropdown').val(),
      index: 1,
      otherTag1: "#from-dropdown",
      otherTag2: "#dates-dropdown",
      otherArr1: from,
      otherArr2: dates
    }
    dynamicDropdown(opts);
  });

  $("#dates-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      selection1: $('#from-dropdown').val(),
      selection2: $('#to-dropdown').val(),
      index: 2,
      otherTag1: "#from-dropdown",
      otherTag2: "#to-dropdown",
      otherArr1: from,
      otherArr2: to
    }
    dynamicDropdown(opts);
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

  var dynamicDropdown = function(opts){
    thisSelection = opts['thisSelection'];
    selection1 = opts['selection1'];
    selection2 = opts['selection2'];
    index = opts['index'];
    otherTag1 = opts['otherTag1'];
    otherTag2 = opts['otherTag2'];
    otherArr1 = opts['otherArr1'];
    otherArr2 = opts['otherArr2'];

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
      for (i = 0; i < otherArr1.length; i++ ) {
        $(otherTag1).append("<option value='" + otherArr1[i] + "'>" + otherArr1[i] + "</option>");
        if (otherArr1[i] == selection1) {
          $(otherTag1 + " option:last-child").attr("selected", "selected");
        }
      }
      for (i = 0; i < otherArr2.length; i++ ) {
        $(otherTag2).append("<option value='" + otherArr2[i] + "'>" + otherArr2[i] + "</option>");
        if (otherArr2[i] == selection2) {
          $(otherTag2 + " option:last-child").attr("selected", "selected");
        }
      }
    }
    else {
      var arr1 = [];
      var arr2 = [];

      $(otherTag1).append("<option value='Any'>Any</option>");
      $(otherTag2).append("<option value='Any'>Any</option>");

      for (i = 0; i < combinations.length; i++ ) {
        if (combinations[i][index] == thisSelection) {
          
          if ($.inArray(combinations[i][index1], arr1) == -1) {
            arr1.push(combinations[i][index1]);
          }
          if ($.inArray(combinations[i][index2], arr2) == -1) {
            arr2.push(combinations[i][index2]);
          }
        }
      }

      arr1 = arr1.sort();
      arr2 = arr2.sort();

      for (i = 0; i < arr1.length; i++ ) {
        $(otherTag1).append("<option value='" + arr1[i] + "'>" + arr1[i] + "</option>");
        if (arr1[i] == selection1) {
          $(otherTag1 + " option:last-child").attr("selected", "selected");
        }
      }
      for (i = 0; i < arr2.length; i++ ) {
        $(otherTag2).append("<option value='" + arr2[i] + "'>" + arr2[i] + "</option>");
        if (arr2[i] == selection2) {
          $(otherTag2 + " option:last-child").attr("selected", "selected");
        }
      }
    }
  }
});

  // $(function() {
 //    $('#datetimepicker4').datetimepicker({
 //      maskInput: true,           // disables the text input mask
  //    pickDate: true,            // disables the date picker
  //    pickTime: false,           // disables de time picker
  //    pick12HourFormat: false,   // enables the 12-hour format time picker
  //    pickSeconds: true,         // disables seconds in the time picker
  //    startDate: new Date(),     // set a minimum date
  //    endDate: new Date() + 7    // set a maximum date
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
