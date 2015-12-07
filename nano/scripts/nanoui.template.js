/*jslint browser devel this*/
/*global nanoui*/

nanoui.template = (function (nanoui, doT) {
    "use strict";
    var template = {};


    var _templateData = {};

    var _templates = {};
    var _compiledTemplates = {};

    var _dotSettings = {
        evaluate: /\{\{([\s\S]+?(\}?)+)\}\}/g,
        interpolate: /\{\{:([\s\S]+?)\}\}/g,
        encode: /\{\{!([\s\S]+?)\}\}/g,
        use: /\{\{#([\s\S]+?)\}\}/g,
        useParams: /(^|[^\w$])def(?:\.|\[[\'\"])([\w$\.]+)(?:[\'\"]\])?\s*\:\s*([\w$\.]+|\"[^\"]+\"|\'[^\']+\'|\{[^\}]+\})/g,
        define: /\{\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g,
        defineParams: /^\s*([\w$]+):([\s\S]+)/,
        conditional: /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g,
        iterate: /\{\{~\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]+)\s*(?:\:\s*([\w$]+))?\s*\}\})/g,
        varname: 'data, config, helper',
        strip: true,
        append: true,
        selfcontained: false,
        doNotSkipEncoded: false
    };


    var load = function () {
        Object.keys(_templateData).forEach(function (key) {
            var xhr;
            var activex;
            if (ActiveXObject !== undefined) {
                activex = true;
                xhr = new ActiveXObject('MSXML2.XMLHTTP.6.0');
            } else {
                activex = false;
                xhr = new XMLHttpRequest();
            }

            if (activex) {
                xhr.onreadystatechange = function () {
                    if (xhr.readystate === 4) {
                        _templates[key] = xhr.responseText;
                    }
                };
            } else {
                xhr.on('load', function () {
                    _templates[key] = this.responseText;
                });
                xhr.on('error', function () {
                    nanoui.emit('error', "Loading template " + key + " (" + _templateData[key] + ") failed.");
                });
            }
            xhr.open("GET", _templateData[key]);
            xhr.send();
        });

        nanoui.emit('loaded');
    };

    var compile = function () {
        Object.keys(_templates).forEach(function (key) {
            try {
                _compiledTemplates[key] = doT.template(_templates[key], null, _templates);
            } catch (error) {
                nanoui.emit('error', error.fileName + ":" + error.lineNumber + ": " + error.message);
                return;
            }
        });

        nanoui.emit('compiled');
    };

    var init = function () {
        doT.templateSettings = _dotSettings;

        _templateData = JSON.parse(document.query('body').data('template-data'));
        if (_templateData === null) {
            nanoui.emit('error', "Template data did not load correctly.");
			return;
        }
    };

    template.template = function (key, data) {
        if (!nanoui.util.hasKey(_templates, key)) {
            nanoui.emit('error', "Template " + key + " does not exist!");
            return "<h1>Template Error: Does Not Exist</h1>";
        }

        if (nanoui.util.isFunction(_compiledTemplates[key])) {
            return _compiledTemplates[key].call(this, data.data, data.config, nanoui.helpers);
        } else {
            nanoui.emit('error', "Template " + key + " failed to compile!");
            return "<h2>Template Error: Compile Failure</h2>";
        }
    };


    nanoui.on('earlyInit', init);
    nanoui.on('lateInit', load);
    nanoui.on('loaded', compile);

    return template;
}(nanoui, doT));