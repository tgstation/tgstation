/*jslint browser devel this*/
/*global nanoui*/

nanoui.helpers = (function (nanoui) {
    "use strict";
    var helpers = {};


    helpers.link = function (text, icon, parameters, status, elementClass, elementId) {
        var iconHtml = "";
        var iconClass = "noIcon";
        if (icon !== "undefined" && icon) {
            iconHtml = '<i class="pendingIcon fa fa-fw fa-spinner fa-pulse"></i><i class="fa fa-fw fa-' + icon + '"></i>';
            iconClass = "hasIcon";
        }
        if (elementClass === "undefined" || !elementClass) {
            elementClass = "link";
        }
        var elementIdHtml = "";
        if (elementId !== "undefined" && elementId) {
            elementIdHtml = 'id="' + elementId + '"';
        }
        if (status !== "undefined" && status) {
            return '<div unselectable="on" class="link ' + iconClass + ' ' + elementClass + ' ' + status + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
        }
        return '<div unselectable="on" class="linkActive ' + iconClass + ' ' + elementClass + '" data-href="' + nanoui.util.href(parameters) + '" ' + elementIdHtml + '>' + iconHtml + text + '</div>';
    };

    helpers.displayBar = function (value, rangeMin, rangeMax, styleClass, showText) {
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
        if (styleClass === "undefined" || !styleClass) {
            styleClass = "";
        }
        if (showText === "undefined" || !showText) {
            showText = "";
        }
        var percentage = Math.round((value - rangeMin) / (rangeMax - rangeMin) * 100);
        return '<div class="displayBar ' + styleClass + '"><div class="displayBarFill ' + styleClass + '" style="width: ' + percentage + '%;"></div><div class="displayBarText ' + styleClass + '">' + showText + '</div></div>';
    };

    helpers.round = function (number) {
        return Math.round(number);
    };

    helpers.fixed = function (number) {
        return Math.round(number * 10) / 10;
    };

    helpers.floor = function (number) {
        return Math.floor(number);
    };

    helpers.ceil = function (number) {
        return Math.ceil(number);
    };


    return helpers;
}(nanoui));