(function () {
  // Utility functions
  let hasOwn = Object.prototype.hasOwnProperty;
  // todo: remove
  let assign = function (target) {
    for (let i = 1; i < arguments.length; i++) {
      let source = arguments[i];
      for (let key in source) {
        if (hasOwn.call(source, key)) {
          target[key] = source[key];
        }
      }
    }
    return target;
  };
  let parseMetaTag = function (name) {
    let content = document.getElementById(name).getAttribute('content');
    if (content === '[' + name + ']') {
      return null;
    }
    return content;
  };

  // BYOND API object
  // ------------------------------------------------------

  let Byond = (window.Byond = {});

  // Expose inlined metadata
  Byond.windowId = parseMetaTag('tgui:windowId');

  // Backwards compatibility
  window.__windowId__ = Byond.windowId;

  // Trident engine version
  // todo: remove
  Byond.TRIDENT = (function () {
    let groups = navigator.userAgent.match(/Trident\/(\d+).+?;/i);
    let majorVersion = groups && groups[1];
    return majorVersion ? parseInt(majorVersion, 10) : null;
  })();

  // Blink engine version
  Byond.BLINK = (function () {
    let groups = navigator.userAgent.match(/Chrome\/(\d+)\./);
    let majorVersion = groups && groups[1];
    return majorVersion ? parseInt(majorVersion, 10) : null;
  })();

  // Basic checks to detect whether this page runs in BYOND
  // todo: remoe trident
  let isByond =
    (Byond.TRIDENT !== null || Byond.BLINK !== null || window.cef_to_byond) &&
    location.hostname === '127.0.0.1' &&
    location.search !== '?external';
  // As of BYOND 515 the path doesn't seem to include tmp dir anymore if you're trying to open tgui in external browser and looking why it doesn't work
  // && location.pathname.indexOf('/tmp') === 0

  // Version constants
  Byond.IS_BYOND = isByond;

  // Strict mode flag
  Byond.strictMode = Boolean(Number(parseMetaTag('tgui:strictMode')));

  // Callbacks for asynchronous calls
  Byond.__callbacks__ = [];

  // Reviver for BYOND JSON
  let byondJsonReviver = function (key, value) {
    if (typeof value === 'object' && value !== null && value.__number__) {
      return parseFloat(value.__number__);
    }
    return value;
  };

  // Makes a BYOND call.
  // See: https://secure.byond.com/docs/ref/skinparams.html
  Byond.call = function (path, params) {
    // Not running in BYOND, abort.
    if (!isByond) {
      return;
    }
    // Build the URL
    let url = (path || '') + '?';
    let i = 0;
    if (params) {
      for (let key in params) {
        if (hasOwn.call(params, key)) {
          if (i++ > 0) {
            url += '&';
          }
          let value = params[key];
          if (value === null || value === undefined) {
            value = '';
          }
          url += encodeURIComponent(key) + '=' + encodeURIComponent(value);
        }
      }
    }

    // If we're a Chromium client, just use the fancy method
    if (window.cef_to_byond) {
      cef_to_byond('byond://' + url);
      return;
    }

    // Perform a standard call via location.href
    // todo: remove
    if (url.length < 2048) {
      location.href = 'byond://' + url;
      return;
    }
    // Send an HTTP request to DreamSeeker's HTTP server.
    // Allows sending much bigger payloads.
    let xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    xhr.send();
  };

  Byond.callAsync = function (path, params) {
    if (!window.Promise) {
      throw new Error('Async calls require API level of ES2015 or later.');
    }
    let index = Byond.__callbacks__.length;
    let promise = new window.Promise((resolve) => {
      Byond.__callbacks__.push(resolve);
    });
    Byond.call(
      path,
      assign({}, params, {
        callback: 'Byond.__callbacks__[' + index + ']',
      }),
    );
    return promise;
  };

  Byond.topic = function (params) {
    return Byond.call('', params);
  };

  Byond.command = function (command) {
    return Byond.call('winset', {
      command: command,
    });
  };

  Byond.winget = function (id, propName) {
    if (id === null) {
      id = '';
    }
    let isArray = propName instanceof Array;
    let isSpecific = propName && propName !== '*' && !isArray;
    let promise = Byond.callAsync('winget', {
      id: id,
      property: (isArray && propName.join(',')) || propName || '*',
    });
    if (isSpecific) {
      promise = promise.then((props) => {
        return props[propName];
      });
    }
    return promise;
  };

  Byond.winset = function (id, propName, propValue) {
    if (id === null) {
      id = '';
    } else if (typeof id === 'object') {
      return Byond.call('winset', id);
    }
    let props = {};
    if (typeof propName === 'string') {
      props[propName] = propValue;
    } else {
      assign(props, propName);
    }
    props.id = id;
    return Byond.call('winset', props);
  };

  Byond.parseJson = function (json) {
    try {
      return JSON.parse(json, byondJsonReviver);
    } catch (err) {
      throw new Error('JSON parsing error: ' + (err && err.message));
    }
  };

  Byond.sendMessage = function (type, payload) {
    let message =
      typeof type === 'string' ? { type: type, payload: payload } : type;
    // JSON-encode the payload
    if (message.payload !== null && message.payload !== undefined) {
      message.payload = JSON.stringify(message.payload);
    }
    // Append an identifying header
    assign(message, {
      tgui: 1,
      window_id: Byond.windowId,
    });
    Byond.topic(message);
  };

  // This function exists purely for debugging, do not use it in code!
  Byond.injectMessage = function (type, payload) {
    window.update(JSON.stringify({ type: type, payload: payload }));
  };

  Byond.subscribe = function (listener) {
    window.update.flushQueue(listener);
    window.update.listeners.push(listener);
  };

  Byond.subscribeTo = function (type, listener) {
    let _listener = function (_type, payload) {
      if (_type === type) {
        listener(payload);
      }
    };
    window.update.flushQueue(_listener);
    window.update.listeners.push(_listener);
  };

  // Asset loaders
  // ------------------------------------------------------

  let RETRY_ATTEMPTS = 5;
  let RETRY_WAIT_INITIAL = 500;
  let RETRY_WAIT_INCREMENT = 500;

  let loadedAssetByUrl = {};

  let isStyleSheetLoaded = function (node, url) {
    let styleSheet = node.sheet;
    if (styleSheet) {
      return styleSheet.rules.length > 0;
    }
    return false;
  };

  let injectNode = function (node) {
    if (!document.body) {
      // todo: replace with DOMContentLoaded
      setTimeout(() => {
        injectNode(node);
      });
      // document.addEventListener('DOMContentLoaded', () => {
      //   injectNode(node);
      // });
      return;
    }
    let refs = document.body.childNodes;
    let ref = refs[refs.length - 1];
    ref.parentNode.insertBefore(node, ref.nextSibling);
  };

  let loadAsset = function (options) {
    let url = options.url;
    let type = options.type;
    let sync = options.sync;
    let attempt = options.attempt || 0;
    if (loadedAssetByUrl[url]) {
      return;
    }
    loadedAssetByUrl[url] = options;
    // Generic retry function
    let retry = function () {
      if (attempt >= RETRY_ATTEMPTS) {
        let errorMessage =
          'Error: Failed to load the asset ' +
          "'" +
          url +
          "' after several attempts.";
        if (type === 'css') {
          errorMessage +=
            +'\nStylesheet was either not found, ' +
            "or you're trying to load an empty stylesheet " +
            'that has no CSS rules in it.';
        }
        throw new Error(errorMessage);
      }
      setTimeout(
        () => {
          loadedAssetByUrl[url] = null;
          options.attempt += 1;
          loadAsset(options);
        },
        RETRY_WAIT_INITIAL + attempt * RETRY_WAIT_INCREMENT,
      );
    };
    // JS specific code
    if (type === 'js') {
      let node = document.createElement('script');
      node.type = 'text/javascript';
      node.crossOrigin = 'anonymous';
      node.src = url;
      if (sync) {
        node.defer = true;
      } else {
        node.async = true;
      }
      node.onerror = function () {
        node.onerror = null;
        node.parentNode.removeChild(node);
        node = null;
        retry();
      };
      injectNode(node);
      return;
    }
    // CSS specific code
    if (type === 'css') {
      let node = document.createElement('link');
      node.type = 'text/css';
      node.rel = 'stylesheet';
      node.href = url;
      // Temporarily set media to something inapplicable
      // to ensure it'll fetch without blocking render
      if (!sync) {
        node.media = 'only x';
      }
      node.onload = function () {
        node.onload = null;
        if (isStyleSheetLoaded(node, url)) {
          // Render the stylesheet
          node.media = 'all';
          return;
        }
        // Try again
        node.parentNode.removeChild(node);
        node = null;
        retry();
      };
      injectNode(node);
      return;
    }
  };

  Byond.loadJs = function (url, sync) {
    loadAsset({ url: url, sync: sync, type: 'js' });
  };

  Byond.loadCss = function (url, sync) {
    loadAsset({ url: url, sync: sync, type: 'css' });
  };
})();

