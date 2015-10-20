var message;
pos=0;
var i = Math.floor(Math.random()*16);

var type ="";
					  
//message = type; Who needs to delete when you got comments?
					  
//maxlength=message.length+1;


function writemsg(msg)
{
	message = msg.getAttribute('data-list');
	maxlength = message.length+1;
if (pos<maxlength)
	{
	txt=message.substring(pos,0);
	document.getElementById("parText").innerHTML=txt;
	pos++;
	timer=setTimeout("writemsg()",50);
	}
}
function stoptimer()
{
clearTimeout(timer);
}

