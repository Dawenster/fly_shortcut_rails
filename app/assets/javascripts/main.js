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
    updateFlights(thisSelection);
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
    updateFlights(thisSelection);
  });

  $('.filter').click(function() {
    var clicked = $(this).text();
    updateFlights(clicked);
  });
    
  var updateFlights = function(clicked) {
    $('.all-flights').children('.hero-unit').remove();
    $('.all-flights no-flights').text("");
    $('.loading').removeClass('hide');
    var type = null;
    var sort = null;
    var month1 = null;
    var month2 = null;
    var month3 = null;
    var typeButton = $('.filter-type button:nth-child(1)');
    var monthButton1 = $('.filter-month button:nth-child(1)');
    var monthButton2 = $('.filter-month button:nth-child(2)');
    var monthButton3 = $('.filter-month button:nth-child(3)');
    var sortButton = $('.filter-sort button:nth-child(1)');
    var from = $('#from-dropdown').val();
    var to = $('#to-dropdown').val();

    if (typeButton.hasClass('active')) {
      type = typeButton.text();
    }
    if (sortButton.hasClass('active')) {
      sort = sortButton.text();
    }
    if (monthButton1.hasClass('active')) {
      month1 = monthButton1.text();
    }
    if (monthButton2.hasClass('active')) {
      month2 = monthButton2.text();
    }
    if (monthButton3.hasClass('active')) {
      month3 = monthButton3.text();
    }

    if (clicked == "Epic") {
      if (type) {
        type = null;
      }
      else {
        type = clicked;
      }
    }

    if (clicked == "All") {
      type = null;
    } 

    if (clicked == "Price") {
      if (sort) {
        sort = null;
      }
      else {
        sort = clicked;
      }
    }

    if (clicked == "Time") {
      sort = null;
    }

    if (clicked == monthButton1.text()) {
      if (month1) {
        month1 = null;
      }
      else {
        month1 = clicked;
      }
    }

    if (clicked == monthButton2.text()) {
      if (month2) {
        month2 = null;
      }
      else {
        month2 = clicked;
      }
    }

    if (clicked == monthButton3.text()) {
      if (month3) {
        month3 = null;
      }
      else {
        month3 = clicked;
      }
    }

    $.ajax({
      url: '/filter',
      method: 'get',
      dataType: 'json',
      data: { type: type, month1: month1, month2: month2, month3: month3, from: from, to: to, sort: sort }
    })
    .done(function(data) {
      $('.all-flights').append(data.partial);
      $('.loading').addClass('hide');
    })
  }

  $('.filter-type button:first-child').addClass('active');
  $('.filter-month button:nth-child(1)').addClass('active');
  $('.filter-month button:nth-child(2)').addClass('active');
  $('.filter-month button:nth-child(3)').addClass('active');
  $('.filter-sort button:first-child').addClass('active');

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
