// NanoBaseHelpers is where the base template helpers (common to all templates) are stored
NanoBaseHelpers = function ()
{
	var _baseHelpers = {
            // change ui styling to "syndicate mode"
			syndicateMode: function() {
				$('body').css("background-color","#8f1414");
				$('body').css("background-image","url('uiBackground-Syndicate.png')");
				$('body').css("background-position","50% 0");
				$('body').css("background-repeat","repeat-x");

				$('#uiTitleFluff').css("background-image","url('uiTitleFluff-Syndicate.png')");
				$('#uiTitleFluff').css("background-position","50% 50%");
				$('#uiTitleFluff').css("background-repeat", "no-repeat");

				return '';
			},
            combine: function( arr1, arr2 ) {
                return arr1 && arr2 ? arr1.concat(arr2) : arr1 || arr2;
            },  
            dump: function( arr1 ) {
                return JSON.stringify(arr1);
            },
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

				return '<div unselectable="on" class="link linkActive ' + iconClass + ' ' + elementClass + '" data-href="' + NanoUtility.generateHref(parameters) + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
			},
			// Since jsrender breaks the ^ operator
            xor: function(number,bit) {                               
                return number ^ bit;
            },
            precisionRound: function (value, places) {
                if(places==0)
                    return Math.round(number);
                var multiplier = Math.pow(10, places);
                return (Math.round(value * multiplier) / multiplier);
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
			formatNumber: function(x) {
				// From http://stackoverflow.com/questions/2901102/how-to-print-a-number-with-commas-as-thousands-separators-in-javascript
				var parts = x.toString().split(".");
				parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
				return parts.join(".");
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
			// Convert danger level to class (for the air alarm)
			dangerToClass: function(level) {
				if(level==0) return 'good';
				if(level==1) return 'average';
				return 'bad';
			},
			dangerToSpan: function(level) {
				if(level==0) return '"<span class="good">Good</span>"';
				if(level==1) return '"<span class="average">Minor Alert</span>"';
				return '"<span class="bad">Major Alert</span>"';
			},
			generateHref: function (parameters) {
				var body = $('body'); // We store data in the body tag, it's as good a place as any
				_urlParameters = body.data('urlParameters');
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

                    html += '<div class="link ' + status + ' dnaSubBlock" data-href="' + NanoUtility.generateHref(parameters) + '" id="dnaBlock' + index + '">' + characters[index] + '</div>'

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
		};
		
	return {
        addHelpers: function ()
		{
            NanoTemplate.addHelpers(_baseHelpers);
        },
		removeHelpers: function ()
		{
			for (var helperKey in _baseHelpers)
			{
				if (_baseHelpers.hasOwnProperty(helperKey))
				{
					NanoTemplate.removeHelper(helperKey);
				}
			}            
        }
	};
} ();
 






