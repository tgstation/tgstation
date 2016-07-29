var mode = null;
var question = null;
var time_left = 0;
var allow_restart = 0;
var allow_mode = 0 ;
var selected_vote = 0;
var admin = 0;
var updates = 0;
var clearallup = 0;


function clearAll(){
	clearallup += 1;
	$("#vote_main").empty();
	$("#vote_choices").empty();
	$("#vote_admin").html("<br />(<a href='?src="+hSrc+";vote=cancel;'>Cancel Vote</a>)");

}

function fuck(){
	var shit = document.all[0].outerHTML;
	$("body").empty().text(shit);
	//alert(document.all[0].outerHTML);
}
function client_data(selection, privs){
	updates += 1;
	selected_vote = parseInt(selection) || 0;
	admin = parseInt(privs) || 0;
}

function update_mode(newMode, newQuestion, newTimeleft, vrestart, vmode){
	mode = newMode;
	question = newQuestion;
	allow_mode = parseInt(vmode) || 0;
	allow_restart = parseInt(vrestart) || 0;
	time_left = parseInt(newTimeleft) || 0;
	$("#vote_choices").append($("<div class='item'></div>").append($("<div class='itemLabel'></div>").html("Time Left")).append($("<div class='itemContent'></div>").html(displayBar(time_left, 0, 60, (time_left >= 50) ? 'good' : (time_left >= 25) ? 'average' : 'bad', '<center>' + time_left + '</center>'))));
	$("#vote_choices").append($("<div class='item'></div>").append($("<div class='itemLabel'></div>").html("<br />Question")).append($("<div class='itemContentMedium'></div>").append($("<div class='statusDisplay'></div>").text(question))));
	if(admin > 0 || allow_restart > 0){
		$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=restart'>Restart</a>" + (admin == 2 ? "(<a href='?src=" + hSrc + ";vote=toggle_restart'>" + (allow_restart?"Allowed":"Disallowed") + "</a>)" : ""))));
		$("#vote_main").append($("<div class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=crew_transfer'>Crew Transfer</a>")));
	}
	else{
		$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<font color='grey'>Restart</font>")));
		$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<font color='grey'>Crew Transfer</font>")));
	}
	
	if(admin > 0 || allow_mode > 0){
		$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=gamemode'>GameMode</a>" + (admin == 2 ? "(<a href='?src=" + hSrc + ";vote=toggle_gamemode'>" + (allow_mode?"Allowed":"Disallowed") + "</a>)" : ""))));
	}

	if(admin > 0)
		$("#vote_main").append($("<div  class='item'></div>").append($("<div class='itemContent'></div>").html("<a href='?src=" + hSrc + ";vote=custom'>Custom</a>")));

	if(mode != null && mode != ""){
		$("#vote_main").hide();
		$("#vote_choices").show();
		if(admin > 0) $("#vote_admin").show();
	}
	else{
		$("#vote_main").show();
		$("#vote_choices").hide();
		$("#vote_admin").hide();
	}
	
}

function update_choices(ID, choice, votes){
	try{ID = parseInt(ID);
		votes = parseInt(votes);}
	catch(ex){alert("Failed to parse something " + ID + " " + votes); return;}
	$("#vote_choices").append($("<div class='item'></div>").append($("<div id='choice_"+ID +"'></div>").html("<a " + (selected_vote == ID ? "class='linkOn' " : "")  +  "href='?src=" + hSrc + ";vote=" + ID + "'>"+choice+" (" + votes + " votes)</a>")));
}
function displayBar(value, rangeMin, rangeMax, styleClass, showText) {

	if (rangeMin < rangeMax)
	{
		if (value < rangeMin)
		{
			value = rangeMin;
		}
		else if (value > rangeMax)
		{
			value = rangeMax;
		}
	}
	else
	{
		if (value > rangeMin)
		{
			value = rangeMin;
		}
		else if (value < rangeMax)
		{
			value = rangeMax;
		}
	}

	if (typeof styleClass == 'undefined' || !styleClass)
	{
		styleClass = '';
	}

	if (typeof showText == 'undefined' || !showText)
	{
		showText = '';
	}

	var percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);

	return '<div class="displayBar ' + styleClass + '"><div class="displayBarFill ' + styleClass + '" style="width: ' + percentage + '%;"></div><div class="displayBarText">' + showText + '</div></div>';
}