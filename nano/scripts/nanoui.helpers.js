nanoui.helpers = (function (nanoui) {
    "use strict";
    var helpers = {};


    helpers.link = function (text, icon, parameters, status, elementClass, elementId) {
        var context = {};

        context.text = text || "";
        context.icon = "";
        context.parameters = nanoui.util.href(parameters);
        context.status = status || "";
        context.elementClass = elementClass || "normal";
        context.elementId = elementId || "";

        if (nanoui.util.yes(icon)) {
            context.icon = nanoui.util.format("<i class='pending fa fa-fw fa-spinner fa-pulse'></i><i class='main fa fa-fw fa-#{icon}'></i>", {icon: icon});
            context.elementClass += ' iconed';
        }

        if (nanoui.util.yes(status)) {
            return nanoui.util.format("<div unselectable='on' id='#{elementId}' class='link inactive #{status} #{elementClass}'>#{icon}#{text}</div>", context);
        }
        return nanoui.util.format("<div unselectable='on' id='#{elementId}' class='link active #{elementClass}' data-href='#{parameters}'>#{icon}#{text}</div>", context);
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
