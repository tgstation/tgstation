/*!
 * jQuery scrollintoview() plugin and :scrollable selector filter
 *
 * Version 1.8 (14 Jul 2011)
 * Requires jQuery 1.4 or newer
 */
 (function($) {
    $.fn.drags = function(opt) {
        opt = $.extend({handle:"",cursor:"move"}, opt);

        if(opt.handle === "") {
            var $el = this;
        } else {
            var $el = this.find(opt.handle);
        }

        return $el.css('cursor', opt.cursor).on("mousedown", function(e) {
            if(opt.handle === "") {
                var $drag = $(this).addClass('draggable');
            } else {
                var $drag = $(this).addClass('active-handle').parent().addClass('draggable');
            }
            var z_idx = $drag.css('z-index'),
                drg_h = $drag.outerHeight(),
                drg_w = $drag.outerWidth(),
                pos_y = $drag.offset().top + drg_h - e.pageY,
                pos_x = $drag.offset().left + drg_w - e.pageX;
            $drag.css('z-index', 1).parents().on("mousemove", function(e) {
                $('.draggable').offset({
                    top:e.pageY + pos_y - drg_h,
                    left:e.pageX + pos_x - drg_w
                }).on("mouseup", function() {
                    $(this).removeClass('draggable').css('z-index', z_idx);
                });
            });
            e.preventDefault(); // disable selection
        }).on("mouseup", function() {
            if(opt.handle === "") {
                $(this).removeClass('draggable');
            } else {
                $(this).removeClass('active-handle').parent().removeClass('draggable');
            }
        });

    }
})(jQuery);
(function ($) {
    var converter = {
        vertical: { x: false, y: true },
        horizontal: { x: true, y: false },
        both: { x: true, y: true },
        x: { x: true, y: false },
        y: { x: false, y: true }
    };
 
    var settings = {
        duration: "fast",
        direction: "both"
    };
 
    var rootrx = /^(?:html)$/i;

    // gets border dimensions
    var borders = function (domElement, styles) {
        styles = styles || (document.defaultView && document.defaultView.getComputedStyle ? document.defaultView.getComputedStyle(domElement, null) : domElement.currentStyle);
        var px = document.defaultView && document.defaultView.getComputedStyle ? true : false;
        var b = {
            top: (parseFloat(px ? styles.borderTopWidth : $.css(domElement, "borderTopWidth")) || 0),
            left: (parseFloat(px ? styles.borderLeftWidth : $.css(domElement, "borderLeftWidth")) || 0),
            bottom: (parseFloat(px ? styles.borderBottomWidth : $.css(domElement, "borderBottomWidth")) || 0),
            right: (parseFloat(px ? styles.borderRightWidth : $.css(domElement, "borderRightWidth")) || 0)
        };
        return {
            top: b.top,
            left: b.left,
            bottom: b.bottom,
            right: b.right,
            vertical: b.top + b.bottom,
            horizontal: b.left + b.right
        };
    };
 
    var dimensions = function ($element) {
        var win = $(window);
        var isRoot = rootrx.test($element[0].nodeName);
        return {
            border: isRoot ? { top: 0, left: 0, bottom: 0, right: 0} : borders($element[0]),
            scroll: {
                top: (isRoot ? win : $element).scrollTop(),
                left: (isRoot ? win : $element).scrollLeft()
            },
            scrollbar: {
                right: isRoot ? 0 : $element.innerWidth() - $element[0].clientWidth,
                bottom: isRoot ? 0 : $element.innerHeight() - $element[0].clientHeight
            },
            rect: (function () {
                var r = $element[0].getBoundingClientRect();
                return {
                    top: isRoot ? 0 : r.top,
                    left: isRoot ? 0 : r.left,
                    bottom: isRoot ? $element[0].clientHeight : r.bottom,
                    right: isRoot ? $element[0].clientWidth : r.right
                };
            })()
        };
    };
 
    $.fn.extend({
        scrollintoview: function (options) {
            /// <summary>Scrolls the first element in the set into view by scrolling its closest scrollable parent.</summary>
            /// <param name="options" type="Object">Additional options that can configure scrolling:
            ///        duration (default: "fast") - jQuery animation speed (can be a duration string or number of milliseconds)
            ///        direction (default: "both") - select possible scrollings ("vertical" or "y", "horizontal" or "x", "both")
            ///        complete (default: none) - a function to call when scrolling completes (called in context of the DOM element being scrolled)
            /// </param>
            /// <return type="jQuery">Returns the same jQuery set that this function was run on.</return>
 
            options = $.extend({}, settings, options);
            options.direction = converter[typeof (options.direction) === "string" && options.direction.toLowerCase()] || converter.both;
 
            var dirStr = "";
            if (options.direction.x === true) dirStr = "horizontal";
            if (options.direction.y === true) dirStr = dirStr ? "both" : "vertical";
 
            var el = this.eq(0);
            var scroller = el.closest(":scrollable(" + dirStr + ")");
 
            // check if there's anything to scroll in the first place
            if (scroller.length > 0)
            {
                scroller = scroller.eq(0);
 
                var dim = {
                    e: dimensions(el),
                    s: dimensions(scroller)
                };
 
                var rel = {
                    top: dim.e.rect.top - (dim.s.rect.top + dim.s.border.top),
                    bottom: dim.s.rect.bottom - dim.s.border.bottom - dim.s.scrollbar.bottom - dim.e.rect.bottom,
                    left: dim.e.rect.left - (dim.s.rect.left + dim.s.border.left),
                    right: dim.s.rect.right - dim.s.border.right - dim.s.scrollbar.right - dim.e.rect.right
                };
 
                var animOptions = {};
 
                // vertical scroll
                if (options.direction.y === true)
                {
                    if (rel.top < 0)
                    {
                        animOptions.scrollTop = dim.s.scroll.top + rel.top;
                    }
                    else if (rel.top > 0 && rel.bottom < 0)
                    {
                        animOptions.scrollTop = dim.s.scroll.top + Math.min(rel.top, -rel.bottom);
                    }
                }
 
                // horizontal scroll
                if (options.direction.x === true)
                {
                    if (rel.left < 0)
                    {
                        animOptions.scrollLeft = dim.s.scroll.left + rel.left;
                    }
                    else if (rel.left > 0 && rel.right < 0)
                    {
                        animOptions.scrollLeft = dim.s.scroll.left + Math.min(rel.left, -rel.right);
                    }
                }
 
                // scroll if needed
                if (!$.isEmptyObject(animOptions))
                {
                    if (rootrx.test(scroller[0].nodeName))
                    {
                        scroller = $("html,body");
                    }
                    scroller
                        .animate(animOptions, options.duration)
                        .eq(0) // we want function to be called just once (ref. "html,body")
                        .queue(function (next) {
                            $.isFunction(options.complete) && options.complete.call(scroller[0]);
                            next();
                        });
                }
                else
                {
                    // when there's nothing to scroll, just call the "complete" function
                    $.isFunction(options.complete) && options.complete.call(scroller[0]);
                }
            }
 
            // return set back
            return this;
        }
    });
 
    var scrollValue = {
        auto: true,
        scroll: true,
        visible: false,
        hidden: false
    };
 
    $.extend($.expr[":"], {
        scrollable: function (element, index, meta, stack) {
            var direction = converter[typeof (meta[3]) === "string" && meta[3].toLowerCase()] || converter.both;
            var styles = (document.defaultView && document.defaultView.getComputedStyle ? document.defaultView.getComputedStyle(element, null) : element.currentStyle);
            var overflow = {
                x: scrollValue[styles.overflowX.toLowerCase()] || false,
                y: scrollValue[styles.overflowY.toLowerCase()] || false,
                isRoot: rootrx.test(element.nodeName)
            };
 
            // check if completely unscrollable (exclude HTML element because it's special)
            if (!overflow.x && !overflow.y && !overflow.isRoot)
            {
                return false;
            }
 
            var size = {
                height: {
                    scroll: element.scrollHeight,
                    client: element.clientHeight
                },
                width: {
                    scroll: element.scrollWidth,
                    client: element.clientWidth
                },
                // check overflow.x/y because iPad (and possibly other tablets) don't dislay scrollbars
                scrollableX: function () {
                    return (overflow.x || overflow.isRoot) && this.width.scroll > this.width.client;
                },
                scrollableY: function () {
                    return (overflow.y || overflow.isRoot) && this.height.scroll > this.height.client;
                }
            };
            return direction.y && size.scrollableY() || direction.x && size.scrollableX();
        }
    });
})(jQuery);

