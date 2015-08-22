//Note: the var "chartSize" is defined in the power monitor code, in a seperate <script> tag.

var powerChart = null;

function makeChart()
{
	
	var ctx = document.getElementById("powerChart").getContext("2d");
	var data = {
		labels: ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
		datasets: [
			{
				label: "power production",
				fillColor: "rgba(100,255,100,0.2)",
				strokeColor: "rgba(100,255,100,1)",
				pointColor: "rgba(0,255,0,1)",
				data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]                 
			},			
			{
				label: "power load",
				fillColor: "rgba(100,100,255,0.2)",
				strokeColor: "rgba(100,100,255,1)",
				pointColor: "rgba(0,0,255,1)",
				data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]                 
			},			
			{
				label: "power usage",
				fillColor: "rgba(255,100,100,0.2)",
				strokeColor: "rgba(255,100,100,1)",
				pointColor: "rgba(255,0,0,1)",
				data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  
			}
		]
	};
	var options = {
		scaleLineColor: "#e9c183",
		scaleLabel: "<%=formatWatts(value)%>",
		multiTooltipTemplate: "<%=formatWatts(value)%>",
		scaleFontColor: "#BBBBBB",
		legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"color:<%=datasets[i].strokeColor%>\">&bull; </span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"
	};
	
	powerChart = new Chart(ctx).Line(data, options);
	$("#legend").html(powerChart.generateLegend());
}
function checkSize()
{
	$("span.area").css("width", "auto");
	if($(window).width() < window.document.body.scrollWidth)
	{
		var width = 0;
		$("span.area").each(
		function()
			{
				width = Math.max(width, $(this).parent().outerWidth());
			}
		);
		width = Math.round($(window).width() - (window.document.body.scrollWidth - width + 16 + 8));
		$("span.area").css("width", width + "px"); 
	} 
}
$(window).on("resize", checkSize);
$(window).on("onUpdateContent", checkSize);
$(document).on("ready", checkSize);

function setDisabled()
{
	$("#operatable").hide();
	$("#n_operatable").show();
}

function setEnabled()
{
	$("#operatable").show();
	$("#n_operatable").hide();
}


function pushPowerData(demand, supply, load)
{
	//Thanks BYOND
	if(typeof(demand) == "string")
	{
		load = parseFloat(load);
		supply = parseFloat(supply);
		demand = parseFloat(demand);
	}
	if(powerChart.datasets[0].points.length == 15)
	{
		powerChart.removeData();
	}
	powerChart.addData([supply, load, demand], "");
}

var watt_suffixes = ["W", "KW", "MW", "GW", "TW", "PW", "EW", "ZW", "YW"];
function formatWatts(wattage)
{
	if(wattage == 0)
	{
		return "0 W";
	}
	var i = 0;
	while(Math.abs(Math.round(wattage / 1000)) >= 1 && i < watt_suffixes.length)
	{
		wattage /= 1000;
		i++;
	}
	return "" + wattage + " " + watt_suffixes[i];
}