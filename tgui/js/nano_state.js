// This is the base state class, it is not to be used directly

function NanoStateClass() {
	/*if (typeof this.key != 'string' || !this.key.length)
	{
		alert('ERROR: Tried to create a state with an invalid state key: ' + this.key);
		return;
	}
	
    this.key = this.key.toLowerCase();
	
	NanoStateManager.addState(this);*/
}

NanoStateClass.prototype.key = null;
NanoStateClass.prototype.layoutRendered = false;
NanoStateClass.prototype.contentRendered = false;
NanoStateClass.prototype.mapInitialised = false;

NanoStateClass.prototype.isCurrent = function () {
    return NanoStateManager.getCurrentState() == this;
};

NanoStateClass.prototype.onAdd = function (previousState) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    NanoBaseCallbacks.addCallbacks();
    NanoBaseHelpers.addHelpers();
};

NanoStateClass.prototype.onRemove = function (nextState) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    NanoBaseCallbacks.removeCallbacks();
    NanoBaseHelpers.removeHelpers();
};

NanoStateClass.prototype.onBeforeUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    data = NanoStateManager.executeBeforeUpdateCallbacks(data);

    return data; // Return data to continue, return false to prevent onUpdate and onAfterUpdate
};

NanoStateClass.prototype.onUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    try
    {
        if (!this.layoutRendered || (data['config'].hasOwnProperty('autoUpdateLayout') && data['config']['autoUpdateLayout']))
        {
            $("#uiLayout").html(NanoTemplate.parse('layout', data)); // render the 'mail' template to the #mainTemplate div
            this.layoutRendered = true;
        }
        if (!this.contentRendered || (data['config'].hasOwnProperty('autoUpdateContent') && data['config']['autoUpdateContent']))
        {
            $("#uiContent").html(NanoTemplate.parse('main', data)); // render the 'mail' template to the #mainTemplate div
            this.contentRendered = true;
        }
        if (NanoTemplate.templateExists('mapContent'))
        {
            if (!this.mapInitialised)
            {
                // Add drag functionality to the map ui
                $('#uiMap').draggable();

                $('#uiMapTooltip')
                    .off('click')
                    .on('click', function (event) {
                        event.preventDefault();
                        $(this).fadeOut(400);
                    });

                this.mapInitialised = true;
            }

            $("#uiMapContent").html(NanoTemplate.parse('mapContent', data)); // render the 'mapContent' template to the #uiMapContent div

            if (data['config'].hasOwnProperty('showMap') && data['config']['showMap'])
            {
                $('#uiContent').addClass('hidden');
                $('#uiMapWrapper').removeClass('hidden');
            }
            else
            {
                $('#uiMapWrapper').addClass('hidden');
                $('#uiContent').removeClass('hidden');
            }
        }
        if (NanoTemplate.templateExists('mapHeader'))
        {
            $("#uiMapHeader").html(NanoTemplate.parse('mapHeader', data)); // render the 'mapHeader' template to the #uiMapHeader div
        }
        if (NanoTemplate.templateExists('mapFooter'))
        {
            $("#uiMapFooter").html(NanoTemplate.parse('mapFooter', data)); // render the 'mapFooter' template to the #uiMapFooter div
        }
    }
    catch(error)
    {
        alert('ERROR: An error occurred while rendering the UI: ' + error.message);
        return;
    }
};

NanoStateClass.prototype.onAfterUpdate = function (data) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    NanoStateManager.executeAfterUpdateCallbacks(data);
};

NanoStateClass.prototype.alertText = function (text) {
    // Do not add code here, add it to the 'default' state (nano_state_defaut.js) or create a new state and override this function

    alert(text);
};


