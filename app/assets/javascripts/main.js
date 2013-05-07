$(document).ready(function() {
  var combinations = [];
  var from = [];
  var to = [];
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
  })

  var selectedFrom = "Any";
  var selectedTo = "Any";

  $("#from-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      selection: $('#to-dropdown').val(),
      index: 0,
      otherTag: "#to-dropdown",
      otherArr: to
    }
    dynamicDropdown(opts);
  });

  $("#to-dropdown").change(function() {  
    opts = {
      thisSelection: $(this).val(),
      selection: $('#from-dropdown').val(),
      index: 1,
      otherTag: "#from-dropdown",
      otherArr: from
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

  	if (concat == "") {
  		concat = '.hero-unit';
  	}

  	$('.hero-unit').show().effect('fade');
  	$(concat).hide().effect('fade');
  });

  $('.filter-type button').click(function() {
    var type = $(this).text();
    typeFilter(type);
  });

  var typeFilter = function(type) {
    $('.hero-unit').show().effect('fade');
    if (type == "Epic") {
      $('.epic').hide().effect('fade');
    }
    else {
      $('.hero-unit').hide().effect('fade');
    }
  }

  typeFilter("Epic");
  $('.filter-type button:first-child').addClass('active');

  var dynamicDropdown = function(opts) {
    thisSelection = opts['thisSelection'];
    selection = opts['selection'];
    index = opts['index'];
    otherTag = opts['otherTag'];
    otherArr = opts['otherArr'];

    if (index == 0) {
      var otherIndex = 1;
    }
    else if (index == 1) {
      var otherIndex = 0;
    }

    $(otherTag + " option").remove();

    if (thisSelection == "Any") {
      for (i = 0; i < otherArr.length; i++ ) {
        $(otherTag).append("<option value='" + otherArr[i] + "'>" + otherArr[i] + "</option>");
        if (otherArr[i] == selection) {
          $(otherTag + " option:last-child").attr("selected", "selected");
        }
      }
    }
    else {
      var tempArray = [];

      $(otherTag).append("<option value='Any'>Any</option>");

      for (i = 0; i < combinations.length; i++ ) {
        if (combinations[i][index] == thisSelection) {
          if ($.inArray(combinations[i][otherIndex], tempArray) == -1) {
            tempArray.push(combinations[i][otherIndex]);
          }
        }
      }

      tempArray = tempArray.sort();

      for (i = 0; i < tempArray.length; i++ ) {
        $(otherTag).append("<option value='" + tempArray[i] + "'>" + tempArray[i] + "</option>");
        if (tempArray[i] == selection) {
          $(otherTag + " option:last-child").attr("selected", "selected");
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
