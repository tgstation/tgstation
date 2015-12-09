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
