var nanoui = (function (templates) {
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
				document.query('#layout').innerHTML = templates[data.config.templates.layout](data.data, data.config, nanoui.helpers);
				_layoutRendered = true;
				nanoui.emit('layoutRendered');
			}
			if (!_contentRendered || data.config.autoUpdateContent) {
				document.query('#content').innerHTML = templates[data.config.templates.content](data.data, data.config, nanoui.helpers);
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
    nanoui.on('lateInit', render);
    nanoui.on('serverUpdate', serverUpdate);

	nanoui.on('render', render);
    nanoui.on('update', update);

    return nanoui;
}(TMPL));

nanoui.handlers = (function (nanoui) {
    "use strict";


    var updateStatus = function (data) {
        var statusicon = document.query('#statusicon');
        if (!statusicon) {
            return;
        }

        switch (data.config.status) {
        case 2:
            statusicon.className = 'good';
            break;
        case 1:
            statusicon.className = 'average';
            break;
        default:
            statusicon.className = 'bad';
        }
    };

    var updateLinks = function (data) {
        var links = document.queryAll('.link');
        var pendingLinks = document.queryAll('.link.pending');

        if (data.config.status === 2) {
            links.forEach(function (element) {
                element.classList.remove('disabled');
            });
            pendingLinks.forEach(function (element) {
                element.classList.remove('pending');
            });
        } else {
            links.forEach(function (element) {
                element.classList.remove('active');
                element.classList.remove('pending');
                element.classList.add('disabled');
            });
        }
    };

    var attachHandlers = function (data) {
        var onClick = function (event) {
            event.preventDefault();

            var href = this.data('href');
            if (href !== null) {
                if (data.config.status === 2) {
                    this.classList.add('pending');
                }

                location.href = href;
            }
        };

        document.queryAll('.link.active').forEach(function (element) {
            element.on('click', onClick);
        });
    };

    var error = function (message) {
        var url = nanoui.util.href({nanoui_error: message});

        location.href = url;
    };


    nanoui.on('beforeRender', updateStatus);
    nanoui.on('afterRender', updateLinks);
    nanoui.on('afterRender', attachHandlers);

    nanoui.on('error', error);

    return {};
}(nanoui));

nanoui.helpers = (function (nanoui) {
    "use strict";
    var helpers = {};


    helpers.link = function (text, icon, parameters, status, elementClass) {
        var context = {};

        context.text = text || "";
        context.icon = "";
        context.parameters = nanoui.util.href(parameters);
        context.status = status;
        context.elementClass = elementClass || "";

        if (nanoui.util.yes(icon)) {
            context.icon = nanoui.util.format("<i class='pending fa fa-fw fa-spinner fa-pulse'></i><i class='main fa fa-fw fa-#{icon}'></i>", {icon: icon});
            context.elementClass += ' iconed';
        }

        if (nanoui.util.yes(status)) {
            return nanoui.util.format("<div unselectable='on' class='link inactive #{status} #{elementClass}'>#{icon}#{text}</div>", context);
        }
        return nanoui.util.format("<div unselectable='on' class='link active #{elementClass}' data-href='#{parameters}'>#{icon}#{text}</div>", context);
    };

    helpers.bar = function (value, rangeMin, rangeMax, styleClass, barText) {
        var context = {};

        if (rangeMin < rangeMax) {
            if (value < rangeMin) {
                value = rangeMin;
            } else if (value > rangeMax) {
                value = rangeMax;
            }
        } else {
            if (value > rangeMin) {
                value = rangeMin;
            } else if (value < rangeMax) {
                value = rangeMax;
            }
        }

        context.styleClass = styleClass || "";
        context.barText = barText || "";
        context.percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);

        return nanoui.util.format("<div class='bar'><div class='barFill #{styleClass}' style='width: #{percentage}%;'></div><div class='barText #{styleClass}'>#{barText}</div></div>", context);
    };

    helpers.round = function (number) {
        return Math.round(number);
    };

    helpers.fixed = function (number, decimals) {
        if (nanoui.util.no(decimals)) { decimals = 1; }
        return Number(Math.round(number + 'e'+decimals) + 'e-'+decimals);
    };

    helpers.floor = function (number) {
        return Math.floor(number);
    };

    helpers.ceil = function (number) {
        return Math.ceil(number);
    };


    return helpers;
}(nanoui));

nanoui.util = (function (nanoui) {
    "use strict";
    var util = {};


    var _urlParameters = {};


    var init = function () {
        _urlParameters = JSON.parse(document.query('body').data('url-parameters'));
        if (_urlParameters === null) {
            nanoui.emit('error', "URL parameters did not load correctly.");
            return;
        }
    };

    util.extend = function (first, second) {
        Object.keys(second).forEach(function (key) {
            var secondVal = second[key];
            if (secondVal && Object.prototype.toString.call(secondVal) === '[object Object]') {
                first[key] = first[key] || {};
                util.extend(first[key], secondVal);
            } else {
                first[key] = secondVal;
            }
        });

        return first;
    };

    util.format = function (str, obj) {
        if (!obj) {
            return str;
        }
        function getValue(str, context) {
            var ix = str.lastIndexOf('()');
            if (ix > 0 && ix + '()'.length === str.length) {
                return context[str.substring(0, ix)]();
            }
            return context[str];
        }
        return str.replace(/#\{(.+?)\}/g, function (ignore, $1) {
            var split = $1.split('.'),
                tmp = getValue(split[0], obj),
                i,
                l;
            for (i = 1, l = split.length; i < l; i++) {
                tmp = getValue(split[i], tmp);
            }
            return tmp;
        });
    };

    util.href = function (parameters) {
        var url = new Url("byond://");

        nanoui.util.extend(url.query, nanoui.util.extend(parameters, _urlParameters));

        return url;
    };

    util.isFunction = function (func) {
        return !!(func && func.call && func.apply);
    };

    util.hasKey = function (obj, key) {
        return obj.hasOwnProperty(key);
    };

    util.yes = function (arg) {
        return !(arg === 'undefined' || !arg);
    };

    util.no = function (arg) {
        return arg === 'undefined' || !arg;
    };


    nanoui.on('earlyInit', init);

    return util;
}(nanoui));
