
var NanoTemplate = function () {

    var _templateData = {};

    var _templates = {};
    var _compiledTemplates = {};
	
	var _helpers = {};

    var init = function () {
        // We store templateData in the body tag, it's as good a place as any
		_templateData = $('body').data('templateData');

		if (_templateData == null)
		{
			alert('Error: Template data did not load correctly.');
		}

		loadNextTemplate();
    };

    var loadNextTemplate = function () {
        // we count the number of templates for this ui so that we know when they've all been rendered
        var templateCount = Object.size(_templateData);

        if (!templateCount)
        {
            $(document).trigger('templatesLoaded');
            return;
        }

        // load markup for each template and register it
        for (var key in _templateData)
        {
            if (!_templateData.hasOwnProperty(key))
            {
                continue;
            }

            $.when($.ajax({
                    url: _templateData[key],
                    cache: false,
                    dataType: 'text'
                }))
                .done(function(templateMarkup) {

                    templateMarkup += '<div class="clearBoth"></div>';

                    try
                    {
                        NanoTemplate.addTemplate(key, templateMarkup);
                    }
                    catch(error)
                    {
                        alert('ERROR: An error occurred while loading the UI: ' + error.message);
                        return;
                    }

                    delete _templateData[key];

                    loadNextTemplate();
                })
                .fail(function () {
                    alert('ERROR: Loading template ' + key + '(' + _templateData[key] + ') failed!');
                });

            return;
        }
    }

    var compileTemplates = function () {

        for (var key in _templates) {
            try {
                _compiledTemplates[key] = doT.template(_templates[key], null, _templates)
            }
            catch (error) {
                alert(error.message);
            }
        }
    };

    return {
        init: function () {
            init();
        },
        addTemplate: function (key, templateString) {
            _templates[key] = templateString;
        },
        templateExists: function (key) {
            return _templates.hasOwnProperty(key);
        },
        parse: function (templateKey, data) {
            if (!_compiledTemplates.hasOwnProperty(templateKey) || !_compiledTemplates[templateKey]) {
                if (!_templates.hasOwnProperty(templateKey)) {
                    alert('ERROR: Template "' + templateKey + '" does not exist in _compiledTemplates!');
                    return '<h2>Template error (does not exist)</h2>';
                }
                compileTemplates();
            }
            if (typeof _compiledTemplates[templateKey] != 'function') {
                alert(_compiledTemplates[templateKey]);
                alert('ERROR: Template "' + templateKey + '" failed to compile!');
                return '<h2>Template error (failed to compile)</h2>';
            }
            return _compiledTemplates[templateKey].call(this, data['data'], data['config'], _helpers);
        },
		addHelper: function (helperName, helperFunction) {
			if (!jQuery.isFunction(helperFunction)) {
				alert('NanoTemplate.addHelper failed to add ' + helperName + ' as it is not a function.');
				return;	
			}
			
			_helpers[helperName] = helperFunction;
		},
		addHelpers: function (helpers) {		
			for (var helperName in helpers) {
				if (!helpers.hasOwnProperty(helperName))
				{
					continue;
				}
				NanoTemplate.addHelper(helperName, helpers[helperName]);
			}
		},
		removeHelper: function (helperName) {
			if (helpers.hasOwnProperty(helperName))
			{
				delete _helpers[helperName];
			}	
		}
    }
}();
 

