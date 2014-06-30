$(document).ready(function() {
  $('#stripeDonateButton').click(function(){
    $(".donation-message").text("");

    var token = function(res){
      var $input = $('<input type=hidden name=stripeToken />').val(res.id);
      $('donation-form').append($input).submit();
    };

    // var amount = $("#custom-donation").val();
    var amountText = $("#pay-shortcut-fee").text();
    var amount = parseFloat(amountText.substring(1));

    if (!isNumber(amount)) {
      amount = "5";
    }
    amount = parseFloat(amount) * 100;

    var stripePK = $(".donation-form").attr("data-stripe-pk");

    StripeCheckout.open({
      key:         stripePK,
      address:     false,
      amount:      amount,
      currency:    'usd',
      name:        'Fly Shortcut',
      description: '25% of Savings',
      image:       'https://s3-us-west-2.amazonaws.com/flyshortcut/flyshortcut_icon.png',
      panelLabel:  'Checkout',
      token: function(token, args) {
        $(".hide-after-payment").toggle();
        $(".donation-processing-message").toggle();

        $.ajax({
          url: "/donate",
          type: "post",
          data: { stripeToken: token, amount: amount }
        })
        .done(function(data) {
          $(".show-after-payment").toggle();

          if (data.success == true) {
            $(".donation-processing-message").toggle();
            // $(".pay-booking-instructions").toggle();
            $(".donation-message").text(data.message);

            var flightNumber = $("#pay-flight-number").text();
            var shortcutDestination = $("#payModal").attr("data-shortcut-destination");

            $(".shortcut-instructions").html("Find " + flightNumber + " connecting on to " + shortcutDestination + ". Have fun, and remember to read about the <a href='http://www.flyshortcut.com/#panel3' target='_blank'>risks</a> before you shortcut!");

            // setTimeout(function(){
            //   $('#donateModal').modal('hide');
            //   $(".hide-after-payment").toggle();
            //   $(".show-after-payment").toggle();

            //   $(".donation-processing-message").toggle();
            //   $(".donation-message").text("");
            // }, 3000);
            
          } else {
            $(".donation-processing-message").toggle();
            $(".donation-message").text(data.message + " Please try again!");
            $(".hide-after-payment").toggle();
          }
        })
      }
    });

    return false;
  });

  function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }
});