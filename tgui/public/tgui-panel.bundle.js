/******/ (function(modules) { // webpackBootstrap
/******/ 	// install a JSONP callback for chunk loading
/******/ 	function webpackJsonpCallback(data) {
/******/ 		var chunkIds = data[0];
/******/ 		var moreModules = data[1];
/******/ 		var executeModules = data[2];
/******/
/******/ 		// add "moreModules" to the modules object,
/******/ 		// then flag all "chunkIds" as loaded and fire callback
/******/ 		var moduleId, chunkId, i = 0, resolves = [];
/******/ 		for(;i < chunkIds.length; i++) {
/******/ 			chunkId = chunkIds[i];
/******/ 			if(Object.prototype.hasOwnProperty.call(installedChunks, chunkId) && installedChunks[chunkId]) {
/******/ 				resolves.push(installedChunks[chunkId][0]);
/******/ 			}
/******/ 			installedChunks[chunkId] = 0;
/******/ 		}
/******/ 		for(moduleId in moreModules) {
/******/ 			if(Object.prototype.hasOwnProperty.call(moreModules, moduleId)) {
/******/ 				modules[moduleId] = moreModules[moduleId];
/******/ 			}
/******/ 		}
/******/ 		if(parentJsonpFunction) parentJsonpFunction(data);
/******/
/******/ 		while(resolves.length) {
/******/ 			resolves.shift()();
/******/ 		}
/******/
/******/ 		// add entry modules from loaded chunk to deferred list
/******/ 		deferredModules.push.apply(deferredModules, executeModules || []);
/******/
/******/ 		// run deferred modules when all chunks ready
/******/ 		return checkDeferredModules();
/******/ 	};
/******/ 	function checkDeferredModules() {
/******/ 		var result;
/******/ 		for(var i = 0; i < deferredModules.length; i++) {
/******/ 			var deferredModule = deferredModules[i];
/******/ 			var fulfilled = true;
/******/ 			for(var j = 1; j < deferredModule.length; j++) {
/******/ 				var depId = deferredModule[j];
/******/ 				if(installedChunks[depId] !== 0) fulfilled = false;
/******/ 			}
/******/ 			if(fulfilled) {
/******/ 				deferredModules.splice(i--, 1);
/******/ 				result = __webpack_require__(__webpack_require__.s = deferredModule[0]);
/******/ 			}
/******/ 		}
/******/
/******/ 		return result;
/******/ 	}
/******/
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// object to store loaded and loading chunks
/******/ 	// undefined = chunk not loaded, null = chunk preloaded/prefetched
/******/ 	// Promise = chunk loading, 0 = chunk loaded
/******/ 	var installedChunks = {
/******/ 		"tgui-panel": 0
/******/ 	};
/******/
/******/ 	var deferredModules = [];
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	var jsonpArray = window["webpackJsonp"] = window["webpackJsonp"] || [];
/******/ 	var oldJsonpFunction = jsonpArray.push.bind(jsonpArray);
/******/ 	jsonpArray.push = webpackJsonpCallback;
/******/ 	jsonpArray = jsonpArray.slice();
/******/ 	for(var i = 0; i < jsonpArray.length; i++) webpackJsonpCallback(jsonpArray[i]);
/******/ 	var parentJsonpFunction = oldJsonpFunction;
/******/
/******/
/******/ 	// add entry module to deferred list
/******/ 	deferredModules.push([1,"tgui-common"]);
/******/ 	// run deferred modules when ready
/******/ 	return checkDeferredModules();
/******/ })
/************************************************************************/
/******/ ({

/***/ "./packages/common/color.js":
/*!**********************************!*\
  !*** ./packages/common/color.js ***!
  \**********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Color = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var EPSILON = 0.0001;

var Color = /*#__PURE__*/function () {
  function Color(r, g, b, a) {
    if (r === void 0) {
      r = 0;
    }

    if (g === void 0) {
      g = 0;
    }

    if (b === void 0) {
      b = 0;
    }

    if (a === void 0) {
      a = 1;
    }

    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  var _proto = Color.prototype;

  _proto.toString = function () {
    function toString() {
      return "rgba(" + (this.r | 0) + ", " + (this.g | 0) + ", " + (this.b | 0) + ", " + (this.a | 0) + ")";
    }

    return toString;
  }();

  return Color;
}();
/**
 * Creates a color from the CSS hex color notation.
 */


exports.Color = Color;

Color.fromHex = function (hex) {
  return new Color(parseInt(hex.substr(1, 2), 16), parseInt(hex.substr(3, 2), 16), parseInt(hex.substr(5, 2), 16));
};
/**
 * Linear interpolation of two colors.
 */


Color.lerp = function (c1, c2, n) {
  return new Color((c2.r - c1.r) * n + c1.r, (c2.g - c1.g) * n + c1.g, (c2.b - c1.b) * n + c1.b, (c2.a - c1.a) * n + c1.a);
};
/**
 * Loops up the color in the provided list of colors
 * with linear interpolation.
 */


Color.lookup = function (value, colors) {
  if (colors === void 0) {
    colors = [];
  }

  var len = colors.length;

  if (len < 2) {
    throw new Error('Needs at least two colors!');
  }

  var scaled = value * (len - 1);

  if (value < EPSILON) {
    return colors[0];
  }

  if (value >= 1 - EPSILON) {
    return colors[len - 1];
  }

  var ratio = scaled % 1;
  var index = scaled | 0;
  return Color.lerp(colors[index], colors[index + 1], ratio);
};

/***/ }),

/***/ "./packages/common/uuid.js":
/*!*********************************!*\
  !*** ./packages/common/uuid.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.createUuid = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Creates a UUID v4 string
 *
 * @return {string}
 */
var createUuid = function createUuid() {
  var d = new Date().getTime();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = (d + Math.random() * 16) % 16 | 0;
    d = Math.floor(d / 16);
    return (c === 'x' ? r : r & 0x3 | 0x8).toString(16);
  });
};

exports.createUuid = createUuid;

/***/ }),

/***/ "./packages/tgui-panel/Notifications.js":
/*!**********************************************!*\
  !*** ./packages/tgui-panel/Notifications.js ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Notifications = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var Notifications = function Notifications(props) {
  var children = props.children;
  return (0, _inferno.createVNode)(1, "div", "Notifications", children, 0);
};

exports.Notifications = Notifications;

var NotificationsItem = function NotificationsItem(props) {
  var rightSlot = props.rightSlot,
      children = props.children;
  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    "align": "center",
    "className": "Notification",
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "className": "Notification__content",
      "grow": 1,
      children: children
    }), rightSlot && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "className": "Notification__rightSlot",
      children: rightSlot
    })]
  });
};

Notifications.Item = NotificationsItem;

/***/ }),

/***/ "./packages/tgui-panel/Panel.js":
/*!**************************************!*\
  !*** ./packages/tgui-panel/Panel.js ***!
  \**************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Panel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _layouts = __webpack_require__(/*! tgui/layouts */ "./packages/tgui/layouts/index.js");

var _audio = __webpack_require__(/*! ./audio */ "./packages/tgui-panel/audio/index.js");

var _chat = __webpack_require__(/*! ./chat */ "./packages/tgui-panel/chat/index.js");

var _game = __webpack_require__(/*! ./game */ "./packages/tgui-panel/game/index.js");

var _Notifications = __webpack_require__(/*! ./Notifications */ "./packages/tgui-panel/Notifications.js");

var _ping = __webpack_require__(/*! ./ping */ "./packages/tgui-panel/ping/index.js");

var _settings = __webpack_require__(/*! ./settings */ "./packages/tgui-panel/settings/index.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var Panel = function Panel(props, context) {
  // IE8-10: Needs special treatment due to missing Flex support
  if (Byond.IS_LTE_IE10) {
    return (0, _inferno.createComponentVNode)(2, HoboPanel);
  }

  var audio = (0, _audio.useAudio)(context);
  var settings = (0, _settings.useSettings)(context);
  var game = (0, _game.useGame)(context);

  if (true) {
    var _require = __webpack_require__(/*! tgui/debug */ "./packages/tgui/debug/index.js"),
        useDebug = _require.useDebug,
        KitchenSink = _require.KitchenSink;

    var debug = useDebug(context);

    if (debug.kitchenSink) {
      return (0, _inferno.createComponentVNode)(2, KitchenSink, {
        "panel": true
      });
    }
  }

  return (0, _inferno.createComponentVNode)(2, _layouts.Pane, {
    "theme": settings.theme,
    children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
      "direction": "column",
      "height": "100%",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        children: (0, _inferno.createComponentVNode)(2, _components.Section, {
          "fitted": true,
          children: (0, _inferno.createComponentVNode)(2, _components.Flex, {
            "mx": 0.5,
            "align": "center",
            children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "mx": 0.5,
              "grow": 1,
              "overflowX": "auto",
              children: (0, _inferno.createComponentVNode)(2, _chat.ChatTabs)
            }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "mx": 0.5,
              children: (0, _inferno.createComponentVNode)(2, _ping.PingIndicator)
            }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "mx": 0.5,
              children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                "color": "grey",
                "selected": audio.visible,
                "icon": "music",
                "tooltip": "Music player",
                "tooltipPosition": "bottom-left",
                "onClick": function () {
                  function onClick() {
                    return audio.toggle();
                  }

                  return onClick;
                }()
              })
            }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
              "mx": 0.5,
              children: (0, _inferno.createComponentVNode)(2, _components.Button, {
                "icon": settings.visible ? 'times' : 'cog',
                "selected": settings.visible,
                "tooltip": settings.visible ? 'Close settings' : 'Open settings',
                "tooltipPosition": "bottom-left",
                "onClick": function () {
                  function onClick() {
                    return settings.toggle();
                  }

                  return onClick;
                }()
              })
            })]
          })
        })
      }), audio.visible && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mt": 1,
        children: (0, _inferno.createComponentVNode)(2, _components.Section, {
          children: (0, _inferno.createComponentVNode)(2, _audio.NowPlayingWidget)
        })
      }), settings.visible && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mt": 1,
        children: (0, _inferno.createComponentVNode)(2, _settings.SettingsPanel)
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mt": 1,
        "grow": 1,
        children: (0, _inferno.createComponentVNode)(2, _components.Section, {
          "fill": true,
          "fitted": true,
          "position": "relative",
          children: [(0, _inferno.createComponentVNode)(2, _layouts.Pane.Content, {
            "scrollable": true,
            children: (0, _inferno.createComponentVNode)(2, _chat.ChatPanel, {
              "lineHeight": settings.lineHeight
            })
          }), (0, _inferno.createComponentVNode)(2, _Notifications.Notifications, {
            children: [game.connectionLostAt && (0, _inferno.createComponentVNode)(2, _Notifications.Notifications.Item, {
              "rightSlot": (0, _inferno.createComponentVNode)(2, _components.Button, {
                "color": "white",
                "onClick": function () {
                  function onClick() {
                    return Byond.command('.reconnect');
                  }

                  return onClick;
                }(),
                children: "Reconnect"
              }),
              children: "You are either AFK, experiencing lag or the connection has closed."
            }), game.roundRestartedAt && (0, _inferno.createComponentVNode)(2, _Notifications.Notifications.Item, {
              children: "The connection has been closed because the server is restarting. Please wait while you automatically reconnect."
            })]
          })]
        })
      })]
    })
  });
};

exports.Panel = Panel;

var HoboPanel = function HoboPanel(props, context) {
  var settings = (0, _settings.useSettings)(context);
  return (0, _inferno.createComponentVNode)(2, _layouts.Pane, {
    "theme": settings.theme,
    children: (0, _inferno.createComponentVNode)(2, _layouts.Pane.Content, {
      "scrollable": true,
      children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
        "style": {
          position: 'fixed',
          top: '1em',
          right: '2em',
          'z-index': 1000
        },
        "selected": settings.visible,
        "onClick": function () {
          function onClick() {
            return settings.toggle();
          }

          return onClick;
        }(),
        children: "Settings"
      }), settings.visible && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mt": 1,
        children: (0, _inferno.createComponentVNode)(2, _settings.SettingsPanel)
      }) || (0, _inferno.createComponentVNode)(2, _chat.ChatPanel, {
        "lineHeight": settings.lineHeight
      })]
    })
  });
};

/***/ }),

/***/ "./packages/tgui-panel/audio/NowPlayingWidget.js":
/*!*******************************************************!*\
  !*** ./packages/tgui-panel/audio/NowPlayingWidget.js ***!
  \*******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.NowPlayingWidget = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _settings = __webpack_require__(/*! ../settings */ "./packages/tgui-panel/settings/index.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/audio/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var NowPlayingWidget = function NowPlayingWidget(props, context) {
  var _audio$meta;

  var audio = (0, _redux.useSelector)(context, _selectors.selectAudio);
  var dispatch = (0, _redux.useDispatch)(context);
  var settings = (0, _settings.useSettings)(context);
  var title = (_audio$meta = audio.meta) == null ? void 0 : _audio$meta.title;
  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    "align": "center",
    children: [audio.playing && (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "shrink": 0,
      "mx": 0.5,
      "color": "label",
      children: "Now playing:"
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "mx": 0.5,
      "grow": 1,
      "style": {
        'white-space': 'nowrap',
        'overflow': 'hidden',
        'text-overflow': 'ellipsis'
      },
      children: title || 'Unknown Track'
    })], 4) || (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "grow": 1,
      "color": "label",
      children: "Nothing to play."
    }), audio.playing && (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "mx": 0.5,
      "fontSize": "0.9em",
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "tooltip": "Stop",
        "icon": "stop",
        "onClick": function () {
          function onClick() {
            return dispatch({
              type: 'audio/stopMusic'
            });
          }

          return onClick;
        }()
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "mx": 0.5,
      "fontSize": "0.9em",
      children: (0, _inferno.createComponentVNode)(2, _components.Knob, {
        "minValue": 0,
        "maxValue": 1,
        "value": settings.adminMusicVolume,
        "step": 0.0025,
        "stepPixelSize": 1,
        "format": function () {
          function format(value) {
            return (0, _math.toFixed)(value * 100) + '%';
          }

          return format;
        }(),
        "onDrag": function () {
          function onDrag(e, value) {
            return settings.update({
              adminMusicVolume: value
            });
          }

          return onDrag;
        }()
      })
    })]
  });
};

exports.NowPlayingWidget = NowPlayingWidget;

/***/ }),