/*!
 * Crew manifest script
 */

$(window).on("onUpdateContent", function(){
	$("#textbased").html("<table><colgroup><col id=\"name\" style=\"width: 24px;\" /><col id=\"pos\" style=\"width: 180px;\" /></colgroup><thead><tr><td><h3>Name</h3></td><td><h3>&nbsp;</h3></td><td><h3>Position</h3></td></tr></thead><tbody id=\"textbased-tbody\"></tbody></table>");

	$("#uiMap").append("<img src=\"minimap_" + z + ".png\" id=\"uiMapImage\" width=\"256\" height=\"256\" unselectable=\"on\"/><div id=\"uiMapContent\" unselectable=\"on\"></div>");
	$("#uiMapContainer").append("<div id=\"uiMapTooltip\"></div>");
	if(!html5compat){
		var i = document.createElement("input");
		i.setAttribute("type", "range");
		html5compat = i.type !== "text";
	}
	if(html5compat){
	$("#switches").append("<div id='zoomcontainer' style='position: static; z-index: 9999; margin-bottom: -75px;'>Zoom: <div id='zoomslider' style='width: 75px; position: relative; top: -31px; right: -50px; z-index: 9999;'><input type=\"range\" onchange=\"setzoom(value);\" value=\"4\" step=\"0.5\" max=\"16\" min=\"0.5\" id=\"zoom\"></div><div id=\"zoomval\" style='position:relative; z-index: 9999; right: -135px; top: -80px; color: white;'>100%</div></div>");
	}
	else{
			$("#switches").append(" Zoom: <a href='javascript:changeZoom(-2);'>--</a> <a href='javascript:changeZoom(2);'>++</a> <span id=\"zoomval\" style='color: white;'>100%</span>");

	}
	//$("body")[0].onselectstart = disableSelection;

	var width = $("#uiMap").width();

	scale_x = width / (maxx * tile_size);
	scale_y = width / (maxy * tile_size); // height is assumed to be the same
/*
	$("#uiMap").on("click", function(e)
	{
		var x		= ((((e.clientX - 8) / scale_x) / tile_size) + 1).toFixed(0);
		var y		= ((maxy - (((e.clientY - 8) / scale_y) / tile_size)) + 1).toFixed(0);

		window.location.href = "byond://?src=" + hSrc + "&action=select_position&x=" + x + "&y=" + y;
	});*/
	$("#uiMap").css({	position: 'absolute',
						top: '50%',
						left: '50%',
						margin: '-512px 0 0 -512px',
						width: '256px',
						height: '256px',
						overflow: 'hidden',
						zoom: '4'
					});
	$('#uiMap').drags({handle : '#uiMapImage'});
	$('#uiMapTooltip')
		.off('click')
		.on('click', function (event) {
			event.preventDefault();
			$(this).fadeOut(400);
		});
	$('#uiMap').click(function(ev) {
		var el = document.getElementById('uiMap');
		var rect = el.getBoundingClientRect();
		var tileX = (((ev.clientX - rect.left - el.clientLeft + el.scrollLeft)) / defaultzoom + 7).toFixed(0);
		var tileY = (maxy-((ev.clientY - rect.top - el.clientTop + el.scrollTop)) / defaultzoom).toFixed(0);
		var xx = ((ev.clientX - rect.left - el.clientLeft + el.scrollLeft) / defaultzoom).toFixed(0);
		var yy = ((ev.clientY - rect.top - el.clientTop + el.scrollTop) / defaultzoom).toFixed(0);
		//var dot = document.createElement('div');
		//dot.setAttribute('style', 'position:absolute; width: 2px; height: 2px; top: '+top+'px; left: '+left+'px; background: red; z-index: 99999999;');
		//el.appendChild(dot);
		//alert(tileX + ' ' + tileY);
		window.location.href = "byond://?src=" + hSrc + "&action=crewclick&x=" + tileX + "&y=" + tileY + "&z=" + z;
	});
}
)

