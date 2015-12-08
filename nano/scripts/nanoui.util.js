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