/***/ "./packages/tgui-panel/audio/hooks.js":
/*!********************************************!*\
  !*** ./packages/tgui-panel/audio/hooks.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.useAudio = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/audio/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var useAudio = function useAudio(context) {
  var state = (0, _redux.useSelector)(context, _selectors.selectAudio);
  var dispatch = (0, _redux.useDispatch)(context);
  return Object.assign({}, state, {
    toggle: function () {
      function toggle() {
        return dispatch({
          type: 'audio/toggle'
        });
      }

      return toggle;
    }()
  });
};

exports.useAudio = useAudio;

/***/ }),

/***/ "./packages/tgui-panel/audio/index.js":
/*!********************************************!*\
  !*** ./packages/tgui-panel/audio/index.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.audioReducer = exports.NowPlayingWidget = exports.audioMiddleware = exports.useAudio = void 0;

var _hooks = __webpack_require__(/*! ./hooks */ "./packages/tgui-panel/audio/hooks.js");

exports.useAudio = _hooks.useAudio;

var _middleware = __webpack_require__(/*! ./middleware */ "./packages/tgui-panel/audio/middleware.js");

exports.audioMiddleware = _middleware.audioMiddleware;

var _NowPlayingWidget = __webpack_require__(/*! ./NowPlayingWidget */ "./packages/tgui-panel/audio/NowPlayingWidget.js");

exports.NowPlayingWidget = _NowPlayingWidget.NowPlayingWidget;

var _reducer = __webpack_require__(/*! ./reducer */ "./packages/tgui-panel/audio/reducer.js");

exports.audioReducer = _reducer.audioReducer;

/***/ }),

/***/ "./packages/tgui-panel/audio/middleware.js":
/*!*************************************************!*\
  !*** ./packages/tgui-panel/audio/middleware.js ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.audioMiddleware = void 0;

var _player = __webpack_require__(/*! ./player */ "./packages/tgui-panel/audio/player.js");

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

var audioMiddleware = function audioMiddleware(store) {
  var player = new _player.AudioPlayer();
  player.onPlay(function () {
    store.dispatch({
      type: 'audio/playing'
    });
  });
  player.onStop(function () {
    store.dispatch({
      type: 'audio/stopped'
    });
  });
  return function (next) {
    return function (action) {
      var type = action.type,
          payload = action.payload;

      if (type === 'audio/playMusic') {
        var url = payload.url,
            options = _objectWithoutPropertiesLoose(payload, ["url"]);

        player.play(url, options);
        return next(action);
      }

      if (type === 'audio/stopMusic') {
        player.stop();
        return next(action);
      }

      if (type === 'settings/update' || type === 'settings/load') {
        var volume = payload == null ? void 0 : payload.adminMusicVolume;

        if (typeof volume === 'number') {
          player.setVolume(volume);
        }

        return next(action);
      }

      return next(action);
    };
  };
};

exports.audioMiddleware = audioMiddleware;

/***/ }),

/***/ "./packages/tgui-panel/audio/player.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/audio/player.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.AudioPlayer = void 0;

var _logging = __webpack_require__(/*! tgui/logging */ "./packages/tgui/logging.js");

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } it = o[Symbol.iterator](); return it.next.bind(it); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

var logger = (0, _logging.createLogger)('AudioPlayer');

var AudioPlayer = /*#__PURE__*/function () {
  function AudioPlayer() {
    var _this = this;

    // Doesn't support HTMLAudioElement
    if (Byond.IS_LTE_IE9) {
      return;
    } // Set up the HTMLAudioElement node


    this.node = document.createElement('audio');
    this.node.style.setProperty('display', 'none');
    document.body.appendChild(this.node); // Set up other properties

    this.playing = false;
    this.volume = 1;
    this.options = {};
    this.onPlaySubscribers = [];
    this.onStopSubscribers = []; // Listen for playback start events

    this.node.addEventListener('canplaythrough', function () {
      logger.log('canplaythrough');
      _this.playing = true;
      _this.node.playbackRate = _this.options.pitch || 1;
      _this.node.currentTime = _this.options.start || 0;
      _this.node.volume = _this.volume;

      _this.node.play();

      for (var _iterator = _createForOfIteratorHelperLoose(_this.onPlaySubscribers), _step; !(_step = _iterator()).done;) {
        var subscriber = _step.value;
        subscriber();
      }
    }); // Listen for playback stop events

    this.node.addEventListener('ended', function () {
      logger.log('ended');

      _this.stop();
    }); // Listen for playback errors

    this.node.addEventListener('error', function (e) {
      if (_this.playing) {
        logger.log('playback error', e.error);

        _this.stop();
      }
    }); // Check every second to stop the playback at the right time

    this.playbackInterval = setInterval(function () {
      if (!_this.playing) {
        return;
      }

      var shouldStop = _this.options.end > 0 && _this.node.currentTime >= _this.options.end;

      if (shouldStop) {
        _this.stop();
      }
    }, 1000);
  }

  var _proto = AudioPlayer.prototype;

  _proto.destroy = function () {
    function destroy() {
      if (!this.node) {
        return;
      }

      this.node.stop();
      document.removeChild(this.node);
      clearInterval(this.playbackInterval);
    }

    return destroy;
  }();

  _proto.play = function () {
    function play(url, options) {
      if (options === void 0) {
        options = {};
      }

      if (!this.node) {
        return;
      }

      logger.log('playing', url, options);
      this.options = options;
      this.node.src = url;
    }

    return play;
  }();

  _proto.stop = function () {
    function stop() {
      if (!this.node) {
        return;
      }

      if (this.playing) {
        for (var _iterator2 = _createForOfIteratorHelperLoose(this.onStopSubscribers), _step2; !(_step2 = _iterator2()).done;) {
          var subscriber = _step2.value;
          subscriber();
        }
      }

      logger.log('stopping');
      this.playing = false;
      this.node.src = '';
    }

    return stop;
  }();

  _proto.setVolume = function () {
    function setVolume(volume) {
      if (!this.node) {
        return;
      }

      this.volume = volume;
      this.node.volume = volume;
    }

    return setVolume;
  }();

  _proto.onPlay = function () {
    function onPlay(subscriber) {
      if (!this.node) {
        return;
      }

      this.onPlaySubscribers.push(subscriber);
    }

    return onPlay;
  }();

  _proto.onStop = function () {
    function onStop(subscriber) {
      if (!this.node) {
        return;
      }

      this.onStopSubscribers.push(subscriber);
    }

    return onStop;
  }();

  return AudioPlayer;
}();

exports.AudioPlayer = AudioPlayer;

/***/ }),

/***/ "./packages/tgui-panel/audio/reducer.js":
/*!**********************************************!*\
  !*** ./packages/tgui-panel/audio/reducer.js ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.audioReducer = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var initialState = {
  visible: false,
  playing: false,
  track: null
};

var audioReducer = function audioReducer(state, action) {
  if (state === void 0) {
    state = initialState;
  }

  var type = action.type,
      payload = action.payload;

  if (type === 'audio/playing') {
    return Object.assign({}, state, {
      visible: true,
      playing: true
    });
  }

  if (type === 'audio/stopped') {
    return Object.assign({}, state, {
      visible: false,
      playing: false
    });
  }

  if (type === 'audio/playMusic') {
    return Object.assign({}, state, {
      meta: payload
    });
  }

  if (type === 'audio/stopMusic') {
    return Object.assign({}, state, {
      visible: false,
      playing: false,
      meta: null
    });
  }

  if (type === 'audio/toggle') {
    return Object.assign({}, state, {
      visible: !state.visible
    });
  }

  return state;
};

exports.audioReducer = audioReducer;

/***/ }),

/***/ "./packages/tgui-panel/audio/selectors.js":
/*!************************************************!*\
  !*** ./packages/tgui-panel/audio/selectors.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.selectAudio = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var selectAudio = function selectAudio(state) {
  return state.audio;
};

exports.selectAudio = selectAudio;

/***/ }),

/***/ "./packages/tgui-panel/chat/ChatPageSettings.js":
/*!******************************************************!*\
  !*** ./packages/tgui-panel/chat/ChatPageSettings.js ***!
  \******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ChatPageSettings = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/chat/actions.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/chat/constants.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/chat/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var ChatPageSettings = function ChatPageSettings(props, context) {
  var page = (0, _redux.useSelector)(context, _selectors.selectCurrentChatPage);
  var dispatch = (0, _redux.useDispatch)(context);
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "fill": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex, {
      "mx": -0.5,
      "align": "center",
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mx": 0.5,
        "grow": 1,
        children: (0, _inferno.createComponentVNode)(2, _components.Input, {
          "fluid": true,
          "value": page.name,
          "onChange": function () {
            function onChange(e, value) {
              return dispatch((0, _actions.updateChatPage)({
                pageId: page.id,
                name: value
              }));
            }

            return onChange;
          }()
        })
      }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
        "mx": 0.5,
        children: (0, _inferno.createComponentVNode)(2, _components.Button, {
          "icon": "times",
          "color": "red",
          "onClick": function () {
            function onClick() {
              return dispatch((0, _actions.removeChatPage)({
                pageId: page.id
              }));
            }

            return onClick;
          }(),
          children: "Remove"
        })
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Section, {
      "title": "Messages to display",
      "level": 2,
      children: [_constants.MESSAGE_TYPES.filter(function (typeDef) {
        return !typeDef.important && !typeDef.admin;
      }).map(function (typeDef) {
        return (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
          "checked": page.acceptedTypes[typeDef.type],
          "onClick": function () {
            function onClick() {
              return dispatch((0, _actions.toggleAcceptedType)({
                pageId: page.id,
                type: typeDef.type
              }));
            }

            return onClick;
          }(),
          children: typeDef.name
        }, typeDef.type);
      }), (0, _inferno.createComponentVNode)(2, _components.Collapsible, {
        "mt": 1,
        "color": "transparent",
        "title": "Admin stuff",
        children: _constants.MESSAGE_TYPES.filter(function (typeDef) {
          return !typeDef.important && typeDef.admin;
        }).map(function (typeDef) {
          return (0, _inferno.createComponentVNode)(2, _components.Button.Checkbox, {
            "checked": page.acceptedTypes[typeDef.type],
            "onClick": function () {
              function onClick() {
                return dispatch((0, _actions.toggleAcceptedType)({
                  pageId: page.id,
                  type: typeDef.type
                }));
              }

              return onClick;
            }(),
            children: typeDef.name
          }, typeDef.type);
        })
      })]
    })]
  });
};

exports.ChatPageSettings = ChatPageSettings;

/***/ }),

/***/ "./packages/tgui-panel/chat/ChatPanel.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/chat/ChatPanel.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ChatPanel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _renderer = __webpack_require__(/*! ./renderer */ "./packages/tgui-panel/chat/renderer.js");

function _inheritsLoose(subClass, superClass) { subClass.prototype = Object.create(superClass.prototype); subClass.prototype.constructor = subClass; subClass.__proto__ = superClass; }

var ChatPanel = /*#__PURE__*/function (_Component) {
  _inheritsLoose(ChatPanel, _Component);

  function ChatPanel() {
    var _this;

    _this = _Component.call(this) || this;
    _this.ref = (0, _inferno.createRef)();
    _this.state = {
      scrollTracking: true
    };

    _this.handleScrollTrackingChange = function (value) {
      return _this.setState({
        scrollTracking: value
      });
    };

    return _this;
  }

  var _proto = ChatPanel.prototype;

  _proto.componentDidMount = function () {
    function componentDidMount() {
      _renderer.chatRenderer.mount(this.ref.current);

      _renderer.chatRenderer.events.on('scrollTrackingChanged', this.handleScrollTrackingChange);

      this.componentDidUpdate();
    }

    return componentDidMount;
  }();

  _proto.componentWillUnmount = function () {
    function componentWillUnmount() {
      _renderer.chatRenderer.events.off('scrollTrackingChanged', this.handleScrollTrackingChange);
    }

    return componentWillUnmount;
  }();

  _proto.componentDidUpdate = function () {
    function componentDidUpdate(prevProps) {
      requestAnimationFrame(function () {
        _renderer.chatRenderer.ensureScrollTracking();
      });
      var shouldUpdateStyle = !prevProps || (0, _react.shallowDiffers)(this.props, prevProps);

      if (shouldUpdateStyle) {
        _renderer.chatRenderer.assignStyle({
          'width': '100%',
          'white-space': 'pre-wrap',
          'font-size': this.props.fontSize,
          'line-height': this.props.lineHeight
        });
      }
    }

    return componentDidUpdate;
  }();

  _proto.render = function () {
    function render() {
      var scrollTracking = this.state.scrollTracking;
      return (0, _inferno.createFragment)([(0, _inferno.createVNode)(1, "div", "Chat", null, 1, null, null, this.ref), !scrollTracking && (0, _inferno.createComponentVNode)(2, _components.Button, {
        "className": "Chat__scrollButton",
        "icon": "arrow-down",
        "onClick": function () {
          function onClick() {
            return _renderer.chatRenderer.scrollToBottom();
          }

          return onClick;
        }(),
        children: "Scroll to bottom"
      })], 0);
    }

    return render;
  }();

  return ChatPanel;
}(_inferno.Component);

exports.ChatPanel = ChatPanel;

/***/ }),

/***/ "./packages/tgui-panel/chat/ChatTabs.js":
/*!**********************************************!*\
  !*** ./packages/tgui-panel/chat/ChatTabs.js ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.ChatTabs = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/chat/actions.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/chat/selectors.js");

var _actions2 = __webpack_require__(/*! ../settings/actions */ "./packages/tgui-panel/settings/actions.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var UnreadCountWidget = function UnreadCountWidget(_ref) {
  var value = _ref.value;
  return (0, _inferno.createComponentVNode)(2, _components.Box, {
    "style": {
      'font-size': '0.7em',
      'border-radius': '0.25em',
      'width': '1.7em',
      'line-height': '1.55em',
      'background-color': 'crimson',
      'color': '#fff'
    },
    children: Math.min(value, 99)
  });
};

var ChatTabs = function ChatTabs(props, context) {
  var pages = (0, _redux.useSelector)(context, _selectors.selectChatPages);
  var currentPage = (0, _redux.useSelector)(context, _selectors.selectCurrentChatPage);
  var dispatch = (0, _redux.useDispatch)(context);
  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    "align": "center",
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      children: (0, _inferno.createComponentVNode)(2, _components.Tabs, {
        "textAlign": "center",
        children: pages.map(function (page) {
          return (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
            "selected": page === currentPage,
            "rightSlot": page.unreadCount > 0 && (0, _inferno.createComponentVNode)(2, UnreadCountWidget, {
              "value": page.unreadCount
            }),
            "onClick": function () {
              function onClick() {
                return dispatch((0, _actions.changeChatPage)({
                  pageId: page.id
                }));
              }

              return onClick;
            }(),
            children: page.name
          }, page.id);
        })
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "ml": 1,
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "color": "transparent",
        "icon": "plus",
        "onClick": function () {
          function onClick() {
            dispatch((0, _actions.addChatPage)());
            dispatch((0, _actions2.openChatSettings)());
          }

          return onClick;
        }()
      })
    })]
  });
};