// Error handling
// ------------------------------------------------------

window.onerror = function (msg, url, line, col, error) {
  window.onerror.errorCount = (window.onerror.errorCount || 0) + 1;
  // Proper stacktrace
  let stack = error && error.stack;
  // Ghetto stacktrace
  if (!stack) {
    stack = msg + '\n   at ' + url + ':' + line;
    if (col) {
      stack += ':' + col;
    }
  }
  // Augment the stack
  stack = window.__augmentStack__(stack, error);
  // Print error to the page
  if (Byond.strictMode) {
    let errorRoot = document.getElementById('FatalError');
    let errorStack = document.getElementById('FatalError__stack');
    if (errorRoot) {
      errorRoot.className = 'FatalError FatalError--visible';
      if (window.onerror.__stack__) {
        window.onerror.__stack__ += '\n\n' + stack;
      } else {
        window.onerror.__stack__ = stack;
      }
      let textProp = 'textContent';
      errorStack[textProp] = window.onerror.__stack__;
    }
    // Set window geometry
    let setFatalErrorGeometry = function () {
      Byond.winset(Byond.windowId, {
        titlebar: true,
        'is-visible': true,
        'can-resize': true,
      });
    };
    setFatalErrorGeometry();
    setInterval(setFatalErrorGeometry, 1000);
  }
  // Send logs to the game server
  if (Byond.strictMode) {
    Byond.sendMessage({
      type: 'log',
      fatal: 1,
      message: stack,
    });
  } else if (window.onerror.errorCount <= 1) {
    stack += '\nWindow is in non-strict mode, future errors are suppressed.';
    Byond.sendMessage({
      type: 'log',
      message: stack,
    });
  }
  // Short-circuit further updates
  if (Byond.strictMode) {
    window.update = function () {};
    window.update.queue = [];
  }
  // Prevent default action
  return true;
};

