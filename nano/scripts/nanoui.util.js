/*jslint browser devel this*/
/*global nanoui*/

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

    util.isFunction = function (func) {
        return !!(func && func.call && func.apply);
    };

    util.hasKey = function (obj, key) {
        return obj.hasOwnProperty(key);
    }


    util.href = function (parameters) {
        var url = new Url("byond://");

        nanoui.util.extend(url.query, nanoui.util.extend(parameters, _urlParameters));

        return url;
    };


    nanoui.on('earlyInit', init);

    return util;
}(nanoui));