exports.ChatTabs = ChatTabs;

/***/ }),

/***/ "./packages/tgui-panel/chat/actions.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/chat/actions.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.saveChatToDisk = exports.changeScrollTracking = exports.removeChatPage = exports.toggleAcceptedType = exports.updateChatPage = exports.changeChatPage = exports.addChatPage = exports.updateMessageCount = exports.rebuildChat = exports.loadChat = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _model = __webpack_require__(/*! ./model */ "./packages/tgui-panel/chat/model.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var loadChat = (0, _redux.createAction)('chat/load');
exports.loadChat = loadChat;
var rebuildChat = (0, _redux.createAction)('chat/rebuild');
exports.rebuildChat = rebuildChat;
var updateMessageCount = (0, _redux.createAction)('chat/updateMessageCount');
exports.updateMessageCount = updateMessageCount;
var addChatPage = (0, _redux.createAction)('chat/addPage', function () {
  return {
    payload: (0, _model.createPage)()
  };
});
exports.addChatPage = addChatPage;
var changeChatPage = (0, _redux.createAction)('chat/changePage');
exports.changeChatPage = changeChatPage;
var updateChatPage = (0, _redux.createAction)('chat/updatePage');
exports.updateChatPage = updateChatPage;
var toggleAcceptedType = (0, _redux.createAction)('chat/toggleAcceptedType');
exports.toggleAcceptedType = toggleAcceptedType;
var removeChatPage = (0, _redux.createAction)('chat/removePage');
exports.removeChatPage = removeChatPage;
var changeScrollTracking = (0, _redux.createAction)('chat/changeScrollTracking');
exports.changeScrollTracking = changeScrollTracking;
var saveChatToDisk = (0, _redux.createAction)('chat/saveToDisk');
exports.saveChatToDisk = saveChatToDisk;

/***/ }),

/***/ "./packages/tgui-panel/chat/constants.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/chat/constants.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.MESSAGE_TYPES = exports.MESSAGE_TYPE_DEBUG = exports.MESSAGE_TYPE_ATTACKLOG = exports.MESSAGE_TYPE_ADMINLOG = exports.MESSAGE_TYPE_EVENTCHAT = exports.MESSAGE_TYPE_MODCHAT = exports.MESSAGE_TYPE_ADMINCHAT = exports.MESSAGE_TYPE_COMBAT = exports.MESSAGE_TYPE_ADMINPM = exports.MESSAGE_TYPE_OOC = exports.MESSAGE_TYPE_DEADCHAT = exports.MESSAGE_TYPE_WARNING = exports.MESSAGE_TYPE_INFO = exports.MESSAGE_TYPE_RADIO = exports.MESSAGE_TYPE_LOCALCHAT = exports.MESSAGE_TYPE_SYSTEM = exports.MESSAGE_TYPE_INTERNAL = exports.MESSAGE_TYPE_UNKNOWN = exports.IMAGE_RETRY_MESSAGE_AGE = exports.IMAGE_RETRY_LIMIT = exports.IMAGE_RETRY_DELAY = exports.COMBINE_MAX_TIME_WINDOW = exports.COMBINE_MAX_MESSAGES = exports.MESSAGE_PRUNE_INTERVAL = exports.MESSAGE_SAVE_INTERVAL = exports.MAX_PERSISTED_MESSAGES = exports.MAX_VISIBLE_MESSAGES = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var MAX_VISIBLE_MESSAGES = 2500;
exports.MAX_VISIBLE_MESSAGES = MAX_VISIBLE_MESSAGES;
var MAX_PERSISTED_MESSAGES = 1000;
exports.MAX_PERSISTED_MESSAGES = MAX_PERSISTED_MESSAGES;
var MESSAGE_SAVE_INTERVAL = 10000;
exports.MESSAGE_SAVE_INTERVAL = MESSAGE_SAVE_INTERVAL;
var MESSAGE_PRUNE_INTERVAL = 60000;
exports.MESSAGE_PRUNE_INTERVAL = MESSAGE_PRUNE_INTERVAL;
var COMBINE_MAX_MESSAGES = 5;
exports.COMBINE_MAX_MESSAGES = COMBINE_MAX_MESSAGES;
var COMBINE_MAX_TIME_WINDOW = 5000;
exports.COMBINE_MAX_TIME_WINDOW = COMBINE_MAX_TIME_WINDOW;
var IMAGE_RETRY_DELAY = 250;
exports.IMAGE_RETRY_DELAY = IMAGE_RETRY_DELAY;
var IMAGE_RETRY_LIMIT = 10;
exports.IMAGE_RETRY_LIMIT = IMAGE_RETRY_LIMIT;
var IMAGE_RETRY_MESSAGE_AGE = 60000; // Default message type

exports.IMAGE_RETRY_MESSAGE_AGE = IMAGE_RETRY_MESSAGE_AGE;
var MESSAGE_TYPE_UNKNOWN = 'unknown'; // Internal message type

exports.MESSAGE_TYPE_UNKNOWN = MESSAGE_TYPE_UNKNOWN;
var MESSAGE_TYPE_INTERNAL = 'internal'; // Must match the set of defines in code/__DEFINES/chat.dm

exports.MESSAGE_TYPE_INTERNAL = MESSAGE_TYPE_INTERNAL;
var MESSAGE_TYPE_SYSTEM = 'system';
exports.MESSAGE_TYPE_SYSTEM = MESSAGE_TYPE_SYSTEM;
var MESSAGE_TYPE_LOCALCHAT = 'localchat';
exports.MESSAGE_TYPE_LOCALCHAT = MESSAGE_TYPE_LOCALCHAT;
var MESSAGE_TYPE_RADIO = 'radio';
exports.MESSAGE_TYPE_RADIO = MESSAGE_TYPE_RADIO;
var MESSAGE_TYPE_INFO = 'info';
exports.MESSAGE_TYPE_INFO = MESSAGE_TYPE_INFO;
var MESSAGE_TYPE_WARNING = 'warning';
exports.MESSAGE_TYPE_WARNING = MESSAGE_TYPE_WARNING;
var MESSAGE_TYPE_DEADCHAT = 'deadchat';
exports.MESSAGE_TYPE_DEADCHAT = MESSAGE_TYPE_DEADCHAT;
var MESSAGE_TYPE_OOC = 'ooc';
exports.MESSAGE_TYPE_OOC = MESSAGE_TYPE_OOC;
var MESSAGE_TYPE_ADMINPM = 'adminpm';
exports.MESSAGE_TYPE_ADMINPM = MESSAGE_TYPE_ADMINPM;
var MESSAGE_TYPE_COMBAT = 'combat';
exports.MESSAGE_TYPE_COMBAT = MESSAGE_TYPE_COMBAT;
var MESSAGE_TYPE_ADMINCHAT = 'adminchat';
exports.MESSAGE_TYPE_ADMINCHAT = MESSAGE_TYPE_ADMINCHAT;
var MESSAGE_TYPE_MODCHAT = 'modchat';
exports.MESSAGE_TYPE_MODCHAT = MESSAGE_TYPE_MODCHAT;
var MESSAGE_TYPE_EVENTCHAT = 'eventchat';
exports.MESSAGE_TYPE_EVENTCHAT = MESSAGE_TYPE_EVENTCHAT;
var MESSAGE_TYPE_ADMINLOG = 'adminlog';
exports.MESSAGE_TYPE_ADMINLOG = MESSAGE_TYPE_ADMINLOG;
var MESSAGE_TYPE_ATTACKLOG = 'attacklog';
exports.MESSAGE_TYPE_ATTACKLOG = MESSAGE_TYPE_ATTACKLOG;
var MESSAGE_TYPE_DEBUG = 'debug'; // Metadata for each message type

exports.MESSAGE_TYPE_DEBUG = MESSAGE_TYPE_DEBUG;
var MESSAGE_TYPES = [// Always-on types
{
  type: MESSAGE_TYPE_SYSTEM,
  name: 'System Messages',
  description: 'Messages from your client, always enabled',
  selector: '.boldannounce',
  important: true
}, // Basic types
{
  type: MESSAGE_TYPE_LOCALCHAT,
  name: 'Local',
  description: 'In-character local messages (say, emote, etc)',
  selector: '.say, .emote'
}, {
  type: MESSAGE_TYPE_RADIO,
  name: 'Radio',
  description: 'All departments of radio messages',
  selector: '.alert, .syndradio, .centradio, .airadio, .entradio, .comradio, .secradio, .engradio, .medradio, .sciradio, .supradio, .srvradio, .expradio, .radio, .deptradio, .newscaster'
}, {
  type: MESSAGE_TYPE_INFO,
  name: 'Info',
  description: 'Non-urgent messages from the game and items',
  selector: '.notice:not(.pm), .adminnotice, .info, .sinister, .cult'
}, {
  type: MESSAGE_TYPE_WARNING,
  name: 'Warnings',
  description: 'Urgent messages from the game and items',
  selector: '.warning:not(.pm), .critical, .userdanger, .italics'
}, {
  type: MESSAGE_TYPE_DEADCHAT,
  name: 'Deadchat',
  description: 'All of deadchat',
  selector: '.deadsay'
}, {
  type: MESSAGE_TYPE_OOC,
  name: 'OOC',
  description: 'The bluewall of global OOC messages',
  selector: '.ooc, .adminooc'
}, {
  type: MESSAGE_TYPE_ADMINPM,
  name: 'Admin PMs',
  description: 'Messages to/from admins (adminhelp)',
  selector: '.pm, .adminhelp'
}, {
  type: MESSAGE_TYPE_COMBAT,
  name: 'Combat Log',
  description: 'Urist McTraitor has stabbed you with a knife!',
  selector: '.danger'
}, {
  type: MESSAGE_TYPE_UNKNOWN,
  name: 'Unsorted',
  description: 'Everything we could not sort, always enabled'
}, // Admin stuff
{
  type: MESSAGE_TYPE_ADMINCHAT,
  name: 'Admin Chat',
  description: 'ASAY messages',
  selector: '.admin_channel, .adminsay',
  admin: true
}, {
  type: MESSAGE_TYPE_MODCHAT,
  name: 'Mod Chat',
  description: 'MSAY messages',
  selector: '.mod_channel',
  admin: true
}, {
  type: MESSAGE_TYPE_ADMINLOG,
  name: 'Admin Log',
  description: 'ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z',
  selector: '.log_message',
  admin: true
}, {
  type: MESSAGE_TYPE_ATTACKLOG,
  name: 'Attack Log',
  description: 'Urist McTraitor has shot John Doe',
  admin: true
}, {
  type: MESSAGE_TYPE_DEBUG,
  name: 'Debug Log',
  description: 'DEBUG: SSPlanets subsystem Recover().',
  admin: true
}];
exports.MESSAGE_TYPES = MESSAGE_TYPES;

/***/ }),

/***/ "./packages/tgui-panel/chat/index.js":
/*!*******************************************!*\
  !*** ./packages/tgui-panel/chat/index.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.chatReducer = exports.chatMiddleware = exports.ChatTabs = exports.ChatPanel = exports.ChatPageSettings = void 0;

var _ChatPageSettings = __webpack_require__(/*! ./ChatPageSettings */ "./packages/tgui-panel/chat/ChatPageSettings.js");

exports.ChatPageSettings = _ChatPageSettings.ChatPageSettings;

var _ChatPanel = __webpack_require__(/*! ./ChatPanel */ "./packages/tgui-panel/chat/ChatPanel.js");

exports.ChatPanel = _ChatPanel.ChatPanel;

var _ChatTabs = __webpack_require__(/*! ./ChatTabs */ "./packages/tgui-panel/chat/ChatTabs.js");

exports.ChatTabs = _ChatTabs.ChatTabs;

var _middleware = __webpack_require__(/*! ./middleware */ "./packages/tgui-panel/chat/middleware.js");

exports.chatMiddleware = _middleware.chatMiddleware;

var _reducer = __webpack_require__(/*! ./reducer */ "./packages/tgui-panel/chat/reducer.js");

exports.chatReducer = _reducer.chatReducer;

/***/ }),

/***/ "./packages/tgui-panel/chat/middleware.js":
/*!************************************************!*\
  !*** ./packages/tgui-panel/chat/middleware.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.chatMiddleware = void 0;

var _storage = __webpack_require__(/*! common/storage */ "./packages/common/storage.js");

var _actions = __webpack_require__(/*! ../settings/actions */ "./packages/tgui-panel/settings/actions.js");

var _selectors = __webpack_require__(/*! ../settings/selectors */ "./packages/tgui-panel/settings/selectors.js");

var _actions2 = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/chat/actions.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/chat/constants.js");

var _model = __webpack_require__(/*! ./model */ "./packages/tgui-panel/chat/model.js");

var _renderer = __webpack_require__(/*! ./renderer */ "./packages/tgui-panel/chat/renderer.js");

var _selectors2 = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/chat/selectors.js");

var _logging = __webpack_require__(/*! tgui/logging */ "./packages/tgui/logging.js");

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

var saveChatToStorage = /*#__PURE__*/function () {
  var _ref = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function () {
    function _callee(store) {
      var state, fromIndex, messages;
      return regeneratorRuntime.wrap(function () {
        function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                state = (0, _selectors2.selectChat)(store.getState());
                fromIndex = Math.max(0, _renderer.chatRenderer.messages.length - _constants.MAX_PERSISTED_MESSAGES);
                messages = _renderer.chatRenderer.messages.slice(fromIndex).map(function (message) {
                  return (0, _model.serializeMessage)(message);
                });

                _storage.storage.set('chat-state', state);

                _storage.storage.set('chat-messages', messages);

              case 5:
              case "end":
                return _context.stop();
            }
          }
        }

        return _callee$;
      }(), _callee);
    }

    return _callee;
  }()));

  return function () {
    function saveChatToStorage(_x) {
      return _ref.apply(this, arguments);
    }

    return saveChatToStorage;
  }();
}();

