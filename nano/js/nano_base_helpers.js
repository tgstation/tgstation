// NanoBaseHelpers is where the base template helpers (common to all templates) are stored
NanoBaseHelpers = function () 
{
	var _urlParameters = {}; // This is populated with the base url parameters (used by all links), which is probaby just the "src" parameter
	
	var init = function () 
	{
		var body = $('body'); // We store data in the body tag, it's as good a place as any
	
		_urlParameters = body.data('urlParameters');
		
		initHelpers();
	};
	
	var initHelpers = function ()
	{
		$.views.helpers({			

			// Generate a Byond link
			link: function( text, icon, parameters, status, elementClass, elementId) {
	
				var iconHtml = '';
				var iconClass = 'noIcon';
				if (typeof icon != 'undefined' && icon)
				{
					iconHtml = '<div class="uiLinkPendingIcon"></div><div class="uiIcon16 icon-' + icon + '"></div>';
					iconClass = 'hasIcon';
				}
				
				if (typeof elementClass == 'undefined' || !elementClass)
				{
					elementClass = '';
				}
				
				var elementIdHtml = '';
				if (typeof elementId != 'undefined' && elementId)
				{
					elementIdHtml = 'id="' + elementId + '"';
				}
				
				if (typeof status != 'undefined' && status)
				{
					return '<div unselectable="on" class="link ' + iconClass + ' ' + elementClass + ' ' + status + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
				}
				
				return '<div unselectable="on" class="link linkActive ' + iconClass + ' ' + elementClass + '" data-href="' + generateHref(parameters) + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
			},
			// Round a number to the nearest integer
			round: function(number) {								
				return Math.round(number);
			},
			// Round a number down to integer
			floor: function(number) {								
				return Math.floor(number);
			},
			// Round a number up to integer
			ceil: function(number) {								
				return Math.ceil(number);
			},
			// Format a string (~string("Hello {0}, how are {1}?", 'Martin', 'you') becomes "Hello Martin, how are you?")
			string: function() {		
				if (arguments.length == 0)
				{					
					return '';
				}
				else if (arguments.length == 1)
				{					
					return arguments[0];
				}
				else if (arguments.length > 1)
				{
					stringArgs = [];
					for (var i = 1; i < arguments.length; i++)
					{
						stringArgs.push(arguments[i]);   
					}
					return arguments[0].format(stringArgs);
				}
				return '';
			},
			// Display a bar. Used to show health, capacity, etc.
			displayBar: function(value, rangeMin, rangeMax, styleClass, showText) {		
			
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
				
				return '<div class="displayBar ' + styleClass + '"><div class="displayBarFill ' + styleClass + '" style="width: ' + percentage + '%;"></div><div class="displayBarText ' + styleClass + '">' + showText + '</div></div>';
			},
			// Display DNA Blocks (for the DNA Modifier UI)
			displayDNABlocks: function(dnaString, selectedBlock, selectedSubblock, blockSize, paramKey) {		
			    if (!dnaString)
				{
					return '<div class="notice">Please place a valid subject into the DNA modifier.</div>';
				}
				
				var characters = dnaString.split('');
				
                var html = '<div class="dnaBlock"><div class="link dnaBlockNumber">1</div>';
                var block = 1;
                var subblock = 1;
                for (index in characters)
                {
					if (!characters.hasOwnProperty(index) || typeof characters[index] === 'object')
					{
						continue;
					}
					
					var parameters;
					if (paramKey.toUpperCase() == 'UI')
					{
						parameters = { 'selectUIBlock' : block, 'selectUISubblock' : subblock };
					}
					else
					{
						parameters = { 'selectSEBlock' : block, 'selectSESubblock' : subblock };
					}                    
                    
                    var status = 'linkActive';
                    if (block == selectedBlock && subblock == selectedSubblock)
                    {
                        status = 'selected';
                    }
                    
                    html += '<div class="link ' + status + ' dnaSubBlock" data-href="' + generateHref(parameters) + '" id="dnaBlock' + index + '">' + characters[index] + '</div>'
                    
                    index++;
                    if (index % blockSize == 0 && index < characters.length)
                    {
						block++;
                        subblock = 1;
                        html += '</div><div class="dnaBlock"><div class="link dnaBlockNumber">' + block + '</div>';                        
                    }
                    else
                    {
                        subblock++;
                    }
                }
                
                html += '</div>';
				
				return html;
			}
		});
	};
	
	// generate a Byond href, combines _urlParameters with parameters
	var generateHref = function (parameters)
	{
		var queryString = '?';
		
		for (var key in _urlParameters)
		{
			if (_urlParameters.hasOwnProperty(key))
			{
				if (queryString !== '?')
				{
					queryString += ';';
				}
				queryString += key + '=' + _urlParameters[key];
			}
		}
		
		for (var key in parameters)
		{
			if (parameters.hasOwnProperty(key))
			{
				if (queryString !== '?')
				{
					queryString += ';';
				}
				queryString += key + '=' + parameters[key];
			}
		}
		return queryString;
	};

	return {
        init: function () 
		{
            init();
        }
	};
} ();

$(document).ready(function() 
{
	NanoBaseHelpers.init();
});