// Catch unhandled promise rejections
window.onunhandledrejection = function (e) {
  let msg = 'UnhandledRejection';
  if (e.reason) {
    msg += ': ' + (e.reason.message || e.reason.description || e.reason);
    if (e.reason.stack) {
      e.reason.stack = 'UnhandledRejection: ' + e.reason.stack;
    }
  }
  window.onerror(msg, null, null, null, e.reason);
};

// Helper for augmenting stack traces on fatal errors
window.__augmentStack__ = function (stack, error) {
  return stack + '\nUser Agent: ' + navigator.userAgent;
};

// Incoming message handling
// ------------------------------------------------------

// Message handler
window.update = function (rawMessage) {
  // Push onto the queue (active during initialization)
  if (window.update.queueActive) {
    window.update.queue.push(rawMessage);
    return;
  }
  // Parse the message
  let message = Byond.parseJson(rawMessage);
  // Notify listeners
  let listeners = window.update.listeners;
  for (let i = 0; i < listeners.length; i++) {
    listeners[i](message.type, message.payload);
  }
};

// Properties and variables of this specific handler
window.update.listeners = [];
window.update.queue = [];
window.update.queueActive = true;
window.update.flushQueue = function (listener) {
  // Disable and clear the queue permanently on short delay
  if (window.update.queueActive) {
    window.update.queueActive = false;
    if (window.setTimeout) {
      window.setTimeout(() => {
        window.update.queue = [];
      }, 0);
    }
  }
  // Process queued messages on provided listener
  let queue = window.update.queue;
  for (let i = 0; i < queue.length; i++) {
    let message = Byond.parseJson(queue[i]);
    listener(message.type, message.payload);
  }
};

window.replaceHtml = function (inline_html) {
  let children = document.body.childNodes;

  for (let i = 0; i < children.length; i++) {
    if (children[i].nodeValue === ' tgui:inline-html-start ') {
      while (children[i].nodeValue !== ' tgui:inline-html-end ') {
        children[i].remove();
      }
      children[i].remove();
    }
  }

  document.body.insertAdjacentHTML(
    'afterbegin',
    '<!-- tgui:inline-html-start -->' +
      inline_html +
      '<!-- tgui:inline-html-end -->',
  );
};