var loadChatFromStorage = /*#__PURE__*/function () {
  var _ref2 = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function () {
    function _callee2(store) {
      var _yield$Promise$all, state, messages, batch;

      return regeneratorRuntime.wrap(function () {
        function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                _context2.next = 2;
                return Promise.all([_storage.storage.get('chat-state'), _storage.storage.get('chat-messages')]);

              case 2:
                _yield$Promise$all = _context2.sent;
                state = _yield$Promise$all[0];
                messages = _yield$Promise$all[1];

                if (!(state && state.version <= 4)) {
                  _context2.next = 8;
                  break;
                }

                store.dispatch((0, _actions2.loadChat)());
                return _context2.abrupt("return");

              case 8:
                if (messages) {
                  batch = [].concat(messages, [(0, _model.createMessage)({
                    type: 'internal/reconnected'
                  })]);

                  _renderer.chatRenderer.processBatch(batch, {
                    prepend: true
                  });
                }

                store.dispatch((0, _actions2.loadChat)(state));

              case 10:
              case "end":
                return _context2.stop();
            }
          }
        }

        return _callee2$;
      }(), _callee2);
    }

    return _callee2;
  }()));

  return function () {
    function loadChatFromStorage(_x2) {
      return _ref2.apply(this, arguments);
    }

    return loadChatFromStorage;
  }();
}();

var chatMiddleware = function chatMiddleware(store) {
  var initialized = false;
  var loaded = false;

  _renderer.chatRenderer.events.on('batchProcessed', function (countByType) {
    // Use this flag to workaround unread messages caused by
    // loading them from storage. Side effect of that, is that
    // message count can not be trusted, only unread count.
    if (loaded) {
      store.dispatch((0, _actions2.updateMessageCount)(countByType));
    }
  });

  _renderer.chatRenderer.events.on('scrollTrackingChanged', function (scrollTracking) {
    store.dispatch((0, _actions2.changeScrollTracking)(scrollTracking));
  });

  setInterval(function () {
    return saveChatToStorage(store);
  }, _constants.MESSAGE_SAVE_INTERVAL);
  return function (next) {
    return function (action) {
      var type = action.type,
          payload = action.payload;

      if (!initialized) {
        initialized = true;
        loadChatFromStorage(store);
      }

      if (type === 'chat/message') {
        // Normalize the payload
        var batch = Array.isArray(payload) ? payload : [payload];

        _renderer.chatRenderer.processBatch(batch);

        return;
      }

      if (type === _actions2.loadChat.type) {
        next(action);
        var page = (0, _selectors2.selectCurrentChatPage)(store.getState());

        _renderer.chatRenderer.changePage(page);

        _renderer.chatRenderer.onStateLoaded();

        loaded = true;
        return;
      }

      if (type === _actions2.changeChatPage.type || type === _actions2.addChatPage.type || type === _actions2.removeChatPage.type || type === _actions2.toggleAcceptedType.type) {
        next(action);

        var _page = (0, _selectors2.selectCurrentChatPage)(store.getState());

        _renderer.chatRenderer.changePage(_page);

        return;
      }

      if (type === _actions2.rebuildChat.type) {
        _renderer.chatRenderer.rebuildChat();

        return next(action);
      }

      if (type === _actions.updateSettings.type || type === _actions.loadSettings.type) {
        next(action);
        var settings = (0, _selectors.selectSettings)(store.getState());

        _renderer.chatRenderer.setHighlight(settings.highlightText, settings.highlightColor);

        return;
      }

      if (type === 'roundrestart') {
        // Save chat as soon as possible
        saveChatToStorage(store);
        return next(action);
      }

      if (type === _actions2.saveChatToDisk.type) {
        _renderer.chatRenderer.saveToDisk();

        return;
      }

      return next(action);
    };
  };
};

exports.chatMiddleware = chatMiddleware;

/***/ }),

/***/ "./packages/tgui-panel/chat/model.js":
/*!*******************************************!*\
  !*** ./packages/tgui-panel/chat/model.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.isSameMessage = exports.serializeMessage = exports.createMessage = exports.createMainPage = exports.createPage = exports.canPageAcceptType = void 0;

var _uuid = __webpack_require__(/*! common/uuid */ "./packages/common/uuid.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/chat/constants.js");

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } it = o[Symbol.iterator](); return it.next.bind(it); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

var canPageAcceptType = function canPageAcceptType(page, type) {
  return type.startsWith(_constants.MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type];
};

exports.canPageAcceptType = canPageAcceptType;

var createPage = function createPage(obj) {
  return Object.assign({
    id: (0, _uuid.createUuid)(),
    name: 'New Tab',
    acceptedTypes: {},
    unreadCount: 0,
    createdAt: Date.now()
  }, obj);
};

exports.createPage = createPage;

var createMainPage = function createMainPage() {
  var acceptedTypes = {};

  for (var _iterator = _createForOfIteratorHelperLoose(_constants.MESSAGE_TYPES), _step; !(_step = _iterator()).done;) {
    var typeDef = _step.value;
    acceptedTypes[typeDef.type] = true;
  }

  return createPage({
    name: 'Main',
    acceptedTypes: acceptedTypes
  });
};

exports.createMainPage = createMainPage;

var createMessage = function createMessage(payload) {
  return Object.assign({
    createdAt: Date.now()
  }, payload);
};

exports.createMessage = createMessage;

var serializeMessage = function serializeMessage(message) {
  return {
    type: message.type,
    text: message.text,
    html: message.html,
    times: message.times,
    createdAt: message.createdAt
  };
};

exports.serializeMessage = serializeMessage;

var isSameMessage = function isSameMessage(a, b) {
  return typeof a.text === 'string' && a.text === b.text || typeof a.html === 'string' && a.html === b.html;
};

exports.isSameMessage = isSameMessage;

/***/ }),

/***/ "./packages/tgui-panel/chat/reducer.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/chat/reducer.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.chatReducer = exports.initialState = void 0;

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/chat/actions.js");

var _model = __webpack_require__(/*! ./model */ "./packages/tgui-panel/chat/model.js");

var _pageById;

function _objectWithoutPropertiesLoose(source, excluded) { if (source == null) return {}; var target = {}; var sourceKeys = Object.keys(source); var key, i; for (i = 0; i < sourceKeys.length; i++) { key = sourceKeys[i]; if (excluded.indexOf(key) >= 0) continue; target[key] = source[key]; } return target; }

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } it = o[Symbol.iterator](); return it.next.bind(it); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

var mainPage = (0, _model.createMainPage)();
var initialState = {
  version: 5,
  currentPageId: mainPage.id,
  scrollTracking: true,
  pages: [mainPage.id],
  pageById: (_pageById = {}, _pageById[mainPage.id] = mainPage, _pageById)
};
exports.initialState = initialState;

var chatReducer = function chatReducer(state, action) {
  if (state === void 0) {
    state = initialState;
  }

  var type = action.type,
      payload = action.payload;

  if (type === _actions.loadChat.type) {
    // Validate version and/or migrate state
    if ((payload == null ? void 0 : payload.version) !== state.version) {
      return state;
    } // Reset page message counts
    // NOTE: We are mutably changing the payload on the assumption
    // that it is a copy that comes straight from the web storage.


    for (var _i = 0, _Object$keys = Object.keys(payload.pageById); _i < _Object$keys.length; _i++) {
      var id = _Object$keys[_i];
      var page = payload.pageById[id];
      page.unreadCount = 0;
    }

    return Object.assign({}, state, payload);
  }

  if (type === _actions.changeScrollTracking.type) {
    var scrollTracking = payload;
    var nextState = Object.assign({}, state, {
      scrollTracking: scrollTracking
    });

    if (scrollTracking) {
      var _Object$assign;

      var pageId = state.currentPageId;

      var _page = Object.assign({}, state.pageById[pageId], {
        unreadCount: 0
      });

      nextState.pageById = Object.assign({}, state.pageById, (_Object$assign = {}, _Object$assign[pageId] = _page, _Object$assign));
    }

    return nextState;
  }

  if (type === _actions.updateMessageCount.type) {
    var countByType = payload;
    var pages = state.pages.map(function (id) {
      return state.pageById[id];
    });
    var currentPage = state.pageById[state.currentPageId];
    var nextPageById = Object.assign({}, state.pageById);

    for (var _iterator = _createForOfIteratorHelperLoose(pages), _step; !(_step = _iterator()).done;) {
      var _page2 = _step.value;
      var unreadCount = 0;

      for (var _i2 = 0, _Object$keys2 = Object.keys(countByType); _i2 < _Object$keys2.length; _i2++) {
        var _type = _Object$keys2[_i2];

        // Message does not belong here
        if (!(0, _model.canPageAcceptType)(_page2, _type)) {
          continue;
        } // Current page is scroll tracked


        if (_page2 === currentPage && state.scrollTracking) {
          continue;
        } // This page received the same message which we can read
        // on the current page.


        if (_page2 !== currentPage && (0, _model.canPageAcceptType)(currentPage, _type)) {
          continue;
        }

        unreadCount += countByType[_type];
      }

      if (unreadCount > 0) {
        nextPageById[_page2.id] = Object.assign({}, _page2, {
          unreadCount: _page2.unreadCount + unreadCount
        });
      }
    }

    return Object.assign({}, state, {
      pageById: nextPageById
    });
  }

  if (type === _actions.addChatPage.type) {
    var _Object$assign2;

    return Object.assign({}, state, {
      currentPageId: payload.id,
      pages: [].concat(state.pages, [payload.id]),
      pageById: Object.assign({}, state.pageById, (_Object$assign2 = {}, _Object$assign2[payload.id] = payload, _Object$assign2))
    });
  }

  if (type === _actions.changeChatPage.type) {
    var _Object$assign3;

    var _pageId = payload.pageId;

    var _page3 = Object.assign({}, state.pageById[_pageId], {
      unreadCount: 0
    });

    return Object.assign({}, state, {
      currentPageId: _pageId,
      pageById: Object.assign({}, state.pageById, (_Object$assign3 = {}, _Object$assign3[_pageId] = _page3, _Object$assign3))
    });
  }

  if (type === _actions.updateChatPage.type) {
    var _Object$assign4;

    var _pageId2 = payload.pageId,
        update = _objectWithoutPropertiesLoose(payload, ["pageId"]);

    var _page4 = Object.assign({}, state.pageById[_pageId2], update);

    return Object.assign({}, state, {
      pageById: Object.assign({}, state.pageById, (_Object$assign4 = {}, _Object$assign4[_pageId2] = _page4, _Object$assign4))
    });
  }

  if (type === _actions.toggleAcceptedType.type) {
    var _Object$assign5;

    var _pageId3 = payload.pageId,
        _type2 = payload.type;

    var _page5 = Object.assign({}, state.pageById[_pageId3]);

    _page5.acceptedTypes = Object.assign({}, _page5.acceptedTypes);
    _page5.acceptedTypes[_type2] = !_page5.acceptedTypes[_type2];
    return Object.assign({}, state, {
      pageById: Object.assign({}, state.pageById, (_Object$assign5 = {}, _Object$assign5[_pageId3] = _page5, _Object$assign5))
    });
  }

  if (type === _actions.removeChatPage.type) {
    var _pageId4 = payload.pageId;

    var _nextState = Object.assign({}, state, {
      pages: [].concat(state.pages),
      pageById: Object.assign({}, state.pageById)
    });

    delete _nextState.pageById[_pageId4];
    _nextState.pages = _nextState.pages.filter(function (id) {
      return id !== _pageId4;
    });

    if (_nextState.pages.length === 0) {
      _nextState.pages.push(mainPage.id);

      _nextState.pageById[mainPage.id] = mainPage;
      _nextState.currentPageId = mainPage.id;
    }

    if (!_nextState.currentPageId || _nextState.currentPageId === _pageId4) {
      _nextState.currentPageId = _nextState.pages[0];
    }

    return _nextState;
  }

  return state;
};

exports.chatReducer = chatReducer;

/***/ }),

/***/ "./packages/tgui-panel/chat/renderer.js":
/*!**********************************************!*\
  !*** ./packages/tgui-panel/chat/renderer.js ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(setImmediate) {

exports.__esModule = true;
exports.chatRenderer = void 0;

var _events = __webpack_require__(/*! common/events */ "./packages/common/events.js");

var _react = __webpack_require__(/*! common/react */ "./packages/common/react.js");

var _logging = __webpack_require__(/*! tgui/logging */ "./packages/tgui/logging.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/chat/constants.js");

var _model = __webpack_require__(/*! ./model */ "./packages/tgui-panel/chat/model.js");

var _replaceInTextNode = __webpack_require__(/*! ./replaceInTextNode */ "./packages/tgui-panel/chat/replaceInTextNode.js");

function _createForOfIteratorHelperLoose(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; return function () { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } it = o[Symbol.iterator](); return it.next.bind(it); }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

var logger = (0, _logging.createLogger)('chatRenderer'); // We consider this as the smallest possible scroll offset
// that is still trackable.

var SCROLL_TRACKING_TOLERANCE = 24;

var findNearestScrollableParent = function findNearestScrollableParent(startingNode) {
  var body = document.body;
  var node = startingNode;

  while (node && node !== body) {
    // This definitely has a vertical scrollbar, because it reduces
    // scrollWidth of the element. Might not work if element uses
    // overflow: hidden.
    if (node.scrollWidth < node.offsetWidth) {
      return node;
    }

    node = node.parentNode;
  }

  return window;
};

var createHighlightNode = function createHighlightNode(text, color) {
  var node = document.createElement('span');
  node.className = 'Chat__highlight';
  node.setAttribute('style', 'background-color:' + color);
  node.textContent = text;
  return node;
};

var createMessageNode = function createMessageNode() {
  var node = document.createElement('div');
  node.className = 'ChatMessage';
  return node;
};

var createReconnectedNode = function createReconnectedNode() {
  var node = document.createElement('div');
  node.className = 'Chat__reconnected';
  return node;
};

var handleImageError = function handleImageError(e) {
  setTimeout(function () {
    /** @type {HTMLImageElement} */
    var node = e.target;
    var attempts = parseInt(node.getAttribute('data-reload-n'), 10) || 0;

    if (attempts >= _constants.IMAGE_RETRY_LIMIT) {
      logger.error("failed to load an image after " + attempts + " attempts");
      return;
    }

    var src = node.src;
    node.src = null;
    node.src = src + '#' + attempts;
    node.setAttribute('data-reload-n', attempts + 1);
  }, _constants.IMAGE_RETRY_DELAY);
};
/**
 * Assigns a "times-repeated" badge to the message.
 */


var updateMessageBadge = function updateMessageBadge(message) {
  var node = message.node,
      times = message.times;

  if (!node || !times) {
    // Nothing to update
    return;
  }

  var foundBadge = node.querySelector('.Chat__badge');
  var badge = foundBadge || document.createElement('div');
  badge.textContent = times;
  badge.className = (0, _react.classes)(['Chat__badge', 'Chat__badge--animate']);
  requestAnimationFrame(function () {
    badge.className = 'Chat__badge';
  });

  if (!foundBadge) {
    node.appendChild(badge);
  }
};

