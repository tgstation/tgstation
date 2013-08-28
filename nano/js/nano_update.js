NanoUpdate = function () 
{
	var _isInitialised = false;

	var _templates = null;
	var _data = null;
	var _earlyUpdateData = null; // This is for newer data which has arrived before the template has been rendered
	
	var _beforeUpdateCallbacks = [];
	var _afterUpdateCallbacks = [];
	
	var _canClick = true;
	
	var init = function () 
	{
		var body = $('body'); // We store data in the body tag, it's as good a place as any
		
		_data = body.data('initialData');

		var templateData = body.data('templateData');
		
		var templateCount = 0;
		for (var key in templateData)
		{
			if (templateData.hasOwnProperty(key))
			{
				templateCount++;
			}
		}
		
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
	};
	
	// Receive update data from the server
	var receiveUpdateData = function (jsonString)
	{
		var updateData = jQuery.parseJSON(jsonString);
		
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
	
	var executeCallbacks = function (callbacks, updateData)
	{
		for (var index in callbacks)
		{
			callbacks[index].call(this, updateData);
		}
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