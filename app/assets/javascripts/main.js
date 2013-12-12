$(document).ready(function() {
  !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');
  
  var from = [];
  var to = [];
  var regex = /\(([^\)]+)\)/;
  var pageCount = 1;
  var noMoreFlights = false;
  var emptySearch = false;
  var changedFromCity = false;

  $('#signup-link').removeClass("hidden");
  $('#signup-link').toggle();
  
  $.ajax({
    url: '/flights',
    method: 'get',
    dataType: 'json'
  })
  .done(function(data) {
    from = data.from;
    to = data.to;
    totalPages = data.totalPages;
  })

  if (Modernizr.touch) {
    $('.selectpicker').selectpicker('mobile');
    $(".first-time-here-content").toggle();
    $(".initial-email-content").toggle();
  } else {
    $('.selectpicker').selectpicker();
  }

  $('.all-flights').append("<div class='infinite-more'></div><div class='infinite-loading hide'><img src='/assets/loading.gif'></div>");

  $('.infinite-more').bind('inview', function(event, isInView, visiblePartX, visiblePartY) {
    if (isInView && !noMoreFlights && !emptySearch) {
      $('infinite-more').addClass('hide');
      updateFlights(null);
    }
  });

  var today = new Date();
  var lastDay = new Date();
  lastDay.setDate(lastDay.getDate() + 90);

  $('#daterange').daterangepicker(
    {
      minDate: (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear(),
      maxDate: (lastDay.getMonth() + 1) + "/" + lastDay.getDate() + "/" + lastDay.getFullYear()
    },
    function(start, end) {
      if (start) {
        $('#daterange').val(start.format('MMM D, YYYY') + ' - ' + end.format('MMM D, YYYY') );
      }
      updateFlights(true);
    }
  );

  $('#daterange-return').daterangepicker(
    {
      minDate: (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear(),
      maxDate: (lastDay.getMonth() + 1) + "/" + lastDay.getDate() + "/" + lastDay.getFullYear()
    },
    function(start, end) {
      if (start) {
        $('#daterange-return').val(start.format('MMM D, YYYY') + ' - ' + end.format('MMM D, YYYY') );
      }
      updateFlights(true);
    }
  );

  $('.returning-button').attr('disabled', 'disabled').addClass('disabled');
  $('#daterange-return').attr('disabled', 'disabled').addClass('disabled');

  $("#from-dropdown").change(function() { 
    $('#to-dropdown').val("Any");
    changedFromCity = true;
    switchDirection();
    disableReturnButton();
    updateFlights($(this).val());
  });

  $("#to-dropdown").change(function() {  
    updateFlights($(this).val());
    if ($('#to-dropdown').val() == "Any") {
      disableReturnButton();
    } else {
      enableReturnButton();
    }
  });

  $('.filter').click(function() {
    var clicked = $(this).text();
    updateFlights(clicked);
  });

  $('.segment button').click(function() {
    var clicked = null;
    if ($(this).hasClass("going-button")) {
      clicked = "Going";
    }
    else {
      clicked = "Returning";
    }

    updateFlights(clicked);

    if ($('.going-button').text() == "Showing") {
      $('.going-button').text("Click to show");
      $('.going-button').removeClass("active");
    }
    else {
      $('.returning-button').text("Click to show");
      $('.returning-button').removeClass("active");
    }
    $(this).text("Showing");
  });

  $(".book-button").click(function(e) {
    e.preventDefault();
    var win=window.open($(this).parent().attr("action"), '_blank');
    win.focus();
  });
    
  var updateFlights = function(clicked) {
    $('.infinite-more').addClass('hide');
    $('.filter').attr('disabled', 'disabled').addClass('disabled');
    $('#from-dropdown').attr('disabled', 'disabled').addClass('disabled');
    $('#to-dropdown').attr('disabled', 'disabled').addClass('disabled');
    var type = null;
    var sort = null;
    var dates = null;
    var segment = null;
    var typeButton = $('.filter-type button:nth-child(1)');
    var sortButton = $('.filter-sort button:nth-child(1)');
    var segmentButton = $('.going-button');
    var from = $('#from-dropdown').val();
    var to = $('#to-dropdown').val();

    if (typeButton.hasClass('active')) {
      type = typeButton.text();
    }
    if (sortButton.hasClass('active')) {
      sort = sortButton.text();
    }
    if (segmentButton.hasClass('active')) {
      segment = "Going"
      dates = $('#daterange').val();
    }
    else {
      dates = $('#daterange-return').val();
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
        type = "Epic";
      }

      if (clicked == "All") {
        type = null;
      } 

      if (clicked == "Price") {
        sort = "Price";
      }

      if (clicked == "Time") {
        sort = null;
      }

      if (clicked == "Returning") {
        segment = "";
        dates = $('#daterange-return').val();
      }

      $.ajax({
        url: '/filter',
        method: 'get',
        dataType: 'json',
        data: { type: type, dates: dates, from: from, to: to, sort: sort, segment: segment, page: pageCount }
      })
      .done(function(data) {
        if (changedFromCity) {
          updateDropdowns(data.destinations, data.destination_name);
        }

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
        $('.actual-destination').popover({
          'placement': "right",
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
        $('.selectpicker').selectpicker('refresh');
        clickedFilter(clicked);

        $(".book-button").click(function(e) {
          e.preventDefault();
          var win=window.open($(this).parent().attr("action"), '_blank');
          win.focus();
        });

        $('.empty-results-signup').click(function() {
          if ($('.email-signup').attr("style") == "display: none;") {
            $('.email-signup').toggle();
            $('#signup-link').toggle();
            $('#close-link').toggle();
            $('#initial-email').focus();
          } else {
            $('#initial-email').focus();
          }
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
        data: { type: type, dates: dates, from: from, to: to, sort: sort, segment: segment, page: pageCount, scroll: true }
      })
      .done(function(data) {
        if (changedFromCity) {
          updateDropdowns(data.destinations, data.destination_name);
        }

        $(".book-button").click(function(e) {
          e.preventDefault();
          var win=window.open($(this).parent().attr("action"), '_blank');
          win.focus();
        });

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
        $('.actual-destination').popover({
          'placement': "right",
          'trigger': 'hover'
        });

        if (data.noMoreFlights) {
          noMoreFlights = true;
        }
        $('.infinite-loading').addClass('hide');
        $('.filter').removeAttr('disabled').removeClass('disabled');
        $('#from-dropdown').removeAttr('disabled').removeClass('disabled');
        $('#to-dropdown').removeAttr('disabled').removeClass('disabled');
        $('.selectpicker').selectpicker('refresh');
        clickedFilter(clicked);
      })
    }
  }

  $('.filter-type button:first-child').addClass('active');
  $('.filter-sort button:first-child').addClass('active');
  $('.going-button').addClass('active');

  var updateDropdowns = function(destinations, name) {
    if (destinations.length > 0) {
      $("#to-dropdown option").remove();
      for (i = 0; i < destinations.length; i++ ) {
        $("#to-dropdown").append("<option value=" + '"' + destinations[i] + '"' + ">" + destinations[i] + "</option>");
        if (destinations[i] == name) {
          $("#to-dropdown option:last-child").attr("selected", "selected");
        }
      }
      changedFromCity = false;
    }
  }

  var switchDirection = function() {
    $('.going-button').text("Showing");
    $('.going-button').addClass("active");
    $('.returning-button').text("Click to show");
    $('.returning-button').removeClass("active");
  }

  var enableReturnButton = function() {
    $('.returning-button').removeAttr('disabled').removeClass('disabled');
    $('#daterange-return').removeAttr('disabled').removeClass('disabled');
    $(".returning-filters").popover('destroy');
  }

  var disableReturnButton = function() {
    $('.returning-button').attr('disabled', 'disabled').addClass('disabled');
    $('#daterange-return').attr('disabled', 'disabled').addClass('disabled');
    $('.returning-filters').popover({
      'title': "Returning flight",
      'content': "Please select a city to go to first.",
      'placement': "bottom",
      'trigger': 'hover'
    });
  }

  var clickedFilter = function(clicked) {
    if (clicked == "Epic") {
      $('.filter-type button:first-child').addClass('active');
      $('.filter-type button:last-child').removeClass('active');
    }

    if (clicked == "All") {
      $('.filter-type button:first-child').removeClass('active');
      $('.filter-type button:last-child').addClass('active');
    } 

    if (clicked == "Price") {
      $('.filter-sort button:first-child').addClass('active');
      $('.filter-sort button:last-child').removeClass('active');
    }

    if (clicked == "Time") {
      $('.filter-sort button:first-child').removeClass('active');
      $('.filter-sort button:last-child').addClass('active');
    }
  }
});