var ChatRenderer = /*#__PURE__*/function () {
  function ChatRenderer() {
    var _this = this;

    /** @type {HTMLElement} */
    this.loaded = false;
    /** @type {HTMLElement} */

    this.rootNode = null;
    this.queue = [];
    this.messages = [];
    this.visibleMessages = [];
    this.page = null;
    this.events = new _events.EventEmitter(); // Scroll handler

    /** @type {HTMLElement} */

    this.scrollNode = null;
    this.scrollTracking = true;

    this.handleScroll = function (type) {
      var node = _this.scrollNode;
      var height = node.scrollHeight;
      var bottom = node.scrollTop + node.offsetHeight;
      var scrollTracking = Math.abs(height - bottom) < SCROLL_TRACKING_TOLERANCE;

      if (scrollTracking !== _this.scrollTracking) {
        _this.scrollTracking = scrollTracking;

        _this.events.emit('scrollTrackingChanged', scrollTracking);

        logger.debug('tracking', _this.scrollTracking);
      }
    };

    this.ensureScrollTracking = function () {
      if (_this.scrollTracking) {
        _this.scrollToBottom();
      }
    }; // Periodic message pruning


    setInterval(function () {
      return _this.pruneMessages();
    }, _constants.MESSAGE_PRUNE_INTERVAL);
  }

  var _proto = ChatRenderer.prototype;

  _proto.isReady = function () {
    function isReady() {
      return this.loaded && this.rootNode && this.page;
    }

    return isReady;
  }();

  _proto.mount = function () {
    function mount(node) {
      var _this2 = this;

      // Mount existing root node on top of the new node
      if (this.rootNode) {
        node.appendChild(this.rootNode);
      } // Initialize the root node
      else {
          this.rootNode = node;
        } // Find scrollable parent


      this.scrollNode = findNearestScrollableParent(this.rootNode);
      this.scrollNode.addEventListener('scroll', this.handleScroll);
      setImmediate(function () {
        _this2.scrollToBottom();
      }); // Flush the queue

      this.tryFlushQueue();
    }

    return mount;
  }();

  _proto.onStateLoaded = function () {
    function onStateLoaded() {
      this.loaded = true;
      this.tryFlushQueue();
    }

    return onStateLoaded;
  }();

  _proto.tryFlushQueue = function () {
    function tryFlushQueue() {
      if (this.isReady() && this.queue.length > 0) {
        this.processBatch(this.queue);
        this.queue = [];
      }
    }

    return tryFlushQueue;
  }();

  _proto.assignStyle = function () {
    function assignStyle(style) {
      if (style === void 0) {
        style = {};
      }

      for (var _i = 0, _Object$keys = Object.keys(style); _i < _Object$keys.length; _i++) {
        var key = _Object$keys[_i];
        this.rootNode.style.setProperty(key, style[key]);
      }
    }

    return assignStyle;
  }();

  _proto.setHighlight = function () {
    function setHighlight(text, color) {
      if (!text || !color) {
        this.highlightRegex = null;
        this.highlightColor = null;
        return;
      }

      var allowedRegex = /^[a-z0-9_\-\s]+$/ig;
      var lines = String(text).split(',').map(function (str) {
        return str.trim();
      }).filter(function (str) {
        return (// Must be longer than one character
          str && str.length > 1 // Must be alphanumeric (with some punctuation)
          && allowedRegex.test(str)
        );
      }); // Nothing to match, reset highlighting

      if (lines.length === 0) {
        this.highlightRegex = null;
        this.highlightColor = null;
        return;
      }

      this.highlightRegex = new RegExp('(' + lines.join('|') + ')', 'gi');
      this.highlightColor = color;
    }

    return setHighlight;
  }();

  _proto.scrollToBottom = function () {
    function scrollToBottom() {
      // scrollHeight is always bigger than scrollTop and is
      // automatically clamped to the valid range.
      this.scrollNode.scrollTop = this.scrollNode.scrollHeight;
    }

    return scrollToBottom;
  }();

  _proto.changePage = function () {
    function changePage(page) {
      if (!this.isReady()) {
        this.page = page;
        this.tryFlushQueue();
        return;
      }

      this.page = page; // Fast clear of the root node

      this.rootNode.textContent = '';
      this.visibleMessages = []; // Re-add message nodes

      var fragment = document.createDocumentFragment();
      var node;

      for (var _iterator = _createForOfIteratorHelperLoose(this.messages), _step; !(_step = _iterator()).done;) {
        var message = _step.value;

        if ((0, _model.canPageAcceptType)(page, message.type)) {
          node = message.node;
          fragment.appendChild(node);
          this.visibleMessages.push(message);
        }
      }

      if (node) {
        this.rootNode.appendChild(fragment);
        node.scrollIntoView();
      }
    }

    return changePage;
  }();

  _proto.getCombinableMessage = function () {
    function getCombinableMessage(predicate) {
      var now = Date.now();
      var len = this.visibleMessages.length;
      var from = len - 1;
      var to = Math.max(0, len - _constants.COMBINE_MAX_MESSAGES);

      for (var i = from; i >= to; i--) {
        var message = this.visibleMessages[i];

        var matches = // Is not an internal message
        !message.type.startsWith(_constants.MESSAGE_TYPE_INTERNAL) // Text payload must fully match
        && (0, _model.isSameMessage)(message, predicate) // Must land within the specified time window
        && now < message.createdAt + _constants.COMBINE_MAX_TIME_WINDOW;

        if (matches) {
          return message;
        }
      }

      return null;
    }

    return getCombinableMessage;
  }();

  _proto.processBatch = function () {
    function processBatch(batch, options) {
      var _this3 = this;

      if (options === void 0) {
        options = {};
      }

      var _options = options,
          prepend = _options.prepend,
          _options$notifyListen = _options.notifyListeners,
          notifyListeners = _options$notifyListen === void 0 ? true : _options$notifyListen;
      var now = Date.now(); // Queue up messages until chat is ready

      if (!this.isReady()) {
        if (prepend) {
          this.queue = [].concat(batch, this.queue);
        } else {
          this.queue = [].concat(this.queue, batch);
        }

        return;
      } // Insert messages


      var fragment = document.createDocumentFragment();
      var countByType = {};
      var node;

      for (var _iterator2 = _createForOfIteratorHelperLoose(batch), _step2; !(_step2 = _iterator2()).done;) {
        var payload = _step2.value;
        var message = (0, _model.createMessage)(payload); // Combine messages

        var combinable = this.getCombinableMessage(message);

        if (combinable) {
          combinable.times = (combinable.times || 1) + 1;
          updateMessageBadge(combinable);
          continue;
        } // Reuse message node


        if (message.node) {
          node = message.node;
        } // Reconnected
        else if (message.type === 'internal/reconnected') {
            node = createReconnectedNode();
          } // Create message node
          else {
              node = createMessageNode(); // Payload is plain text

              if (message.text) {
                node.textContent = message.text;
              } // Payload is HTML
              else if (message.html) {
                  node.innerHTML = message.html;
                } else {
                  logger.error('Error: message is missing text payload', message);
                } // Highlight text


              if (!message.avoidHighlighting && this.highlightRegex) {
                var highlighted = (0, _replaceInTextNode.highlightNode)(node, this.highlightRegex, function (text) {
                  return createHighlightNode(text, _this3.highlightColor);
                });

                if (highlighted) {
                  node.className += ' ChatMessage--highlighted';
                }
              } // Linkify text


              (0, _replaceInTextNode.linkifyNode)(node); // Assign an image error handler

              if (now < message.createdAt + _constants.IMAGE_RETRY_MESSAGE_AGE) {
                var imgNodes = node.querySelectorAll('img');

                for (var i = 0; i < imgNodes.length; i++) {
                  var imgNode = imgNodes[i];
                  imgNode.addEventListener('error', handleImageError);
                }
              }
            } // Store the node in the message


        message.node = node; // Query all possible selectors to find out the message type

        if (!message.type) {
          // IE8: Does not support querySelector on elements that
          // are not yet in the document.
          var typeDef = !Byond.IS_LTE_IE8 && _constants.MESSAGE_TYPES.find(function (typeDef) {
            return typeDef.selector && node.querySelector(typeDef.selector);
          });

          message.type = (typeDef == null ? void 0 : typeDef.type) || _constants.MESSAGE_TYPE_UNKNOWN;
        }

        updateMessageBadge(message);

        if (!countByType[message.type]) {
          countByType[message.type] = 0;
        }

        countByType[message.type] += 1; // TODO: Detect duplicates

        this.messages.push(message);

        if ((0, _model.canPageAcceptType)(this.page, message.type)) {
          fragment.appendChild(node);
          this.visibleMessages.push(message);
        }
      }

      if (node) {
        var firstChild = this.rootNode.childNodes[0];

        if (prepend && firstChild) {
          this.rootNode.insertBefore(fragment, firstChild);
        } else {
          this.rootNode.appendChild(fragment);
        }

        if (this.scrollTracking) {
          setImmediate(function () {
            return _this3.scrollToBottom();
          });
        }
      } // Notify listeners that we have processed the batch


      if (notifyListeners) {
        this.events.emit('batchProcessed', countByType);
      }
    }

    return processBatch;
  }();

  _proto.pruneMessages = function () {
    function pruneMessages() {
      if (!this.isReady()) {
        return;
      } // Delay pruning because user is currently interacting
      // with chat history


      if (!this.scrollTracking) {
        logger.debug('pruning delayed');
        return;
      } // Visible messages


      {
        var messages = this.visibleMessages;
        var fromIndex = Math.max(0, messages.length - _constants.MAX_VISIBLE_MESSAGES);

        if (fromIndex > 0) {
          this.visibleMessages = messages.slice(fromIndex);

          for (var i = 0; i < fromIndex; i++) {
            var message = messages[i];
            this.rootNode.removeChild(message.node); // Mark this message as pruned

            message.node = 'pruned';
          } // Remove pruned messages from the message array


          this.messages = this.messages.filter(function (message) {
            return message.node !== 'pruned';
          });
          logger.log("pruned " + fromIndex + " visible messages");
        }
      } // All messages

      {
        var _fromIndex = Math.max(0, this.messages.length - _constants.MAX_PERSISTED_MESSAGES);

        if (_fromIndex > 0) {
          this.messages = this.messages.slice(_fromIndex);
          logger.log("pruned " + _fromIndex + " stored messages");
        }
      }
    }

    return pruneMessages;
  }();

  _proto.rebuildChat = function () {
    function rebuildChat() {
      if (!this.isReady()) {
        return;
      } // Make a copy of messages


      var fromIndex = Math.max(0, this.messages.length - _constants.MAX_PERSISTED_MESSAGES);
      var messages = this.messages.slice(fromIndex); // Remove existing nodes

      for (var _iterator3 = _createForOfIteratorHelperLoose(messages), _step3; !(_step3 = _iterator3()).done;) {
        var message = _step3.value;
        message.node = undefined;
      } // Fast clear of the root node


      this.rootNode.textContent = '';
      this.messages = [];
      this.visibleMessages = []; // Repopulate the chat log

      this.processBatch(messages, {
        notifyListeners: false
      });
    }

    return rebuildChat;
  }();

  _proto.saveToDisk = function () {
    function saveToDisk() {
      // Allow only on IE11
      if (Byond.IS_LTE_IE10) {
        return;
      } // Compile currently loaded stylesheets as CSS text


      var cssText = '';
      var styleSheets = document.styleSheets;

      for (var i = 0; i < styleSheets.length; i++) {
        var cssRules = styleSheets[i].cssRules;

        for (var _i2 = 0; _i2 < cssRules.length; _i2++) {
          var rule = cssRules[_i2];
          cssText += rule.cssText + '\n';
        }
      }

      cssText += 'body, html { background-color: #141414 }\n'; // Compile chat log as HTML text

      var messagesHtml = '';

      for (var _iterator4 = _createForOfIteratorHelperLoose(this.messages), _step4; !(_step4 = _iterator4()).done;) {
        var message = _step4.value;

        if (message.node) {
          messagesHtml += message.node.outerHTML + '\n';
        }
      } // Create a page


      var pageHtml = '<!doctype html>\n' + '<html>\n' + '<head>\n' + '<title>SS13 Chat Log</title>\n' + '<style>\n' + cssText + '</style>\n' + '</head>\n' + '<body>\n' + '<div class="Chat">\n' + messagesHtml + '</div>\n' + '</body>\n' + '</html>\n'; // Create and send a nice blob

      var blob = new Blob([pageHtml]);
      var timestamp = new Date().toISOString().substring(0, 19).replace(/[-:]/g, '').replace('T', '-');
      window.navigator.msSaveBlob(blob, "ss13-chatlog-" + timestamp + ".html");
    }

    return saveToDisk;
  }();

  return ChatRenderer;
}(); // Make chat renderer global so that we can continue using the same
// instance after hot code replacement.


if (!window.__chatRenderer__) {
  window.__chatRenderer__ = new ChatRenderer();
}
/** @type {ChatRenderer} */


var chatRenderer = window.__chatRenderer__;
exports.chatRenderer = chatRenderer;
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../.yarn/cache/timers-browserify-npm-2.0.11-f20435228f-73faad065e.zip/node_modules/timers-browserify/main.js */ "./.yarn/cache/timers-browserify-npm-2.0.11-f20435228f-73faad065e.zip/node_modules/timers-browserify/main.js").setImmediate))

/***/ }),

/***/ "./packages/tgui-panel/chat/replaceInTextNode.js":
/*!*******************************************************!*\
  !*** ./packages/tgui-panel/chat/replaceInTextNode.js ***!
  \*******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.linkifyNode = exports.highlightNode = exports.replaceInTextNode = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

/**
 * Replaces text matching a regular expression with a custom node.
 */
var replaceInTextNode = function replaceInTextNode(regex, createNode) {
  return function (node) {
    var text = node.textContent;
    var textLength = text.length;
    var match;
    var lastIndex = 0;
    var fragment;
    var n = 0; // eslint-disable-next-line no-cond-assign

    while (match = regex.exec(text)) {
      n += 1; // Lazy init fragment

      if (!fragment) {
        fragment = document.createDocumentFragment();
      }

      var matchText = match[0];
      var matchLength = matchText.length;
      var matchIndex = match.index; // Insert previous unmatched chunk

      if (lastIndex < matchIndex) {
        fragment.appendChild(document.createTextNode(text.substring(lastIndex, matchIndex)));
      }

      lastIndex = matchIndex + matchLength; // Create a wrapper node

      fragment.appendChild(createNode(matchText));
    }

    if (fragment) {
      // Insert the remaining unmatched chunk
      if (lastIndex < textLength) {
        fragment.appendChild(document.createTextNode(text.substring(lastIndex, textLength)));
      } // Commit the fragment


      node.parentNode.replaceChild(fragment, node);
    }

    return n;
  };
}; // Highlight
// --------------------------------------------------------

