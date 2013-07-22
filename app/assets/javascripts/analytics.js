$(document).ready(function() {
	$('#play-test').on('click', function(e) {
		e.preventDefault();
	  _gaq.push(['_trackEvent', 'Test', 'Click', 'Testing GA']);
	});
});