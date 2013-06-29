
$(document).ready(function(){

});


function startGateway()
{
	var randomNum = 'data=' + (Math.floor((Math.random() * 10000) + 1)).toString();
	$.ajax({
	  url: '/start',
	  type: 'post',
	  data: randomNum,
	  success: function(data){
	    console.log("Succeeded in starting the gateway");
	    window.location = "/";
	  },
	  
	  error: function(xhr, status, error){
	    console.log("Failed to start the gateway");
	  }
	});
}
