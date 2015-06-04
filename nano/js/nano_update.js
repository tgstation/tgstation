// NanoUpdate handles data from the server and uses it to render templates
NanoUpdate = function () 
{
	// _isInitialised is set to true when all of this ui's templates have been processed/rendered
	var _isInitialised = false;

	// the array of template names to use for this ui
	var _templates = null;
	// the data for this ui
	var _data = null;
	// new data which arrives before _isInitialised is true is stored here for processing later
	var _earlyUpdateData = null; 
	
	// this is an array of callbacks which are called when new data arrives, before it is processed
	var _beforeUpdateCallbacks = [];
	// this is an array of callbacks which are called when new data arrives, before it is processed
	var _afterUpdateCallbacks = [];
	
	// _canClick is used to disable clicks for a short period after each click (to avoid mis-clicks)
	var _canClick = true;
	
	// the init function is called when the ui has loaded
	// this function sets up the templates and base functionality
	var init = function () 
	{
		$('#uiNoJavaScript').html('Loading...');
		
		// this callback is triggered after new data is processed
		// it updates the status/visibility icon and adds click event handling to buttons/links
		NanoUpdate.addAfterUpdateCallback(function (updateData) {
			var uiStatusClass;
			if (updateData['ui']['status'] == 2)
			{
				uiStatusClass = 'icon24 uiStatusGood';
				$('.linkActive').removeClass('inactive');
			}
			else if (updateData['ui']['status'] == 1)
			{
				uiStatusClass = 'icon24 uiStatusAverage';
				$('.linkActive').addClass('inactive');
			}
			else
			{
				uiStatusClass = 'icon24 uiStatusBad'
				$('.linkActive').addClass('inactive');
			}
			$('#uiStatusIcon').attr('class', uiStatusClass);

			$('.linkActive').stopTime('linkPending');
			$('.linkActive').removeClass('linkPending');

			$('.linkActive').off('click');
			$('.linkActive').on('click', function (event) {
				event.preventDefault();
				var href = $(this).data('href');
				if (href != null && _canClick)
				{
					_canClick = false;
					$('body').oneTime(300, 'enableClick', function () {
						_canClick = true;
					});
					if (updateData['ui']['status'] == 2)
					{						
						$(this).oneTime(300, 'linkPending', function () {
							$(this).addClass('linkPending');
						});
					}
					window.location.href = href;
				}
			});
		});
	
		// We store initialData and templateData in the body tag, it's as good a place as any
		var body = $('body'); 		
		var templateData = body.data('templateData');
		var initialData = body.data('initialData');		
		
		if (templateData == null || !initialData == null)
		{
			alert('Error: Initial data did not load correctly.');
		}		
		
		// we count the number of templates for this ui so that we know when they've all been rendered
		var templateCount = 0;
		for (var key in templateData)
		{
			if (templateData.hasOwnProperty(key))
			{
				templateCount++;
			}
		}
		
		if (!templateCount)
		{
			alert('ERROR: No templates listed!');
		}
		
		// load markup for each template and register it
		for (var key in templateData)
		{
			if (templateData.hasOwnProperty(key))
			{
				$.when($.get(templateData[key]))
					.done(function(templateMarkup) {
						if (_templates == null)
						{
							_templates = {};
						}
						
						templateMarkup = templateMarkup.replace(/ +\) *\}\}/g, ')}}');
						
						templateMarkup += '<div class="clearBoth"></div>'
					
						try
						{
							_templates[key] = $.templates(key, templateMarkup);							
							
							templateCount--;
							
							if (templateCount <= 0)
							{
								if (_earlyUpdateData !== null) // Newer data has already arrived, so update
								{
									renderTemplates(_earlyUpdateData);
								}
								else
								{
									renderTemplates(initialData);
								}
								_isInitialised = true;
								$('#uiNoJavaScript').hide();
							}
			
							executeCallbacks(_afterUpdateCallbacks, _data);
						}
						catch(error)
						{
							alert('ERROR: An error occurred while loading the UI: ' + error.message);
							return;
						}
					});    
			}
		}	
	};
	
	// Receive update data from the server
	var receiveUpdateData = function (jsonString)
	{
		var updateData;
		try
		{
			// parse the JSON string from the server into a JSON object
			updateData = jQuery.parseJSON(jsonString);
		}
		catch (error)
		{
			alert(error.Message);
			return;
		}
		
		
		if (_isInitialised) // all templates have been registered, so render them
		{
			executeCallbacks(_beforeUpdateCallbacks, updateData);
		
			renderTemplates(updateData);
			
			executeCallbacks(_afterUpdateCallbacks, updateData);
		}
		else
		{
			_earlyUpdateData = updateData; // all templates have not been registered. We set _earlyUpdateData which will be applied after the template is loaded with the initial data
		}	
	};

	// This function renders the template with the latest data
	// It has to be done recursively as each piece of data is observed individually and needs to be updated individually
	var renderTemplates = function (data)
	{
		if (!_templates.hasOwnProperty("main"))
		{
			alert('Error: Main template not found.');
		}
		
		_data = data;		
		
		try
		{
			$("#mainTemplate").html(_templates["main"].render(_data));
		}
		catch(error)
		{
			alert('ERROR: An error occurred while rendering the UI: ' + error.message);
			return;
		}
	};
	
	// Execute all callbacks in the callbacks array/object provided, updateData is passed to them for processing
	var executeCallbacks = function (callbacks, updateData)
	{
		for (var index in callbacks)
		{
			callbacks[index].call(this, updateData);
		}
		
		return updateData;
	};

	return {
        init: function () 
		{
            init();
        },
		isInitialised: function () 
		{
            return _isInitialised;
        },
		receiveUpdateData: function (jsonString) 
		{
			receiveUpdateData(jsonString);
        },
		addBeforeUpdateCallback: function (callbackFunction)
		{
			_beforeUpdateCallbacks.push(callbackFunction);
		},
		addAfterUpdateCallback: function (callbackFunction)
		{
			_afterUpdateCallbacks.push(callbackFunction);
		}
	};
} ();

$(document).ready(function() 
{
	NanoUpdate.init();	
});