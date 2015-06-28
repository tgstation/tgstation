var isAI = null;
var scale_x;
var scale_y;

function disableSelection(){ return false; };

$(window).on("onUpdateContent", function()
{
	$("#textbased").html("<table><colgroup><col /><col style=\"width: 24px;\" /><col style=\"width: 180px;\" /></colgroup><thead><tr><td><h3>Name</h3></td><td><h3>&nbsp;</h3></td><td><h3>Position</h3></td></tr></thead><tbody id=\"textbased-tbody\"></tbody></table>");

	$("#minimap").append("<img src=\"minimap_" + z + ".png\" id=\"map\" style=\"width: auto; height: 480px;\" />");

	$("body")[0].onselectstart = disableSelection;

	var width = $("#minimap").width();

	scale_x = width / (maxx * tile_size);
	scale_y = width / (maxy * tile_size); // height is assumed to be the same

	$("#minimap").on("click", function(e)
	{
		var x		= ((((e.clientX - 8) / scale_x) / tile_size) + 1).toFixed(0);
		var y		= ((maxy - (((e.clientY - 8) / scale_y) / tile_size)) + 1).toFixed(0);

		window.location.href = "byond://?src=" + hSrc + "&action=select_position&x=" + x + "&y=" + y;
	});
});

var updateMap = true;

function switchTo(i)
{
	if (i == 1)
	{
		$("#minimap").hide();
		$("#textbased").show();
	}
	else
	{
		$("#textbased").hide();
		$("#minimap").show();
	}
}

function clearAll(ai)
{
	if (isAI === null)					{ isAI = (ai == "true"); }
	$("#textbased-tbody").empty();
	$("#minimap .dot").remove();
}

function isHead(ijob)
{
	return (ijob % 10 == 0); // head roles always end in 0
}

function getColor(ijob)
{
	if		(ijob >= 10 && ijob < 20)	{ return "#E74C3C"; } // security
	else if (ijob >= 20 && ijob < 30)	{ return "#3498DB"; } // medical
	else if (ijob >= 30 && ijob < 40)	{ return "#9B59B6"; } // science
	else if (ijob >= 40 && ijob < 50)	{ return "#F1C40F"; } // engineering
	else if (ijob >= 50 && ijob < 60)	{ return "#F39C12"; } // cargo
	else if (ijob >= 200 && ijob < 230)	{ return "#00C100"; } // Centcom
}

function add(name, assignment, ijob, life_status, dam1, dam2, dam3, dam4, area, pos_x, pos_y, in_range)
{
	try							{ ijob = parseInt(ijob); }
	catch (ex)					{ ijob = 0; }

	var ls						= "";

	if (life_status === null)	{ ls = (life_status ? "<span class=\"bad\">Deceased</span>" : "<span class=\"good\">Living</span>"); }

	var healthHTML				= "";

	if (dam1 != "" || dam2 != "" || dam3 != "" || dam4 != "")
	{
		var avg_dam				= parseInt(dam1) + parseInt(dam2) + parseInt(dam3) + parseInt(dam4);
		var i;

		if (isAI)				{ i = -1; }
		else
		{
			if		(avg_dam <= 0)	{ i = 5; }
			else if (avg_dam <= 25)	{ i = 4; }
			else if (avg_dam <= 50)	{ i = 3; }
			else if (avg_dam <= 75)	{ i = 2; }
			else					{ i = 0; }
		}

		healthHTML = "<div class=\"health health-" + i + " tt\"><div><span>(<font color=\"#3498db\">" + dam1 + "</font>/<font color=\"#2ecc71\">" + dam2 + "</font>/<font color=\"#e67e22\">" + dam3 + "</font>/<font color=\"#e74c3c\">" + dam4 + "</font>)</span></div></div>";
	}
	else
	{
		healthHTML = "<div class=\"health health-" + (life_status == "" ? -1 : (life_status == "true" ? 4 : 0)) + " tt\"><div><span>Not Available</span></div></div>";
	}

	var trElem					= $("<tr></tr>").attr("data-ijob", ijob);
	var tdElem;
	var spanElem;

	tdElem						= $("<td></td>");

	var italics = false;

	if (name.length >= 7 && name.substring(0, 3) == "<i>")
	{
		name = name.substring(3, name.length - 4);
		italics = true;
	}

	spanElem					= $("<span></span>").text(name);
	
	if (italics)
	{
		spanElem.css("font-style", "italic");
	}

	if (isHead(ijob))			{ spanElem.css("font-weight", "bold"); }
	
	var color					= getColor(ijob);
	
	if (color)					{ spanElem.css("color", color); }

	tdElem.append(spanElem);

	if (assignment)				{ tdElem.append($("<span></span>").text(" (" + assignment + ")")); }

	trElem.append(tdElem);

	tdElem						= $("<td style=\"text-align: center; vertical-align: top; cursor: default;\"></td>");
	tdElem.html(healthHTML);

	trElem.append(tdElem);

	tdElem						= $("<td style=\"cursor: default;\"></td>");

	if (area && pos_x && pos_y)	{ tdElem.append($("<div></div>").text(area).addClass("tt").append($("<div></div>").append($("<span></span>").text("(" + pos_x + ", " + pos_y + ")")))); }
	else						{ tdElem.text("Not Available"); }

	trElem.append(tdElem);

	$("#textbased-tbody").append(trElem);

	if (updateMap && pos_x && pos_y && (in_range == "1"))
	{
		var x					= parseInt(pos_x);
		var y					= maxy - parseInt(pos_y);

		var tx					= (translate(x - 1, scale_x) - 1.5).toFixed(0);
		var ty					= (translate(y - 1, scale_y) + 3).toFixed(0);
		
		if (!color)				{ color = "#FFFFFF"; }
		
		var dotElem				= $("<div class=\"dot\" style=\"position: absolute; top: " + ty + "px; left: " + tx + "px; background-color: " + color + "; border: 1px solid transparent; width: 3px; height: 3px; z-index: " + ijob + ";\"></div>");

		$("#minimap").append(dotElem);

		function enable()
		{
			dotElem.css({ "border-color": "#FFFFFF", "z-index": 9999, "width": "6px", "height": "6px", "margin-top": "-1px", "margin-left": "-2px" });
		}
		
		function disable()
		{
			dotElem.css({ "border-color": "transparent", "z-index": ijob, "width": "3px", "height": "3px", "margin-top": "0px", "margin-left": "0px", "filter": "" });
		}
		
		function click(e)
		{
			e.preventDefault();
			e.stopPropagation();

			window.location.href = "byond://?src=" + hSrc + "&action=select_person&name=" + encodeURIComponent(name);
		}

		trElem.on("mouseover", enable).on("mouseout", disable).on("click", click);

		dotElem.on("mouseover", function()
		{
			trElem.addClass("hover");
			enable();
		}).on("mouseout", function()
		{
			trElem.removeClass("hover");
			disable();
		}).on("click", click);
	}
}

function translate(n, scale)
{
	return (n * tile_size) * scale;
}