$(document).ready(function() {
  // $('#systemDownModal').modal("show");

  $(document).on("click", ".pay-button", function(e) {
    e.preventDefault();
    
    var itinerary = $(this).attr("data-itinerary");
    var cheapestPrice = parseInt($(this).attr("data-cheapest-price"));
    var shortcutPrice = parseInt($(this).attr("data-shortcut-price"));
    var savings = cheapestPrice - shortcutPrice;
    var shortcutFee = (savings / 4).toFixed(2);
    var shortcutDestination = $(this).attr("data-shortcut-airport") + " (" + $(this).attr("data-shortcut-airport-code") + ")";
    var stillSave = (savings - shortcutFee).toFixed(2);

    // $.get(
    //   "http://urls.api.twitter.com/1/urls/count.json?url=http://flyshortcut.com",
    //   {},
    //   function(data) {
    //     alert('page content: ' + data);
    //   }
    // );

    $("#donateModalLabel").text(itinerary);
    $("#pay-flight-number").text($(this).attr("data-flight-number"));
    $("#pay-flight-departure").text("Depart: " + $(this).attr("data-departure-time"));
    $("#pay-flight-arrival").text("Arrive: " + $(this).attr("data-arrival-time"));
    $("#pay-cheapest-price").text("$" + cheapestPrice);
    $("#pay-cheapest-offsite-link").attr("href", $(this).attr("data-offsite-original-link"))
    $("#pay-shortcut-price").text("$" + shortcutPrice);
    $("#pay-shortcut-savings").text("$" + savings);
    $("#pay-shortcut-fee").text("$" + shortcutFee);
    $("#pay-still-save").text("$" + stillSave);
    $("#pay-offsite-link").attr("href", $(this).attr("data-offsite-link"));
    $("#payModal").attr("data-shortcut-destination", shortcutDestination);

    // var twitterMessage = "What%3F!%20I%20just%20found%20a%20flight%20from%20" + itinerary + "%20for%20%24" + shortcutPrice + "!&tw_p=tweetbutton&url=http%3A%2F%2Fflyshortcut.com"
    // $("#facebook-share-link").attr("onclick", "popupwindow('https://www.facebook.com/sharer/sharer.php?u=http://www.flyshortcut.com/flights'" + itinerary + ", 'Share this Shortcut', '550', '550'); return false;");
    // $("#twitter-share-link").attr("href", "https://twitter.com/intent/tweet?hashtags=flyshortcut%2Ctravel&text=" + twitterMessage);

    if ($.cookie('shared')) {
      showBookingDetails();
      _gaq.push(['_trackEvent', 'button', 'shared-click', 'Book: ' + $(this).attr("data-ga-airport-tracking")]);
    } else {
      _gaq.push(['_trackEvent', 'button', 'unshared-click', 'Book: ' + $(this).attr("data-ga-airport-tracking")]);
    }

    $('#payModal').modal("show");

  });

  $(document).on("click", ".close-pay-modal", function(e) {
    $('#payModal').modal("hide");

    $(".donation-message").text("");
    $(".hide-after-payment").toggle();
    $(".show-after-payment").toggle();
  });

  $(document).on("click", ".social-share-button", function(e) {
    $(".social-share-button").toggle();
    $(".confirm-share").toggle();

    $.get(
      "http://graph.facebook.com/http://flyshortcut.com", function(data) {
        $("#facebook-share-link").attr("share-count", data.shares);
      }
    );
  });

  $(document).on("click", ".confirm-share", function(e) {
    var currentShares = null;

    $.get(
      "http://graph.facebook.com/http://flyshortcut.com", function(data) {
        currentShares = data.shares;
      }
    ).done(function() {
      var higherShareCount = currentShares > parseInt($("#facebook-share-link").attr("share-count"));
      // var higherShareCount = true;
      if (higherShareCount) {
        setSharedCookie();
        showBookingDetails();
      } else {
        $(".social-share-button").toggle();
        $(".confirm-share").toggle();
        alert("You need to share FlyShortcut on Facebook in order to unlock how to book a Shortcut flight!");
      }
    });
  });

  var setSharedCookie = function() {
    var date = new Date();
    var days = 7;
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    $.cookie('shared', true, { expires: date });
  }

  var showBookingDetails = function() {
    var flightNumber = $("#pay-flight-number").text();
    var shortcutDestination = $("#payModal").attr("data-shortcut-destination");
    $(".shortcut-instructions").html("Find " + flightNumber + " connecting on to " + shortcutDestination + ". Have fun, and remember to read about the <a href='http://www.flyshortcut.com/#panel3' target='_blank'>risks</a> before you shortcut!");

    $(".hide-after-payment").toggle();
    $(".show-after-payment").toggle();
  }
});