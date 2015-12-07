/*jslint browser devel this*/
/*global nanoui*/

var nanoui = (function () {
    "use strict";
    var nanoui = {};


    var _initialized = false;
    var _layoutRendered = false;
    var _contentRendered = false;

    var _initialData = {};
    var _data = {};


    var render = function (data) {
        if (!_initialized) {
            data = _initialData;
        }
    
        nanoui.emit('beforeRender', data);
        try {
			if (!_layoutRendered || data.config.autoUpdateLayout) {
				document.query('#layout').innerHTML = nanoui.template.template('layout', data);
				_layoutRendered = true;
				nanoui.emit('layoutRendered');
			}
			if (!_contentRendered || data.config.autoUpdateContent) {
				document.query('#content').innerHTML = nanoui.template.template('main', data);
				_contentRendered = true;
				nanoui.emit('contentRendered');
			}
        } catch (error) {
            nanoui.emit('error', error.fileName + ":" + error.lineNumber + ": " + error.message);
            return;
        }
        nanoui.emit('afterRender', data);

        if (!_initialized) {
            _initialized = true;
        }
    };

    var update = function (data) {
        if (!nanoui.util.hasKey(data, 'data')) {
            if (nanoui.util.hasKey(_data, 'data')) {
                data.data = _data.data;
            } else {
                data.data = {};
            }
        }

		_data = data;

        if (_initialized) {
            nanoui.emit('render', _data);
		}
        
        nanoui.emit('updateReceived');
    };

    var serverUpdate = function (dataString) {
        var data;
        try {
            data = JSON.parse(dataString);
        } catch (error) {
            nanoui.emit('error', error.fileName + ":" + error.lineNumber + ": " + error.message);
            return;
        }

        nanoui.emit('serverUpdateReceived');
        nanoui.emit('update', data);
    };

    var init = function () {
        nanoui.emit('earlyInit');

        _initialData = JSON.parse(document.query('body').data('initial-data'));
        if (_initialData === null || !nanoui.util.hasKey(_initialData, 'config') || !nanoui.util.hasKey(_initialData, 'data')) {
            nanoui.emit('error', "Initial data did not load correctly.");
			return;
        }

        nanoui.emit('lateInit');
    };


    document.when('ready', init);
    nanoui.on('compiled', render);
    nanoui.on('serverUpdate', serverUpdate);

	nanoui.on('render', render);
    nanoui.on('update', update);

    return nanoui;
}());