
let HEIGHT_LIST = new Object();

HEIGHT_LIST[1] = 6.7;
HEIGHT_LIST[2] = 9;
HEIGHT_LIST[3] = 11.3;
HEIGHT_LIST[4] = 13.6;
HEIGHT_LIST[5] = 16;
HEIGHT_LIST[6] = 18.5;

let MAXIMUM_ELEMENTS_COUNT = 0;

function CloseNUI() {
  $('#menu').fadeOut();

  $("#main").fadeOut();
  $('#main-elements-list').html('');
  $('#main-elements-page-list').html('');

	$.post('http://tpz_society/close', JSON.stringify({}));
}

// When loading for first time, we hide the UI for avoiding any displaying issues.
document.addEventListener('DOMContentLoaded', function() { 
  $('#menu').hide(); 
  $("#main").fadeOut();

  $('#main-elements-list').html('');
  $('#main-elements-page-list').html('');

}, false);

$(function() {

	window.addEventListener('message', function(event) {
		var item = event.data;

		if (item.type == "enable") {

			item.enable ? $('#menu').fadeIn() : $('#menu').fadeOut();
		
      if (item.enable) {
        $("#main").fadeIn();
      }
    }

		else if (item.action == "updateMainTitle"){
      $("#main-elements-title").text(item.cb);
    }
    
    else if (item.action == "insetElement"){
      var prod_option = item.option_det;

      let issuer = prod_option.issuer;

      var threshold = 20; // Start replacing with * after this value
      if (issuer.length > threshold) {
        issuer = issuer.replace(new RegExp(".(?=.{0," + (issuer.length-threshold-1) + "}$)", "g"), ' ');
      }
     
      MAXIMUM_ELEMENTS_COUNT = MAXIMUM_ELEMENTS_COUNT + 1

      $("#main-elements-list").append( 
        `<div id="main-elements-list-background-border"></div>` +
        `<div id="main-elements-list-label">` + issuer + `</div>` +
        `<div date = "` + prod_option.date + `" billIndex = "` + prod_option.id + `" id="main-elements-list-cost-label">` + `PAY NOW: ` + prod_option.cost + `$ ‎</div>`
      );
    }

    else if (event.data.action == 'resetPages'){
      $('#main-elements-list').html('');
      $('#main-elements-page-list').html('');

      MAXIMUM_ELEMENTS_COUNT = 0;
    } 
    
    else if (event.data.action == 'setTotalPages') {
      let pages    = event.data.total;
      let selected = event.data.selected;

      if (pages > 1 ) {

        $("#main-elements-page-list").css('margin-top', HEIGHT_LIST[MAXIMUM_ELEMENTS_COUNT] + "%");

        $.each(new Array(pages + 1), function( value ) {
          if (value != 0){
            var opacity = selected == value ? '0.7' : null;
            $("#main-elements-page-list").append(`<div page = "` + value + `" id="main-elements-page-list-value" style = "opacity: ` + opacity + `;" >` + value + `</div>`);
          }
        });

      }

    }

		else if (item.action == 'closeUI'){
			CloseNUI();
		}
		

	});

  $("body").on("keyup", function (key) {
    if (key.which == 27){ 
      CloseNUI();
    } 
  });

  $("#menu").on("click", "#main-elements-list-cost-label", function(event) {
    playAudio("button_click.wav");

    let $button      = $(this);
    let $billIndex   = $button.attr('billIndex');
    let $date        = $button.attr('date');

    $.post("http://tpz_society/performAction", JSON.stringify({
      billIndex : $billIndex,
      date : $date,
    }));

    CloseNUI();

  });

  $("#menu").on("click", "#main-elements-page-list-value", function() {
    playAudio("button_click.wav");

    var $button = $(this);
    var $selectedPage = $button.attr('page');

    $.post("http://tpz_society/selectPage", JSON.stringify({ page: $selectedPage }));
  });

  function playAudio(sound) {
    var audio = new Audio('./audio/' + sound);
    audio.volume = 0.1;
    audio.play();
  }

});