/**
 * Default highlight node.
 */


exports.replaceInTextNode = replaceInTextNode;

var createHighlightNode = function createHighlightNode(text) {
  var node = document.createElement('span');
  node.setAttribute('style', 'background-color:#fd4;color:#000');
  node.textContent = text;
  return node;
};
/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @param {RegExp} regex Regular expression to highlight
 * @param {(text: string) => Node} createNode Highlight node creator
 * @returns {number} Number of matches
 */


var highlightNode = function highlightNode(node, regex, createNode) {
  if (createNode === void 0) {
    createNode = createHighlightNode;
  }

  if (!createNode) {
    createNode = createHighlightNode;
  }

  var n = 0;
  var childNodes = node.childNodes;

  for (var i = 0; i < childNodes.length; i++) {
    var _node = childNodes[i]; // Is a text node

    if (_node.nodeType === 3) {
      n += replaceInTextNode(regex, createNode)(_node);
    } else {
      n += highlightNode(_node, regex, createNode);
    }
  }

  return n;
}; // Linkify
// --------------------------------------------------------


exports.highlightNode = highlightNode;
var URL_REGEX = /(?:(?:https?:\/\/)|(?:www\.))(?:[^ ]*?\.[^ ]*?)+[-A-Za-z0-9+&@#/%?=~_|$!:,.;()]+/ig;
/**
 * Highlights the text in the node based on the provided regular expression.
 *
 * @param {Node} node Node which you want to process
 * @returns {number} Number of matches
 */

var linkifyNode = function linkifyNode(node) {
  var n = 0;
  var childNodes = node.childNodes;

  for (var i = 0; i < childNodes.length; i++) {
    var _node2 = childNodes[i];
    var tag = String(_node2.nodeName).toLowerCase(); // Is a text node

    if (_node2.nodeType === 3) {
      n += linkifyTextNode(_node2);
    } else if (tag !== 'a') {
      n += linkifyNode(_node2);
    }
  }

  return n;
};

exports.linkifyNode = linkifyNode;
var linkifyTextNode = replaceInTextNode(URL_REGEX, function (text) {
  var node = document.createElement('a');
  node.href = text;
  node.textContent = text;
  return node;
});

/***/ }),

/***/ "./packages/tgui-panel/chat/selectors.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/chat/selectors.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.selectChatPageById = exports.selectCurrentChatPage = exports.selectChatPages = exports.selectChat = void 0;

var _collections = __webpack_require__(/*! common/collections */ "./packages/common/collections.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var selectChat = function selectChat(state) {
  return state.chat;
};

exports.selectChat = selectChat;

var selectChatPages = function selectChatPages(state) {
  return (0, _collections.map)(function (id) {
    return state.chat.pageById[id];
  })(state.chat.pages);
};

exports.selectChatPages = selectChatPages;

var selectCurrentChatPage = function selectCurrentChatPage(state) {
  return state.chat.pageById[state.chat.currentPageId];
};

exports.selectCurrentChatPage = selectCurrentChatPage;

var selectChatPageById = function selectChatPageById(id) {
  return function (state) {
    return state.chat.pageById[id];
  };
};

exports.selectChatPageById = selectChatPageById;

/***/ }),

/***/ "./packages/tgui-panel/game/actions.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/game/actions.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.connectionRestored = exports.connectionLost = exports.roundRestarted = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var roundRestarted = (0, _redux.createAction)('roundrestart');
exports.roundRestarted = roundRestarted;
var connectionLost = (0, _redux.createAction)('game/connectionLost');
exports.connectionLost = connectionLost;
var connectionRestored = (0, _redux.createAction)('game/connectionRestored');
exports.connectionRestored = connectionRestored;

/***/ }),

/***/ "./packages/tgui-panel/game/constants.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/game/constants.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.CONNECTION_LOST_AFTER = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var CONNECTION_LOST_AFTER = 15000;
exports.CONNECTION_LOST_AFTER = CONNECTION_LOST_AFTER;

/***/ }),

/***/ "./packages/tgui-panel/game/hooks.js":
/*!*******************************************!*\
  !*** ./packages/tgui-panel/game/hooks.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.useGame = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/game/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var useGame = function useGame(context) {
  return (0, _redux.useSelector)(context, _selectors.selectGame);
};

exports.useGame = useGame;

/***/ }),

/***/ "./packages/tgui-panel/game/index.js":
/*!*******************************************!*\
  !*** ./packages/tgui-panel/game/index.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.gameReducer = exports.gameMiddleware = exports.useGame = void 0;

var _hooks = __webpack_require__(/*! ./hooks */ "./packages/tgui-panel/game/hooks.js");

exports.useGame = _hooks.useGame;

var _middleware = __webpack_require__(/*! ./middleware */ "./packages/tgui-panel/game/middleware.js");

exports.gameMiddleware = _middleware.gameMiddleware;

var _reducer = __webpack_require__(/*! ./reducer */ "./packages/tgui-panel/game/reducer.js");

exports.gameReducer = _reducer.gameReducer;

/***/ }),

/***/ "./packages/tgui-panel/game/middleware.js":
/*!************************************************!*\
  !*** ./packages/tgui-panel/game/middleware.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.gameMiddleware = void 0;

var _actions = __webpack_require__(/*! ../ping/actions */ "./packages/tgui-panel/ping/actions.js");

var _actions2 = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/game/actions.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/game/selectors.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/game/constants.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var withTimestamp = function withTimestamp(action) {
  return Object.assign({}, action, {
    meta: Object.assign({}, action.meta, {
      now: Date.now()
    })
  });
};

var gameMiddleware = function gameMiddleware(store) {
  var lastPingedAt;
  setInterval(function () {
    var state = store.getState();

    if (!state) {
      return;
    }

    var game = (0, _selectors.selectGame)(state);

    var pingsAreFailing = lastPingedAt && Date.now() >= lastPingedAt + _constants.CONNECTION_LOST_AFTER;

    if (!game.connectionLostAt && pingsAreFailing) {
      store.dispatch(withTimestamp((0, _actions2.connectionLost)()));
    }

    if (game.connectionLostAt && !pingsAreFailing) {
      store.dispatch(withTimestamp((0, _actions2.connectionRestored)()));
    }
  }, 1000);
  return function (next) {
    return function (action) {
      var type = action.type,
          payload = action.payload,
          meta = action.meta;

      if (type === _actions.pingSuccess.type) {
        lastPingedAt = meta.now;
        return next(action);
      }

      if (type === _actions2.roundRestarted.type) {
        return next(withTimestamp(action));
      }

      return next(action);
    };
  };
};

exports.gameMiddleware = gameMiddleware;

/***/ }),

/***/ "./packages/tgui-panel/game/reducer.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/game/reducer.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.gameReducer = void 0;

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/game/actions.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var initialState = {
  // TODO: This is where round info should be.
  roundId: null,
  roundTime: null,
  roundRestartedAt: null,
  connectionLostAt: null
};

var gameReducer = function gameReducer(state, action) {
  if (state === void 0) {
    state = initialState;
  }

  var type = action.type,
      payload = action.payload,
      meta = action.meta;

  if (type === 'roundrestart') {
    return Object.assign({}, state, {
      roundRestartedAt: meta.now
    });
  }

  if (type === _actions.connectionLost.type) {
    return Object.assign({}, state, {
      connectionLostAt: meta.now
    });
  }

  if (type === _actions.connectionRestored.type) {
    return Object.assign({}, state, {
      connectionLostAt: null
    });
  }

  return state;
};

exports.gameReducer = gameReducer;

/***/ }),

/***/ "./packages/tgui-panel/game/selectors.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/game/selectors.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.selectGame = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var selectGame = function selectGame(state) {
  return state.game;
};

exports.selectGame = selectGame;

/***/ }),

/***/ "./packages/tgui-panel/index.js":
/*!**************************************!*\
  !*** ./packages/tgui-panel/index.js ***!
  \**************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

__webpack_require__(/*! ./styles/main.scss */ "./packages/tgui-panel/styles/main.scss");

__webpack_require__(/*! ./styles/themes/light.scss */ "./packages/tgui-panel/styles/themes/light.scss");

var _perf = __webpack_require__(/*! common/perf */ "./packages/common/perf.js");

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _client = __webpack_require__(/*! tgui-dev-server/link/client */ "./packages/tgui-dev-server/link/client.js");

var _events = __webpack_require__(/*! tgui/events */ "./packages/tgui/events.js");

var _links = __webpack_require__(/*! tgui/links */ "./packages/tgui/links.js");

var _renderer = __webpack_require__(/*! tgui/renderer */ "./packages/tgui/renderer.js");

var _store = __webpack_require__(/*! tgui/store */ "./packages/tgui/store.js");

var _audio = __webpack_require__(/*! ./audio */ "./packages/tgui-panel/audio/index.js");

var _chat = __webpack_require__(/*! ./chat */ "./packages/tgui-panel/chat/index.js");

var _game = __webpack_require__(/*! ./game */ "./packages/tgui-panel/game/index.js");

var _panelFocus = __webpack_require__(/*! ./panelFocus */ "./packages/tgui-panel/panelFocus.js");

var _ping = __webpack_require__(/*! ./ping */ "./packages/tgui-panel/ping/index.js");

var _settings = __webpack_require__(/*! ./settings */ "./packages/tgui-panel/settings/index.js");

var _telemetry = __webpack_require__(/*! ./telemetry */ "./packages/tgui-panel/telemetry.js");

var _window$performance, _window$performance$t;

_perf.perf.mark('inception', (_window$performance = window.performance) == null ? void 0 : (_window$performance$t = _window$performance.timing) == null ? void 0 : _window$performance$t.navigationStart);

_perf.perf.mark('init');

var store = (0, _store.configureStore)({
  reducer: (0, _redux.combineReducers)({
    audio: _audio.audioReducer,
    chat: _chat.chatReducer,
    game: _game.gameReducer,
    ping: _ping.pingReducer,
    settings: _settings.settingsReducer
  }),
  middleware: {
    pre: [_chat.chatMiddleware, _ping.pingMiddleware, _telemetry.telemetryMiddleware, _settings.settingsMiddleware, _audio.audioMiddleware, _game.gameMiddleware]
  }
});
var renderApp = (0, _renderer.createRenderer)(function () {
  var _require = __webpack_require__(/*! ./Panel */ "./packages/tgui-panel/Panel.js"),
      Panel = _require.Panel;

  return (0, _inferno.createComponentVNode)(2, _store.StoreProvider, {
    "store": store,
    children: (0, _inferno.createComponentVNode)(2, Panel)
  });
});

var setupApp = function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  (0, _events.setupGlobalEvents)({
    ignoreWindowFocus: true
  });
  (0, _panelFocus.setupPanelFocusHacks)();
  (0, _links.captureExternalLinks)(); // Subscribe for Redux state updates

  store.subscribe(renderApp); // Subscribe for bankend updates

  window.update = function (msg) {
    return store.dispatch(Byond.parseJson(msg));
  }; // Process the early update queue


  while (true) {
    var msg = window.__updateQueue__.shift();

    if (!msg) {
      break;
    }

    window.update(msg);
  } // Unhide the panel


  Byond.winset('output', {
    'is-visible': false
  });
  Byond.winset('browseroutput', {
    'is-visible': true,
    'is-disabled': false,
    'pos': '0x0',
    'size': '0x0'
  }); // Enable hot module reloading

  if (false) {}
};

setupApp();

/***/ }),

/***/ "./packages/tgui-panel/panelFocus.js":
/*!*******************************************!*\
  !*** ./packages/tgui-panel/panelFocus.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(setImmediate) {

exports.__esModule = true;
exports.setupPanelFocusHacks = void 0;

var _vector = __webpack_require__(/*! common/vector */ "./packages/common/vector.js");

var _events = __webpack_require__(/*! tgui/events */ "./packages/tgui/events.js");

var _focus = __webpack_require__(/*! tgui/focus */ "./packages/tgui/focus.js");

/**
 * Basically, hacks from goonchat which try to keep the map focused at all
 * times, except for when some meaningful action happens o
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
// Empyrically determined number for the smallest possible
// text you can select with the mouse.
var MIN_SELECTION_DISTANCE = 10;

var deferredFocusMap = function deferredFocusMap() {
  return setImmediate(function () {
    return (0, _focus.focusMap)();
  });
};

var setupPanelFocusHacks = function setupPanelFocusHacks() {
  var focusStolen = false;
  var clickStartPos = null;
  window.addEventListener('focusin', function (e) {
    focusStolen = (0, _events.canStealFocus)(e.target);
  });
  window.addEventListener('mousedown', function (e) {
    clickStartPos = [e.screenX, e.screenY];
  });
  window.addEventListener('mouseup', function (e) {
    if (clickStartPos) {
      var clickEndPos = [e.screenX, e.screenY];
      var dist = (0, _vector.vecLength)((0, _vector.vecSubtract)(clickEndPos, clickStartPos));

      if (dist >= MIN_SELECTION_DISTANCE) {
        focusStolen = true;
      }
    }

    if (!focusStolen) {
      deferredFocusMap();
    }
  });

  _events.globalEvents.on('keydown', function (key) {
    if (key.isModifierKey()) {
      return;
    }

    deferredFocusMap();
  });
};

exports.setupPanelFocusHacks = setupPanelFocusHacks;
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../.yarn/cache/timers-browserify-npm-2.0.11-f20435228f-73faad065e.zip/node_modules/timers-browserify/main.js */ "./.yarn/cache/timers-browserify-npm-2.0.11-f20435228f-73faad065e.zip/node_modules/timers-browserify/main.js").setImmediate))

/***/ }),

/***/ "./packages/tgui-panel/ping/PingIndicator.js":
/*!***************************************************!*\
  !*** ./packages/tgui-panel/ping/PingIndicator.js ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PingIndicator = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _color = __webpack_require__(/*! common/color */ "./packages/common/color.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/ping/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var PingIndicator = function PingIndicator(props, context) {
  var ping = (0, _redux.useSelector)(context, _selectors.selectPing);

  var color = _color.Color.lookup(ping.networkQuality, [new _color.Color(220, 40, 40), new _color.Color(220, 200, 40), new _color.Color(60, 220, 40)]);

  var roundtrip = ping.roundtrip ? (0, _math.toFixed)(ping.roundtrip) : '--';
  return (0, _inferno.createVNode)(1, "div", "Ping", [(0, _inferno.createComponentVNode)(2, _components.Box, {
    "className": "Ping__indicator",
    "backgroundColor": color
  }), roundtrip], 0);
};

