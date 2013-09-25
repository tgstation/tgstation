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
		_data = body.data('initialData');		
		
		if (!templateData || !_data)
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
		
		// load each template file and render it using _data
		for (var key in templateData)
		{
			if (templateData.hasOwnProperty(key))
			{
				$.when($.get(templateData[key]))
					.done(function(templateData) {
						if (_templates == null)
						{
							_templates = {};
						}
						
						templateData += '<div class="clearBoth"></div>'
					
						try
						{
							_templates[key] = $.templates(templateData);
							_templates[key].link( "#mainTemplate", _data ); // initial data gets applied first, before any updates
							
							templateCount--;
							
							if (templateCount <= 0)
							{
								_isInitialised = true;
							}
							
							if (_earlyUpdateData !== null) // Newer data has already arrived, so update
							{
								observedDataUpdateRecursive(_earlyUpdateData, _data);
							}	
			
							executeCallbacks(_afterUpdateCallbacks, _data);
							
							//alert($("#mainTemplate").html());
						}
						catch(error)
						{
							alert('An error occurred while loading the UI: ' + error.message);
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
		
		
		if (_isInitialised) // templates have been loaded and are observing the data. We need to update it recursively
		{
			executeCallbacks(_beforeUpdateCallbacks, updateData);
		
			observedDataUpdateRecursive(updateData, _data);
			
			executeCallbacks(_afterUpdateCallbacks, updateData);
		}
		else
		{
			_earlyUpdateData = updateData; // templates have not been loaded, therefor they are not observing the data. We set _earlyUpdateData which will be applied after the template is loaded with the initial data
		}	
	}

	// This function updates the observed data recursively
	// It has to be done recursively as each piece of data is observed individually and needs to be updated individually
	var observedDataUpdateRecursive = function (updateData, data, path)
	{
		if (path === null || typeof path === 'undefined')
		{
			path = '';
		}
		else
		{
			path += '.';        
		}
		for (var key in updateData)
		{
			if (updateData.hasOwnProperty(key))
			{
				var currentPath = path + key;
				if (updateData[key] != null && typeof updateData[key] === 'object' && !$.isArray(updateData[key]))
				{
					observedDataUpdateRecursive(updateData[key], data, currentPath)
				}
				else
				{
					$.observable(data).setProperty(currentPath, updateData[key]);
				}
			}
		}       
	}
	
	// execute all callbacks in the callbacks array/object provided, updateData is passed to them for processing
	var executeCallbacks = function (callbacks, updateData)
	{
		for (var index in callbacks)
		{
			callbacks[index].call(this, updateData);
		}
		
		return updateData;
	}

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