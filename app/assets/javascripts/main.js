$(document).ready(function() {
  FB.init({appId: "651908141502421", status: true, cookie: true});
  function postToFeed() {
    // calling the API ...
    var obj = {
      method: 'feed',
      redirect_uri: 'http://flyshortcut.com/flights',
      link: 'http://flyshortcut.com',
      picture: 'http://fbrell.com/f8.jpg',
      name: 'Fly Shortcut',
      caption: 'Cheaper than the cheapest flights',
      description: 'Find A:B:C flights that are cheaper than A:B flights and simply drop the last segment.'
    };

    function callback(response) {
      document.getElementById('msg').innerHTML = "Post ID: " + response['post_id'];
    }

    FB.ui(obj, callback);
  }

  var combinations = [];
  var from = [];
  var to = [];
	var regex = /\(([^\)]+)\)/;
  var pageCount = 1;
  var noMoreFlights = false;
  var emptySearch = false;
  
  $.ajax({
    url: '/flights',
    method: 'get',
    dataType: 'json'
  })
  .done(function(data) {
    combinations = data.combinations;
    from = data.from;
    to = data.to;
    totalPages = data.totalPages;
  })

  $('.all-flights').append("<div class='infinite-more'></div><div class='infinite-loading hide'><img src='/assets/loading.gif'></div>");

  $('.infinite-more').bind('inview', function(event, isInView, visiblePartX, visiblePartY) {
    if (isInView && !noMoreFlights && !emptySearch) {
      $('infinite-more').addClass('hide');
      updateFlights(null);
    }
  });

  !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');

  $('.fb-button').click(function() {
    FB.ui({
      method: 'feed',
      // redirect_uri: 'http://flyshortcut.com/flights',
      link: 'http://flyshortcut.com',
      picture: 'http://www.flyshortcut.com/img/fs_logo.png',
      name: 'Fly Shortcut',
      caption: 'Cheaper than the cheapest flights',
      description: 'Find A:B:C flights that are cheaper than A:B flights and simply drop the last segment.'
    }, function(response) {
        if (response && response.post_id) {
          alert('Your post was successfully published - thanks for sharing with your friends!');
        } else {
          alert('Post was not published.');
        }
      }
    );
  });

  $('#epic-button').popover({
    'placement': "bottom",
    'trigger': 'hover'
  });

  $('.book-button').popover({
    'placement': "left",
    'trigger': 'hover'
  });

  $('#signup-link').popover({
    'placement': "top",
    'trigger': 'hover'
  });

  $('.contact-us').popover({
    'placement': "left",
    'trigger': 'hover',
    'title': 'Contact us',
    'content': "We'd love to hear to your comments, suggestions, and travel stories!"
  });

  $('.dates-label').popover({
    'placement': "top",
    'trigger': 'hover',
    'title': 'Available dates',
    'content': "For now, we only have data for the next three months. We're working on it though!"
  });

  $('#signup-link').click(function() {
    $('#signup-link').toggle();
    $('#close-link').toggle();
    $('.email-signup').toggle();
  });

  $('#close-link').click(function() {
    $('.email-signup').toggle();
    $('#signup-link').toggle();
    $('#close-link').toggle();
  });

  $('.alert').bind('closed', function () {
    $('.email-signup').toggle();
    $('#signup-link').toggle();
    $('#close-link').toggle();
  })

  $('.close').click(function() {
    $('.email-signup').toggle();
    $('#signup-link').toggle();
    $('#close-link').toggle();
  });

  var today = new Date();
  var lastDay = new Date();
  lastDay.setDate(lastDay.getDate() + 90);

  $('input[name="daterange"]').daterangepicker(
    {
      ranges: {
        'Next 7 days': [new Date(), moment().add('days', 6)],
        'Next 30 days': [new Date(), moment().add('days', 29)]
      },
      minDate: (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear(),
      maxDate: (lastDay.getMonth() + 1) + "/" + lastDay.getDate() + "/" + lastDay.getFullYear()
    },
    function(start, end) {
      if (start) {
        $('#daterange').val(start.format('MMM D, YYYY') + ' - ' + end.format('MMM D, YYYY') );
      }
      updateFlights(true, null);
    }
  );

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
    updateFlights(thisSelection, $(this));
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
    updateFlights(thisSelection, $(this));
  });

  $('.filter').click(function() {
    var clicked = $(this).text();
    updateFlights(clicked, $(this));
  });
    
  var updateFlights = function(clicked, thisButton) {
    $('.infinite-more').addClass('hide');
    $('.filter').attr('disabled', 'disabled').addClass('disabled');
    $('#from-dropdown').attr('disabled', 'disabled').addClass('disabled');
    $('#to-dropdown').attr('disabled', 'disabled').addClass('disabled');
    var dates = $('#daterange').val();
    var type = null;
    var sort = null;
    var typeButton = $('.filter-type button:nth-child(1)');
    var sortButton = $('.filter-sort button:nth-child(1)');
    var from = $('#from-dropdown').val();
    var to = $('#to-dropdown').val();

    if (typeButton.hasClass('active')) {
      type = typeButton.text();
    }
    if (sortButton.hasClass('active')) {
      sort = sortButton.text();
    }

    if (clicked) {
      $('.loading').removeClass('hide');
      $('.hero-unit').remove();
      $('.all-stats').children().remove();
      $('.all-flights .no-flights').children().remove();
      $('.no-more-flights').remove();
      noMoreFlights = false;
      pageCount = 1;

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

      $.ajax({
        url: '/filter',
        method: 'get',
        dataType: 'json',
        data: { type: type, dates: dates, from: from, to: to, sort: sort, page: pageCount, clicked: clicked }
      })
      .done(function(data) {
        $('.infinite-more').before(data.flights);
        $('.all-stats').append(data.stats);
        $('.loading').addClass('hide');
        $('#epic-button').popover({
          'placement': "bottom",
          'trigger': 'hover'
        });
        $('.book-button').popover({
          'placement': "left",
          'trigger': 'hover'
        });
        if (data.noMoreFlights) {
          noMoreFlights = true;
        }
        else {
          $('.infinite-more').removeClass('hide');
        }
        $('.filter').removeAttr('disabled').removeClass('disabled');
        $('#from-dropdown').removeAttr('disabled').removeClass('disabled');
        $('#to-dropdown').removeAttr('disabled').removeClass('disabled');

        $('.empty-results-signup').click(function() {
          $('#signup-link').toggle();
          $('#close-link').toggle();
          $('.email-signup').toggle();
        });

        $('#second-email-button').click(function(e) {
          e.preventDefault();

          $.ajax({
            url: '/users',
            method: 'post',
            dataType: 'json',
            data: { email: $('#second-email').val() }
          })
          .done(function(data) {
            $('.flash').text("");
            $('.flash').removeClass("alert alert-errors");
            $('.flash').removeClass("hide");
            $('.flash').text("Added " + data.email);
          })
          .fail(function(data) {
            $('.flash').text("");
            $('.flash').removeClass("hide");
            $('.flash').addClass("alert alert-errors");
            $('.flash').html(data.responseText.replace("<BR>", ", "));
          })
        });
      })
    }
    else {
      pageCount += 1;
      $('.infinite-loading').removeClass('hide');
      $("html, body").animate({ scrollTop: $(document).height() }, "slow");

      $.ajax({
        url: '/filter',
        method: 'get',
        dataType: 'json',
        data: { type: type, dates: dates, from: from, to: to, sort: sort, page: pageCount, scroll: true }
      })
      .done(function(data) {
        $('.infinite-loading').addClass('hide');
        $('.infinite-more').removeClass('hide');
        $('.infinite-more').before(data.flights);
        $('#epic-button').popover({
          'placement': "bottom",
          'trigger': 'hover'
        });
        $('.book-button').popover({
          'placement': "left",
          'trigger': 'hover'
        });
        if (data.noMoreFlights) {
          noMoreFlights = true;
        }
        $('.infinite-loading').addClass('hide');
        $('.filter').removeAttr('disabled').removeClass('disabled');
        $('#from-dropdown').removeAttr('disabled').removeClass('disabled');
        $('#to-dropdown').removeAttr('disabled').removeClass('disabled');
      })
    }
  }

  $('.filter-type button:first-child').addClass('active');
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
        $(otherTag).append("<option value=" + '"' + otherArr[i] + '"' + ">" + otherArr[i] + "</option>");
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
        $(otherTag).append("<option value=" + '"' + tempArray[i] + '"' + ">" + tempArray[i] + "</option>");
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