exports.PingIndicator = PingIndicator;

/***/ }),

/***/ "./packages/tgui-panel/ping/actions.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/ping/actions.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.pingReply = exports.pingFail = exports.pingSuccess = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var pingSuccess = (0, _redux.createAction)('ping/success', function (ping) {
  var now = Date.now();
  var roundtrip = (now - ping.sentAt) * 0.5;
  return {
    payload: {
      lastId: ping.id,
      roundtrip: roundtrip
    },
    meta: {
      now: now
    }
  };
});
exports.pingSuccess = pingSuccess;
var pingFail = (0, _redux.createAction)('ping/fail');
exports.pingFail = pingFail;
var pingReply = (0, _redux.createAction)('ping/reply');
exports.pingReply = pingReply;

/***/ }),

/***/ "./packages/tgui-panel/ping/constants.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/ping/constants.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.PING_ROUNDTRIP_WORST = exports.PING_ROUNDTRIP_BEST = exports.PING_QUEUE_SIZE = exports.PING_MAX_FAILS = exports.PING_TIMEOUT = exports.PING_INTERVAL = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var PING_INTERVAL = 2500;
exports.PING_INTERVAL = PING_INTERVAL;
var PING_TIMEOUT = 2000;
exports.PING_TIMEOUT = PING_TIMEOUT;
var PING_MAX_FAILS = 3;
exports.PING_MAX_FAILS = PING_MAX_FAILS;
var PING_QUEUE_SIZE = 8;
exports.PING_QUEUE_SIZE = PING_QUEUE_SIZE;
var PING_ROUNDTRIP_BEST = 50;
exports.PING_ROUNDTRIP_BEST = PING_ROUNDTRIP_BEST;
var PING_ROUNDTRIP_WORST = 200;
exports.PING_ROUNDTRIP_WORST = PING_ROUNDTRIP_WORST;

/***/ }),

/***/ "./packages/tgui-panel/ping/index.js":
/*!*******************************************!*\
  !*** ./packages/tgui-panel/ping/index.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.pingReducer = exports.PingIndicator = exports.pingMiddleware = void 0;

var _middleware = __webpack_require__(/*! ./middleware */ "./packages/tgui-panel/ping/middleware.js");

exports.pingMiddleware = _middleware.pingMiddleware;

var _PingIndicator = __webpack_require__(/*! ./PingIndicator */ "./packages/tgui-panel/ping/PingIndicator.js");

exports.PingIndicator = _PingIndicator.PingIndicator;

var _reducer = __webpack_require__(/*! ./reducer */ "./packages/tgui-panel/ping/reducer.js");

exports.pingReducer = _reducer.pingReducer;

/***/ }),

/***/ "./packages/tgui-panel/ping/middleware.js":
/*!************************************************!*\
  !*** ./packages/tgui-panel/ping/middleware.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.pingMiddleware = void 0;

var _backend = __webpack_require__(/*! tgui/backend */ "./packages/tgui/backend.js");

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/ping/actions.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/ping/constants.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var pingMiddleware = function pingMiddleware(store) {
  var initialized = false;
  var index = 0;
  var pings = [];

  var sendPing = function sendPing() {
    for (var i = 0; i < _constants.PING_QUEUE_SIZE; i++) {
      var _ping = pings[i];

      if (_ping && Date.now() - _ping.sentAt > _constants.PING_TIMEOUT) {
        pings[i] = null;
        store.dispatch((0, _actions.pingFail)());
      }
    }

    var ping = {
      index: index,
      sentAt: Date.now()
    };
    pings[index] = ping;
    (0, _backend.sendMessage)({
      type: 'ping',
      payload: {
        index: index
      }
    });
    index = (index + 1) % _constants.PING_QUEUE_SIZE;
  };

  return function (next) {
    return function (action) {
      var type = action.type,
          payload = action.payload;

      if (!initialized) {
        initialized = true;
        setInterval(sendPing, _constants.PING_INTERVAL);
        sendPing();
      }

      if (type === 'pingReply') {
        var _index = payload.index;
        var ping = pings[_index]; // Received a timed out ping

        if (!ping) {
          return;
        }

        pings[_index] = null;
        return next((0, _actions.pingSuccess)(ping));
      }

      return next(action);
    };
  };
};

exports.pingMiddleware = pingMiddleware;

/***/ }),

/***/ "./packages/tgui-panel/ping/reducer.js":
/*!*********************************************!*\
  !*** ./packages/tgui-panel/ping/reducer.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.pingReducer = void 0;

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/ping/actions.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/ping/constants.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var pingReducer = function pingReducer(state, action) {
  if (state === void 0) {
    state = {};
  }

  var type = action.type,
      payload = action.payload;

  if (type === _actions.pingSuccess.type) {
    var roundtrip = payload.roundtrip;
    var prevRoundtrip = state.roundtripAvg || roundtrip;
    var roundtripAvg = Math.round(prevRoundtrip * 0.4 + roundtrip * 0.6);
    var networkQuality = 1 - (0, _math.scale)(roundtripAvg, _constants.PING_ROUNDTRIP_BEST, _constants.PING_ROUNDTRIP_WORST);
    return {
      roundtrip: roundtrip,
      roundtripAvg: roundtripAvg,
      failCount: 0,
      networkQuality: networkQuality
    };
  }

  if (type === _actions.pingFail.type) {
    var _state = state,
        _state$failCount = _state.failCount,
        failCount = _state$failCount === void 0 ? 0 : _state$failCount;

    var _networkQuality = (0, _math.clamp01)(state.networkQuality - failCount / _constants.PING_MAX_FAILS);

    var nextState = Object.assign({}, state, {
      failCount: failCount + 1,
      networkQuality: _networkQuality
    });

    if (failCount > _constants.PING_MAX_FAILS) {
      nextState.roundtrip = undefined;
      nextState.roundtripAvg = undefined;
    }

    return nextState;
  }

  return state;
};

exports.pingReducer = pingReducer;

/***/ }),

/***/ "./packages/tgui-panel/ping/selectors.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/ping/selectors.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.selectPing = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var selectPing = function selectPing(state) {
  return state.ping;
};

exports.selectPing = selectPing;

/***/ }),

/***/ "./packages/tgui-panel/settings/SettingsPanel.js":
/*!*******************************************************!*\
  !*** ./packages/tgui-panel/settings/SettingsPanel.js ***!
  \*******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SettingsGeneral = exports.SettingsPanel = void 0;

var _inferno = __webpack_require__(/*! inferno */ "./.yarn/unplugged/inferno-npm-7.4.2-80e5e35292/node_modules/inferno/index.esm.js");

var _math = __webpack_require__(/*! common/math */ "./packages/common/math.js");

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _components = __webpack_require__(/*! tgui/components */ "./packages/tgui/components/index.js");

var _chat = __webpack_require__(/*! ../chat */ "./packages/tgui-panel/chat/index.js");

var _actions = __webpack_require__(/*! ../chat/actions */ "./packages/tgui-panel/chat/actions.js");

var _themes = __webpack_require__(/*! ../themes */ "./packages/tgui-panel/themes.js");

var _actions2 = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/settings/actions.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/settings/constants.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/settings/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var SettingsPanel = function SettingsPanel(props, context) {
  var activeTab = (0, _redux.useSelector)(context, _selectors.selectActiveTab);
  var dispatch = (0, _redux.useDispatch)(context);
  return (0, _inferno.createComponentVNode)(2, _components.Flex, {
    children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "mr": 1,
      children: (0, _inferno.createComponentVNode)(2, _components.Section, {
        "fitted": true,
        "fill": true,
        "minHeight": "8em",
        children: (0, _inferno.createComponentVNode)(2, _components.Tabs, {
          "vertical": true,
          children: _constants.SETTINGS_TABS.map(function (tab) {
            return (0, _inferno.createComponentVNode)(2, _components.Tabs.Tab, {
              "selected": tab.id === activeTab,
              "onClick": function () {
                function onClick() {
                  return dispatch((0, _actions2.changeSettingsTab)({
                    tabId: tab.id
                  }));
                }

                return onClick;
              }(),
              children: tab.name
            }, tab.id);
          })
        })
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
      "grow": 1,
      "basis": 0,
      children: [activeTab === 'general' && (0, _inferno.createComponentVNode)(2, SettingsGeneral), activeTab === 'chatPage' && (0, _inferno.createComponentVNode)(2, _chat.ChatPageSettings)]
    })]
  });
};

exports.SettingsPanel = SettingsPanel;

var SettingsGeneral = function SettingsGeneral(props, context) {
  var _useSelector = (0, _redux.useSelector)(context, _selectors.selectSettings),
      theme = _useSelector.theme,
      fontSize = _useSelector.fontSize,
      lineHeight = _useSelector.lineHeight,
      highlightText = _useSelector.highlightText,
      highlightColor = _useSelector.highlightColor;

  var dispatch = (0, _redux.useDispatch)(context);
  return (0, _inferno.createComponentVNode)(2, _components.Section, {
    "fill": true,
    children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Theme",
        children: (0, _inferno.createComponentVNode)(2, _components.Dropdown, {
          "selected": theme,
          "options": _themes.THEMES,
          "onSelected": function () {
            function onSelected(value) {
              return dispatch((0, _actions2.updateSettings)({
                theme: value
              }));
            }

            return onSelected;
          }()
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Font size",
        children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "width": "4em",
          "step": 1,
          "stepPixelSize": 10,
          "minValue": 8,
          "maxValue": 32,
          "value": fontSize,
          "unit": "px",
          "format": function () {
            function format(value) {
              return (0, _math.toFixed)(value);
            }

            return format;
          }(),
          "onChange": function () {
            function onChange(e, value) {
              return dispatch((0, _actions2.updateSettings)({
                fontSize: value
              }));
            }

            return onChange;
          }()
        })
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Line height",
        children: (0, _inferno.createComponentVNode)(2, _components.NumberInput, {
          "width": "4em",
          "step": 0.01,
          "stepPixelSize": 2,
          "minValue": 0.8,
          "maxValue": 5,
          "value": lineHeight,
          "format": function () {
            function format(value) {
              return (0, _math.toFixed)(value, 2);
            }

            return format;
          }(),
          "onDrag": function () {
            function onDrag(e, value) {
              return dispatch((0, _actions2.updateSettings)({
                lineHeight: value
              }));
            }

            return onDrag;
          }()
        })
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Flex, {
        "mb": 1,
        "color": "label",
        "align": "baseline",
        children: [(0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "grow": 1,
          children: "Highlight words (comma separated):"
        }), (0, _inferno.createComponentVNode)(2, _components.Flex.Item, {
          "shrink": 0,
          children: [(0, _inferno.createComponentVNode)(2, _components.ColorBox, {
            "mr": 1,
            "color": highlightColor
          }), (0, _inferno.createComponentVNode)(2, _components.Input, {
            "width": "5em",
            "monospace": true,
            "placeholder": "#ffffff",
            "value": highlightColor,
            "onInput": function () {
              function onInput(e, value) {
                return dispatch((0, _actions2.updateSettings)({
                  highlightColor: value
                }));
              }

              return onInput;
            }()
          })]
        })]
      }), (0, _inferno.createComponentVNode)(2, _components.TextArea, {
        "height": "3em",
        "value": highlightText,
        "onChange": function () {
          function onChange(e, value) {
            return dispatch((0, _actions2.updateSettings)({
              highlightText: value
            }));
          }

          return onChange;
        }()
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: [(0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "check",
        "onClick": function () {
          function onClick() {
            return dispatch((0, _actions.rebuildChat)());
          }

          return onClick;
        }(),
        children: "Apply now"
      }), (0, _inferno.createComponentVNode)(2, _components.Box, {
        "inline": true,
        "fontSize": "0.9em",
        "ml": 1,
        "color": "label",
        children: "Can freeze the chat for a while."
      })]
    }), (0, _inferno.createComponentVNode)(2, _components.Divider), (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "save",
      "onClick": function () {
        function onClick() {
          return dispatch((0, _actions.saveChatToDisk)());
        }

        return onClick;
      }(),
      children: "Save chat log"
    })]
  });
};

exports.SettingsGeneral = SettingsGeneral;

/***/ }),

/***/ "./packages/tgui-panel/settings/actions.js":
/*!*************************************************!*\
  !*** ./packages/tgui-panel/settings/actions.js ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.openChatSettings = exports.toggleSettings = exports.changeSettingsTab = exports.loadSettings = exports.updateSettings = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var updateSettings = (0, _redux.createAction)('settings/update');
exports.updateSettings = updateSettings;
var loadSettings = (0, _redux.createAction)('settings/load');
exports.loadSettings = loadSettings;
var changeSettingsTab = (0, _redux.createAction)('settings/changeTab');
exports.changeSettingsTab = changeSettingsTab;
var toggleSettings = (0, _redux.createAction)('settings/toggle');
exports.toggleSettings = toggleSettings;
var openChatSettings = (0, _redux.createAction)('settings/openChatTab');
exports.openChatSettings = openChatSettings;

/***/ }),

/***/ "./packages/tgui-panel/settings/constants.js":
/*!***************************************************!*\
  !*** ./packages/tgui-panel/settings/constants.js ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SETTINGS_TABS = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var SETTINGS_TABS = [{
  id: 'general',
  name: 'General'
}, {
  id: 'chatPage',
  name: 'Chat Tabs'
}];
exports.SETTINGS_TABS = SETTINGS_TABS;

/***/ }),

/***/ "./packages/tgui-panel/settings/hooks.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/settings/hooks.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.useSettings = void 0;

var _redux = __webpack_require__(/*! common/redux */ "./packages/common/redux.js");

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/settings/actions.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/settings/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var useSettings = function useSettings(context) {
  var settings = (0, _redux.useSelector)(context, _selectors.selectSettings);
  var dispatch = (0, _redux.useDispatch)(context);
  return Object.assign({}, settings, {
    visible: settings.view.visible,
    toggle: function () {
      function toggle() {
        return dispatch((0, _actions.toggleSettings)());
      }

      return toggle;
    }(),
    update: function () {
      function update(obj) {
        return dispatch((0, _actions.updateSettings)(obj));
      }

      return update;
    }()
  });
};

exports.useSettings = useSettings;

/***/ }),

/***/ "./packages/tgui-panel/settings/index.js":
/*!***********************************************!*\
  !*** ./packages/tgui-panel/settings/index.js ***!
  \***********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.SettingsPanel = exports.settingsReducer = exports.settingsMiddleware = exports.useSettings = void 0;

var _hooks = __webpack_require__(/*! ./hooks */ "./packages/tgui-panel/settings/hooks.js");

