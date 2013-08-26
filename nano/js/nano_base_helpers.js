NanoBaseHelpers = function () 
{
	var _urlParameters = {}; // This is populated with the base url parameters, which is probaby just the "src" parameter
	
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
			link: function( text, icon, parameters, status ) {
	
				var iconHtml = '';
				if (typeof icon != 'undefined' && icon != null)
				{
					iconHtml = '<div class="uiLinkPendingIcon"></div><div class="uiIcon16 ' + icon + '"></div>';
				}
				
				if (typeof status != 'undefined' && status != null)
				{
					return '<div class="link ' + status + '">' + iconHtml + text + '</div>';
				}
				
				return '<div class="link linkActive" data-href="' + generateHref(parameters) + '">' + iconHtml + text + '</div>';
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
			displayBar: function(value, rangeMin, rangeMax, styleClass) {		
			
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
				
				if (typeof styleClass == 'undefined')
				{
					styleClass = '';
				}
				
				var percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);
				
				return '<div class="progressBar"><div class="progressFill ' + styleClass + '" style="width: ' + percentage + '%;"></div></div>';
			}
		});
	}
	
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
	}

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






