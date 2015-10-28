var message;
pos=0;
var i = Math.floor(Math.random()*16);

var type ="";
					  
//message = type; Who needs to delete when you got comments?
					  
//maxlength=message.length+1;


function writemsg()
{
if (pos<maxlength)
	{
	txt=message.substring(pos,0);
	document.getElementById("parText").innerHTML=txt;
	pos++;
	timer=setTimeout("writemsg",50);
	}
}

function setVars(obj)
{
	message = obj;
	maxlength = message.length+1;
	document.getElementById("parText").innerHTML=message;
	//document.getElementById("parText").innerHTML=message;
	writemsg();
}

function stoptimer()
{
clearTimeout(timer);
}