exports.useSettings = _hooks.useSettings;

var _middleware = __webpack_require__(/*! ./middleware */ "./packages/tgui-panel/settings/middleware.js");

exports.settingsMiddleware = _middleware.settingsMiddleware;

var _reducer = __webpack_require__(/*! ./reducer */ "./packages/tgui-panel/settings/reducer.js");

exports.settingsReducer = _reducer.settingsReducer;

var _SettingsPanel = __webpack_require__(/*! ./SettingsPanel */ "./packages/tgui-panel/settings/SettingsPanel.js");

exports.SettingsPanel = _SettingsPanel.SettingsPanel;

/***/ }),

/***/ "./packages/tgui-panel/settings/middleware.js":
/*!****************************************************!*\
  !*** ./packages/tgui-panel/settings/middleware.js ***!
  \****************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.settingsMiddleware = void 0;

var _storage = __webpack_require__(/*! common/storage */ "./packages/common/storage.js");

var _themes = __webpack_require__(/*! ../themes */ "./packages/tgui-panel/themes.js");

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/settings/actions.js");

var _selectors = __webpack_require__(/*! ./selectors */ "./packages/tgui-panel/settings/selectors.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var setGlobalFontSize = function setGlobalFontSize(fontSize) {
  document.documentElement.style.setProperty('font-size', fontSize + 'px');
  document.body.style.setProperty('font-size', fontSize + 'px');
};

var settingsMiddleware = function settingsMiddleware(store) {
  var initialized = false;
  return function (next) {
    return function (action) {
      var type = action.type,
          payload = action.payload;

      if (!initialized) {
        initialized = true;

        _storage.storage.get('panel-settings').then(function (settings) {
          store.dispatch((0, _actions.loadSettings)(settings));
        });
      }

      if (type === _actions.updateSettings.type || type === _actions.loadSettings.type) {
        // Set client theme
        var theme = payload == null ? void 0 : payload.theme;

        if (theme) {
          (0, _themes.setClientTheme)(theme);
        } // Pass action to get an updated state


        next(action);
        var settings = (0, _selectors.selectSettings)(store.getState()); // Update global UI font size

        setGlobalFontSize(settings.fontSize); // Save settings to the web storage

        _storage.storage.set('panel-settings', settings);

        return;
      }

      return next(action);
    };
  };
};

exports.settingsMiddleware = settingsMiddleware;

/***/ }),

/***/ "./packages/tgui-panel/settings/reducer.js":
/*!*************************************************!*\
  !*** ./packages/tgui-panel/settings/reducer.js ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.settingsReducer = void 0;

var _actions = __webpack_require__(/*! ./actions */ "./packages/tgui-panel/settings/actions.js");

var _constants = __webpack_require__(/*! ./constants */ "./packages/tgui-panel/settings/constants.js");

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var initialState = {
  version: 1,
  fontSize: 13,
  lineHeight: 1.2,
  theme: 'light',
  adminMusicVolume: 0.5,
  highlightText: '',
  highlightColor: '#ffdd44',
  view: {
    visible: false,
    activeTab: _constants.SETTINGS_TABS[0].id
  }
};

var settingsReducer = function settingsReducer(state, action) {
  if (state === void 0) {
    state = initialState;
  }

  var type = action.type,
      payload = action.payload;

  if (type === _actions.updateSettings.type) {
    return Object.assign({}, state, payload);
  }

  if (type === _actions.loadSettings.type) {
    // Validate version and/or migrate state
    if (!(payload == null ? void 0 : payload.version)) {
      return state;
    }

    delete payload.view;
    return Object.assign({}, state, payload);
  }

  if (type === _actions.toggleSettings.type) {
    return Object.assign({}, state, {
      view: Object.assign({}, state.view, {
        visible: !state.view.visible
      })
    });
  }

  if (type === _actions.openChatSettings.type) {
    return Object.assign({}, state, {
      view: Object.assign({}, state.view, {
        visible: true,
        activeTab: 'chatPage'
      })
    });
  }

  if (type === _actions.changeSettingsTab.type) {
    var tabId = payload.tabId;
    return Object.assign({}, state, {
      view: Object.assign({}, state.view, {
        activeTab: tabId
      })
    });
  }

  return state;
};

exports.settingsReducer = settingsReducer;

/***/ }),

/***/ "./packages/tgui-panel/settings/selectors.js":
/*!***************************************************!*\
  !*** ./packages/tgui-panel/settings/selectors.js ***!
  \***************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.selectActiveTab = exports.selectSettings = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var selectSettings = function selectSettings(state) {
  return state.settings;
};

exports.selectSettings = selectSettings;

var selectActiveTab = function selectActiveTab(state) {
  return state.settings.view.activeTab;
};

exports.selectActiveTab = selectActiveTab;

/***/ }),

/***/ "./packages/tgui-panel/styles/main.scss":
/*!**********************************************!*\
  !*** ./packages/tgui-panel/styles/main.scss ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// extracted by extract-css-chunks-webpack-plugin

/***/ }),

/***/ "./packages/tgui-panel/styles/themes/light.scss":
/*!******************************************************!*\
  !*** ./packages/tgui-panel/styles/themes/light.scss ***!
  \******************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// extracted by extract-css-chunks-webpack-plugin

/***/ }),

/***/ "./packages/tgui-panel/telemetry.js":
/*!******************************************!*\
  !*** ./packages/tgui-panel/telemetry.js ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.telemetryMiddleware = void 0;

var _backend = __webpack_require__(/*! tgui/backend */ "./packages/tgui/backend.js");

var _storage = __webpack_require__(/*! common/storage */ "./packages/common/storage.js");

var _logging = __webpack_require__(/*! tgui/logging */ "./packages/tgui/logging.js");

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

var logger = (0, _logging.createLogger)('telemetry');
var MAX_CONNECTIONS_STORED = 10;

var connectionsMatch = function connectionsMatch(a, b) {
  return a.ckey === b.ckey && a.address === b.address && a.computer_id === b.computer_id;
};

var telemetryMiddleware = function telemetryMiddleware(store) {
  var telemetry;
  var wasRequestedWithPayload;
  return function (next) {
    return function (action) {
      var type = action.type,
          payload = action.payload; // Handle telemetry requests

      if (type === 'telemetry/request') {
        // Defer telemetry request until we have the actual telemetry
        if (!telemetry) {
          logger.debug('deferred');
          wasRequestedWithPayload = payload;
          return;
        }

        logger.debug('sending');
        var limits = (payload == null ? void 0 : payload.limits) || {}; // Trim connections according to the server limit

        var connections = telemetry.connections.slice(0, limits.connections);
        (0, _backend.sendMessage)({
          type: 'telemetry',
          payload: {
            connections: connections
          }
        });
        return;
      } // Keep telemetry up to date


      if (type === 'backend/update') {
        next(action);

        _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function () {
          function _callee() {
            var _payload$config;

            var client, telemetryMutated, duplicateConnection, _payload;

            return regeneratorRuntime.wrap(function () {
              function _callee$(_context) {
                while (1) {
                  switch (_context.prev = _context.next) {
                    case 0:
                      // Extract client data
                      client = payload == null ? void 0 : (_payload$config = payload.config) == null ? void 0 : _payload$config.client;

                      if (client) {
                        _context.next = 4;
                        break;
                      }

                      logger.error('backend/update payload is missing client data!');
                      return _context.abrupt("return");

                    case 4:
                      if (telemetry) {
                        _context.next = 13;
                        break;
                      }

                      _context.next = 7;
                      return _storage.storage.get('telemetry');

                    case 7:
                      _context.t0 = _context.sent;

                      if (_context.t0) {
                        _context.next = 10;
                        break;
                      }

                      _context.t0 = {};

                    case 10:
                      telemetry = _context.t0;

                      if (!telemetry.connections) {
                        telemetry.connections = [];
                      }

                      logger.debug('retrieved telemetry from storage', telemetry);

                    case 13:
                      // Append a connection record
                      telemetryMutated = false;
                      duplicateConnection = telemetry.connections.find(function (conn) {
                        return connectionsMatch(conn, client);
                      });

                      if (!duplicateConnection) {
                        telemetryMutated = true;
                        telemetry.connections.unshift(client);

                        if (telemetry.connections.length > MAX_CONNECTIONS_STORED) {
                          telemetry.connections.pop();
                        }
                      } // Save telemetry


                      if (telemetryMutated) {
                        logger.debug('saving telemetry to storage', telemetry);

                        _storage.storage.set('telemetry', telemetry);
                      } // Continue deferred telemetry requests


                      if (wasRequestedWithPayload) {
                        _payload = wasRequestedWithPayload;
                        wasRequestedWithPayload = null;
                        store.dispatch({
                          type: 'telemetry/request',
                          payload: _payload
                        });
                      }

                    case 18:
                    case "end":
                      return _context.stop();
                  }
                }
              }

              return _callee$;
            }(), _callee);
          }

          return _callee;
        }()))();

        return;
      }

      return next(action);
    };
  };
};

exports.telemetryMiddleware = telemetryMiddleware;

/***/ }),

/***/ "./packages/tgui-panel/themes.js":
/*!***************************************!*\
  !*** ./packages/tgui-panel/themes.js ***!
  \***************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.setClientTheme = exports.THEMES = void 0;

/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
var THEMES = ['light', 'dark'];
exports.THEMES = THEMES;
var COLOR_DARK_BG = '#202020';
var COLOR_DARK_BG_DARKER = '#171717';
var COLOR_DARK_TEXT = '#a4bad6';
var setClientThemeTimer = null;
/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */

var setClientTheme = function setClientTheme(name) {
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(".output statbrowser:set_theme " + name);
  setClientThemeTimer = setTimeout(function () {
    Byond.command(".output statbrowser:set_theme " + name);
  }, 1500);

  if (name === 'light') {
    return Byond.winset({
      // Main windows
      'infowindow.background-color': 'none',
      'infowindow.text-color': '#000000',
      'info.background-color': 'none',
      'info.text-color': '#000000',
      'browseroutput.background-color': 'none',
      'browseroutput.text-color': '#000000',
      'outputwindow.background-color': 'none',
      'outputwindow.text-color': '#000000',
      'mainwindow.background-color': 'none',
      'split.background-color': 'none',
      // Buttons
      'changelog.background-color': 'none',
      'changelog.text-color': '#000000',
      'rules.background-color': 'none',
      'rules.text-color': '#000000',
      'wiki.background-color': 'none',
      'wiki.text-color': '#000000',
      'forum.background-color': 'none',
      'forum.text-color': '#000000',
      'github.background-color': 'none',
      'github.text-color': '#000000',
      'report-issue.background-color': 'none',
      'report-issue.text-color': '#000000',
      // Status and verb tabs
      'output.background-color': 'none',
      'output.text-color': '#000000',
      'statwindow.background-color': 'none',
      'statwindow.text-color': '#000000',
      'stat.background-color': '#FFFFFF',
      'stat.tab-background-color': 'none',
      'stat.text-color': '#000000',
      'stat.tab-text-color': '#000000',
      'stat.prefix-color': '#000000',
      'stat.suffix-color': '#000000',
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': 'none',
      'saybutton.text-color': '#000000',
      'oocbutton.background-color': 'none',
      'oocbutton.text-color': '#000000',
      'mebutton.background-color': 'none',
      'mebutton.text-color': '#000000',
      'asset_cache_browser.background-color': 'none',
      'asset_cache_browser.text-color': '#000000',
      'tooltip.background-color': 'none',
      'tooltip.text-color': '#000000'
    });
  }

  if (name === 'dark') {
    Byond.winset({
      // Main windows
      'infowindow.background-color': COLOR_DARK_BG,
      'infowindow.text-color': COLOR_DARK_TEXT,
      'info.background-color': COLOR_DARK_BG,
      'info.text-color': COLOR_DARK_TEXT,
      'browseroutput.background-color': COLOR_DARK_BG,
      'browseroutput.text-color': COLOR_DARK_TEXT,
      'outputwindow.background-color': COLOR_DARK_BG,
      'outputwindow.text-color': COLOR_DARK_TEXT,
      'mainwindow.background-color': COLOR_DARK_BG,
      'split.background-color': COLOR_DARK_BG,
      // Buttons
      'changelog.background-color': '#494949',
      'changelog.text-color': COLOR_DARK_TEXT,
      'rules.background-color': '#494949',
      'rules.text-color': COLOR_DARK_TEXT,
      'wiki.background-color': '#494949',
      'wiki.text-color': COLOR_DARK_TEXT,
      'forum.background-color': '#494949',
      'forum.text-color': COLOR_DARK_TEXT,
      'github.background-color': '#3a3a3a',
      'github.text-color': COLOR_DARK_TEXT,
      'report-issue.background-color': '#492020',
      'report-issue.text-color': COLOR_DARK_TEXT,
      // Status and verb tabs
      'output.background-color': COLOR_DARK_BG_DARKER,
      'output.text-color': COLOR_DARK_TEXT,
      'statwindow.background-color': COLOR_DARK_BG_DARKER,
      'statwindow.text-color': COLOR_DARK_TEXT,
      'stat.background-color': COLOR_DARK_BG_DARKER,
      'stat.tab-background-color': COLOR_DARK_BG,
      'stat.text-color': COLOR_DARK_TEXT,
      'stat.tab-text-color': COLOR_DARK_TEXT,
      'stat.prefix-color': COLOR_DARK_TEXT,
      'stat.suffix-color': COLOR_DARK_TEXT,
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': COLOR_DARK_BG,
      'saybutton.text-color': COLOR_DARK_TEXT,
      'oocbutton.background-color': COLOR_DARK_BG,
      'oocbutton.text-color': COLOR_DARK_TEXT,
      'mebutton.background-color': COLOR_DARK_BG,
      'mebutton.text-color': COLOR_DARK_TEXT,
      'asset_cache_browser.background-color': COLOR_DARK_BG,
      'asset_cache_browser.text-color': COLOR_DARK_TEXT,
      'tooltip.background-color': COLOR_DARK_BG,
      'tooltip.text-color': COLOR_DARK_TEXT
    });
  }
};

exports.setClientTheme = setClientTheme;

/***/ }),

/***/ 1:
/*!************************************************************!*\
  !*** multi ./packages/tgui-polyfill ./packages/tgui-panel ***!
  \************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(/*! ./packages/tgui-polyfill */"./packages/tgui-polyfill/index.js");
module.exports = __webpack_require__(/*! ./packages/tgui-panel */"./packages/tgui-panel/index.js");


/***/ })

/******/ });
//# sourceMappingURL=tgui-panel.bundle.js.map