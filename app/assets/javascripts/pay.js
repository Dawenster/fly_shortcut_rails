$(document).ready(function() {  
  $(document).on("click", ".pay-button", function(e) {
    e.preventDefault();
    
    var cheapestPrice = parseInt($(this).attr("data-cheapest-price"));
    var shortcutPrice = parseInt($(this).attr("data-shortcut-price"));
    var savings = cheapestPrice - shortcutPrice;
    var shortcutFee = (savings / 4).toFixed(2);

    $("#donateModalLabel").text($(this).attr("data-itinerary"));
    $("#pay-flight-number").text($(this).attr("data-flight-number"));
    $("#pay-flight-departure").text("Depart: " + $(this).attr("data-departure-time"));
    $("#pay-flight-arrival").text("Arrive: " + $(this).attr("data-arrival-time"));
    $("#pay-cheapest-price").text("$" + cheapestPrice);
    $("#pay-shortcut-price").text("$" + shortcutPrice);
    $("#pay-shortcut-savings").text("$" + savings);
    $("#pay-shortcut-fee").text("$" + shortcutFee);
    $('#payModal').modal();

    _gaq.push(['_trackEvent', 'button', 'click', 'Book: ' + $(this).attr("data-ga-airport-tracking")]);
  });
});