webpackHotUpdate("tgui",{

/***/ "./interfaces/NtosShipping.js":
/*!************************************!*\
  !*** ./interfaces/NtosShipping.js ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.NtosShipping = void 0;

var _inferno = __webpack_require__(/*! inferno */ "../../node_modules/inferno/index.esm.js");

var _backend = __webpack_require__(/*! ../backend */ "./backend.js");

var _byond = __webpack_require__(/*! ../byond */ "./byond.js");

var _components = __webpack_require__(/*! ../components */ "./components/index.js");

var NtosShipping = function NtosShipping(props) {
  var _useBackend = (0, _backend.useBackend)(props),
      act = _useBackend.act,
      data = _useBackend.data;

  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "NTOS Shipping Hub.",
    "buttons": (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "eject",
      "content": "Eject Id",
      "onClick": function () {
        function onClick() {
          return act('ejectid');
        }

        return onClick;
      }()
    }),
    children: (0, _inferno.createComponentVNode)(2, _components.LabeledList, {
      children: [(0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Current User",
        children: data.current_user || "N/A"
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Inserted Card",
        children: data.card_owner || "N/A"
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Available Paper",
        children: data.has_printer ? data.paperamt : "N/A"
      }), (0, _inferno.createComponentVNode)(2, _components.LabeledList.Item, {
        "label": "Profit on Sale",
        children: [data.barcode_split, "%"]
      })]
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Shipping Options",
    children: [(0, _inferno.createComponentVNode)(2, _components.Box, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "id-card",
        "tooltip": "The currently ID card will become the current user.",
        "tooltipPosition": "right",
        "disabled": !data.has_id_slot,
        "onClick": function () {
          function onClick() {
            return act('selectid');
          }

          return onClick;
        }(),
        "content": "Set Current ID"
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "print",
        "tooltip": "Print a barcode to use on a wrapped package.",
        "tooltipPosition": "right",
        "disabled": !data.has_printer || !data.current_user,
        "onClick": function () {
          function onClick() {
            return act('print');
          }

          return onClick;
        }(),
        "content": "Print Barcode"
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "tags",
        "tooltip": "Set how much profit you'd like on your package.",
        "tooltipPosition": "right",
        "onClick": function () {
          function onClick() {
            return act('setsplit');
          }

          return onClick;
        }(),
        "content": "Set Profit Margin"
      })
    }), (0, _inferno.createComponentVNode)(2, _components.Box, {
      children: (0, _inferno.createComponentVNode)(2, _components.Button, {
        "icon": "sync-alt",
        "content": "Reset ID",
        "onClick": function () {
          function onClick() {
            return act('resetid');
          }

          return onClick;
        }()
      })
    })]
  })], 4);
};

exports.NtosShipping = NtosShipping;

/***/ })

})
//# sourceMappingURL=tgui.8ae2a1d3680657d4cee7.hot-update.js.map