$(document).ready(function(){
	$('#control-panel-click').click(function(){
  		$('#control-panel-div').slideToggle(200);
  	});
  	
  	setTimeout(refreshGraph, 1000);
  	
  	// Load the topology graph
  	$.post('/gateway/topology', function(data){
  		$('#topology-canvas').html(data);
  	});
});


// Function to update the graph on the front page 
function refreshGraph() {
	$.get('/gateway/stats', function(data){
		$('#zonestatistics').html(data);
	});
	setTimeout(refreshGraph, 60000);
}

// variable to hold request
var request;

// bind to the submit event of our form
$("#gateway-system-start").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway
    var request = $.ajax({
        url: "/gateway",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#gateway-response").html(response);
        $("#statusimg").attr("src", "images/glossy_green_button.svg");
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#gateway-response").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});

// bind to the submit event of our form
$("#gateway-system-stop").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway
    var request = $.ajax({
        url: "/gateway",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#gateway-response").html(response);
        $("#statusimg").attr("src", "images/glossy_red_button.svg");
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#gateway-response").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});

// bind to the submit event of our form
$("#gateway-system-config").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway
    var request = $.ajax({
        url: "/gateway",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#gateway-response").html(response);
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#gateway-response").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});

// bind to the submit event of our form
$("#gateway-system-restart").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway
    var request = $.ajax({
        url: "/gateway",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#gateway-response").html(response);
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#gateway-response").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});

// bind to the submit event of our form
$("#gateway-zones").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway/zones
    var request = $.ajax({
        url: "/gateway/zones",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#zones-content").html(response);
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#zones-content").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});


// bind to the submit event of our form
$("#gateway-nodes").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway/nodes
    var request = $.ajax({
        url: "/gateway/nodes",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#nodes-content").html(response);
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#nodes-content").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});


// bind to the submit event of our form
$("#gateway-packets").submit(function(event){
    // abort any pending request
    if (request) {
        request.abort();
    }
    // setup some local variables
    var $form = $(this);
    // let's select and cache all the fields
    //var $inputs = $form.find("input, select, button, textarea");
    // serialize the data in the form
    var serializedData = $form.serialize();

	console.log(serializedData);
	
    // let's disable the inputs for the duration of the ajax request
    //$inputs.prop("disabled", true);

    // fire off the request to /gateway/packets
    var request = $.ajax({
        url: "/gateway/packets",
        type: "post",
        data: serializedData
    });

    // callback handler that will be called on success
    request.done(function (response, textStatus, jqXHR){
        $("#packets-content").html(response);
    });

    // callback handler that will be called on failure
    request.fail(function (jqXHR, textStatus, errorThrown){
        // log the error to the console
        $("#packets-content").html(textStatus);
    });

    // callback handler that will be called regardless
    // if the request failed or succeeded
    request.always(function () {
        // reenable the inputs
        //$inputs.prop("disabled", false);
    });

    // prevent default posting of form
    event.preventDefault();
});