var updateMap = true;
var ijobNames = {
    00: "captain",
        50: "headofpersonnel",
        10: "headofsecurity",
        11: "warden",
        12: "securityofficer",
        13: "detective",
        20: "chiefmedicalofficer",
        21: "chemist",
        22: "geneticist",
        23: "virologist",
        24: "medicaldoctor",
        30: "researchdirector",
        31: "scientist",
        32: "roboticist",
        40: "chiefengineer",
        41: "stationengineer",
        42: "atmospherictechnician",
        51: "quartermaster",
        52: "shaftminer",
        53: "cargotechnician",
        61: "bartender",
        62: "cook",
        63: "botanist",
        64: "librarian",
        65: "chaplain",
        66: "clown",
        67: "mime",
        68: "janitor",
        69: "lawyer",
        200: "admiral",
        210: "centcom commander",
        220: "emergencyresponseteamcommander",
        221: "securityresponseofficer",
        222: "engineerresponseofficer",
        223: "medicalresponseofficer",
        999: "assistant"
};


function isHead(ijob)
{
	return (ijob % 10 == 0); // head roles always end in 0
}

function getColor(ijob)
{
	if		(ijob == 0)					{ return "#C06616"; } // captain
	else if	(ijob >= 10 && ijob < 20)	{ return "#E74C3C"; } // security
	else if (ijob >= 20 && ijob < 30)	{ return "#3498DB"; } // medical
	else if (ijob >= 30 && ijob < 40)	{ return "#9B59B6"; } // science
	else if (ijob >= 40 && ijob < 50)	{ return "#F1C40F"; } // engineering
	else if (ijob >= 50 && ijob < 60)	{ return "#F39C12"; } // cargo
	else if (ijob >= 200 && ijob < 230)	{ return "#00C100"; } // Centcom
	else								{ return "#C38312"; } // other / unknown
}

