/*jslint browser devel this*/
/*global nanoui*/

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
        var activeLinks = document.queryAll('.linkActive');
        var pendingLinks = document.queryAll('.linkPending');

        switch (data.config.status) {
        case 2:
            activeLinks.forEach(function (element) {
                element.classList.remove('inactive');
            });
            pendingLinks.forEach(function (element) {
                element.classList.remove('linkPending');
            });
            break;
        case 1:
            activeLinks.forEach(function (element) {
                element.classList.add('inactive');
            });
            break;
        default:
            activeLinks.forEach(function (element) {
                element.classList.add('inactive');
            });
        }
    };

    var attachHandlers = function (data) {
        var onClick = function (event) {
            event.preventDefault();

            var href = this.data('href');
            if (href !== null) {
                if (data.config.status === 2) {
                    this.classList.add('linkPending');
                }

                location.href = href;
            }
        };

        document.queryAll('.linkActive').forEach(function (element) {
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