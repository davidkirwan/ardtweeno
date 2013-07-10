
$(document).ready(function(){
	
  $('#control-panel-click').click(function(){
    $('#controlpanel-menu').slideToggle(200);
  });

});


function startGateway(uri, divtoupdate)
{
	if(typeof(uri) === 'undefined') uri = "/";
	if(typeof(divtoupdate) === 'undefined') divtoupdate = false;
	
	var randomNum = 'data=' + (Math.floor((Math.random() * 10000) + 1)).toString();
	$.ajax({
	  url: '/gateway/start',
	  type: 'post',
	  data: randomNum,
	  success: function(data){
	    console.log("Succeeded in starting the gateway");
	    if(!divtoupdate)
	      window.location = uri.toString();
	    else
	      $(divtoupdate).html(data);
	  },
	  
	  error: function(xhr, status, error){
	    console.log("Failed to start the gateway");
	    window.location = "/";
	  }
	});
}

function stopGateway(uri, divtoupdate)
{
	if(typeof(uri) === 'undefined') uri = "/";
	if(typeof(divtoupdate) === 'undefined') divtoupdate = false;
	
	var randomNum = 'data=' + (Math.floor((Math.random() * 10000) + 1)).toString();
	$.ajax({
	  url: '/gateway/stop',
	  type: 'post',
	  data: randomNum,
	  success: function(data){
	    console.log("Succeeded in stopping the gateway");
	    if(!divtoupdate)
	      window.location = uri.toString();
	    else
	      $(divtoupdate).html(data);
	  },
	  
	  error: function(xhr, status, error){
	    console.log("Failed to stop the gateway");
	    window.location = "/";
	  }
	});
}

function configGateway(uri, divtoupdate)
{
	if(typeof(uri) === 'undefined') uri = "/";
	if(typeof(divtoupdate) === 'undefined') divtoupdate = false;
	
	var randomNum = 'data=' + (Math.floor((Math.random() * 10000) + 1)).toString();
	$.ajax({
	  url: '/gateway/config',
	  type: 'post',
	  data: randomNum,
	  success: function(data){
	    console.log("Succeeded in retrieving the gateway config");
	    if(!divtoupdate)
	      window.location = uri.toString();
	    else
	      $(divtoupdate).html(data);
	  },
	  
	  error: function(xhr, status, error){
	    console.log("Failed to retrieve the gateway config");
	    window.location = "/";
	  }
	});
}