function add(name, assignment, ijob, life_status, dam1, dam2, dam3, dam4, area, pos_x, pos_y, in_range, see_pos_x, see_pos_y)
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


		{
			if		(avg_dam <= 0)	{ i = 5; }
			else if (avg_dam <= 25)	{ i = 4; }
			else if (avg_dam <= 50)	{ i = 3; }
			else if (avg_dam <= 75)	{ i = 2; }
			else					{ i = 0; }
		}

		healthHTML = "<div class=\"health health-" + i + " tt\"><div><span>(<span class=\"oxygen\">" + dam1 + "</span>/<span class=\"toxin\">" + dam2 + "</span>/<span class=\"fire\">" + dam3 + "</span>/<span class=\"brute\">" + dam4 + "</span>)</span></div></div>";
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

	if (area && pos_x && pos_y)	{ tdElem.append($("<div></div>").text(area).addClass("tt").append($("<div></div>").append($("<span></span>").text("(" + see_pos_x + ", " + see_pos_y + ")")))); }
	else						{ tdElem.text("Not Available"); }

	trElem.append(tdElem);

	var item = $("#textbased-tbody > tr").filter(function(){ return parseInt($(this).attr("data-ijob")) >= ijob; }).eq(0);

	if (item.length > 0)		{ trElem.insertBefore(item); }
	else						{ $("#textbased-tbody").append(trElem); }

	if (updateMap && pos_x && pos_y && (in_range == "1"))
	{
		var translated = tileToMapCoords(pos_x,pos_y);
		var dotElem				= $("<div class=\"mapIcon mapIcon16 rank-" +  ijobNames[ijob.toString()] + " " + (avg_dam <= 25 ? 'good' : (avg_dam > 25 && avg_dam <= 90 ? 'average' : 'bad')) + "\" style =\"top:" + translated.yy +"px; left: " + translated.xx + "px;\" z-index: 2; unselectable=\"on\"><div class=\"tooltip hidden\">" + name + " " + (life_status ? "<span class='good'>Living</span>" : "<span class='bad'>Deceased</span>") + " (<span class=\"oxyloss_light\">" + dam1 + "</span>/<span class=\"toxin_light\">" + dam2 + "</span>/<span class=\"fire\">" + dam3 + "</span>/<span class=\"brute\">" + dam4 + "</span>) "+area+": "+see_pos_x+", "+see_pos_y+")</div></div>");
		//$("#uiMap").append("<div class=\"dot\" style=\"top: " + ty + "px; left: " + tx + "px; background-color: " + color + "; z-index: " + 999 + ";\"></div>");

		$("#uiMap").append(dotElem);
		//$("#uiMapContainer").append(dotElem);
		//$("minimapImage").append(dotElem);
		//alert($("#uiMap").html());
		//$("#textbased").html(dotElem);

		
		function enable()
		{
			dotElem.addClass("active").css({ "border-color": color });
		}

		function disable()
		{
			dotElem.removeClass("active").css({ "border-color": "transparent" });
		}

		function click(e)
		{
			e.preventDefault();
			e.stopPropagation();

			window.location.href = "byond://?src=" + hSrc + "&action=select_person&name=" + encodeURIComponent(name);
		}

		$('.mapIcon')
			.off('mouseenter mouseleave')
			.on('mouseenter',
				function (event) {
					var self = this;
					$('#uiMapTooltip')
						.html($(this).children('.tooltip').html())
						.show()
						.stopTime()
						.oneTime(5000, 'hideTooltip', function () {
							$(this).fadeOut(500);
						});
				}
			);
		trElem.on("mouseover", enable).on("mouseout", disable).on("click", click);
		dotElem.on("mouseover", function()
		{
			trElem.addClass("hover");
			enable();
			trElem.scrollintoview();
		}).on("mouseout", function()
		{
			trElem.removeClass("hover");
			disable();
		}).on("click", click);
	}
}

