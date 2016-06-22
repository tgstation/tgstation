require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (global){
(function (global){
"use strict";

require("core-js/shim");

require("babel-regenerator-runtime");

if (global._babelPolyfill) {
  throw new Error("only one instance of babel-polyfill is allowed");
}
global._babelPolyfill = true;
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"babel-regenerator-runtime":189,"core-js/shim":188}],2:[function(require,module,exports){
module.exports = function(it){
  if(typeof it != 'function')throw TypeError(it + ' is not a function!');
  return it;
};
},{}],3:[function(require,module,exports){
// 22.1.3.31 Array.prototype[@@unscopables]
var UNSCOPABLES = require('./$.wks')('unscopables')
  , ArrayProto  = Array.prototype;
if(ArrayProto[UNSCOPABLES] == undefined)require('./$.hide')(ArrayProto, UNSCOPABLES, {});
module.exports = function(key){
  ArrayProto[UNSCOPABLES][key] = true;
};
},{"./$.hide":31,"./$.wks":83}],4:[function(require,module,exports){
var isObject = require('./$.is-object');
module.exports = function(it){
  if(!isObject(it))throw TypeError(it + ' is not an object!');
  return it;
};
},{"./$.is-object":38}],5:[function(require,module,exports){
// 22.1.3.3 Array.prototype.copyWithin(target, start, end = this.length)
'use strict';
var toObject = require('./$.to-object')
  , toIndex  = require('./$.to-index')
  , toLength = require('./$.to-length');

module.exports = [].copyWithin || function copyWithin(target/*= 0*/, start/*= 0, end = @length*/){
  var O     = toObject(this)
    , len   = toLength(O.length)
    , to    = toIndex(target, len)
    , from  = toIndex(start, len)
    , $$    = arguments
    , end   = $$.length > 2 ? $$[2] : undefined
    , count = Math.min((end === undefined ? len : toIndex(end, len)) - from, len - to)
    , inc   = 1;
  if(from < to && to < from + count){
    inc  = -1;
    from += count - 1;
    to   += count - 1;
  }
  while(count-- > 0){
    if(from in O)O[to] = O[from];
    else delete O[to];
    to   += inc;
    from += inc;
  } return O;
};
},{"./$.to-index":76,"./$.to-length":79,"./$.to-object":80}],6:[function(require,module,exports){
// 22.1.3.6 Array.prototype.fill(value, start = 0, end = this.length)
'use strict';
var toObject = require('./$.to-object')
  , toIndex  = require('./$.to-index')
  , toLength = require('./$.to-length');
module.exports = [].fill || function fill(value /*, start = 0, end = @length */){
  var O      = toObject(this)
    , length = toLength(O.length)
    , $$     = arguments
    , $$len  = $$.length
    , index  = toIndex($$len > 1 ? $$[1] : undefined, length)
    , end    = $$len > 2 ? $$[2] : undefined
    , endPos = end === undefined ? length : toIndex(end, length);
  while(endPos > index)O[index++] = value;
  return O;
};
},{"./$.to-index":76,"./$.to-length":79,"./$.to-object":80}],7:[function(require,module,exports){
// false -> Array#indexOf
// true  -> Array#includes
var toIObject = require('./$.to-iobject')
  , toLength  = require('./$.to-length')
  , toIndex   = require('./$.to-index');
module.exports = function(IS_INCLUDES){
  return function($this, el, fromIndex){
    var O      = toIObject($this)
      , length = toLength(O.length)
      , index  = toIndex(fromIndex, length)
      , value;
    // Array#includes uses SameValueZero equality algorithm
    if(IS_INCLUDES && el != el)while(length > index){
      value = O[index++];
      if(value != value)return true;
    // Array#toIndex ignores holes, Array#includes - not
    } else for(;length > index; index++)if(IS_INCLUDES || index in O){
      if(O[index] === el)return IS_INCLUDES || index;
    } return !IS_INCLUDES && -1;
  };
};
},{"./$.to-index":76,"./$.to-iobject":78,"./$.to-length":79}],8:[function(require,module,exports){
// 0 -> Array#forEach
// 1 -> Array#map
// 2 -> Array#filter
// 3 -> Array#some
// 4 -> Array#every
// 5 -> Array#find
// 6 -> Array#findIndex
var ctx      = require('./$.ctx')
  , IObject  = require('./$.iobject')
  , toObject = require('./$.to-object')
  , toLength = require('./$.to-length')
  , asc      = require('./$.array-species-create');
module.exports = function(TYPE){
  var IS_MAP        = TYPE == 1
    , IS_FILTER     = TYPE == 2
    , IS_SOME       = TYPE == 3
    , IS_EVERY      = TYPE == 4
    , IS_FIND_INDEX = TYPE == 6
    , NO_HOLES      = TYPE == 5 || IS_FIND_INDEX;
  return function($this, callbackfn, that){
    var O      = toObject($this)
      , self   = IObject(O)
      , f      = ctx(callbackfn, that, 3)
      , length = toLength(self.length)
      , index  = 0
      , result = IS_MAP ? asc($this, length) : IS_FILTER ? asc($this, 0) : undefined
      , val, res;
    for(;length > index; index++)if(NO_HOLES || index in self){
      val = self[index];
      res = f(val, index, O);
      if(TYPE){
        if(IS_MAP)result[index] = res;            // map
        else if(res)switch(TYPE){
          case 3: return true;                    // some
          case 5: return val;                     // find
          case 6: return index;                   // findIndex
          case 2: result.push(val);               // filter
        } else if(IS_EVERY)return false;          // every
      }
    }
    return IS_FIND_INDEX ? -1 : IS_SOME || IS_EVERY ? IS_EVERY : result;
  };
};
},{"./$.array-species-create":9,"./$.ctx":17,"./$.iobject":34,"./$.to-length":79,"./$.to-object":80}],9:[function(require,module,exports){
// 9.4.2.3 ArraySpeciesCreate(originalArray, length)
var isObject = require('./$.is-object')
  , isArray  = require('./$.is-array')
  , SPECIES  = require('./$.wks')('species');
module.exports = function(original, length){
  var C;
  if(isArray(original)){
    C = original.constructor;
    // cross-realm fallback
    if(typeof C == 'function' && (C === Array || isArray(C.prototype)))C = undefined;
    if(isObject(C)){
      C = C[SPECIES];
      if(C === null)C = undefined;
    }
  } return new (C === undefined ? Array : C)(length);
};
},{"./$.is-array":36,"./$.is-object":38,"./$.wks":83}],10:[function(require,module,exports){
// getting tag from 19.1.3.6 Object.prototype.toString()
var cof = require('./$.cof')
  , TAG = require('./$.wks')('toStringTag')
  // ES3 wrong here
  , ARG = cof(function(){ return arguments; }()) == 'Arguments';

module.exports = function(it){
  var O, T, B;
  return it === undefined ? 'Undefined' : it === null ? 'Null'
    // @@toStringTag case
    : typeof (T = (O = Object(it))[TAG]) == 'string' ? T
    // builtinTag case
    : ARG ? cof(O)
    // ES3 arguments fallback
    : (B = cof(O)) == 'Object' && typeof O.callee == 'function' ? 'Arguments' : B;
};
},{"./$.cof":11,"./$.wks":83}],11:[function(require,module,exports){
var toString = {}.toString;

module.exports = function(it){
  return toString.call(it).slice(8, -1);
};
},{}],12:[function(require,module,exports){
'use strict';
var $            = require('./$')
  , hide         = require('./$.hide')
  , redefineAll  = require('./$.redefine-all')
  , ctx          = require('./$.ctx')
  , strictNew    = require('./$.strict-new')
  , defined      = require('./$.defined')
  , forOf        = require('./$.for-of')
  , $iterDefine  = require('./$.iter-define')
  , step         = require('./$.iter-step')
  , ID           = require('./$.uid')('id')
  , $has         = require('./$.has')
  , isObject     = require('./$.is-object')
  , setSpecies   = require('./$.set-species')
  , DESCRIPTORS  = require('./$.descriptors')
  , isExtensible = Object.isExtensible || isObject
  , SIZE         = DESCRIPTORS ? '_s' : 'size'
  , id           = 0;

var fastKey = function(it, create){
  // return primitive with prefix
  if(!isObject(it))return typeof it == 'symbol' ? it : (typeof it == 'string' ? 'S' : 'P') + it;
  if(!$has(it, ID)){
    // can't set id to frozen object
    if(!isExtensible(it))return 'F';
    // not necessary to add id
    if(!create)return 'E';
    // add missing object id
    hide(it, ID, ++id);
  // return object id with prefix
  } return 'O' + it[ID];
};

var getEntry = function(that, key){
  // fast case
  var index = fastKey(key), entry;
  if(index !== 'F')return that._i[index];
  // frozen object case
  for(entry = that._f; entry; entry = entry.n){
    if(entry.k == key)return entry;
  }
};

module.exports = {
  getConstructor: function(wrapper, NAME, IS_MAP, ADDER){
    var C = wrapper(function(that, iterable){
      strictNew(that, C, NAME);
      that._i = $.create(null); // index
      that._f = undefined;      // first entry
      that._l = undefined;      // last entry
      that[SIZE] = 0;           // size
      if(iterable != undefined)forOf(iterable, IS_MAP, that[ADDER], that);
    });
    redefineAll(C.prototype, {
      // 23.1.3.1 Map.prototype.clear()
      // 23.2.3.2 Set.prototype.clear()
      clear: function clear(){
        for(var that = this, data = that._i, entry = that._f; entry; entry = entry.n){
          entry.r = true;
          if(entry.p)entry.p = entry.p.n = undefined;
          delete data[entry.i];
        }
        that._f = that._l = undefined;
        that[SIZE] = 0;
      },
      // 23.1.3.3 Map.prototype.delete(key)
      // 23.2.3.4 Set.prototype.delete(value)
      'delete': function(key){
        var that  = this
          , entry = getEntry(that, key);
        if(entry){
          var next = entry.n
            , prev = entry.p;
          delete that._i[entry.i];
          entry.r = true;
          if(prev)prev.n = next;
          if(next)next.p = prev;
          if(that._f == entry)that._f = next;
          if(that._l == entry)that._l = prev;
          that[SIZE]--;
        } return !!entry;
      },
      // 23.2.3.6 Set.prototype.forEach(callbackfn, thisArg = undefined)
      // 23.1.3.5 Map.prototype.forEach(callbackfn, thisArg = undefined)
      forEach: function forEach(callbackfn /*, that = undefined */){
        var f = ctx(callbackfn, arguments.length > 1 ? arguments[1] : undefined, 3)
          , entry;
        while(entry = entry ? entry.n : this._f){
          f(entry.v, entry.k, this);
          // revert to the last existing entry
          while(entry && entry.r)entry = entry.p;
        }
      },
      // 23.1.3.7 Map.prototype.has(key)
      // 23.2.3.7 Set.prototype.has(value)
      has: function has(key){
        return !!getEntry(this, key);
      }
    });
    if(DESCRIPTORS)$.setDesc(C.prototype, 'size', {
      get: function(){
        return defined(this[SIZE]);
      }
    });
    return C;
  },
  def: function(that, key, value){
    var entry = getEntry(that, key)
      , prev, index;
    // change existing entry
    if(entry){
      entry.v = value;
    // create new entry
    } else {
      that._l = entry = {
        i: index = fastKey(key, true), // <- index
        k: key,                        // <- key
        v: value,                      // <- value
        p: prev = that._l,             // <- previous entry
        n: undefined,                  // <- next entry
        r: false                       // <- removed
      };
      if(!that._f)that._f = entry;
      if(prev)prev.n = entry;
      that[SIZE]++;
      // add to index
      if(index !== 'F')that._i[index] = entry;
    } return that;
  },
  getEntry: getEntry,
  setStrong: function(C, NAME, IS_MAP){
    // add .keys, .values, .entries, [@@iterator]
    // 23.1.3.4, 23.1.3.8, 23.1.3.11, 23.1.3.12, 23.2.3.5, 23.2.3.8, 23.2.3.10, 23.2.3.11
    $iterDefine(C, NAME, function(iterated, kind){
      this._t = iterated;  // target
      this._k = kind;      // kind
      this._l = undefined; // previous
    }, function(){
      var that  = this
        , kind  = that._k
        , entry = that._l;
      // revert to the last existing entry
      while(entry && entry.r)entry = entry.p;
      // get next entry
      if(!that._t || !(that._l = entry = entry ? entry.n : that._t._f)){
        // or finish the iteration
        that._t = undefined;
        return step(1);
      }
      // return step by kind
      if(kind == 'keys'  )return step(0, entry.k);
      if(kind == 'values')return step(0, entry.v);
      return step(0, [entry.k, entry.v]);
    }, IS_MAP ? 'entries' : 'values' , !IS_MAP, true);

    // add [@@species], 23.1.2.2, 23.2.2.2
    setSpecies(NAME);
  }
};
},{"./$":46,"./$.ctx":17,"./$.defined":18,"./$.descriptors":19,"./$.for-of":27,"./$.has":30,"./$.hide":31,"./$.is-object":38,"./$.iter-define":42,"./$.iter-step":44,"./$.redefine-all":60,"./$.set-species":65,"./$.strict-new":69,"./$.uid":82}],13:[function(require,module,exports){
// https://github.com/DavidBruant/Map-Set.prototype.toJSON
var forOf   = require('./$.for-of')
  , classof = require('./$.classof');
module.exports = function(NAME){
  return function toJSON(){
    if(classof(this) != NAME)throw TypeError(NAME + "#toJSON isn't generic");
    var arr = [];
    forOf(this, false, arr.push, arr);
    return arr;
  };
};
},{"./$.classof":10,"./$.for-of":27}],14:[function(require,module,exports){
'use strict';
var hide              = require('./$.hide')
  , redefineAll       = require('./$.redefine-all')
  , anObject          = require('./$.an-object')
  , isObject          = require('./$.is-object')
  , strictNew         = require('./$.strict-new')
  , forOf             = require('./$.for-of')
  , createArrayMethod = require('./$.array-methods')
  , $has              = require('./$.has')
  , WEAK              = require('./$.uid')('weak')
  , isExtensible      = Object.isExtensible || isObject
  , arrayFind         = createArrayMethod(5)
  , arrayFindIndex    = createArrayMethod(6)
  , id                = 0;

// fallback for frozen keys
var frozenStore = function(that){
  return that._l || (that._l = new FrozenStore);
};
var FrozenStore = function(){
  this.a = [];
};
var findFrozen = function(store, key){
  return arrayFind(store.a, function(it){
    return it[0] === key;
  });
};
FrozenStore.prototype = {
  get: function(key){
    var entry = findFrozen(this, key);
    if(entry)return entry[1];
  },
  has: function(key){
    return !!findFrozen(this, key);
  },
  set: function(key, value){
    var entry = findFrozen(this, key);
    if(entry)entry[1] = value;
    else this.a.push([key, value]);
  },
  'delete': function(key){
    var index = arrayFindIndex(this.a, function(it){
      return it[0] === key;
    });
    if(~index)this.a.splice(index, 1);
    return !!~index;
  }
};

module.exports = {
  getConstructor: function(wrapper, NAME, IS_MAP, ADDER){
    var C = wrapper(function(that, iterable){
      strictNew(that, C, NAME);
      that._i = id++;      // collection id
      that._l = undefined; // leak store for frozen objects
      if(iterable != undefined)forOf(iterable, IS_MAP, that[ADDER], that);
    });
    redefineAll(C.prototype, {
      // 23.3.3.2 WeakMap.prototype.delete(key)
      // 23.4.3.3 WeakSet.prototype.delete(value)
      'delete': function(key){
        if(!isObject(key))return false;
        if(!isExtensible(key))return frozenStore(this)['delete'](key);
        return $has(key, WEAK) && $has(key[WEAK], this._i) && delete key[WEAK][this._i];
      },
      // 23.3.3.4 WeakMap.prototype.has(key)
      // 23.4.3.4 WeakSet.prototype.has(value)
      has: function has(key){
        if(!isObject(key))return false;
        if(!isExtensible(key))return frozenStore(this).has(key);
        return $has(key, WEAK) && $has(key[WEAK], this._i);
      }
    });
    return C;
  },
  def: function(that, key, value){
    if(!isExtensible(anObject(key))){
      frozenStore(that).set(key, value);
    } else {
      $has(key, WEAK) || hide(key, WEAK, {});
      key[WEAK][that._i] = value;
    } return that;
  },
  frozenStore: frozenStore,
  WEAK: WEAK
};
},{"./$.an-object":4,"./$.array-methods":8,"./$.for-of":27,"./$.has":30,"./$.hide":31,"./$.is-object":38,"./$.redefine-all":60,"./$.strict-new":69,"./$.uid":82}],15:[function(require,module,exports){
'use strict';
var global         = require('./$.global')
  , $export        = require('./$.export')
  , redefine       = require('./$.redefine')
  , redefineAll    = require('./$.redefine-all')
  , forOf          = require('./$.for-of')
  , strictNew      = require('./$.strict-new')
  , isObject       = require('./$.is-object')
  , fails          = require('./$.fails')
  , $iterDetect    = require('./$.iter-detect')
  , setToStringTag = require('./$.set-to-string-tag');

module.exports = function(NAME, wrapper, methods, common, IS_MAP, IS_WEAK){
  var Base  = global[NAME]
    , C     = Base
    , ADDER = IS_MAP ? 'set' : 'add'
    , proto = C && C.prototype
    , O     = {};
  var fixMethod = function(KEY){
    var fn = proto[KEY];
    redefine(proto, KEY,
      KEY == 'delete' ? function(a){
        return IS_WEAK && !isObject(a) ? false : fn.call(this, a === 0 ? 0 : a);
      } : KEY == 'has' ? function has(a){
        return IS_WEAK && !isObject(a) ? false : fn.call(this, a === 0 ? 0 : a);
      } : KEY == 'get' ? function get(a){
        return IS_WEAK && !isObject(a) ? undefined : fn.call(this, a === 0 ? 0 : a);
      } : KEY == 'add' ? function add(a){ fn.call(this, a === 0 ? 0 : a); return this; }
        : function set(a, b){ fn.call(this, a === 0 ? 0 : a, b); return this; }
    );
  };
  if(typeof C != 'function' || !(IS_WEAK || proto.forEach && !fails(function(){
    new C().entries().next();
  }))){
    // create collection constructor
    C = common.getConstructor(wrapper, NAME, IS_MAP, ADDER);
    redefineAll(C.prototype, methods);
  } else {
    var instance             = new C
      // early implementations not supports chaining
      , HASNT_CHAINING       = instance[ADDER](IS_WEAK ? {} : -0, 1) != instance
      // V8 ~  Chromium 40- weak-collections throws on primitives, but should return false
      , THROWS_ON_PRIMITIVES = fails(function(){ instance.has(1); })
      // most early implementations doesn't supports iterables, most modern - not close it correctly
      , ACCEPT_ITERABLES     = $iterDetect(function(iter){ new C(iter); }) // eslint-disable-line no-new
      // for early implementations -0 and +0 not the same
      , BUGGY_ZERO;
    if(!ACCEPT_ITERABLES){ 
      C = wrapper(function(target, iterable){
        strictNew(target, C, NAME);
        var that = new Base;
        if(iterable != undefined)forOf(iterable, IS_MAP, that[ADDER], that);
        return that;
      });
      C.prototype = proto;
      proto.constructor = C;
    }
    IS_WEAK || instance.forEach(function(val, key){
      BUGGY_ZERO = 1 / key === -Infinity;
    });
    if(THROWS_ON_PRIMITIVES || BUGGY_ZERO){
      fixMethod('delete');
      fixMethod('has');
      IS_MAP && fixMethod('get');
    }
    if(BUGGY_ZERO || HASNT_CHAINING)fixMethod(ADDER);
    // weak collections should not contains .clear method
    if(IS_WEAK && proto.clear)delete proto.clear;
  }

  setToStringTag(C, NAME);

  O[NAME] = C;
  $export($export.G + $export.W + $export.F * (C != Base), O);

  if(!IS_WEAK)common.setStrong(C, NAME, IS_MAP);

  return C;
};
},{"./$.export":22,"./$.fails":24,"./$.for-of":27,"./$.global":29,"./$.is-object":38,"./$.iter-detect":43,"./$.redefine":61,"./$.redefine-all":60,"./$.set-to-string-tag":66,"./$.strict-new":69}],16:[function(require,module,exports){
var core = module.exports = {version: '1.2.6'};
if(typeof __e == 'number')__e = core; // eslint-disable-line no-undef
},{}],17:[function(require,module,exports){
// optional / simple context binding
var aFunction = require('./$.a-function');
module.exports = function(fn, that, length){
  aFunction(fn);
  if(that === undefined)return fn;
  switch(length){
    case 1: return function(a){
      return fn.call(that, a);
    };
    case 2: return function(a, b){
      return fn.call(that, a, b);
    };
    case 3: return function(a, b, c){
      return fn.call(that, a, b, c);
    };
  }
  return function(/* ...args */){
    return fn.apply(that, arguments);
  };
};
},{"./$.a-function":2}],18:[function(require,module,exports){
// 7.2.1 RequireObjectCoercible(argument)
module.exports = function(it){
  if(it == undefined)throw TypeError("Can't call method on  " + it);
  return it;
};
},{}],19:[function(require,module,exports){
// Thank's IE8 for his funny defineProperty
module.exports = !require('./$.fails')(function(){
  return Object.defineProperty({}, 'a', {get: function(){ return 7; }}).a != 7;
});
},{"./$.fails":24}],20:[function(require,module,exports){
var isObject = require('./$.is-object')
  , document = require('./$.global').document
  // in old IE typeof document.createElement is 'object'
  , is = isObject(document) && isObject(document.createElement);
module.exports = function(it){
  return is ? document.createElement(it) : {};
};
},{"./$.global":29,"./$.is-object":38}],21:[function(require,module,exports){
// all enumerable object keys, includes symbols
var $ = require('./$');
module.exports = function(it){
  var keys       = $.getKeys(it)
    , getSymbols = $.getSymbols;
  if(getSymbols){
    var symbols = getSymbols(it)
      , isEnum  = $.isEnum
      , i       = 0
      , key;
    while(symbols.length > i)if(isEnum.call(it, key = symbols[i++]))keys.push(key);
  }
  return keys;
};
},{"./$":46}],22:[function(require,module,exports){
var global    = require('./$.global')
  , core      = require('./$.core')
  , hide      = require('./$.hide')
  , redefine  = require('./$.redefine')
  , ctx       = require('./$.ctx')
  , PROTOTYPE = 'prototype';

var $export = function(type, name, source){
  var IS_FORCED = type & $export.F
    , IS_GLOBAL = type & $export.G
    , IS_STATIC = type & $export.S
    , IS_PROTO  = type & $export.P
    , IS_BIND   = type & $export.B
    , target    = IS_GLOBAL ? global : IS_STATIC ? global[name] || (global[name] = {}) : (global[name] || {})[PROTOTYPE]
    , exports   = IS_GLOBAL ? core : core[name] || (core[name] = {})
    , expProto  = exports[PROTOTYPE] || (exports[PROTOTYPE] = {})
    , key, own, out, exp;
  if(IS_GLOBAL)source = name;
  for(key in source){
    // contains in native
    own = !IS_FORCED && target && key in target;
    // export native or passed
    out = (own ? target : source)[key];
    // bind timers to global for call from export context
    exp = IS_BIND && own ? ctx(out, global) : IS_PROTO && typeof out == 'function' ? ctx(Function.call, out) : out;
    // extend global
    if(target && !own)redefine(target, key, out);
    // export
    if(exports[key] != out)hide(exports, key, exp);
    if(IS_PROTO && expProto[key] != out)expProto[key] = out;
  }
};
global.core = core;
// type bitmap
$export.F = 1;  // forced
$export.G = 2;  // global
$export.S = 4;  // static
$export.P = 8;  // proto
$export.B = 16; // bind
$export.W = 32; // wrap
module.exports = $export;
},{"./$.core":16,"./$.ctx":17,"./$.global":29,"./$.hide":31,"./$.redefine":61}],23:[function(require,module,exports){
var MATCH = require('./$.wks')('match');
module.exports = function(KEY){
  var re = /./;
  try {
    '/./'[KEY](re);
  } catch(e){
    try {
      re[MATCH] = false;
      return !'/./'[KEY](re);
    } catch(f){ /* empty */ }
  } return true;
};
},{"./$.wks":83}],24:[function(require,module,exports){
module.exports = function(exec){
  try {
    return !!exec();
  } catch(e){
    return true;
  }
};
},{}],25:[function(require,module,exports){
'use strict';
var hide     = require('./$.hide')
  , redefine = require('./$.redefine')
  , fails    = require('./$.fails')
  , defined  = require('./$.defined')
  , wks      = require('./$.wks');

module.exports = function(KEY, length, exec){
  var SYMBOL   = wks(KEY)
    , original = ''[KEY];
  if(fails(function(){
    var O = {};
    O[SYMBOL] = function(){ return 7; };
    return ''[KEY](O) != 7;
  })){
    redefine(String.prototype, KEY, exec(defined, SYMBOL, original));
    hide(RegExp.prototype, SYMBOL, length == 2
      // 21.2.5.8 RegExp.prototype[@@replace](string, replaceValue)
      // 21.2.5.11 RegExp.prototype[@@split](string, limit)
      ? function(string, arg){ return original.call(string, this, arg); }
      // 21.2.5.6 RegExp.prototype[@@match](string)
      // 21.2.5.9 RegExp.prototype[@@search](string)
      : function(string){ return original.call(string, this); }
    );
  }
};
},{"./$.defined":18,"./$.fails":24,"./$.hide":31,"./$.redefine":61,"./$.wks":83}],26:[function(require,module,exports){
'use strict';
// 21.2.5.3 get RegExp.prototype.flags
var anObject = require('./$.an-object');
module.exports = function(){
  var that   = anObject(this)
    , result = '';
  if(that.global)     result += 'g';
  if(that.ignoreCase) result += 'i';
  if(that.multiline)  result += 'm';
  if(that.unicode)    result += 'u';
  if(that.sticky)     result += 'y';
  return result;
};
},{"./$.an-object":4}],27:[function(require,module,exports){
var ctx         = require('./$.ctx')
  , call        = require('./$.iter-call')
  , isArrayIter = require('./$.is-array-iter')
  , anObject    = require('./$.an-object')
  , toLength    = require('./$.to-length')
  , getIterFn   = require('./core.get-iterator-method');
module.exports = function(iterable, entries, fn, that){
  var iterFn = getIterFn(iterable)
    , f      = ctx(fn, that, entries ? 2 : 1)
    , index  = 0
    , length, step, iterator;
  if(typeof iterFn != 'function')throw TypeError(iterable + ' is not iterable!');
  // fast case for arrays with default iterator
  if(isArrayIter(iterFn))for(length = toLength(iterable.length); length > index; index++){
    entries ? f(anObject(step = iterable[index])[0], step[1]) : f(iterable[index]);
  } else for(iterator = iterFn.call(iterable); !(step = iterator.next()).done; ){
    call(iterator, f, step.value, entries);
  }
};
},{"./$.an-object":4,"./$.ctx":17,"./$.is-array-iter":35,"./$.iter-call":40,"./$.to-length":79,"./core.get-iterator-method":84}],28:[function(require,module,exports){
// fallback for IE11 buggy Object.getOwnPropertyNames with iframe and window
var toIObject = require('./$.to-iobject')
  , getNames  = require('./$').getNames
  , toString  = {}.toString;

var windowNames = typeof window == 'object' && Object.getOwnPropertyNames
  ? Object.getOwnPropertyNames(window) : [];

var getWindowNames = function(it){
  try {
    return getNames(it);
  } catch(e){
    return windowNames.slice();
  }
};

module.exports.get = function getOwnPropertyNames(it){
  if(windowNames && toString.call(it) == '[object Window]')return getWindowNames(it);
  return getNames(toIObject(it));
};
},{"./$":46,"./$.to-iobject":78}],29:[function(require,module,exports){
// https://github.com/zloirock/core-js/issues/86#issuecomment-115759028
var global = module.exports = typeof window != 'undefined' && window.Math == Math
  ? window : typeof self != 'undefined' && self.Math == Math ? self : Function('return this')();
if(typeof __g == 'number')__g = global; // eslint-disable-line no-undef
},{}],30:[function(require,module,exports){
var hasOwnProperty = {}.hasOwnProperty;
module.exports = function(it, key){
  return hasOwnProperty.call(it, key);
};
},{}],31:[function(require,module,exports){
var $          = require('./$')
  , createDesc = require('./$.property-desc');
module.exports = require('./$.descriptors') ? function(object, key, value){
  return $.setDesc(object, key, createDesc(1, value));
} : function(object, key, value){
  object[key] = value;
  return object;
};
},{"./$":46,"./$.descriptors":19,"./$.property-desc":59}],32:[function(require,module,exports){
module.exports = require('./$.global').document && document.documentElement;
},{"./$.global":29}],33:[function(require,module,exports){
// fast apply, http://jsperf.lnkit.com/fast-apply/5
module.exports = function(fn, args, that){
  var un = that === undefined;
  switch(args.length){
    case 0: return un ? fn()
                      : fn.call(that);
    case 1: return un ? fn(args[0])
                      : fn.call(that, args[0]);
    case 2: return un ? fn(args[0], args[1])
                      : fn.call(that, args[0], args[1]);
    case 3: return un ? fn(args[0], args[1], args[2])
                      : fn.call(that, args[0], args[1], args[2]);
    case 4: return un ? fn(args[0], args[1], args[2], args[3])
                      : fn.call(that, args[0], args[1], args[2], args[3]);
  } return              fn.apply(that, args);
};
},{}],34:[function(require,module,exports){
// fallback for non-array-like ES3 and non-enumerable old V8 strings
var cof = require('./$.cof');
module.exports = Object('z').propertyIsEnumerable(0) ? Object : function(it){
  return cof(it) == 'String' ? it.split('') : Object(it);
};
},{"./$.cof":11}],35:[function(require,module,exports){
// check on default Array iterator
var Iterators  = require('./$.iterators')
  , ITERATOR   = require('./$.wks')('iterator')
  , ArrayProto = Array.prototype;

module.exports = function(it){
  return it !== undefined && (Iterators.Array === it || ArrayProto[ITERATOR] === it);
};
},{"./$.iterators":45,"./$.wks":83}],36:[function(require,module,exports){
// 7.2.2 IsArray(argument)
var cof = require('./$.cof');
module.exports = Array.isArray || function(arg){
  return cof(arg) == 'Array';
};
},{"./$.cof":11}],37:[function(require,module,exports){
// 20.1.2.3 Number.isInteger(number)
var isObject = require('./$.is-object')
  , floor    = Math.floor;
module.exports = function isInteger(it){
  return !isObject(it) && isFinite(it) && floor(it) === it;
};
},{"./$.is-object":38}],38:[function(require,module,exports){
module.exports = function(it){
  return typeof it === 'object' ? it !== null : typeof it === 'function';
};
},{}],39:[function(require,module,exports){
// 7.2.8 IsRegExp(argument)
var isObject = require('./$.is-object')
  , cof      = require('./$.cof')
  , MATCH    = require('./$.wks')('match');
module.exports = function(it){
  var isRegExp;
  return isObject(it) && ((isRegExp = it[MATCH]) !== undefined ? !!isRegExp : cof(it) == 'RegExp');
};
},{"./$.cof":11,"./$.is-object":38,"./$.wks":83}],40:[function(require,module,exports){
// call something on iterator step with safe closing on error
var anObject = require('./$.an-object');
module.exports = function(iterator, fn, value, entries){
  try {
    return entries ? fn(anObject(value)[0], value[1]) : fn(value);
  // 7.4.6 IteratorClose(iterator, completion)
  } catch(e){
    var ret = iterator['return'];
    if(ret !== undefined)anObject(ret.call(iterator));
    throw e;
  }
};
},{"./$.an-object":4}],41:[function(require,module,exports){
'use strict';
var $              = require('./$')
  , descriptor     = require('./$.property-desc')
  , setToStringTag = require('./$.set-to-string-tag')
  , IteratorPrototype = {};

// 25.1.2.1.1 %IteratorPrototype%[@@iterator]()
require('./$.hide')(IteratorPrototype, require('./$.wks')('iterator'), function(){ return this; });

module.exports = function(Constructor, NAME, next){
  Constructor.prototype = $.create(IteratorPrototype, {next: descriptor(1, next)});
  setToStringTag(Constructor, NAME + ' Iterator');
};
},{"./$":46,"./$.hide":31,"./$.property-desc":59,"./$.set-to-string-tag":66,"./$.wks":83}],42:[function(require,module,exports){
'use strict';
var LIBRARY        = require('./$.library')
  , $export        = require('./$.export')
  , redefine       = require('./$.redefine')
  , hide           = require('./$.hide')
  , has            = require('./$.has')
  , Iterators      = require('./$.iterators')
  , $iterCreate    = require('./$.iter-create')
  , setToStringTag = require('./$.set-to-string-tag')
  , getProto       = require('./$').getProto
  , ITERATOR       = require('./$.wks')('iterator')
  , BUGGY          = !([].keys && 'next' in [].keys()) // Safari has buggy iterators w/o `next`
  , FF_ITERATOR    = '@@iterator'
  , KEYS           = 'keys'
  , VALUES         = 'values';

var returnThis = function(){ return this; };

module.exports = function(Base, NAME, Constructor, next, DEFAULT, IS_SET, FORCED){
  $iterCreate(Constructor, NAME, next);
  var getMethod = function(kind){
    if(!BUGGY && kind in proto)return proto[kind];
    switch(kind){
      case KEYS: return function keys(){ return new Constructor(this, kind); };
      case VALUES: return function values(){ return new Constructor(this, kind); };
    } return function entries(){ return new Constructor(this, kind); };
  };
  var TAG        = NAME + ' Iterator'
    , DEF_VALUES = DEFAULT == VALUES
    , VALUES_BUG = false
    , proto      = Base.prototype
    , $native    = proto[ITERATOR] || proto[FF_ITERATOR] || DEFAULT && proto[DEFAULT]
    , $default   = $native || getMethod(DEFAULT)
    , methods, key;
  // Fix native
  if($native){
    var IteratorPrototype = getProto($default.call(new Base));
    // Set @@toStringTag to native iterators
    setToStringTag(IteratorPrototype, TAG, true);
    // FF fix
    if(!LIBRARY && has(proto, FF_ITERATOR))hide(IteratorPrototype, ITERATOR, returnThis);
    // fix Array#{values, @@iterator}.name in V8 / FF
    if(DEF_VALUES && $native.name !== VALUES){
      VALUES_BUG = true;
      $default = function values(){ return $native.call(this); };
    }
  }
  // Define iterator
  if((!LIBRARY || FORCED) && (BUGGY || VALUES_BUG || !proto[ITERATOR])){
    hide(proto, ITERATOR, $default);
  }
  // Plug for library
  Iterators[NAME] = $default;
  Iterators[TAG]  = returnThis;
  if(DEFAULT){
    methods = {
      values:  DEF_VALUES  ? $default : getMethod(VALUES),
      keys:    IS_SET      ? $default : getMethod(KEYS),
      entries: !DEF_VALUES ? $default : getMethod('entries')
    };
    if(FORCED)for(key in methods){
      if(!(key in proto))redefine(proto, key, methods[key]);
    } else $export($export.P + $export.F * (BUGGY || VALUES_BUG), NAME, methods);
  }
  return methods;
};
},{"./$":46,"./$.export":22,"./$.has":30,"./$.hide":31,"./$.iter-create":41,"./$.iterators":45,"./$.library":48,"./$.redefine":61,"./$.set-to-string-tag":66,"./$.wks":83}],43:[function(require,module,exports){
var ITERATOR     = require('./$.wks')('iterator')
  , SAFE_CLOSING = false;

try {
  var riter = [7][ITERATOR]();
  riter['return'] = function(){ SAFE_CLOSING = true; };
  Array.from(riter, function(){ throw 2; });
} catch(e){ /* empty */ }

module.exports = function(exec, skipClosing){
  if(!skipClosing && !SAFE_CLOSING)return false;
  var safe = false;
  try {
    var arr  = [7]
      , iter = arr[ITERATOR]();
    iter.next = function(){ safe = true; };
    arr[ITERATOR] = function(){ return iter; };
    exec(arr);
  } catch(e){ /* empty */ }
  return safe;
};
},{"./$.wks":83}],44:[function(require,module,exports){
module.exports = function(done, value){
  return {value: value, done: !!done};
};
},{}],45:[function(require,module,exports){
module.exports = {};
},{}],46:[function(require,module,exports){
var $Object = Object;
module.exports = {
  create:     $Object.create,
  getProto:   $Object.getPrototypeOf,
  isEnum:     {}.propertyIsEnumerable,
  getDesc:    $Object.getOwnPropertyDescriptor,
  setDesc:    $Object.defineProperty,
  setDescs:   $Object.defineProperties,
  getKeys:    $Object.keys,
  getNames:   $Object.getOwnPropertyNames,
  getSymbols: $Object.getOwnPropertySymbols,
  each:       [].forEach
};
},{}],47:[function(require,module,exports){
var $         = require('./$')
  , toIObject = require('./$.to-iobject');
module.exports = function(object, el){
  var O      = toIObject(object)
    , keys   = $.getKeys(O)
    , length = keys.length
    , index  = 0
    , key;
  while(length > index)if(O[key = keys[index++]] === el)return key;
};
},{"./$":46,"./$.to-iobject":78}],48:[function(require,module,exports){
module.exports = false;
},{}],49:[function(require,module,exports){
// 20.2.2.14 Math.expm1(x)
module.exports = Math.expm1 || function expm1(x){
  return (x = +x) == 0 ? x : x > -1e-6 && x < 1e-6 ? x + x * x / 2 : Math.exp(x) - 1;
};
},{}],50:[function(require,module,exports){
// 20.2.2.20 Math.log1p(x)
module.exports = Math.log1p || function log1p(x){
  return (x = +x) > -1e-8 && x < 1e-8 ? x - x * x / 2 : Math.log(1 + x);
};
},{}],51:[function(require,module,exports){
// 20.2.2.28 Math.sign(x)
module.exports = Math.sign || function sign(x){
  return (x = +x) == 0 || x != x ? x : x < 0 ? -1 : 1;
};
},{}],52:[function(require,module,exports){
var global    = require('./$.global')
  , macrotask = require('./$.task').set
  , Observer  = global.MutationObserver || global.WebKitMutationObserver
  , process   = global.process
  , Promise   = global.Promise
  , isNode    = require('./$.cof')(process) == 'process'
  , head, last, notify;

var flush = function(){
  var parent, domain, fn;
  if(isNode && (parent = process.domain)){
    process.domain = null;
    parent.exit();
  }
  while(head){
    domain = head.domain;
    fn     = head.fn;
    if(domain)domain.enter();
    fn(); // <- currently we use it only for Promise - try / catch not required
    if(domain)domain.exit();
    head = head.next;
  } last = undefined;
  if(parent)parent.enter();
};

// Node.js
if(isNode){
  notify = function(){
    process.nextTick(flush);
  };
// browsers with MutationObserver
} else if(Observer){
  var toggle = 1
    , node   = document.createTextNode('');
  new Observer(flush).observe(node, {characterData: true}); // eslint-disable-line no-new
  notify = function(){
    node.data = toggle = -toggle;
  };
// environments with maybe non-completely correct, but existent Promise
} else if(Promise && Promise.resolve){
  notify = function(){
    Promise.resolve().then(flush);
  };
// for other environments - macrotask based on:
// - setImmediate
// - MessageChannel
// - window.postMessag
// - onreadystatechange
// - setTimeout
} else {
  notify = function(){
    // strange IE + webpack dev server bug - use .call(global)
    macrotask.call(global, flush);
  };
}

module.exports = function asap(fn){
  var task = {fn: fn, next: undefined, domain: isNode && process.domain};
  if(last)last.next = task;
  if(!head){
    head = task;
    notify();
  } last = task;
};
},{"./$.cof":11,"./$.global":29,"./$.task":75}],53:[function(require,module,exports){
// 19.1.2.1 Object.assign(target, source, ...)
var $        = require('./$')
  , toObject = require('./$.to-object')
  , IObject  = require('./$.iobject');

// should work with symbols and should have deterministic property order (V8 bug)
module.exports = require('./$.fails')(function(){
  var a = Object.assign
    , A = {}
    , B = {}
    , S = Symbol()
    , K = 'abcdefghijklmnopqrst';
  A[S] = 7;
  K.split('').forEach(function(k){ B[k] = k; });
  return a({}, A)[S] != 7 || Object.keys(a({}, B)).join('') != K;
}) ? function assign(target, source){ // eslint-disable-line no-unused-vars
  var T     = toObject(target)
    , $$    = arguments
    , $$len = $$.length
    , index = 1
    , getKeys    = $.getKeys
    , getSymbols = $.getSymbols
    , isEnum     = $.isEnum;
  while($$len > index){
    var S      = IObject($$[index++])
      , keys   = getSymbols ? getKeys(S).concat(getSymbols(S)) : getKeys(S)
      , length = keys.length
      , j      = 0
      , key;
    while(length > j)if(isEnum.call(S, key = keys[j++]))T[key] = S[key];
  }
  return T;
} : Object.assign;
},{"./$":46,"./$.fails":24,"./$.iobject":34,"./$.to-object":80}],54:[function(require,module,exports){
// most Object methods by ES6 should accept primitives
var $export = require('./$.export')
  , core    = require('./$.core')
  , fails   = require('./$.fails');
module.exports = function(KEY, exec){
  var fn  = (core.Object || {})[KEY] || Object[KEY]
    , exp = {};
  exp[KEY] = exec(fn);
  $export($export.S + $export.F * fails(function(){ fn(1); }), 'Object', exp);
};
},{"./$.core":16,"./$.export":22,"./$.fails":24}],55:[function(require,module,exports){
var $         = require('./$')
  , toIObject = require('./$.to-iobject')
  , isEnum    = $.isEnum;
module.exports = function(isEntries){
  return function(it){
    var O      = toIObject(it)
      , keys   = $.getKeys(O)
      , length = keys.length
      , i      = 0
      , result = []
      , key;
    while(length > i)if(isEnum.call(O, key = keys[i++])){
      result.push(isEntries ? [key, O[key]] : O[key]);
    } return result;
  };
};
},{"./$":46,"./$.to-iobject":78}],56:[function(require,module,exports){
// all object keys, includes non-enumerable and symbols
var $        = require('./$')
  , anObject = require('./$.an-object')
  , Reflect  = require('./$.global').Reflect;
module.exports = Reflect && Reflect.ownKeys || function ownKeys(it){
  var keys       = $.getNames(anObject(it))
    , getSymbols = $.getSymbols;
  return getSymbols ? keys.concat(getSymbols(it)) : keys;
};
},{"./$":46,"./$.an-object":4,"./$.global":29}],57:[function(require,module,exports){
'use strict';
var path      = require('./$.path')
  , invoke    = require('./$.invoke')
  , aFunction = require('./$.a-function');
module.exports = function(/* ...pargs */){
  var fn     = aFunction(this)
    , length = arguments.length
    , pargs  = Array(length)
    , i      = 0
    , _      = path._
    , holder = false;
  while(length > i)if((pargs[i] = arguments[i++]) === _)holder = true;
  return function(/* ...args */){
    var that  = this
      , $$    = arguments
      , $$len = $$.length
      , j = 0, k = 0, args;
    if(!holder && !$$len)return invoke(fn, pargs, that);
    args = pargs.slice();
    if(holder)for(;length > j; j++)if(args[j] === _)args[j] = $$[k++];
    while($$len > k)args.push($$[k++]);
    return invoke(fn, args, that);
  };
};
},{"./$.a-function":2,"./$.invoke":33,"./$.path":58}],58:[function(require,module,exports){
module.exports = require('./$.global');
},{"./$.global":29}],59:[function(require,module,exports){
module.exports = function(bitmap, value){
  return {
    enumerable  : !(bitmap & 1),
    configurable: !(bitmap & 2),
    writable    : !(bitmap & 4),
    value       : value
  };
};
},{}],60:[function(require,module,exports){
var redefine = require('./$.redefine');
module.exports = function(target, src){
  for(var key in src)redefine(target, key, src[key]);
  return target;
};
},{"./$.redefine":61}],61:[function(require,module,exports){
// add fake Function#toString
// for correct work wrapped methods / constructors with methods like LoDash isNative
var global    = require('./$.global')
  , hide      = require('./$.hide')
  , SRC       = require('./$.uid')('src')
  , TO_STRING = 'toString'
  , $toString = Function[TO_STRING]
  , TPL       = ('' + $toString).split(TO_STRING);

require('./$.core').inspectSource = function(it){
  return $toString.call(it);
};

(module.exports = function(O, key, val, safe){
  if(typeof val == 'function'){
    val.hasOwnProperty(SRC) || hide(val, SRC, O[key] ? '' + O[key] : TPL.join(String(key)));
    val.hasOwnProperty('name') || hide(val, 'name', key);
  }
  if(O === global){
    O[key] = val;
  } else {
    if(!safe)delete O[key];
    hide(O, key, val);
  }
})(Function.prototype, TO_STRING, function toString(){
  return typeof this == 'function' && this[SRC] || $toString.call(this);
});
},{"./$.core":16,"./$.global":29,"./$.hide":31,"./$.uid":82}],62:[function(require,module,exports){
module.exports = function(regExp, replace){
  var replacer = replace === Object(replace) ? function(part){
    return replace[part];
  } : replace;
  return function(it){
    return String(it).replace(regExp, replacer);
  };
};
},{}],63:[function(require,module,exports){
// 7.2.9 SameValue(x, y)
module.exports = Object.is || function is(x, y){
  return x === y ? x !== 0 || 1 / x === 1 / y : x != x && y != y;
};
},{}],64:[function(require,module,exports){
// Works with __proto__ only. Old v8 can't work with null proto objects.
/* eslint-disable no-proto */
var getDesc  = require('./$').getDesc
  , isObject = require('./$.is-object')
  , anObject = require('./$.an-object');
var check = function(O, proto){
  anObject(O);
  if(!isObject(proto) && proto !== null)throw TypeError(proto + ": can't set as prototype!");
};
module.exports = {
  set: Object.setPrototypeOf || ('__proto__' in {} ? // eslint-disable-line
    function(test, buggy, set){
      try {
        set = require('./$.ctx')(Function.call, getDesc(Object.prototype, '__proto__').set, 2);
        set(test, []);
        buggy = !(test instanceof Array);
      } catch(e){ buggy = true; }
      return function setPrototypeOf(O, proto){
        check(O, proto);
        if(buggy)O.__proto__ = proto;
        else set(O, proto);
        return O;
      };
    }({}, false) : undefined),
  check: check
};
},{"./$":46,"./$.an-object":4,"./$.ctx":17,"./$.is-object":38}],65:[function(require,module,exports){
'use strict';
var global      = require('./$.global')
  , $           = require('./$')
  , DESCRIPTORS = require('./$.descriptors')
  , SPECIES     = require('./$.wks')('species');

module.exports = function(KEY){
  var C = global[KEY];
  if(DESCRIPTORS && C && !C[SPECIES])$.setDesc(C, SPECIES, {
    configurable: true,
    get: function(){ return this; }
  });
};
},{"./$":46,"./$.descriptors":19,"./$.global":29,"./$.wks":83}],66:[function(require,module,exports){
var def = require('./$').setDesc
  , has = require('./$.has')
  , TAG = require('./$.wks')('toStringTag');

module.exports = function(it, tag, stat){
  if(it && !has(it = stat ? it : it.prototype, TAG))def(it, TAG, {configurable: true, value: tag});
};
},{"./$":46,"./$.has":30,"./$.wks":83}],67:[function(require,module,exports){
var global = require('./$.global')
  , SHARED = '__core-js_shared__'
  , store  = global[SHARED] || (global[SHARED] = {});
module.exports = function(key){
  return store[key] || (store[key] = {});
};
},{"./$.global":29}],68:[function(require,module,exports){
// 7.3.20 SpeciesConstructor(O, defaultConstructor)
var anObject  = require('./$.an-object')
  , aFunction = require('./$.a-function')
  , SPECIES   = require('./$.wks')('species');
module.exports = function(O, D){
  var C = anObject(O).constructor, S;
  return C === undefined || (S = anObject(C)[SPECIES]) == undefined ? D : aFunction(S);
};
},{"./$.a-function":2,"./$.an-object":4,"./$.wks":83}],69:[function(require,module,exports){
module.exports = function(it, Constructor, name){
  if(!(it instanceof Constructor))throw TypeError(name + ": use the 'new' operator!");
  return it;
};
},{}],70:[function(require,module,exports){
var toInteger = require('./$.to-integer')
  , defined   = require('./$.defined');
// true  -> String#at
// false -> String#codePointAt
module.exports = function(TO_STRING){
  return function(that, pos){
    var s = String(defined(that))
      , i = toInteger(pos)
      , l = s.length
      , a, b;
    if(i < 0 || i >= l)return TO_STRING ? '' : undefined;
    a = s.charCodeAt(i);
    return a < 0xd800 || a > 0xdbff || i + 1 === l || (b = s.charCodeAt(i + 1)) < 0xdc00 || b > 0xdfff
      ? TO_STRING ? s.charAt(i) : a
      : TO_STRING ? s.slice(i, i + 2) : (a - 0xd800 << 10) + (b - 0xdc00) + 0x10000;
  };
};
},{"./$.defined":18,"./$.to-integer":77}],71:[function(require,module,exports){
// helper for String#{startsWith, endsWith, includes}
var isRegExp = require('./$.is-regexp')
  , defined  = require('./$.defined');

module.exports = function(that, searchString, NAME){
  if(isRegExp(searchString))throw TypeError('String#' + NAME + " doesn't accept regex!");
  return String(defined(that));
};
},{"./$.defined":18,"./$.is-regexp":39}],72:[function(require,module,exports){
// https://github.com/ljharb/proposal-string-pad-left-right
var toLength = require('./$.to-length')
  , repeat   = require('./$.string-repeat')
  , defined  = require('./$.defined');

module.exports = function(that, maxLength, fillString, left){
  var S            = String(defined(that))
    , stringLength = S.length
    , fillStr      = fillString === undefined ? ' ' : String(fillString)
    , intMaxLength = toLength(maxLength);
  if(intMaxLength <= stringLength)return S;
  if(fillStr == '')fillStr = ' ';
  var fillLen = intMaxLength - stringLength
    , stringFiller = repeat.call(fillStr, Math.ceil(fillLen / fillStr.length));
  if(stringFiller.length > fillLen)stringFiller = stringFiller.slice(0, fillLen);
  return left ? stringFiller + S : S + stringFiller;
};
},{"./$.defined":18,"./$.string-repeat":73,"./$.to-length":79}],73:[function(require,module,exports){
'use strict';
var toInteger = require('./$.to-integer')
  , defined   = require('./$.defined');

module.exports = function repeat(count){
  var str = String(defined(this))
    , res = ''
    , n   = toInteger(count);
  if(n < 0 || n == Infinity)throw RangeError("Count can't be negative");
  for(;n > 0; (n >>>= 1) && (str += str))if(n & 1)res += str;
  return res;
};
},{"./$.defined":18,"./$.to-integer":77}],74:[function(require,module,exports){
var $export = require('./$.export')
  , defined = require('./$.defined')
  , fails   = require('./$.fails')
  , spaces  = '\x09\x0A\x0B\x0C\x0D\x20\xA0\u1680\u180E\u2000\u2001\u2002\u2003' +
      '\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000\u2028\u2029\uFEFF'
  , space   = '[' + spaces + ']'
  , non     = '\u200b\u0085'
  , ltrim   = RegExp('^' + space + space + '*')
  , rtrim   = RegExp(space + space + '*$');

var exporter = function(KEY, exec){
  var exp  = {};
  exp[KEY] = exec(trim);
  $export($export.P + $export.F * fails(function(){
    return !!spaces[KEY]() || non[KEY]() != non;
  }), 'String', exp);
};

// 1 -> String#trimLeft
// 2 -> String#trimRight
// 3 -> String#trim
var trim = exporter.trim = function(string, TYPE){
  string = String(defined(string));
  if(TYPE & 1)string = string.replace(ltrim, '');
  if(TYPE & 2)string = string.replace(rtrim, '');
  return string;
};

module.exports = exporter;
},{"./$.defined":18,"./$.export":22,"./$.fails":24}],75:[function(require,module,exports){
var ctx                = require('./$.ctx')
  , invoke             = require('./$.invoke')
  , html               = require('./$.html')
  , cel                = require('./$.dom-create')
  , global             = require('./$.global')
  , process            = global.process
  , setTask            = global.setImmediate
  , clearTask          = global.clearImmediate
  , MessageChannel     = global.MessageChannel
  , counter            = 0
  , queue              = {}
  , ONREADYSTATECHANGE = 'onreadystatechange'
  , defer, channel, port;
var run = function(){
  var id = +this;
  if(queue.hasOwnProperty(id)){
    var fn = queue[id];
    delete queue[id];
    fn();
  }
};
var listner = function(event){
  run.call(event.data);
};
// Node.js 0.9+ & IE10+ has setImmediate, otherwise:
if(!setTask || !clearTask){
  setTask = function setImmediate(fn){
    var args = [], i = 1;
    while(arguments.length > i)args.push(arguments[i++]);
    queue[++counter] = function(){
      invoke(typeof fn == 'function' ? fn : Function(fn), args);
    };
    defer(counter);
    return counter;
  };
  clearTask = function clearImmediate(id){
    delete queue[id];
  };
  // Node.js 0.8-
  if(require('./$.cof')(process) == 'process'){
    defer = function(id){
      process.nextTick(ctx(run, id, 1));
    };
  // Browsers with MessageChannel, includes WebWorkers
  } else if(MessageChannel){
    channel = new MessageChannel;
    port    = channel.port2;
    channel.port1.onmessage = listner;
    defer = ctx(port.postMessage, port, 1);
  // Browsers with postMessage, skip WebWorkers
  // IE8 has postMessage, but it's sync & typeof its postMessage is 'object'
  } else if(global.addEventListener && typeof postMessage == 'function' && !global.importScripts){
    defer = function(id){
      global.postMessage(id + '', '*');
    };
    global.addEventListener('message', listner, false);
  // IE8-
  } else if(ONREADYSTATECHANGE in cel('script')){
    defer = function(id){
      html.appendChild(cel('script'))[ONREADYSTATECHANGE] = function(){
        html.removeChild(this);
        run.call(id);
      };
    };
  // Rest old browsers
  } else {
    defer = function(id){
      setTimeout(ctx(run, id, 1), 0);
    };
  }
}
module.exports = {
  set:   setTask,
  clear: clearTask
};
},{"./$.cof":11,"./$.ctx":17,"./$.dom-create":20,"./$.global":29,"./$.html":32,"./$.invoke":33}],76:[function(require,module,exports){
var toInteger = require('./$.to-integer')
  , max       = Math.max
  , min       = Math.min;
module.exports = function(index, length){
  index = toInteger(index);
  return index < 0 ? max(index + length, 0) : min(index, length);
};
},{"./$.to-integer":77}],77:[function(require,module,exports){
// 7.1.4 ToInteger
var ceil  = Math.ceil
  , floor = Math.floor;
module.exports = function(it){
  return isNaN(it = +it) ? 0 : (it > 0 ? floor : ceil)(it);
};
},{}],78:[function(require,module,exports){
// to indexed object, toObject with fallback for non-array-like ES3 strings
var IObject = require('./$.iobject')
  , defined = require('./$.defined');
module.exports = function(it){
  return IObject(defined(it));
};
},{"./$.defined":18,"./$.iobject":34}],79:[function(require,module,exports){
// 7.1.15 ToLength
var toInteger = require('./$.to-integer')
  , min       = Math.min;
module.exports = function(it){
  return it > 0 ? min(toInteger(it), 0x1fffffffffffff) : 0; // pow(2, 53) - 1 == 9007199254740991
};
},{"./$.to-integer":77}],80:[function(require,module,exports){
// 7.1.13 ToObject(argument)
var defined = require('./$.defined');
module.exports = function(it){
  return Object(defined(it));
};
},{"./$.defined":18}],81:[function(require,module,exports){
// 7.1.1 ToPrimitive(input [, PreferredType])
var isObject = require('./$.is-object');
// instead of the ES6 spec version, we didn't implement @@toPrimitive case
// and the second argument - flag - preferred type is a string
module.exports = function(it, S){
  if(!isObject(it))return it;
  var fn, val;
  if(S && typeof (fn = it.toString) == 'function' && !isObject(val = fn.call(it)))return val;
  if(typeof (fn = it.valueOf) == 'function' && !isObject(val = fn.call(it)))return val;
  if(!S && typeof (fn = it.toString) == 'function' && !isObject(val = fn.call(it)))return val;
  throw TypeError("Can't convert object to primitive value");
};
},{"./$.is-object":38}],82:[function(require,module,exports){
var id = 0
  , px = Math.random();
module.exports = function(key){
  return 'Symbol('.concat(key === undefined ? '' : key, ')_', (++id + px).toString(36));
};
},{}],83:[function(require,module,exports){
var store  = require('./$.shared')('wks')
  , uid    = require('./$.uid')
  , Symbol = require('./$.global').Symbol;
module.exports = function(name){
  return store[name] || (store[name] =
    Symbol && Symbol[name] || (Symbol || uid)('Symbol.' + name));
};
},{"./$.global":29,"./$.shared":67,"./$.uid":82}],84:[function(require,module,exports){
var classof   = require('./$.classof')
  , ITERATOR  = require('./$.wks')('iterator')
  , Iterators = require('./$.iterators');
module.exports = require('./$.core').getIteratorMethod = function(it){
  if(it != undefined)return it[ITERATOR]
    || it['@@iterator']
    || Iterators[classof(it)];
};
},{"./$.classof":10,"./$.core":16,"./$.iterators":45,"./$.wks":83}],85:[function(require,module,exports){
'use strict';
var $                 = require('./$')
  , $export           = require('./$.export')
  , DESCRIPTORS       = require('./$.descriptors')
  , createDesc        = require('./$.property-desc')
  , html              = require('./$.html')
  , cel               = require('./$.dom-create')
  , has               = require('./$.has')
  , cof               = require('./$.cof')
  , invoke            = require('./$.invoke')
  , fails             = require('./$.fails')
  , anObject          = require('./$.an-object')
  , aFunction         = require('./$.a-function')
  , isObject          = require('./$.is-object')
  , toObject          = require('./$.to-object')
  , toIObject         = require('./$.to-iobject')
  , toInteger         = require('./$.to-integer')
  , toIndex           = require('./$.to-index')
  , toLength          = require('./$.to-length')
  , IObject           = require('./$.iobject')
  , IE_PROTO          = require('./$.uid')('__proto__')
  , createArrayMethod = require('./$.array-methods')
  , arrayIndexOf      = require('./$.array-includes')(false)
  , ObjectProto       = Object.prototype
  , ArrayProto        = Array.prototype
  , arraySlice        = ArrayProto.slice
  , arrayJoin         = ArrayProto.join
  , defineProperty    = $.setDesc
  , getOwnDescriptor  = $.getDesc
  , defineProperties  = $.setDescs
  , factories         = {}
  , IE8_DOM_DEFINE;

if(!DESCRIPTORS){
  IE8_DOM_DEFINE = !fails(function(){
    return defineProperty(cel('div'), 'a', {get: function(){ return 7; }}).a != 7;
  });
  $.setDesc = function(O, P, Attributes){
    if(IE8_DOM_DEFINE)try {
      return defineProperty(O, P, Attributes);
    } catch(e){ /* empty */ }
    if('get' in Attributes || 'set' in Attributes)throw TypeError('Accessors not supported!');
    if('value' in Attributes)anObject(O)[P] = Attributes.value;
    return O;
  };
  $.getDesc = function(O, P){
    if(IE8_DOM_DEFINE)try {
      return getOwnDescriptor(O, P);
    } catch(e){ /* empty */ }
    if(has(O, P))return createDesc(!ObjectProto.propertyIsEnumerable.call(O, P), O[P]);
  };
  $.setDescs = defineProperties = function(O, Properties){
    anObject(O);
    var keys   = $.getKeys(Properties)
      , length = keys.length
      , i = 0
      , P;
    while(length > i)$.setDesc(O, P = keys[i++], Properties[P]);
    return O;
  };
}
$export($export.S + $export.F * !DESCRIPTORS, 'Object', {
  // 19.1.2.6 / 15.2.3.3 Object.getOwnPropertyDescriptor(O, P)
  getOwnPropertyDescriptor: $.getDesc,
  // 19.1.2.4 / 15.2.3.6 Object.defineProperty(O, P, Attributes)
  defineProperty: $.setDesc,
  // 19.1.2.3 / 15.2.3.7 Object.defineProperties(O, Properties)
  defineProperties: defineProperties
});

  // IE 8- don't enum bug keys
var keys1 = ('constructor,hasOwnProperty,isPrototypeOf,propertyIsEnumerable,' +
            'toLocaleString,toString,valueOf').split(',')
  // Additional keys for getOwnPropertyNames
  , keys2 = keys1.concat('length', 'prototype')
  , keysLen1 = keys1.length;

// Create object with `null` prototype: use iframe Object with cleared prototype
var createDict = function(){
  // Thrash, waste and sodomy: IE GC bug
  var iframe = cel('iframe')
    , i      = keysLen1
    , gt     = '>'
    , iframeDocument;
  iframe.style.display = 'none';
  html.appendChild(iframe);
  iframe.src = 'javascript:'; // eslint-disable-line no-script-url
  // createDict = iframe.contentWindow.Object;
  // html.removeChild(iframe);
  iframeDocument = iframe.contentWindow.document;
  iframeDocument.open();
  iframeDocument.write('<script>document.F=Object</script' + gt);
  iframeDocument.close();
  createDict = iframeDocument.F;
  while(i--)delete createDict.prototype[keys1[i]];
  return createDict();
};
var createGetKeys = function(names, length){
  return function(object){
    var O      = toIObject(object)
      , i      = 0
      , result = []
      , key;
    for(key in O)if(key != IE_PROTO)has(O, key) && result.push(key);
    // Don't enum bug & hidden keys
    while(length > i)if(has(O, key = names[i++])){
      ~arrayIndexOf(result, key) || result.push(key);
    }
    return result;
  };
};
var Empty = function(){};
$export($export.S, 'Object', {
  // 19.1.2.9 / 15.2.3.2 Object.getPrototypeOf(O)
  getPrototypeOf: $.getProto = $.getProto || function(O){
    O = toObject(O);
    if(has(O, IE_PROTO))return O[IE_PROTO];
    if(typeof O.constructor == 'function' && O instanceof O.constructor){
      return O.constructor.prototype;
    } return O instanceof Object ? ObjectProto : null;
  },
  // 19.1.2.7 / 15.2.3.4 Object.getOwnPropertyNames(O)
  getOwnPropertyNames: $.getNames = $.getNames || createGetKeys(keys2, keys2.length, true),
  // 19.1.2.2 / 15.2.3.5 Object.create(O [, Properties])
  create: $.create = $.create || function(O, /*?*/Properties){
    var result;
    if(O !== null){
      Empty.prototype = anObject(O);
      result = new Empty();
      Empty.prototype = null;
      // add "__proto__" for Object.getPrototypeOf shim
      result[IE_PROTO] = O;
    } else result = createDict();
    return Properties === undefined ? result : defineProperties(result, Properties);
  },
  // 19.1.2.14 / 15.2.3.14 Object.keys(O)
  keys: $.getKeys = $.getKeys || createGetKeys(keys1, keysLen1, false)
});

var construct = function(F, len, args){
  if(!(len in factories)){
    for(var n = [], i = 0; i < len; i++)n[i] = 'a[' + i + ']';
    factories[len] = Function('F,a', 'return new F(' + n.join(',') + ')');
  }
  return factories[len](F, args);
};

// 19.2.3.2 / 15.3.4.5 Function.prototype.bind(thisArg, args...)
$export($export.P, 'Function', {
  bind: function bind(that /*, args... */){
    var fn       = aFunction(this)
      , partArgs = arraySlice.call(arguments, 1);
    var bound = function(/* args... */){
      var args = partArgs.concat(arraySlice.call(arguments));
      return this instanceof bound ? construct(fn, args.length, args) : invoke(fn, args, that);
    };
    if(isObject(fn.prototype))bound.prototype = fn.prototype;
    return bound;
  }
});

// fallback for not array-like ES3 strings and DOM objects
$export($export.P + $export.F * fails(function(){
  if(html)arraySlice.call(html);
}), 'Array', {
  slice: function(begin, end){
    var len   = toLength(this.length)
      , klass = cof(this);
    end = end === undefined ? len : end;
    if(klass == 'Array')return arraySlice.call(this, begin, end);
    var start  = toIndex(begin, len)
      , upTo   = toIndex(end, len)
      , size   = toLength(upTo - start)
      , cloned = Array(size)
      , i      = 0;
    for(; i < size; i++)cloned[i] = klass == 'String'
      ? this.charAt(start + i)
      : this[start + i];
    return cloned;
  }
});
$export($export.P + $export.F * (IObject != Object), 'Array', {
  join: function join(separator){
    return arrayJoin.call(IObject(this), separator === undefined ? ',' : separator);
  }
});

// 22.1.2.2 / 15.4.3.2 Array.isArray(arg)
$export($export.S, 'Array', {isArray: require('./$.is-array')});

var createArrayReduce = function(isRight){
  return function(callbackfn, memo){
    aFunction(callbackfn);
    var O      = IObject(this)
      , length = toLength(O.length)
      , index  = isRight ? length - 1 : 0
      , i      = isRight ? -1 : 1;
    if(arguments.length < 2)for(;;){
      if(index in O){
        memo = O[index];
        index += i;
        break;
      }
      index += i;
      if(isRight ? index < 0 : length <= index){
        throw TypeError('Reduce of empty array with no initial value');
      }
    }
    for(;isRight ? index >= 0 : length > index; index += i)if(index in O){
      memo = callbackfn(memo, O[index], index, this);
    }
    return memo;
  };
};

var methodize = function($fn){
  return function(arg1/*, arg2 = undefined */){
    return $fn(this, arg1, arguments[1]);
  };
};

$export($export.P, 'Array', {
  // 22.1.3.10 / 15.4.4.18 Array.prototype.forEach(callbackfn [, thisArg])
  forEach: $.each = $.each || methodize(createArrayMethod(0)),
  // 22.1.3.15 / 15.4.4.19 Array.prototype.map(callbackfn [, thisArg])
  map: methodize(createArrayMethod(1)),
  // 22.1.3.7 / 15.4.4.20 Array.prototype.filter(callbackfn [, thisArg])
  filter: methodize(createArrayMethod(2)),
  // 22.1.3.23 / 15.4.4.17 Array.prototype.some(callbackfn [, thisArg])
  some: methodize(createArrayMethod(3)),
  // 22.1.3.5 / 15.4.4.16 Array.prototype.every(callbackfn [, thisArg])
  every: methodize(createArrayMethod(4)),
  // 22.1.3.18 / 15.4.4.21 Array.prototype.reduce(callbackfn [, initialValue])
  reduce: createArrayReduce(false),
  // 22.1.3.19 / 15.4.4.22 Array.prototype.reduceRight(callbackfn [, initialValue])
  reduceRight: createArrayReduce(true),
  // 22.1.3.11 / 15.4.4.14 Array.prototype.indexOf(searchElement [, fromIndex])
  indexOf: methodize(arrayIndexOf),
  // 22.1.3.14 / 15.4.4.15 Array.prototype.lastIndexOf(searchElement [, fromIndex])
  lastIndexOf: function(el, fromIndex /* = @[*-1] */){
    var O      = toIObject(this)
      , length = toLength(O.length)
      , index  = length - 1;
    if(arguments.length > 1)index = Math.min(index, toInteger(fromIndex));
    if(index < 0)index = toLength(length + index);
    for(;index >= 0; index--)if(index in O)if(O[index] === el)return index;
    return -1;
  }
});

// 20.3.3.1 / 15.9.4.4 Date.now()
$export($export.S, 'Date', {now: function(){ return +new Date; }});

var lz = function(num){
  return num > 9 ? num : '0' + num;
};

// 20.3.4.36 / 15.9.5.43 Date.prototype.toISOString()
// PhantomJS / old WebKit has a broken implementations
$export($export.P + $export.F * (fails(function(){
  return new Date(-5e13 - 1).toISOString() != '0385-07-25T07:06:39.999Z';
}) || !fails(function(){
  new Date(NaN).toISOString();
})), 'Date', {
  toISOString: function toISOString(){
    if(!isFinite(this))throw RangeError('Invalid time value');
    var d = this
      , y = d.getUTCFullYear()
      , m = d.getUTCMilliseconds()
      , s = y < 0 ? '-' : y > 9999 ? '+' : '';
    return s + ('00000' + Math.abs(y)).slice(s ? -6 : -4) +
      '-' + lz(d.getUTCMonth() + 1) + '-' + lz(d.getUTCDate()) +
      'T' + lz(d.getUTCHours()) + ':' + lz(d.getUTCMinutes()) +
      ':' + lz(d.getUTCSeconds()) + '.' + (m > 99 ? m : '0' + lz(m)) + 'Z';
  }
});
},{"./$":46,"./$.a-function":2,"./$.an-object":4,"./$.array-includes":7,"./$.array-methods":8,"./$.cof":11,"./$.descriptors":19,"./$.dom-create":20,"./$.export":22,"./$.fails":24,"./$.has":30,"./$.html":32,"./$.invoke":33,"./$.iobject":34,"./$.is-array":36,"./$.is-object":38,"./$.property-desc":59,"./$.to-index":76,"./$.to-integer":77,"./$.to-iobject":78,"./$.to-length":79,"./$.to-object":80,"./$.uid":82}],86:[function(require,module,exports){
// 22.1.3.3 Array.prototype.copyWithin(target, start, end = this.length)
var $export = require('./$.export');

$export($export.P, 'Array', {copyWithin: require('./$.array-copy-within')});

require('./$.add-to-unscopables')('copyWithin');
},{"./$.add-to-unscopables":3,"./$.array-copy-within":5,"./$.export":22}],87:[function(require,module,exports){
// 22.1.3.6 Array.prototype.fill(value, start = 0, end = this.length)
var $export = require('./$.export');

$export($export.P, 'Array', {fill: require('./$.array-fill')});

require('./$.add-to-unscopables')('fill');
},{"./$.add-to-unscopables":3,"./$.array-fill":6,"./$.export":22}],88:[function(require,module,exports){
'use strict';
// 22.1.3.9 Array.prototype.findIndex(predicate, thisArg = undefined)
var $export = require('./$.export')
  , $find   = require('./$.array-methods')(6)
  , KEY     = 'findIndex'
  , forced  = true;
// Shouldn't skip holes
if(KEY in [])Array(1)[KEY](function(){ forced = false; });
$export($export.P + $export.F * forced, 'Array', {
  findIndex: function findIndex(callbackfn/*, that = undefined */){
    return $find(this, callbackfn, arguments.length > 1 ? arguments[1] : undefined);
  }
});
require('./$.add-to-unscopables')(KEY);
},{"./$.add-to-unscopables":3,"./$.array-methods":8,"./$.export":22}],89:[function(require,module,exports){
'use strict';
// 22.1.3.8 Array.prototype.find(predicate, thisArg = undefined)
var $export = require('./$.export')
  , $find   = require('./$.array-methods')(5)
  , KEY     = 'find'
  , forced  = true;
// Shouldn't skip holes
if(KEY in [])Array(1)[KEY](function(){ forced = false; });
$export($export.P + $export.F * forced, 'Array', {
  find: function find(callbackfn/*, that = undefined */){
    return $find(this, callbackfn, arguments.length > 1 ? arguments[1] : undefined);
  }
});
require('./$.add-to-unscopables')(KEY);
},{"./$.add-to-unscopables":3,"./$.array-methods":8,"./$.export":22}],90:[function(require,module,exports){
'use strict';
var ctx         = require('./$.ctx')
  , $export     = require('./$.export')
  , toObject    = require('./$.to-object')
  , call        = require('./$.iter-call')
  , isArrayIter = require('./$.is-array-iter')
  , toLength    = require('./$.to-length')
  , getIterFn   = require('./core.get-iterator-method');
$export($export.S + $export.F * !require('./$.iter-detect')(function(iter){ Array.from(iter); }), 'Array', {
  // 22.1.2.1 Array.from(arrayLike, mapfn = undefined, thisArg = undefined)
  from: function from(arrayLike/*, mapfn = undefined, thisArg = undefined*/){
    var O       = toObject(arrayLike)
      , C       = typeof this == 'function' ? this : Array
      , $$      = arguments
      , $$len   = $$.length
      , mapfn   = $$len > 1 ? $$[1] : undefined
      , mapping = mapfn !== undefined
      , index   = 0
      , iterFn  = getIterFn(O)
      , length, result, step, iterator;
    if(mapping)mapfn = ctx(mapfn, $$len > 2 ? $$[2] : undefined, 2);
    // if object isn't iterable or it's array with default iterator - use simple case
    if(iterFn != undefined && !(C == Array && isArrayIter(iterFn))){
      for(iterator = iterFn.call(O), result = new C; !(step = iterator.next()).done; index++){
        result[index] = mapping ? call(iterator, mapfn, [step.value, index], true) : step.value;
      }
    } else {
      length = toLength(O.length);
      for(result = new C(length); length > index; index++){
        result[index] = mapping ? mapfn(O[index], index) : O[index];
      }
    }
    result.length = index;
    return result;
  }
});

},{"./$.ctx":17,"./$.export":22,"./$.is-array-iter":35,"./$.iter-call":40,"./$.iter-detect":43,"./$.to-length":79,"./$.to-object":80,"./core.get-iterator-method":84}],91:[function(require,module,exports){
'use strict';
var addToUnscopables = require('./$.add-to-unscopables')
  , step             = require('./$.iter-step')
  , Iterators        = require('./$.iterators')
  , toIObject        = require('./$.to-iobject');

// 22.1.3.4 Array.prototype.entries()
// 22.1.3.13 Array.prototype.keys()
// 22.1.3.29 Array.prototype.values()
// 22.1.3.30 Array.prototype[@@iterator]()
module.exports = require('./$.iter-define')(Array, 'Array', function(iterated, kind){
  this._t = toIObject(iterated); // target
  this._i = 0;                   // next index
  this._k = kind;                // kind
// 22.1.5.2.1 %ArrayIteratorPrototype%.next()
}, function(){
  var O     = this._t
    , kind  = this._k
    , index = this._i++;
  if(!O || index >= O.length){
    this._t = undefined;
    return step(1);
  }
  if(kind == 'keys'  )return step(0, index);
  if(kind == 'values')return step(0, O[index]);
  return step(0, [index, O[index]]);
}, 'values');

// argumentsList[@@iterator] is %ArrayProto_values% (9.4.4.6, 9.4.4.7)
Iterators.Arguments = Iterators.Array;

addToUnscopables('keys');
addToUnscopables('values');
addToUnscopables('entries');
},{"./$.add-to-unscopables":3,"./$.iter-define":42,"./$.iter-step":44,"./$.iterators":45,"./$.to-iobject":78}],92:[function(require,module,exports){
'use strict';
var $export = require('./$.export');

// WebKit Array.of isn't generic
$export($export.S + $export.F * require('./$.fails')(function(){
  function F(){}
  return !(Array.of.call(F) instanceof F);
}), 'Array', {
  // 22.1.2.3 Array.of( ...items)
  of: function of(/* ...args */){
    var index  = 0
      , $$     = arguments
      , $$len  = $$.length
      , result = new (typeof this == 'function' ? this : Array)($$len);
    while($$len > index)result[index] = $$[index++];
    result.length = $$len;
    return result;
  }
});
},{"./$.export":22,"./$.fails":24}],93:[function(require,module,exports){
require('./$.set-species')('Array');
},{"./$.set-species":65}],94:[function(require,module,exports){
'use strict';
var $             = require('./$')
  , isObject      = require('./$.is-object')
  , HAS_INSTANCE  = require('./$.wks')('hasInstance')
  , FunctionProto = Function.prototype;
// 19.2.3.6 Function.prototype[@@hasInstance](V)
if(!(HAS_INSTANCE in FunctionProto))$.setDesc(FunctionProto, HAS_INSTANCE, {value: function(O){
  if(typeof this != 'function' || !isObject(O))return false;
  if(!isObject(this.prototype))return O instanceof this;
  // for environment w/o native `@@hasInstance` logic enough `instanceof`, but add this:
  while(O = $.getProto(O))if(this.prototype === O)return true;
  return false;
}});
},{"./$":46,"./$.is-object":38,"./$.wks":83}],95:[function(require,module,exports){
var setDesc    = require('./$').setDesc
  , createDesc = require('./$.property-desc')
  , has        = require('./$.has')
  , FProto     = Function.prototype
  , nameRE     = /^\s*function ([^ (]*)/
  , NAME       = 'name';
// 19.2.4.2 name
NAME in FProto || require('./$.descriptors') && setDesc(FProto, NAME, {
  configurable: true,
  get: function(){
    var match = ('' + this).match(nameRE)
      , name  = match ? match[1] : '';
    has(this, NAME) || setDesc(this, NAME, createDesc(5, name));
    return name;
  }
});
},{"./$":46,"./$.descriptors":19,"./$.has":30,"./$.property-desc":59}],96:[function(require,module,exports){
'use strict';
var strong = require('./$.collection-strong');

// 23.1 Map Objects
require('./$.collection')('Map', function(get){
  return function Map(){ return get(this, arguments.length > 0 ? arguments[0] : undefined); };
}, {
  // 23.1.3.6 Map.prototype.get(key)
  get: function get(key){
    var entry = strong.getEntry(this, key);
    return entry && entry.v;
  },
  // 23.1.3.9 Map.prototype.set(key, value)
  set: function set(key, value){
    return strong.def(this, key === 0 ? 0 : key, value);
  }
}, strong, true);
},{"./$.collection":15,"./$.collection-strong":12}],97:[function(require,module,exports){
// 20.2.2.3 Math.acosh(x)
var $export = require('./$.export')
  , log1p   = require('./$.math-log1p')
  , sqrt    = Math.sqrt
  , $acosh  = Math.acosh;

// V8 bug https://code.google.com/p/v8/issues/detail?id=3509
$export($export.S + $export.F * !($acosh && Math.floor($acosh(Number.MAX_VALUE)) == 710), 'Math', {
  acosh: function acosh(x){
    return (x = +x) < 1 ? NaN : x > 94906265.62425156
      ? Math.log(x) + Math.LN2
      : log1p(x - 1 + sqrt(x - 1) * sqrt(x + 1));
  }
});
},{"./$.export":22,"./$.math-log1p":50}],98:[function(require,module,exports){
// 20.2.2.5 Math.asinh(x)
var $export = require('./$.export');

function asinh(x){
  return !isFinite(x = +x) || x == 0 ? x : x < 0 ? -asinh(-x) : Math.log(x + Math.sqrt(x * x + 1));
}

$export($export.S, 'Math', {asinh: asinh});
},{"./$.export":22}],99:[function(require,module,exports){
// 20.2.2.7 Math.atanh(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  atanh: function atanh(x){
    return (x = +x) == 0 ? x : Math.log((1 + x) / (1 - x)) / 2;
  }
});
},{"./$.export":22}],100:[function(require,module,exports){
// 20.2.2.9 Math.cbrt(x)
var $export = require('./$.export')
  , sign    = require('./$.math-sign');

$export($export.S, 'Math', {
  cbrt: function cbrt(x){
    return sign(x = +x) * Math.pow(Math.abs(x), 1 / 3);
  }
});
},{"./$.export":22,"./$.math-sign":51}],101:[function(require,module,exports){
// 20.2.2.11 Math.clz32(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  clz32: function clz32(x){
    return (x >>>= 0) ? 31 - Math.floor(Math.log(x + 0.5) * Math.LOG2E) : 32;
  }
});
},{"./$.export":22}],102:[function(require,module,exports){
// 20.2.2.12 Math.cosh(x)
var $export = require('./$.export')
  , exp     = Math.exp;

$export($export.S, 'Math', {
  cosh: function cosh(x){
    return (exp(x = +x) + exp(-x)) / 2;
  }
});
},{"./$.export":22}],103:[function(require,module,exports){
// 20.2.2.14 Math.expm1(x)
var $export = require('./$.export');

$export($export.S, 'Math', {expm1: require('./$.math-expm1')});
},{"./$.export":22,"./$.math-expm1":49}],104:[function(require,module,exports){
// 20.2.2.16 Math.fround(x)
var $export   = require('./$.export')
  , sign      = require('./$.math-sign')
  , pow       = Math.pow
  , EPSILON   = pow(2, -52)
  , EPSILON32 = pow(2, -23)
  , MAX32     = pow(2, 127) * (2 - EPSILON32)
  , MIN32     = pow(2, -126);

var roundTiesToEven = function(n){
  return n + 1 / EPSILON - 1 / EPSILON;
};


$export($export.S, 'Math', {
  fround: function fround(x){
    var $abs  = Math.abs(x)
      , $sign = sign(x)
      , a, result;
    if($abs < MIN32)return $sign * roundTiesToEven($abs / MIN32 / EPSILON32) * MIN32 * EPSILON32;
    a = (1 + EPSILON32 / EPSILON) * $abs;
    result = a - (a - $abs);
    if(result > MAX32 || result != result)return $sign * Infinity;
    return $sign * result;
  }
});
},{"./$.export":22,"./$.math-sign":51}],105:[function(require,module,exports){
// 20.2.2.17 Math.hypot([value1[, value2[, … ]]])
var $export = require('./$.export')
  , abs     = Math.abs;

$export($export.S, 'Math', {
  hypot: function hypot(value1, value2){ // eslint-disable-line no-unused-vars
    var sum   = 0
      , i     = 0
      , $$    = arguments
      , $$len = $$.length
      , larg  = 0
      , arg, div;
    while(i < $$len){
      arg = abs($$[i++]);
      if(larg < arg){
        div  = larg / arg;
        sum  = sum * div * div + 1;
        larg = arg;
      } else if(arg > 0){
        div  = arg / larg;
        sum += div * div;
      } else sum += arg;
    }
    return larg === Infinity ? Infinity : larg * Math.sqrt(sum);
  }
});
},{"./$.export":22}],106:[function(require,module,exports){
// 20.2.2.18 Math.imul(x, y)
var $export = require('./$.export')
  , $imul   = Math.imul;

// some WebKit versions fails with big numbers, some has wrong arity
$export($export.S + $export.F * require('./$.fails')(function(){
  return $imul(0xffffffff, 5) != -5 || $imul.length != 2;
}), 'Math', {
  imul: function imul(x, y){
    var UINT16 = 0xffff
      , xn = +x
      , yn = +y
      , xl = UINT16 & xn
      , yl = UINT16 & yn;
    return 0 | xl * yl + ((UINT16 & xn >>> 16) * yl + xl * (UINT16 & yn >>> 16) << 16 >>> 0);
  }
});
},{"./$.export":22,"./$.fails":24}],107:[function(require,module,exports){
// 20.2.2.21 Math.log10(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  log10: function log10(x){
    return Math.log(x) / Math.LN10;
  }
});
},{"./$.export":22}],108:[function(require,module,exports){
// 20.2.2.20 Math.log1p(x)
var $export = require('./$.export');

$export($export.S, 'Math', {log1p: require('./$.math-log1p')});
},{"./$.export":22,"./$.math-log1p":50}],109:[function(require,module,exports){
// 20.2.2.22 Math.log2(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  log2: function log2(x){
    return Math.log(x) / Math.LN2;
  }
});
},{"./$.export":22}],110:[function(require,module,exports){
// 20.2.2.28 Math.sign(x)
var $export = require('./$.export');

$export($export.S, 'Math', {sign: require('./$.math-sign')});
},{"./$.export":22,"./$.math-sign":51}],111:[function(require,module,exports){
// 20.2.2.30 Math.sinh(x)
var $export = require('./$.export')
  , expm1   = require('./$.math-expm1')
  , exp     = Math.exp;

// V8 near Chromium 38 has a problem with very small numbers
$export($export.S + $export.F * require('./$.fails')(function(){
  return !Math.sinh(-2e-17) != -2e-17;
}), 'Math', {
  sinh: function sinh(x){
    return Math.abs(x = +x) < 1
      ? (expm1(x) - expm1(-x)) / 2
      : (exp(x - 1) - exp(-x - 1)) * (Math.E / 2);
  }
});
},{"./$.export":22,"./$.fails":24,"./$.math-expm1":49}],112:[function(require,module,exports){
// 20.2.2.33 Math.tanh(x)
var $export = require('./$.export')
  , expm1   = require('./$.math-expm1')
  , exp     = Math.exp;

$export($export.S, 'Math', {
  tanh: function tanh(x){
    var a = expm1(x = +x)
      , b = expm1(-x);
    return a == Infinity ? 1 : b == Infinity ? -1 : (a - b) / (exp(x) + exp(-x));
  }
});
},{"./$.export":22,"./$.math-expm1":49}],113:[function(require,module,exports){
// 20.2.2.34 Math.trunc(x)
var $export = require('./$.export');

$export($export.S, 'Math', {
  trunc: function trunc(it){
    return (it > 0 ? Math.floor : Math.ceil)(it);
  }
});
},{"./$.export":22}],114:[function(require,module,exports){
'use strict';
var $           = require('./$')
  , global      = require('./$.global')
  , has         = require('./$.has')
  , cof         = require('./$.cof')
  , toPrimitive = require('./$.to-primitive')
  , fails       = require('./$.fails')
  , $trim       = require('./$.string-trim').trim
  , NUMBER      = 'Number'
  , $Number     = global[NUMBER]
  , Base        = $Number
  , proto       = $Number.prototype
  // Opera ~12 has broken Object#toString
  , BROKEN_COF  = cof($.create(proto)) == NUMBER
  , TRIM        = 'trim' in String.prototype;

// 7.1.3 ToNumber(argument)
var toNumber = function(argument){
  var it = toPrimitive(argument, false);
  if(typeof it == 'string' && it.length > 2){
    it = TRIM ? it.trim() : $trim(it, 3);
    var first = it.charCodeAt(0)
      , third, radix, maxCode;
    if(first === 43 || first === 45){
      third = it.charCodeAt(2);
      if(third === 88 || third === 120)return NaN; // Number('+0x1') should be NaN, old V8 fix
    } else if(first === 48){
      switch(it.charCodeAt(1)){
        case 66 : case 98  : radix = 2; maxCode = 49; break; // fast equal /^0b[01]+$/i
        case 79 : case 111 : radix = 8; maxCode = 55; break; // fast equal /^0o[0-7]+$/i
        default : return +it;
      }
      for(var digits = it.slice(2), i = 0, l = digits.length, code; i < l; i++){
        code = digits.charCodeAt(i);
        // parseInt parses a string to a first unavailable symbol
        // but ToNumber should return NaN if a string contains unavailable symbols
        if(code < 48 || code > maxCode)return NaN;
      } return parseInt(digits, radix);
    }
  } return +it;
};

if(!$Number(' 0o1') || !$Number('0b1') || $Number('+0x1')){
  $Number = function Number(value){
    var it = arguments.length < 1 ? 0 : value
      , that = this;
    return that instanceof $Number
      // check on 1..constructor(foo) case
      && (BROKEN_COF ? fails(function(){ proto.valueOf.call(that); }) : cof(that) != NUMBER)
        ? new Base(toNumber(it)) : toNumber(it);
  };
  $.each.call(require('./$.descriptors') ? $.getNames(Base) : (
    // ES3:
    'MAX_VALUE,MIN_VALUE,NaN,NEGATIVE_INFINITY,POSITIVE_INFINITY,' +
    // ES6 (in case, if modules with ES6 Number statics required before):
    'EPSILON,isFinite,isInteger,isNaN,isSafeInteger,MAX_SAFE_INTEGER,' +
    'MIN_SAFE_INTEGER,parseFloat,parseInt,isInteger'
  ).split(','), function(key){
    if(has(Base, key) && !has($Number, key)){
      $.setDesc($Number, key, $.getDesc(Base, key));
    }
  });
  $Number.prototype = proto;
  proto.constructor = $Number;
  require('./$.redefine')(global, NUMBER, $Number);
}
},{"./$":46,"./$.cof":11,"./$.descriptors":19,"./$.fails":24,"./$.global":29,"./$.has":30,"./$.redefine":61,"./$.string-trim":74,"./$.to-primitive":81}],115:[function(require,module,exports){
// 20.1.2.1 Number.EPSILON
var $export = require('./$.export');

$export($export.S, 'Number', {EPSILON: Math.pow(2, -52)});
},{"./$.export":22}],116:[function(require,module,exports){
// 20.1.2.2 Number.isFinite(number)
var $export   = require('./$.export')
  , _isFinite = require('./$.global').isFinite;

$export($export.S, 'Number', {
  isFinite: function isFinite(it){
    return typeof it == 'number' && _isFinite(it);
  }
});
},{"./$.export":22,"./$.global":29}],117:[function(require,module,exports){
// 20.1.2.3 Number.isInteger(number)
var $export = require('./$.export');

$export($export.S, 'Number', {isInteger: require('./$.is-integer')});
},{"./$.export":22,"./$.is-integer":37}],118:[function(require,module,exports){
// 20.1.2.4 Number.isNaN(number)
var $export = require('./$.export');

$export($export.S, 'Number', {
  isNaN: function isNaN(number){
    return number != number;
  }
});
},{"./$.export":22}],119:[function(require,module,exports){
// 20.1.2.5 Number.isSafeInteger(number)
var $export   = require('./$.export')
  , isInteger = require('./$.is-integer')
  , abs       = Math.abs;

$export($export.S, 'Number', {
  isSafeInteger: function isSafeInteger(number){
    return isInteger(number) && abs(number) <= 0x1fffffffffffff;
  }
});
},{"./$.export":22,"./$.is-integer":37}],120:[function(require,module,exports){
// 20.1.2.6 Number.MAX_SAFE_INTEGER
var $export = require('./$.export');

$export($export.S, 'Number', {MAX_SAFE_INTEGER: 0x1fffffffffffff});
},{"./$.export":22}],121:[function(require,module,exports){
// 20.1.2.10 Number.MIN_SAFE_INTEGER
var $export = require('./$.export');

$export($export.S, 'Number', {MIN_SAFE_INTEGER: -0x1fffffffffffff});
},{"./$.export":22}],122:[function(require,module,exports){
// 20.1.2.12 Number.parseFloat(string)
var $export = require('./$.export');

$export($export.S, 'Number', {parseFloat: parseFloat});
},{"./$.export":22}],123:[function(require,module,exports){
// 20.1.2.13 Number.parseInt(string, radix)
var $export = require('./$.export');

$export($export.S, 'Number', {parseInt: parseInt});
},{"./$.export":22}],124:[function(require,module,exports){
// 19.1.3.1 Object.assign(target, source)
var $export = require('./$.export');

$export($export.S + $export.F, 'Object', {assign: require('./$.object-assign')});
},{"./$.export":22,"./$.object-assign":53}],125:[function(require,module,exports){
// 19.1.2.5 Object.freeze(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('freeze', function($freeze){
  return function freeze(it){
    return $freeze && isObject(it) ? $freeze(it) : it;
  };
});
},{"./$.is-object":38,"./$.object-sap":54}],126:[function(require,module,exports){
// 19.1.2.6 Object.getOwnPropertyDescriptor(O, P)
var toIObject = require('./$.to-iobject');

require('./$.object-sap')('getOwnPropertyDescriptor', function($getOwnPropertyDescriptor){
  return function getOwnPropertyDescriptor(it, key){
    return $getOwnPropertyDescriptor(toIObject(it), key);
  };
});
},{"./$.object-sap":54,"./$.to-iobject":78}],127:[function(require,module,exports){
// 19.1.2.7 Object.getOwnPropertyNames(O)
require('./$.object-sap')('getOwnPropertyNames', function(){
  return require('./$.get-names').get;
});
},{"./$.get-names":28,"./$.object-sap":54}],128:[function(require,module,exports){
// 19.1.2.9 Object.getPrototypeOf(O)
var toObject = require('./$.to-object');

require('./$.object-sap')('getPrototypeOf', function($getPrototypeOf){
  return function getPrototypeOf(it){
    return $getPrototypeOf(toObject(it));
  };
});
},{"./$.object-sap":54,"./$.to-object":80}],129:[function(require,module,exports){
// 19.1.2.11 Object.isExtensible(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('isExtensible', function($isExtensible){
  return function isExtensible(it){
    return isObject(it) ? $isExtensible ? $isExtensible(it) : true : false;
  };
});
},{"./$.is-object":38,"./$.object-sap":54}],130:[function(require,module,exports){
// 19.1.2.12 Object.isFrozen(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('isFrozen', function($isFrozen){
  return function isFrozen(it){
    return isObject(it) ? $isFrozen ? $isFrozen(it) : false : true;
  };
});
},{"./$.is-object":38,"./$.object-sap":54}],131:[function(require,module,exports){
// 19.1.2.13 Object.isSealed(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('isSealed', function($isSealed){
  return function isSealed(it){
    return isObject(it) ? $isSealed ? $isSealed(it) : false : true;
  };
});
},{"./$.is-object":38,"./$.object-sap":54}],132:[function(require,module,exports){
// 19.1.3.10 Object.is(value1, value2)
var $export = require('./$.export');
$export($export.S, 'Object', {is: require('./$.same-value')});
},{"./$.export":22,"./$.same-value":63}],133:[function(require,module,exports){
// 19.1.2.14 Object.keys(O)
var toObject = require('./$.to-object');

require('./$.object-sap')('keys', function($keys){
  return function keys(it){
    return $keys(toObject(it));
  };
});
},{"./$.object-sap":54,"./$.to-object":80}],134:[function(require,module,exports){
// 19.1.2.15 Object.preventExtensions(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('preventExtensions', function($preventExtensions){
  return function preventExtensions(it){
    return $preventExtensions && isObject(it) ? $preventExtensions(it) : it;
  };
});
},{"./$.is-object":38,"./$.object-sap":54}],135:[function(require,module,exports){
// 19.1.2.17 Object.seal(O)
var isObject = require('./$.is-object');

require('./$.object-sap')('seal', function($seal){
  return function seal(it){
    return $seal && isObject(it) ? $seal(it) : it;
  };
});
},{"./$.is-object":38,"./$.object-sap":54}],136:[function(require,module,exports){
// 19.1.3.19 Object.setPrototypeOf(O, proto)
var $export = require('./$.export');
$export($export.S, 'Object', {setPrototypeOf: require('./$.set-proto').set});
},{"./$.export":22,"./$.set-proto":64}],137:[function(require,module,exports){
'use strict';
// 19.1.3.6 Object.prototype.toString()
var classof = require('./$.classof')
  , test    = {};
test[require('./$.wks')('toStringTag')] = 'z';
if(test + '' != '[object z]'){
  require('./$.redefine')(Object.prototype, 'toString', function toString(){
    return '[object ' + classof(this) + ']';
  }, true);
}
},{"./$.classof":10,"./$.redefine":61,"./$.wks":83}],138:[function(require,module,exports){
'use strict';
var $          = require('./$')
  , LIBRARY    = require('./$.library')
  , global     = require('./$.global')
  , ctx        = require('./$.ctx')
  , classof    = require('./$.classof')
  , $export    = require('./$.export')
  , isObject   = require('./$.is-object')
  , anObject   = require('./$.an-object')
  , aFunction  = require('./$.a-function')
  , strictNew  = require('./$.strict-new')
  , forOf      = require('./$.for-of')
  , setProto   = require('./$.set-proto').set
  , same       = require('./$.same-value')
  , SPECIES    = require('./$.wks')('species')
  , speciesConstructor = require('./$.species-constructor')
  , asap       = require('./$.microtask')
  , PROMISE    = 'Promise'
  , process    = global.process
  , isNode     = classof(process) == 'process'
  , P          = global[PROMISE]
  , Wrapper;

var testResolve = function(sub){
  var test = new P(function(){});
  if(sub)test.constructor = Object;
  return P.resolve(test) === test;
};

var USE_NATIVE = function(){
  var works = false;
  function P2(x){
    var self = new P(x);
    setProto(self, P2.prototype);
    return self;
  }
  try {
    works = P && P.resolve && testResolve();
    setProto(P2, P);
    P2.prototype = $.create(P.prototype, {constructor: {value: P2}});
    // actual Firefox has broken subclass support, test that
    if(!(P2.resolve(5).then(function(){}) instanceof P2)){
      works = false;
    }
    // actual V8 bug, https://code.google.com/p/v8/issues/detail?id=4162
    if(works && require('./$.descriptors')){
      var thenableThenGotten = false;
      P.resolve($.setDesc({}, 'then', {
        get: function(){ thenableThenGotten = true; }
      }));
      works = thenableThenGotten;
    }
  } catch(e){ works = false; }
  return works;
}();

// helpers
var sameConstructor = function(a, b){
  // library wrapper special case
  if(LIBRARY && a === P && b === Wrapper)return true;
  return same(a, b);
};
var getConstructor = function(C){
  var S = anObject(C)[SPECIES];
  return S != undefined ? S : C;
};
var isThenable = function(it){
  var then;
  return isObject(it) && typeof (then = it.then) == 'function' ? then : false;
};
var PromiseCapability = function(C){
  var resolve, reject;
  this.promise = new C(function($$resolve, $$reject){
    if(resolve !== undefined || reject !== undefined)throw TypeError('Bad Promise constructor');
    resolve = $$resolve;
    reject  = $$reject;
  });
  this.resolve = aFunction(resolve),
  this.reject  = aFunction(reject)
};
var perform = function(exec){
  try {
    exec();
  } catch(e){
    return {error: e};
  }
};
var notify = function(record, isReject){
  if(record.n)return;
  record.n = true;
  var chain = record.c;
  asap(function(){
    var value = record.v
      , ok    = record.s == 1
      , i     = 0;
    var run = function(reaction){
      var handler = ok ? reaction.ok : reaction.fail
        , resolve = reaction.resolve
        , reject  = reaction.reject
        , result, then;
      try {
        if(handler){
          if(!ok)record.h = true;
          result = handler === true ? value : handler(value);
          if(result === reaction.promise){
            reject(TypeError('Promise-chain cycle'));
          } else if(then = isThenable(result)){
            then.call(result, resolve, reject);
          } else resolve(result);
        } else reject(value);
      } catch(e){
        reject(e);
      }
    };
    while(chain.length > i)run(chain[i++]); // variable length - can't use forEach
    chain.length = 0;
    record.n = false;
    if(isReject)setTimeout(function(){
      var promise = record.p
        , handler, console;
      if(isUnhandled(promise)){
        if(isNode){
          process.emit('unhandledRejection', value, promise);
        } else if(handler = global.onunhandledrejection){
          handler({promise: promise, reason: value});
        } else if((console = global.console) && console.error){
          console.error('Unhandled promise rejection', value);
        }
      } record.a = undefined;
    }, 1);
  });
};
var isUnhandled = function(promise){
  var record = promise._d
    , chain  = record.a || record.c
    , i      = 0
    , reaction;
  if(record.h)return false;
  while(chain.length > i){
    reaction = chain[i++];
    if(reaction.fail || !isUnhandled(reaction.promise))return false;
  } return true;
};
var $reject = function(value){
  var record = this;
  if(record.d)return;
  record.d = true;
  record = record.r || record; // unwrap
  record.v = value;
  record.s = 2;
  record.a = record.c.slice();
  notify(record, true);
};
var $resolve = function(value){
  var record = this
    , then;
  if(record.d)return;
  record.d = true;
  record = record.r || record; // unwrap
  try {
    if(record.p === value)throw TypeError("Promise can't be resolved itself");
    if(then = isThenable(value)){
      asap(function(){
        var wrapper = {r: record, d: false}; // wrap
        try {
          then.call(value, ctx($resolve, wrapper, 1), ctx($reject, wrapper, 1));
        } catch(e){
          $reject.call(wrapper, e);
        }
      });
    } else {
      record.v = value;
      record.s = 1;
      notify(record, false);
    }
  } catch(e){
    $reject.call({r: record, d: false}, e); // wrap
  }
};

// constructor polyfill
if(!USE_NATIVE){
  // 25.4.3.1 Promise(executor)
  P = function Promise(executor){
    aFunction(executor);
    var record = this._d = {
      p: strictNew(this, P, PROMISE),         // <- promise
      c: [],                                  // <- awaiting reactions
      a: undefined,                           // <- checked in isUnhandled reactions
      s: 0,                                   // <- state
      d: false,                               // <- done
      v: undefined,                           // <- value
      h: false,                               // <- handled rejection
      n: false                                // <- notify
    };
    try {
      executor(ctx($resolve, record, 1), ctx($reject, record, 1));
    } catch(err){
      $reject.call(record, err);
    }
  };
  require('./$.redefine-all')(P.prototype, {
    // 25.4.5.3 Promise.prototype.then(onFulfilled, onRejected)
    then: function then(onFulfilled, onRejected){
      var reaction = new PromiseCapability(speciesConstructor(this, P))
        , promise  = reaction.promise
        , record   = this._d;
      reaction.ok   = typeof onFulfilled == 'function' ? onFulfilled : true;
      reaction.fail = typeof onRejected == 'function' && onRejected;
      record.c.push(reaction);
      if(record.a)record.a.push(reaction);
      if(record.s)notify(record, false);
      return promise;
    },
    // 25.4.5.1 Promise.prototype.catch(onRejected)
    'catch': function(onRejected){
      return this.then(undefined, onRejected);
    }
  });
}

$export($export.G + $export.W + $export.F * !USE_NATIVE, {Promise: P});
require('./$.set-to-string-tag')(P, PROMISE);
require('./$.set-species')(PROMISE);
Wrapper = require('./$.core')[PROMISE];

// statics
$export($export.S + $export.F * !USE_NATIVE, PROMISE, {
  // 25.4.4.5 Promise.reject(r)
  reject: function reject(r){
    var capability = new PromiseCapability(this)
      , $$reject   = capability.reject;
    $$reject(r);
    return capability.promise;
  }
});
$export($export.S + $export.F * (!USE_NATIVE || testResolve(true)), PROMISE, {
  // 25.4.4.6 Promise.resolve(x)
  resolve: function resolve(x){
    // instanceof instead of internal slot check because we should fix it without replacement native Promise core
    if(x instanceof P && sameConstructor(x.constructor, this))return x;
    var capability = new PromiseCapability(this)
      , $$resolve  = capability.resolve;
    $$resolve(x);
    return capability.promise;
  }
});
$export($export.S + $export.F * !(USE_NATIVE && require('./$.iter-detect')(function(iter){
  P.all(iter)['catch'](function(){});
})), PROMISE, {
  // 25.4.4.1 Promise.all(iterable)
  all: function all(iterable){
    var C          = getConstructor(this)
      , capability = new PromiseCapability(C)
      , resolve    = capability.resolve
      , reject     = capability.reject
      , values     = [];
    var abrupt = perform(function(){
      forOf(iterable, false, values.push, values);
      var remaining = values.length
        , results   = Array(remaining);
      if(remaining)$.each.call(values, function(promise, index){
        var alreadyCalled = false;
        C.resolve(promise).then(function(value){
          if(alreadyCalled)return;
          alreadyCalled = true;
          results[index] = value;
          --remaining || resolve(results);
        }, reject);
      });
      else resolve(results);
    });
    if(abrupt)reject(abrupt.error);
    return capability.promise;
  },
  // 25.4.4.4 Promise.race(iterable)
  race: function race(iterable){
    var C          = getConstructor(this)
      , capability = new PromiseCapability(C)
      , reject     = capability.reject;
    var abrupt = perform(function(){
      forOf(iterable, false, function(promise){
        C.resolve(promise).then(capability.resolve, reject);
      });
    });
    if(abrupt)reject(abrupt.error);
    return capability.promise;
  }
});
},{"./$":46,"./$.a-function":2,"./$.an-object":4,"./$.classof":10,"./$.core":16,"./$.ctx":17,"./$.descriptors":19,"./$.export":22,"./$.for-of":27,"./$.global":29,"./$.is-object":38,"./$.iter-detect":43,"./$.library":48,"./$.microtask":52,"./$.redefine-all":60,"./$.same-value":63,"./$.set-proto":64,"./$.set-species":65,"./$.set-to-string-tag":66,"./$.species-constructor":68,"./$.strict-new":69,"./$.wks":83}],139:[function(require,module,exports){
// 26.1.1 Reflect.apply(target, thisArgument, argumentsList)
var $export = require('./$.export')
  , _apply  = Function.apply;

$export($export.S, 'Reflect', {
  apply: function apply(target, thisArgument, argumentsList){
    return _apply.call(target, thisArgument, argumentsList);
  }
});
},{"./$.export":22}],140:[function(require,module,exports){
// 26.1.2 Reflect.construct(target, argumentsList [, newTarget])
var $         = require('./$')
  , $export   = require('./$.export')
  , aFunction = require('./$.a-function')
  , anObject  = require('./$.an-object')
  , isObject  = require('./$.is-object')
  , bind      = Function.bind || require('./$.core').Function.prototype.bind;

// MS Edge supports only 2 arguments
// FF Nightly sets third argument as `new.target`, but does not create `this` from it
$export($export.S + $export.F * require('./$.fails')(function(){
  function F(){}
  return !(Reflect.construct(function(){}, [], F) instanceof F);
}), 'Reflect', {
  construct: function construct(Target, args /*, newTarget*/){
    aFunction(Target);
    var newTarget = arguments.length < 3 ? Target : aFunction(arguments[2]);
    if(Target == newTarget){
      // w/o altered newTarget, optimization for 0-4 arguments
      if(args != undefined)switch(anObject(args).length){
        case 0: return new Target;
        case 1: return new Target(args[0]);
        case 2: return new Target(args[0], args[1]);
        case 3: return new Target(args[0], args[1], args[2]);
        case 4: return new Target(args[0], args[1], args[2], args[3]);
      }
      // w/o altered newTarget, lot of arguments case
      var $args = [null];
      $args.push.apply($args, args);
      return new (bind.apply(Target, $args));
    }
    // with altered newTarget, not support built-in constructors
    var proto    = newTarget.prototype
      , instance = $.create(isObject(proto) ? proto : Object.prototype)
      , result   = Function.apply.call(Target, instance, args);
    return isObject(result) ? result : instance;
  }
});
},{"./$":46,"./$.a-function":2,"./$.an-object":4,"./$.core":16,"./$.export":22,"./$.fails":24,"./$.is-object":38}],141:[function(require,module,exports){
// 26.1.3 Reflect.defineProperty(target, propertyKey, attributes)
var $        = require('./$')
  , $export  = require('./$.export')
  , anObject = require('./$.an-object');

// MS Edge has broken Reflect.defineProperty - throwing instead of returning false
$export($export.S + $export.F * require('./$.fails')(function(){
  Reflect.defineProperty($.setDesc({}, 1, {value: 1}), 1, {value: 2});
}), 'Reflect', {
  defineProperty: function defineProperty(target, propertyKey, attributes){
    anObject(target);
    try {
      $.setDesc(target, propertyKey, attributes);
      return true;
    } catch(e){
      return false;
    }
  }
});
},{"./$":46,"./$.an-object":4,"./$.export":22,"./$.fails":24}],142:[function(require,module,exports){
// 26.1.4 Reflect.deleteProperty(target, propertyKey)
var $export  = require('./$.export')
  , getDesc  = require('./$').getDesc
  , anObject = require('./$.an-object');

$export($export.S, 'Reflect', {
  deleteProperty: function deleteProperty(target, propertyKey){
    var desc = getDesc(anObject(target), propertyKey);
    return desc && !desc.configurable ? false : delete target[propertyKey];
  }
});
},{"./$":46,"./$.an-object":4,"./$.export":22}],143:[function(require,module,exports){
'use strict';
// 26.1.5 Reflect.enumerate(target)
var $export  = require('./$.export')
  , anObject = require('./$.an-object');
var Enumerate = function(iterated){
  this._t = anObject(iterated); // target
  this._i = 0;                  // next index
  var keys = this._k = []       // keys
    , key;
  for(key in iterated)keys.push(key);
};
require('./$.iter-create')(Enumerate, 'Object', function(){
  var that = this
    , keys = that._k
    , key;
  do {
    if(that._i >= keys.length)return {value: undefined, done: true};
  } while(!((key = keys[that._i++]) in that._t));
  return {value: key, done: false};
});

$export($export.S, 'Reflect', {
  enumerate: function enumerate(target){
    return new Enumerate(target);
  }
});
},{"./$.an-object":4,"./$.export":22,"./$.iter-create":41}],144:[function(require,module,exports){
// 26.1.7 Reflect.getOwnPropertyDescriptor(target, propertyKey)
var $        = require('./$')
  , $export  = require('./$.export')
  , anObject = require('./$.an-object');

$export($export.S, 'Reflect', {
  getOwnPropertyDescriptor: function getOwnPropertyDescriptor(target, propertyKey){
    return $.getDesc(anObject(target), propertyKey);
  }
});
},{"./$":46,"./$.an-object":4,"./$.export":22}],145:[function(require,module,exports){
// 26.1.8 Reflect.getPrototypeOf(target)
var $export  = require('./$.export')
  , getProto = require('./$').getProto
  , anObject = require('./$.an-object');

$export($export.S, 'Reflect', {
  getPrototypeOf: function getPrototypeOf(target){
    return getProto(anObject(target));
  }
});
},{"./$":46,"./$.an-object":4,"./$.export":22}],146:[function(require,module,exports){
// 26.1.6 Reflect.get(target, propertyKey [, receiver])
var $        = require('./$')
  , has      = require('./$.has')
  , $export  = require('./$.export')
  , isObject = require('./$.is-object')
  , anObject = require('./$.an-object');

function get(target, propertyKey/*, receiver*/){
  var receiver = arguments.length < 3 ? target : arguments[2]
    , desc, proto;
  if(anObject(target) === receiver)return target[propertyKey];
  if(desc = $.getDesc(target, propertyKey))return has(desc, 'value')
    ? desc.value
    : desc.get !== undefined
      ? desc.get.call(receiver)
      : undefined;
  if(isObject(proto = $.getProto(target)))return get(proto, propertyKey, receiver);
}

$export($export.S, 'Reflect', {get: get});
},{"./$":46,"./$.an-object":4,"./$.export":22,"./$.has":30,"./$.is-object":38}],147:[function(require,module,exports){
// 26.1.9 Reflect.has(target, propertyKey)
var $export = require('./$.export');

$export($export.S, 'Reflect', {
  has: function has(target, propertyKey){
    return propertyKey in target;
  }
});
},{"./$.export":22}],148:[function(require,module,exports){
// 26.1.10 Reflect.isExtensible(target)
var $export       = require('./$.export')
  , anObject      = require('./$.an-object')
  , $isExtensible = Object.isExtensible;

$export($export.S, 'Reflect', {
  isExtensible: function isExtensible(target){
    anObject(target);
    return $isExtensible ? $isExtensible(target) : true;
  }
});
},{"./$.an-object":4,"./$.export":22}],149:[function(require,module,exports){
// 26.1.11 Reflect.ownKeys(target)
var $export = require('./$.export');

$export($export.S, 'Reflect', {ownKeys: require('./$.own-keys')});
},{"./$.export":22,"./$.own-keys":56}],150:[function(require,module,exports){
// 26.1.12 Reflect.preventExtensions(target)
var $export            = require('./$.export')
  , anObject           = require('./$.an-object')
  , $preventExtensions = Object.preventExtensions;

$export($export.S, 'Reflect', {
  preventExtensions: function preventExtensions(target){
    anObject(target);
    try {
      if($preventExtensions)$preventExtensions(target);
      return true;
    } catch(e){
      return false;
    }
  }
});
},{"./$.an-object":4,"./$.export":22}],151:[function(require,module,exports){
// 26.1.14 Reflect.setPrototypeOf(target, proto)
var $export  = require('./$.export')
  , setProto = require('./$.set-proto');

if(setProto)$export($export.S, 'Reflect', {
  setPrototypeOf: function setPrototypeOf(target, proto){
    setProto.check(target, proto);
    try {
      setProto.set(target, proto);
      return true;
    } catch(e){
      return false;
    }
  }
});
},{"./$.export":22,"./$.set-proto":64}],152:[function(require,module,exports){
// 26.1.13 Reflect.set(target, propertyKey, V [, receiver])
var $          = require('./$')
  , has        = require('./$.has')
  , $export    = require('./$.export')
  , createDesc = require('./$.property-desc')
  , anObject   = require('./$.an-object')
  , isObject   = require('./$.is-object');

function set(target, propertyKey, V/*, receiver*/){
  var receiver = arguments.length < 4 ? target : arguments[3]
    , ownDesc  = $.getDesc(anObject(target), propertyKey)
    , existingDescriptor, proto;
  if(!ownDesc){
    if(isObject(proto = $.getProto(target))){
      return set(proto, propertyKey, V, receiver);
    }
    ownDesc = createDesc(0);
  }
  if(has(ownDesc, 'value')){
    if(ownDesc.writable === false || !isObject(receiver))return false;
    existingDescriptor = $.getDesc(receiver, propertyKey) || createDesc(0);
    existingDescriptor.value = V;
    $.setDesc(receiver, propertyKey, existingDescriptor);
    return true;
  }
  return ownDesc.set === undefined ? false : (ownDesc.set.call(receiver, V), true);
}

$export($export.S, 'Reflect', {set: set});
},{"./$":46,"./$.an-object":4,"./$.export":22,"./$.has":30,"./$.is-object":38,"./$.property-desc":59}],153:[function(require,module,exports){
var $        = require('./$')
  , global   = require('./$.global')
  , isRegExp = require('./$.is-regexp')
  , $flags   = require('./$.flags')
  , $RegExp  = global.RegExp
  , Base     = $RegExp
  , proto    = $RegExp.prototype
  , re1      = /a/g
  , re2      = /a/g
  // "new" creates a new object, old webkit buggy here
  , CORRECT_NEW = new $RegExp(re1) !== re1;

if(require('./$.descriptors') && (!CORRECT_NEW || require('./$.fails')(function(){
  re2[require('./$.wks')('match')] = false;
  // RegExp constructor can alter flags and IsRegExp works correct with @@match
  return $RegExp(re1) != re1 || $RegExp(re2) == re2 || $RegExp(re1, 'i') != '/a/i';
}))){
  $RegExp = function RegExp(p, f){
    var piRE = isRegExp(p)
      , fiU  = f === undefined;
    return !(this instanceof $RegExp) && piRE && p.constructor === $RegExp && fiU ? p
      : CORRECT_NEW
        ? new Base(piRE && !fiU ? p.source : p, f)
        : Base((piRE = p instanceof $RegExp) ? p.source : p, piRE && fiU ? $flags.call(p) : f);
  };
  $.each.call($.getNames(Base), function(key){
    key in $RegExp || $.setDesc($RegExp, key, {
      configurable: true,
      get: function(){ return Base[key]; },
      set: function(it){ Base[key] = it; }
    });
  });
  proto.constructor = $RegExp;
  $RegExp.prototype = proto;
  require('./$.redefine')(global, 'RegExp', $RegExp);
}

require('./$.set-species')('RegExp');
},{"./$":46,"./$.descriptors":19,"./$.fails":24,"./$.flags":26,"./$.global":29,"./$.is-regexp":39,"./$.redefine":61,"./$.set-species":65,"./$.wks":83}],154:[function(require,module,exports){
// 21.2.5.3 get RegExp.prototype.flags()
var $ = require('./$');
if(require('./$.descriptors') && /./g.flags != 'g')$.setDesc(RegExp.prototype, 'flags', {
  configurable: true,
  get: require('./$.flags')
});
},{"./$":46,"./$.descriptors":19,"./$.flags":26}],155:[function(require,module,exports){
// @@match logic
require('./$.fix-re-wks')('match', 1, function(defined, MATCH){
  // 21.1.3.11 String.prototype.match(regexp)
  return function match(regexp){
    'use strict';
    var O  = defined(this)
      , fn = regexp == undefined ? undefined : regexp[MATCH];
    return fn !== undefined ? fn.call(regexp, O) : new RegExp(regexp)[MATCH](String(O));
  };
});
},{"./$.fix-re-wks":25}],156:[function(require,module,exports){
// @@replace logic
require('./$.fix-re-wks')('replace', 2, function(defined, REPLACE, $replace){
  // 21.1.3.14 String.prototype.replace(searchValue, replaceValue)
  return function replace(searchValue, replaceValue){
    'use strict';
    var O  = defined(this)
      , fn = searchValue == undefined ? undefined : searchValue[REPLACE];
    return fn !== undefined
      ? fn.call(searchValue, O, replaceValue)
      : $replace.call(String(O), searchValue, replaceValue);
  };
});
},{"./$.fix-re-wks":25}],157:[function(require,module,exports){
// @@search logic
require('./$.fix-re-wks')('search', 1, function(defined, SEARCH){
  // 21.1.3.15 String.prototype.search(regexp)
  return function search(regexp){
    'use strict';
    var O  = defined(this)
      , fn = regexp == undefined ? undefined : regexp[SEARCH];
    return fn !== undefined ? fn.call(regexp, O) : new RegExp(regexp)[SEARCH](String(O));
  };
});
},{"./$.fix-re-wks":25}],158:[function(require,module,exports){
// @@split logic
require('./$.fix-re-wks')('split', 2, function(defined, SPLIT, $split){
  // 21.1.3.17 String.prototype.split(separator, limit)
  return function split(separator, limit){
    'use strict';
    var O  = defined(this)
      , fn = separator == undefined ? undefined : separator[SPLIT];
    return fn !== undefined
      ? fn.call(separator, O, limit)
      : $split.call(String(O), separator, limit);
  };
});
},{"./$.fix-re-wks":25}],159:[function(require,module,exports){
'use strict';
var strong = require('./$.collection-strong');

// 23.2 Set Objects
require('./$.collection')('Set', function(get){
  return function Set(){ return get(this, arguments.length > 0 ? arguments[0] : undefined); };
}, {
  // 23.2.3.1 Set.prototype.add(value)
  add: function add(value){
    return strong.def(this, value = value === 0 ? 0 : value, value);
  }
}, strong);
},{"./$.collection":15,"./$.collection-strong":12}],160:[function(require,module,exports){
'use strict';
var $export = require('./$.export')
  , $at     = require('./$.string-at')(false);
$export($export.P, 'String', {
  // 21.1.3.3 String.prototype.codePointAt(pos)
  codePointAt: function codePointAt(pos){
    return $at(this, pos);
  }
});
},{"./$.export":22,"./$.string-at":70}],161:[function(require,module,exports){
// 21.1.3.6 String.prototype.endsWith(searchString [, endPosition])
'use strict';
var $export   = require('./$.export')
  , toLength  = require('./$.to-length')
  , context   = require('./$.string-context')
  , ENDS_WITH = 'endsWith'
  , $endsWith = ''[ENDS_WITH];

$export($export.P + $export.F * require('./$.fails-is-regexp')(ENDS_WITH), 'String', {
  endsWith: function endsWith(searchString /*, endPosition = @length */){
    var that = context(this, searchString, ENDS_WITH)
      , $$   = arguments
      , endPosition = $$.length > 1 ? $$[1] : undefined
      , len    = toLength(that.length)
      , end    = endPosition === undefined ? len : Math.min(toLength(endPosition), len)
      , search = String(searchString);
    return $endsWith
      ? $endsWith.call(that, search, end)
      : that.slice(end - search.length, end) === search;
  }
});
},{"./$.export":22,"./$.fails-is-regexp":23,"./$.string-context":71,"./$.to-length":79}],162:[function(require,module,exports){
var $export        = require('./$.export')
  , toIndex        = require('./$.to-index')
  , fromCharCode   = String.fromCharCode
  , $fromCodePoint = String.fromCodePoint;

// length should be 1, old FF problem
$export($export.S + $export.F * (!!$fromCodePoint && $fromCodePoint.length != 1), 'String', {
  // 21.1.2.2 String.fromCodePoint(...codePoints)
  fromCodePoint: function fromCodePoint(x){ // eslint-disable-line no-unused-vars
    var res   = []
      , $$    = arguments
      , $$len = $$.length
      , i     = 0
      , code;
    while($$len > i){
      code = +$$[i++];
      if(toIndex(code, 0x10ffff) !== code)throw RangeError(code + ' is not a valid code point');
      res.push(code < 0x10000
        ? fromCharCode(code)
        : fromCharCode(((code -= 0x10000) >> 10) + 0xd800, code % 0x400 + 0xdc00)
      );
    } return res.join('');
  }
});
},{"./$.export":22,"./$.to-index":76}],163:[function(require,module,exports){
// 21.1.3.7 String.prototype.includes(searchString, position = 0)
'use strict';
var $export  = require('./$.export')
  , context  = require('./$.string-context')
  , INCLUDES = 'includes';

$export($export.P + $export.F * require('./$.fails-is-regexp')(INCLUDES), 'String', {
  includes: function includes(searchString /*, position = 0 */){
    return !!~context(this, searchString, INCLUDES)
      .indexOf(searchString, arguments.length > 1 ? arguments[1] : undefined);
  }
});
},{"./$.export":22,"./$.fails-is-regexp":23,"./$.string-context":71}],164:[function(require,module,exports){
'use strict';
var $at  = require('./$.string-at')(true);

// 21.1.3.27 String.prototype[@@iterator]()
require('./$.iter-define')(String, 'String', function(iterated){
  this._t = String(iterated); // target
  this._i = 0;                // next index
// 21.1.5.2.1 %StringIteratorPrototype%.next()
}, function(){
  var O     = this._t
    , index = this._i
    , point;
  if(index >= O.length)return {value: undefined, done: true};
  point = $at(O, index);
  this._i += point.length;
  return {value: point, done: false};
});
},{"./$.iter-define":42,"./$.string-at":70}],165:[function(require,module,exports){
var $export   = require('./$.export')
  , toIObject = require('./$.to-iobject')
  , toLength  = require('./$.to-length');

$export($export.S, 'String', {
  // 21.1.2.4 String.raw(callSite, ...substitutions)
  raw: function raw(callSite){
    var tpl   = toIObject(callSite.raw)
      , len   = toLength(tpl.length)
      , $$    = arguments
      , $$len = $$.length
      , res   = []
      , i     = 0;
    while(len > i){
      res.push(String(tpl[i++]));
      if(i < $$len)res.push(String($$[i]));
    } return res.join('');
  }
});
},{"./$.export":22,"./$.to-iobject":78,"./$.to-length":79}],166:[function(require,module,exports){
var $export = require('./$.export');

$export($export.P, 'String', {
  // 21.1.3.13 String.prototype.repeat(count)
  repeat: require('./$.string-repeat')
});
},{"./$.export":22,"./$.string-repeat":73}],167:[function(require,module,exports){
// 21.1.3.18 String.prototype.startsWith(searchString [, position ])
'use strict';
var $export     = require('./$.export')
  , toLength    = require('./$.to-length')
  , context     = require('./$.string-context')
  , STARTS_WITH = 'startsWith'
  , $startsWith = ''[STARTS_WITH];

$export($export.P + $export.F * require('./$.fails-is-regexp')(STARTS_WITH), 'String', {
  startsWith: function startsWith(searchString /*, position = 0 */){
    var that   = context(this, searchString, STARTS_WITH)
      , $$     = arguments
      , index  = toLength(Math.min($$.length > 1 ? $$[1] : undefined, that.length))
      , search = String(searchString);
    return $startsWith
      ? $startsWith.call(that, search, index)
      : that.slice(index, index + search.length) === search;
  }
});
},{"./$.export":22,"./$.fails-is-regexp":23,"./$.string-context":71,"./$.to-length":79}],168:[function(require,module,exports){
'use strict';
// 21.1.3.25 String.prototype.trim()
require('./$.string-trim')('trim', function($trim){
  return function trim(){
    return $trim(this, 3);
  };
});
},{"./$.string-trim":74}],169:[function(require,module,exports){
'use strict';
// ECMAScript 6 symbols shim
var $              = require('./$')
  , global         = require('./$.global')
  , has            = require('./$.has')
  , DESCRIPTORS    = require('./$.descriptors')
  , $export        = require('./$.export')
  , redefine       = require('./$.redefine')
  , $fails         = require('./$.fails')
  , shared         = require('./$.shared')
  , setToStringTag = require('./$.set-to-string-tag')
  , uid            = require('./$.uid')
  , wks            = require('./$.wks')
  , keyOf          = require('./$.keyof')
  , $names         = require('./$.get-names')
  , enumKeys       = require('./$.enum-keys')
  , isArray        = require('./$.is-array')
  , anObject       = require('./$.an-object')
  , toIObject      = require('./$.to-iobject')
  , createDesc     = require('./$.property-desc')
  , getDesc        = $.getDesc
  , setDesc        = $.setDesc
  , _create        = $.create
  , getNames       = $names.get
  , $Symbol        = global.Symbol
  , $JSON          = global.JSON
  , _stringify     = $JSON && $JSON.stringify
  , setter         = false
  , HIDDEN         = wks('_hidden')
  , isEnum         = $.isEnum
  , SymbolRegistry = shared('symbol-registry')
  , AllSymbols     = shared('symbols')
  , useNative      = typeof $Symbol == 'function'
  , ObjectProto    = Object.prototype;

// fallback for old Android, https://code.google.com/p/v8/issues/detail?id=687
var setSymbolDesc = DESCRIPTORS && $fails(function(){
  return _create(setDesc({}, 'a', {
    get: function(){ return setDesc(this, 'a', {value: 7}).a; }
  })).a != 7;
}) ? function(it, key, D){
  var protoDesc = getDesc(ObjectProto, key);
  if(protoDesc)delete ObjectProto[key];
  setDesc(it, key, D);
  if(protoDesc && it !== ObjectProto)setDesc(ObjectProto, key, protoDesc);
} : setDesc;

var wrap = function(tag){
  var sym = AllSymbols[tag] = _create($Symbol.prototype);
  sym._k = tag;
  DESCRIPTORS && setter && setSymbolDesc(ObjectProto, tag, {
    configurable: true,
    set: function(value){
      if(has(this, HIDDEN) && has(this[HIDDEN], tag))this[HIDDEN][tag] = false;
      setSymbolDesc(this, tag, createDesc(1, value));
    }
  });
  return sym;
};

var isSymbol = function(it){
  return typeof it == 'symbol';
};

var $defineProperty = function defineProperty(it, key, D){
  if(D && has(AllSymbols, key)){
    if(!D.enumerable){
      if(!has(it, HIDDEN))setDesc(it, HIDDEN, createDesc(1, {}));
      it[HIDDEN][key] = true;
    } else {
      if(has(it, HIDDEN) && it[HIDDEN][key])it[HIDDEN][key] = false;
      D = _create(D, {enumerable: createDesc(0, false)});
    } return setSymbolDesc(it, key, D);
  } return setDesc(it, key, D);
};
var $defineProperties = function defineProperties(it, P){
  anObject(it);
  var keys = enumKeys(P = toIObject(P))
    , i    = 0
    , l = keys.length
    , key;
  while(l > i)$defineProperty(it, key = keys[i++], P[key]);
  return it;
};
var $create = function create(it, P){
  return P === undefined ? _create(it) : $defineProperties(_create(it), P);
};
var $propertyIsEnumerable = function propertyIsEnumerable(key){
  var E = isEnum.call(this, key);
  return E || !has(this, key) || !has(AllSymbols, key) || has(this, HIDDEN) && this[HIDDEN][key]
    ? E : true;
};
var $getOwnPropertyDescriptor = function getOwnPropertyDescriptor(it, key){
  var D = getDesc(it = toIObject(it), key);
  if(D && has(AllSymbols, key) && !(has(it, HIDDEN) && it[HIDDEN][key]))D.enumerable = true;
  return D;
};
var $getOwnPropertyNames = function getOwnPropertyNames(it){
  var names  = getNames(toIObject(it))
    , result = []
    , i      = 0
    , key;
  while(names.length > i)if(!has(AllSymbols, key = names[i++]) && key != HIDDEN)result.push(key);
  return result;
};
var $getOwnPropertySymbols = function getOwnPropertySymbols(it){
  var names  = getNames(toIObject(it))
    , result = []
    , i      = 0
    , key;
  while(names.length > i)if(has(AllSymbols, key = names[i++]))result.push(AllSymbols[key]);
  return result;
};
var $stringify = function stringify(it){
  if(it === undefined || isSymbol(it))return; // IE8 returns string on undefined
  var args = [it]
    , i    = 1
    , $$   = arguments
    , replacer, $replacer;
  while($$.length > i)args.push($$[i++]);
  replacer = args[1];
  if(typeof replacer == 'function')$replacer = replacer;
  if($replacer || !isArray(replacer))replacer = function(key, value){
    if($replacer)value = $replacer.call(this, key, value);
    if(!isSymbol(value))return value;
  };
  args[1] = replacer;
  return _stringify.apply($JSON, args);
};
var buggyJSON = $fails(function(){
  var S = $Symbol();
  // MS Edge converts symbol values to JSON as {}
  // WebKit converts symbol values to JSON as null
  // V8 throws on boxed symbols
  return _stringify([S]) != '[null]' || _stringify({a: S}) != '{}' || _stringify(Object(S)) != '{}';
});

// 19.4.1.1 Symbol([description])
if(!useNative){
  $Symbol = function Symbol(){
    if(isSymbol(this))throw TypeError('Symbol is not a constructor');
    return wrap(uid(arguments.length > 0 ? arguments[0] : undefined));
  };
  redefine($Symbol.prototype, 'toString', function toString(){
    return this._k;
  });

  isSymbol = function(it){
    return it instanceof $Symbol;
  };

  $.create     = $create;
  $.isEnum     = $propertyIsEnumerable;
  $.getDesc    = $getOwnPropertyDescriptor;
  $.setDesc    = $defineProperty;
  $.setDescs   = $defineProperties;
  $.getNames   = $names.get = $getOwnPropertyNames;
  $.getSymbols = $getOwnPropertySymbols;

  if(DESCRIPTORS && !require('./$.library')){
    redefine(ObjectProto, 'propertyIsEnumerable', $propertyIsEnumerable, true);
  }
}

var symbolStatics = {
  // 19.4.2.1 Symbol.for(key)
  'for': function(key){
    return has(SymbolRegistry, key += '')
      ? SymbolRegistry[key]
      : SymbolRegistry[key] = $Symbol(key);
  },
  // 19.4.2.5 Symbol.keyFor(sym)
  keyFor: function keyFor(key){
    return keyOf(SymbolRegistry, key);
  },
  useSetter: function(){ setter = true; },
  useSimple: function(){ setter = false; }
};
// 19.4.2.2 Symbol.hasInstance
// 19.4.2.3 Symbol.isConcatSpreadable
// 19.4.2.4 Symbol.iterator
// 19.4.2.6 Symbol.match
// 19.4.2.8 Symbol.replace
// 19.4.2.9 Symbol.search
// 19.4.2.10 Symbol.species
// 19.4.2.11 Symbol.split
// 19.4.2.12 Symbol.toPrimitive
// 19.4.2.13 Symbol.toStringTag
// 19.4.2.14 Symbol.unscopables
$.each.call((
  'hasInstance,isConcatSpreadable,iterator,match,replace,search,' +
  'species,split,toPrimitive,toStringTag,unscopables'
).split(','), function(it){
  var sym = wks(it);
  symbolStatics[it] = useNative ? sym : wrap(sym);
});

setter = true;

$export($export.G + $export.W, {Symbol: $Symbol});

$export($export.S, 'Symbol', symbolStatics);

$export($export.S + $export.F * !useNative, 'Object', {
  // 19.1.2.2 Object.create(O [, Properties])
  create: $create,
  // 19.1.2.4 Object.defineProperty(O, P, Attributes)
  defineProperty: $defineProperty,
  // 19.1.2.3 Object.defineProperties(O, Properties)
  defineProperties: $defineProperties,
  // 19.1.2.6 Object.getOwnPropertyDescriptor(O, P)
  getOwnPropertyDescriptor: $getOwnPropertyDescriptor,
  // 19.1.2.7 Object.getOwnPropertyNames(O)
  getOwnPropertyNames: $getOwnPropertyNames,
  // 19.1.2.8 Object.getOwnPropertySymbols(O)
  getOwnPropertySymbols: $getOwnPropertySymbols
});

// 24.3.2 JSON.stringify(value [, replacer [, space]])
$JSON && $export($export.S + $export.F * (!useNative || buggyJSON), 'JSON', {stringify: $stringify});

// 19.4.3.5 Symbol.prototype[@@toStringTag]
setToStringTag($Symbol, 'Symbol');
// 20.2.1.9 Math[@@toStringTag]
setToStringTag(Math, 'Math', true);
// 24.3.3 JSON[@@toStringTag]
setToStringTag(global.JSON, 'JSON', true);
},{"./$":46,"./$.an-object":4,"./$.descriptors":19,"./$.enum-keys":21,"./$.export":22,"./$.fails":24,"./$.get-names":28,"./$.global":29,"./$.has":30,"./$.is-array":36,"./$.keyof":47,"./$.library":48,"./$.property-desc":59,"./$.redefine":61,"./$.set-to-string-tag":66,"./$.shared":67,"./$.to-iobject":78,"./$.uid":82,"./$.wks":83}],170:[function(require,module,exports){
'use strict';
var $            = require('./$')
  , redefine     = require('./$.redefine')
  , weak         = require('./$.collection-weak')
  , isObject     = require('./$.is-object')
  , has          = require('./$.has')
  , frozenStore  = weak.frozenStore
  , WEAK         = weak.WEAK
  , isExtensible = Object.isExtensible || isObject
  , tmp          = {};

// 23.3 WeakMap Objects
var $WeakMap = require('./$.collection')('WeakMap', function(get){
  return function WeakMap(){ return get(this, arguments.length > 0 ? arguments[0] : undefined); };
}, {
  // 23.3.3.3 WeakMap.prototype.get(key)
  get: function get(key){
    if(isObject(key)){
      if(!isExtensible(key))return frozenStore(this).get(key);
      if(has(key, WEAK))return key[WEAK][this._i];
    }
  },
  // 23.3.3.5 WeakMap.prototype.set(key, value)
  set: function set(key, value){
    return weak.def(this, key, value);
  }
}, weak, true, true);

// IE11 WeakMap frozen keys fix
if(new $WeakMap().set((Object.freeze || Object)(tmp), 7).get(tmp) != 7){
  $.each.call(['delete', 'has', 'get', 'set'], function(key){
    var proto  = $WeakMap.prototype
      , method = proto[key];
    redefine(proto, key, function(a, b){
      // store frozen objects on leaky map
      if(isObject(a) && !isExtensible(a)){
        var result = frozenStore(this)[key](a, b);
        return key == 'set' ? this : result;
      // store all the rest on native weakmap
      } return method.call(this, a, b);
    });
  });
}
},{"./$":46,"./$.collection":15,"./$.collection-weak":14,"./$.has":30,"./$.is-object":38,"./$.redefine":61}],171:[function(require,module,exports){
'use strict';
var weak = require('./$.collection-weak');

// 23.4 WeakSet Objects
require('./$.collection')('WeakSet', function(get){
  return function WeakSet(){ return get(this, arguments.length > 0 ? arguments[0] : undefined); };
}, {
  // 23.4.3.1 WeakSet.prototype.add(value)
  add: function add(value){
    return weak.def(this, value, true);
  }
}, weak, false, true);
},{"./$.collection":15,"./$.collection-weak":14}],172:[function(require,module,exports){
'use strict';
var $export   = require('./$.export')
  , $includes = require('./$.array-includes')(true);

$export($export.P, 'Array', {
  // https://github.com/domenic/Array.prototype.includes
  includes: function includes(el /*, fromIndex = 0 */){
    return $includes(this, el, arguments.length > 1 ? arguments[1] : undefined);
  }
});

require('./$.add-to-unscopables')('includes');
},{"./$.add-to-unscopables":3,"./$.array-includes":7,"./$.export":22}],173:[function(require,module,exports){
// https://github.com/DavidBruant/Map-Set.prototype.toJSON
var $export  = require('./$.export');

$export($export.P, 'Map', {toJSON: require('./$.collection-to-json')('Map')});
},{"./$.collection-to-json":13,"./$.export":22}],174:[function(require,module,exports){
// http://goo.gl/XkBrjD
var $export  = require('./$.export')
  , $entries = require('./$.object-to-array')(true);

$export($export.S, 'Object', {
  entries: function entries(it){
    return $entries(it);
  }
});
},{"./$.export":22,"./$.object-to-array":55}],175:[function(require,module,exports){
// https://gist.github.com/WebReflection/9353781
var $          = require('./$')
  , $export    = require('./$.export')
  , ownKeys    = require('./$.own-keys')
  , toIObject  = require('./$.to-iobject')
  , createDesc = require('./$.property-desc');

$export($export.S, 'Object', {
  getOwnPropertyDescriptors: function getOwnPropertyDescriptors(object){
    var O       = toIObject(object)
      , setDesc = $.setDesc
      , getDesc = $.getDesc
      , keys    = ownKeys(O)
      , result  = {}
      , i       = 0
      , key, D;
    while(keys.length > i){
      D = getDesc(O, key = keys[i++]);
      if(key in result)setDesc(result, key, createDesc(0, D));
      else result[key] = D;
    } return result;
  }
});
},{"./$":46,"./$.export":22,"./$.own-keys":56,"./$.property-desc":59,"./$.to-iobject":78}],176:[function(require,module,exports){
// http://goo.gl/XkBrjD
var $export = require('./$.export')
  , $values = require('./$.object-to-array')(false);

$export($export.S, 'Object', {
  values: function values(it){
    return $values(it);
  }
});
},{"./$.export":22,"./$.object-to-array":55}],177:[function(require,module,exports){
// https://github.com/benjamingr/RexExp.escape
var $export = require('./$.export')
  , $re     = require('./$.replacer')(/[\\^$*+?.()|[\]{}]/g, '\\$&');

$export($export.S, 'RegExp', {escape: function escape(it){ return $re(it); }});

},{"./$.export":22,"./$.replacer":62}],178:[function(require,module,exports){
// https://github.com/DavidBruant/Map-Set.prototype.toJSON
var $export  = require('./$.export');

$export($export.P, 'Set', {toJSON: require('./$.collection-to-json')('Set')});
},{"./$.collection-to-json":13,"./$.export":22}],179:[function(require,module,exports){
'use strict';
// https://github.com/mathiasbynens/String.prototype.at
var $export = require('./$.export')
  , $at     = require('./$.string-at')(true);

$export($export.P, 'String', {
  at: function at(pos){
    return $at(this, pos);
  }
});
},{"./$.export":22,"./$.string-at":70}],180:[function(require,module,exports){
'use strict';
var $export = require('./$.export')
  , $pad    = require('./$.string-pad');

$export($export.P, 'String', {
  padLeft: function padLeft(maxLength /*, fillString = ' ' */){
    return $pad(this, maxLength, arguments.length > 1 ? arguments[1] : undefined, true);
  }
});
},{"./$.export":22,"./$.string-pad":72}],181:[function(require,module,exports){
'use strict';
var $export = require('./$.export')
  , $pad    = require('./$.string-pad');

$export($export.P, 'String', {
  padRight: function padRight(maxLength /*, fillString = ' ' */){
    return $pad(this, maxLength, arguments.length > 1 ? arguments[1] : undefined, false);
  }
});
},{"./$.export":22,"./$.string-pad":72}],182:[function(require,module,exports){
'use strict';
// https://github.com/sebmarkbage/ecmascript-string-left-right-trim
require('./$.string-trim')('trimLeft', function($trim){
  return function trimLeft(){
    return $trim(this, 1);
  };
});
},{"./$.string-trim":74}],183:[function(require,module,exports){
'use strict';
// https://github.com/sebmarkbage/ecmascript-string-left-right-trim
require('./$.string-trim')('trimRight', function($trim){
  return function trimRight(){
    return $trim(this, 2);
  };
});
},{"./$.string-trim":74}],184:[function(require,module,exports){
// JavaScript 1.6 / Strawman array statics shim
var $       = require('./$')
  , $export = require('./$.export')
  , $ctx    = require('./$.ctx')
  , $Array  = require('./$.core').Array || Array
  , statics = {};
var setStatics = function(keys, length){
  $.each.call(keys.split(','), function(key){
    if(length == undefined && key in $Array)statics[key] = $Array[key];
    else if(key in [])statics[key] = $ctx(Function.call, [][key], length);
  });
};
setStatics('pop,reverse,shift,keys,values,entries', 1);
setStatics('indexOf,every,some,forEach,map,filter,find,findIndex,includes', 3);
setStatics('join,slice,concat,push,splice,unshift,sort,lastIndexOf,' +
           'reduce,reduceRight,copyWithin,fill');
$export($export.S, 'Array', statics);
},{"./$":46,"./$.core":16,"./$.ctx":17,"./$.export":22}],185:[function(require,module,exports){
require('./es6.array.iterator');
var global      = require('./$.global')
  , hide        = require('./$.hide')
  , Iterators   = require('./$.iterators')
  , ITERATOR    = require('./$.wks')('iterator')
  , NL          = global.NodeList
  , HTC         = global.HTMLCollection
  , NLProto     = NL && NL.prototype
  , HTCProto    = HTC && HTC.prototype
  , ArrayValues = Iterators.NodeList = Iterators.HTMLCollection = Iterators.Array;
if(NLProto && !NLProto[ITERATOR])hide(NLProto, ITERATOR, ArrayValues);
if(HTCProto && !HTCProto[ITERATOR])hide(HTCProto, ITERATOR, ArrayValues);
},{"./$.global":29,"./$.hide":31,"./$.iterators":45,"./$.wks":83,"./es6.array.iterator":91}],186:[function(require,module,exports){
var $export = require('./$.export')
  , $task   = require('./$.task');
$export($export.G + $export.B, {
  setImmediate:   $task.set,
  clearImmediate: $task.clear
});
},{"./$.export":22,"./$.task":75}],187:[function(require,module,exports){
// ie9- setTimeout & setInterval additional parameters fix
var global     = require('./$.global')
  , $export    = require('./$.export')
  , invoke     = require('./$.invoke')
  , partial    = require('./$.partial')
  , navigator  = global.navigator
  , MSIE       = !!navigator && /MSIE .\./.test(navigator.userAgent); // <- dirty ie9- check
var wrap = function(set){
  return MSIE ? function(fn, time /*, ...args */){
    return set(invoke(
      partial,
      [].slice.call(arguments, 2),
      typeof fn == 'function' ? fn : Function(fn)
    ), time);
  } : set;
};
$export($export.G + $export.B + $export.F * MSIE, {
  setTimeout:  wrap(global.setTimeout),
  setInterval: wrap(global.setInterval)
});
},{"./$.export":22,"./$.global":29,"./$.invoke":33,"./$.partial":57}],188:[function(require,module,exports){
require('./modules/es5');
require('./modules/es6.symbol');
require('./modules/es6.object.assign');
require('./modules/es6.object.is');
require('./modules/es6.object.set-prototype-of');
require('./modules/es6.object.to-string');
require('./modules/es6.object.freeze');
require('./modules/es6.object.seal');
require('./modules/es6.object.prevent-extensions');
require('./modules/es6.object.is-frozen');
require('./modules/es6.object.is-sealed');
require('./modules/es6.object.is-extensible');
require('./modules/es6.object.get-own-property-descriptor');
require('./modules/es6.object.get-prototype-of');
require('./modules/es6.object.keys');
require('./modules/es6.object.get-own-property-names');
require('./modules/es6.function.name');
require('./modules/es6.function.has-instance');
require('./modules/es6.number.constructor');
require('./modules/es6.number.epsilon');
require('./modules/es6.number.is-finite');
require('./modules/es6.number.is-integer');
require('./modules/es6.number.is-nan');
require('./modules/es6.number.is-safe-integer');
require('./modules/es6.number.max-safe-integer');
require('./modules/es6.number.min-safe-integer');
require('./modules/es6.number.parse-float');
require('./modules/es6.number.parse-int');
require('./modules/es6.math.acosh');
require('./modules/es6.math.asinh');
require('./modules/es6.math.atanh');
require('./modules/es6.math.cbrt');
require('./modules/es6.math.clz32');
require('./modules/es6.math.cosh');
require('./modules/es6.math.expm1');
require('./modules/es6.math.fround');
require('./modules/es6.math.hypot');
require('./modules/es6.math.imul');
require('./modules/es6.math.log10');
require('./modules/es6.math.log1p');
require('./modules/es6.math.log2');
require('./modules/es6.math.sign');
require('./modules/es6.math.sinh');
require('./modules/es6.math.tanh');
require('./modules/es6.math.trunc');
require('./modules/es6.string.from-code-point');
require('./modules/es6.string.raw');
require('./modules/es6.string.trim');
require('./modules/es6.string.iterator');
require('./modules/es6.string.code-point-at');
require('./modules/es6.string.ends-with');
require('./modules/es6.string.includes');
require('./modules/es6.string.repeat');
require('./modules/es6.string.starts-with');
require('./modules/es6.array.from');
require('./modules/es6.array.of');
require('./modules/es6.array.iterator');
require('./modules/es6.array.species');
require('./modules/es6.array.copy-within');
require('./modules/es6.array.fill');
require('./modules/es6.array.find');
require('./modules/es6.array.find-index');
require('./modules/es6.regexp.constructor');
require('./modules/es6.regexp.flags');
require('./modules/es6.regexp.match');
require('./modules/es6.regexp.replace');
require('./modules/es6.regexp.search');
require('./modules/es6.regexp.split');
require('./modules/es6.promise');
require('./modules/es6.map');
require('./modules/es6.set');
require('./modules/es6.weak-map');
require('./modules/es6.weak-set');
require('./modules/es6.reflect.apply');
require('./modules/es6.reflect.construct');
require('./modules/es6.reflect.define-property');
require('./modules/es6.reflect.delete-property');
require('./modules/es6.reflect.enumerate');
require('./modules/es6.reflect.get');
require('./modules/es6.reflect.get-own-property-descriptor');
require('./modules/es6.reflect.get-prototype-of');
require('./modules/es6.reflect.has');
require('./modules/es6.reflect.is-extensible');
require('./modules/es6.reflect.own-keys');
require('./modules/es6.reflect.prevent-extensions');
require('./modules/es6.reflect.set');
require('./modules/es6.reflect.set-prototype-of');
require('./modules/es7.array.includes');
require('./modules/es7.string.at');
require('./modules/es7.string.pad-left');
require('./modules/es7.string.pad-right');
require('./modules/es7.string.trim-left');
require('./modules/es7.string.trim-right');
require('./modules/es7.regexp.escape');
require('./modules/es7.object.get-own-property-descriptors');
require('./modules/es7.object.values');
require('./modules/es7.object.entries');
require('./modules/es7.map.to-json');
require('./modules/es7.set.to-json');
require('./modules/js.array.statics');
require('./modules/web.timers');
require('./modules/web.immediate');
require('./modules/web.dom.iterable');
module.exports = require('./modules/$.core');
},{"./modules/$.core":16,"./modules/es5":85,"./modules/es6.array.copy-within":86,"./modules/es6.array.fill":87,"./modules/es6.array.find":89,"./modules/es6.array.find-index":88,"./modules/es6.array.from":90,"./modules/es6.array.iterator":91,"./modules/es6.array.of":92,"./modules/es6.array.species":93,"./modules/es6.function.has-instance":94,"./modules/es6.function.name":95,"./modules/es6.map":96,"./modules/es6.math.acosh":97,"./modules/es6.math.asinh":98,"./modules/es6.math.atanh":99,"./modules/es6.math.cbrt":100,"./modules/es6.math.clz32":101,"./modules/es6.math.cosh":102,"./modules/es6.math.expm1":103,"./modules/es6.math.fround":104,"./modules/es6.math.hypot":105,"./modules/es6.math.imul":106,"./modules/es6.math.log10":107,"./modules/es6.math.log1p":108,"./modules/es6.math.log2":109,"./modules/es6.math.sign":110,"./modules/es6.math.sinh":111,"./modules/es6.math.tanh":112,"./modules/es6.math.trunc":113,"./modules/es6.number.constructor":114,"./modules/es6.number.epsilon":115,"./modules/es6.number.is-finite":116,"./modules/es6.number.is-integer":117,"./modules/es6.number.is-nan":118,"./modules/es6.number.is-safe-integer":119,"./modules/es6.number.max-safe-integer":120,"./modules/es6.number.min-safe-integer":121,"./modules/es6.number.parse-float":122,"./modules/es6.number.parse-int":123,"./modules/es6.object.assign":124,"./modules/es6.object.freeze":125,"./modules/es6.object.get-own-property-descriptor":126,"./modules/es6.object.get-own-property-names":127,"./modules/es6.object.get-prototype-of":128,"./modules/es6.object.is":132,"./modules/es6.object.is-extensible":129,"./modules/es6.object.is-frozen":130,"./modules/es6.object.is-sealed":131,"./modules/es6.object.keys":133,"./modules/es6.object.prevent-extensions":134,"./modules/es6.object.seal":135,"./modules/es6.object.set-prototype-of":136,"./modules/es6.object.to-string":137,"./modules/es6.promise":138,"./modules/es6.reflect.apply":139,"./modules/es6.reflect.construct":140,"./modules/es6.reflect.define-property":141,"./modules/es6.reflect.delete-property":142,"./modules/es6.reflect.enumerate":143,"./modules/es6.reflect.get":146,"./modules/es6.reflect.get-own-property-descriptor":144,"./modules/es6.reflect.get-prototype-of":145,"./modules/es6.reflect.has":147,"./modules/es6.reflect.is-extensible":148,"./modules/es6.reflect.own-keys":149,"./modules/es6.reflect.prevent-extensions":150,"./modules/es6.reflect.set":152,"./modules/es6.reflect.set-prototype-of":151,"./modules/es6.regexp.constructor":153,"./modules/es6.regexp.flags":154,"./modules/es6.regexp.match":155,"./modules/es6.regexp.replace":156,"./modules/es6.regexp.search":157,"./modules/es6.regexp.split":158,"./modules/es6.set":159,"./modules/es6.string.code-point-at":160,"./modules/es6.string.ends-with":161,"./modules/es6.string.from-code-point":162,"./modules/es6.string.includes":163,"./modules/es6.string.iterator":164,"./modules/es6.string.raw":165,"./modules/es6.string.repeat":166,"./modules/es6.string.starts-with":167,"./modules/es6.string.trim":168,"./modules/es6.symbol":169,"./modules/es6.weak-map":170,"./modules/es6.weak-set":171,"./modules/es7.array.includes":172,"./modules/es7.map.to-json":173,"./modules/es7.object.entries":174,"./modules/es7.object.get-own-property-descriptors":175,"./modules/es7.object.values":176,"./modules/es7.regexp.escape":177,"./modules/es7.set.to-json":178,"./modules/es7.string.at":179,"./modules/es7.string.pad-left":180,"./modules/es7.string.pad-right":181,"./modules/es7.string.trim-left":182,"./modules/es7.string.trim-right":183,"./modules/js.array.statics":184,"./modules/web.dom.iterable":185,"./modules/web.immediate":186,"./modules/web.timers":187}],189:[function(require,module,exports){
(function (global){
(function (process,global){
/**
 * Copyright (c) 2014, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * https://raw.github.com/facebook/regenerator/master/LICENSE file. An
 * additional grant of patent rights can be found in the PATENTS file in
 * the same directory.
 */

!(function(global) {
  "use strict";

  var hasOwn = Object.prototype.hasOwnProperty;
  var undefined; // More compressible than void 0.
  var iteratorSymbol =
    typeof Symbol === "function" && Symbol.iterator || "@@iterator";

  var inModule = typeof module === "object";
  var runtime = global.regeneratorRuntime;
  if (runtime) {
    if (inModule) {
      // If regeneratorRuntime is defined globally and we're in a module,
      // make the exports object identical to regeneratorRuntime.
      module.exports = runtime;
    }
    // Don't bother evaluating the rest of this file if the runtime was
    // already defined globally.
    return;
  }

  // Define the runtime globally (as expected by generated code) as either
  // module.exports (if we're in a module) or a new, empty object.
  runtime = global.regeneratorRuntime = inModule ? module.exports : {};

  function wrap(innerFn, outerFn, self, tryLocsList) {
    // If outerFn provided, then outerFn.prototype instanceof Generator.
    var generator = Object.create((outerFn || Generator).prototype);
    var context = new Context(tryLocsList || []);

    // The ._invoke method unifies the implementations of the .next,
    // .throw, and .return methods.
    generator._invoke = makeInvokeMethod(innerFn, self, context);

    return generator;
  }
  runtime.wrap = wrap;

  // Try/catch helper to minimize deoptimizations. Returns a completion
  // record like context.tryEntries[i].completion. This interface could
  // have been (and was previously) designed to take a closure to be
  // invoked without arguments, but in all the cases we care about we
  // already have an existing method we want to call, so there's no need
  // to create a new function object. We can even get away with assuming
  // the method takes exactly one argument, since that happens to be true
  // in every case, so we don't have to touch the arguments object. The
  // only additional allocation required is the completion record, which
  // has a stable shape and so hopefully should be cheap to allocate.
  function tryCatch(fn, obj, arg) {
    try {
      return { type: "normal", arg: fn.call(obj, arg) };
    } catch (err) {
      return { type: "throw", arg: err };
    }
  }

  var GenStateSuspendedStart = "suspendedStart";
  var GenStateSuspendedYield = "suspendedYield";
  var GenStateExecuting = "executing";
  var GenStateCompleted = "completed";

  // Returning this object from the innerFn has the same effect as
  // breaking out of the dispatch switch statement.
  var ContinueSentinel = {};

  // Dummy constructor functions that we use as the .constructor and
  // .constructor.prototype properties for functions that return Generator
  // objects. For full spec compliance, you may wish to configure your
  // minifier not to mangle the names of these two functions.
  function Generator() {}
  function GeneratorFunction() {}
  function GeneratorFunctionPrototype() {}

  var Gp = GeneratorFunctionPrototype.prototype = Generator.prototype;
  GeneratorFunction.prototype = Gp.constructor = GeneratorFunctionPrototype;
  GeneratorFunctionPrototype.constructor = GeneratorFunction;
  GeneratorFunction.displayName = "GeneratorFunction";

  // Helper for defining the .next, .throw, and .return methods of the
  // Iterator interface in terms of a single ._invoke method.
  function defineIteratorMethods(prototype) {
    ["next", "throw", "return"].forEach(function(method) {
      prototype[method] = function(arg) {
        return this._invoke(method, arg);
      };
    });
  }

  runtime.isGeneratorFunction = function(genFun) {
    var ctor = typeof genFun === "function" && genFun.constructor;
    return ctor
      ? ctor === GeneratorFunction ||
        // For the native GeneratorFunction constructor, the best we can
        // do is to check its .name property.
        (ctor.displayName || ctor.name) === "GeneratorFunction"
      : false;
  };

  runtime.mark = function(genFun) {
    if (Object.setPrototypeOf) {
      Object.setPrototypeOf(genFun, GeneratorFunctionPrototype);
    } else {
      genFun.__proto__ = GeneratorFunctionPrototype;
    }
    genFun.prototype = Object.create(Gp);
    return genFun;
  };

  // Within the body of any async function, `await x` is transformed to
  // `yield regeneratorRuntime.awrap(x)`, so that the runtime can test
  // `value instanceof AwaitArgument` to determine if the yielded value is
  // meant to be awaited. Some may consider the name of this method too
  // cutesy, but they are curmudgeons.
  runtime.awrap = function(arg) {
    return new AwaitArgument(arg);
  };

  function AwaitArgument(arg) {
    this.arg = arg;
  }

  function AsyncIterator(generator) {
    // This invoke function is written in a style that assumes some
    // calling function (or Promise) will handle exceptions.
    function invoke(method, arg) {
      var result = generator[method](arg);
      var value = result.value;
      return value instanceof AwaitArgument
        ? Promise.resolve(value.arg).then(invokeNext, invokeThrow)
        : Promise.resolve(value).then(function(unwrapped) {
            // When a yielded Promise is resolved, its final value becomes
            // the .value of the Promise<{value,done}> result for the
            // current iteration. If the Promise is rejected, however, the
            // result for this iteration will be rejected with the same
            // reason. Note that rejections of yielded Promises are not
            // thrown back into the generator function, as is the case
            // when an awaited Promise is rejected. This difference in
            // behavior between yield and await is important, because it
            // allows the consumer to decide what to do with the yielded
            // rejection (swallow it and continue, manually .throw it back
            // into the generator, abandon iteration, whatever). With
            // await, by contrast, there is no opportunity to examine the
            // rejection reason outside the generator function, so the
            // only option is to throw it from the await expression, and
            // let the generator function handle the exception.
            result.value = unwrapped;
            return result;
          });
    }

    if (typeof process === "object" && process.domain) {
      invoke = process.domain.bind(invoke);
    }

    var invokeNext = invoke.bind(generator, "next");
    var invokeThrow = invoke.bind(generator, "throw");
    var invokeReturn = invoke.bind(generator, "return");
    var previousPromise;

    function enqueue(method, arg) {
      function callInvokeWithMethodAndArg() {
        return invoke(method, arg);
      }

      return previousPromise =
        // If enqueue has been called before, then we want to wait until
        // all previous Promises have been resolved before calling invoke,
        // so that results are always delivered in the correct order. If
        // enqueue has not been called before, then it is important to
        // call invoke immediately, without waiting on a callback to fire,
        // so that the async generator function has the opportunity to do
        // any necessary setup in a predictable way. This predictability
        // is why the Promise constructor synchronously invokes its
        // executor callback, and why async functions synchronously
        // execute code before the first await. Since we implement simple
        // async functions in terms of async generators, it is especially
        // important to get this right, even though it requires care.
        previousPromise ? previousPromise.then(
          callInvokeWithMethodAndArg,
          // Avoid propagating failures to Promises returned by later
          // invocations of the iterator.
          callInvokeWithMethodAndArg
        ) : new Promise(function (resolve) {
          resolve(callInvokeWithMethodAndArg());
        });
    }

    // Define the unified helper method that is used to implement .next,
    // .throw, and .return (see defineIteratorMethods).
    this._invoke = enqueue;
  }

  defineIteratorMethods(AsyncIterator.prototype);

  // Note that simple async functions are implemented on top of
  // AsyncIterator objects; they just return a Promise for the value of
  // the final result produced by the iterator.
  runtime.async = function(innerFn, outerFn, self, tryLocsList) {
    var iter = new AsyncIterator(
      wrap(innerFn, outerFn, self, tryLocsList)
    );

    return runtime.isGeneratorFunction(outerFn)
      ? iter // If outerFn is a generator, return the full iterator.
      : iter.next().then(function(result) {
          return result.done ? result.value : iter.next();
        });
  };

  function makeInvokeMethod(innerFn, self, context) {
    var state = GenStateSuspendedStart;

    return function invoke(method, arg) {
      if (state === GenStateExecuting) {
        throw new Error("Generator is already running");
      }

      if (state === GenStateCompleted) {
        if (method === "throw") {
          throw arg;
        }

        // Be forgiving, per 25.3.3.3.3 of the spec:
        // https://people.mozilla.org/~jorendorff/es6-draft.html#sec-generatorresume
        return doneResult();
      }

      while (true) {
        var delegate = context.delegate;
        if (delegate) {
          if (method === "return" ||
              (method === "throw" && delegate.iterator[method] === undefined)) {
            // A return or throw (when the delegate iterator has no throw
            // method) always terminates the yield* loop.
            context.delegate = null;

            // If the delegate iterator has a return method, give it a
            // chance to clean up.
            var returnMethod = delegate.iterator["return"];
            if (returnMethod) {
              var record = tryCatch(returnMethod, delegate.iterator, arg);
              if (record.type === "throw") {
                // If the return method threw an exception, let that
                // exception prevail over the original return or throw.
                method = "throw";
                arg = record.arg;
                continue;
              }
            }

            if (method === "return") {
              // Continue with the outer return, now that the delegate
              // iterator has been terminated.
              continue;
            }
          }

          var record = tryCatch(
            delegate.iterator[method],
            delegate.iterator,
            arg
          );

          if (record.type === "throw") {
            context.delegate = null;

            // Like returning generator.throw(uncaught), but without the
            // overhead of an extra function call.
            method = "throw";
            arg = record.arg;
            continue;
          }

          // Delegate generator ran and handled its own exceptions so
          // regardless of what the method was, we continue as if it is
          // "next" with an undefined arg.
          method = "next";
          arg = undefined;

          var info = record.arg;
          if (info.done) {
            context[delegate.resultName] = info.value;
            context.next = delegate.nextLoc;
          } else {
            state = GenStateSuspendedYield;
            return info;
          }

          context.delegate = null;
        }

        if (method === "next") {
          context._sent = arg;

          if (state === GenStateSuspendedYield) {
            context.sent = arg;
          } else {
            context.sent = undefined;
          }
        } else if (method === "throw") {
          if (state === GenStateSuspendedStart) {
            state = GenStateCompleted;
            throw arg;
          }

          if (context.dispatchException(arg)) {
            // If the dispatched exception was caught by a catch block,
            // then let that catch block handle the exception normally.
            method = "next";
            arg = undefined;
          }

        } else if (method === "return") {
          context.abrupt("return", arg);
        }

        state = GenStateExecuting;

        var record = tryCatch(innerFn, self, context);
        if (record.type === "normal") {
          // If an exception is thrown from innerFn, we leave state ===
          // GenStateExecuting and loop back for another invocation.
          state = context.done
            ? GenStateCompleted
            : GenStateSuspendedYield;

          var info = {
            value: record.arg,
            done: context.done
          };

          if (record.arg === ContinueSentinel) {
            if (context.delegate && method === "next") {
              // Deliberately forget the last sent value so that we don't
              // accidentally pass it on to the delegate.
              arg = undefined;
            }
          } else {
            return info;
          }

        } else if (record.type === "throw") {
          state = GenStateCompleted;
          // Dispatch the exception by looping back around to the
          // context.dispatchException(arg) call above.
          method = "throw";
          arg = record.arg;
        }
      }
    };
  }

  // Define Generator.prototype.{next,throw,return} in terms of the
  // unified ._invoke helper method.
  defineIteratorMethods(Gp);

  Gp[iteratorSymbol] = function() {
    return this;
  };

  Gp.toString = function() {
    return "[object Generator]";
  };

  function pushTryEntry(locs) {
    var entry = { tryLoc: locs[0] };

    if (1 in locs) {
      entry.catchLoc = locs[1];
    }

    if (2 in locs) {
      entry.finallyLoc = locs[2];
      entry.afterLoc = locs[3];
    }

    this.tryEntries.push(entry);
  }

  function resetTryEntry(entry) {
    var record = entry.completion || {};
    record.type = "normal";
    delete record.arg;
    entry.completion = record;
  }

  function Context(tryLocsList) {
    // The root entry object (effectively a try statement without a catch
    // or a finally block) gives us a place to store values thrown from
    // locations where there is no enclosing try statement.
    this.tryEntries = [{ tryLoc: "root" }];
    tryLocsList.forEach(pushTryEntry, this);
    this.reset(true);
  }

  runtime.keys = function(object) {
    var keys = [];
    for (var key in object) {
      keys.push(key);
    }
    keys.reverse();

    // Rather than returning an object with a next method, we keep
    // things simple and return the next function itself.
    return function next() {
      while (keys.length) {
        var key = keys.pop();
        if (key in object) {
          next.value = key;
          next.done = false;
          return next;
        }
      }

      // To avoid creating an additional object, we just hang the .value
      // and .done properties off the next function object itself. This
      // also ensures that the minifier will not anonymize the function.
      next.done = true;
      return next;
    };
  };

  function values(iterable) {
    if (iterable) {
      var iteratorMethod = iterable[iteratorSymbol];
      if (iteratorMethod) {
        return iteratorMethod.call(iterable);
      }

      if (typeof iterable.next === "function") {
        return iterable;
      }

      if (!isNaN(iterable.length)) {
        var i = -1, next = function next() {
          while (++i < iterable.length) {
            if (hasOwn.call(iterable, i)) {
              next.value = iterable[i];
              next.done = false;
              return next;
            }
          }

          next.value = undefined;
          next.done = true;

          return next;
        };

        return next.next = next;
      }
    }

    // Return an iterator with no values.
    return { next: doneResult };
  }
  runtime.values = values;

  function doneResult() {
    return { value: undefined, done: true };
  }

  Context.prototype = {
    constructor: Context,

    reset: function(skipTempReset) {
      this.prev = 0;
      this.next = 0;
      this.sent = undefined;
      this.done = false;
      this.delegate = null;

      this.tryEntries.forEach(resetTryEntry);

      if (!skipTempReset) {
        for (var name in this) {
          // Not sure about the optimal order of these conditions:
          if (name.charAt(0) === "t" &&
              hasOwn.call(this, name) &&
              !isNaN(+name.slice(1))) {
            this[name] = undefined;
          }
        }
      }
    },

    stop: function() {
      this.done = true;

      var rootEntry = this.tryEntries[0];
      var rootRecord = rootEntry.completion;
      if (rootRecord.type === "throw") {
        throw rootRecord.arg;
      }

      return this.rval;
    },

    dispatchException: function(exception) {
      if (this.done) {
        throw exception;
      }

      var context = this;
      function handle(loc, caught) {
        record.type = "throw";
        record.arg = exception;
        context.next = loc;
        return !!caught;
      }

      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        var record = entry.completion;

        if (entry.tryLoc === "root") {
          // Exception thrown outside of any try block that could handle
          // it, so set the completion value of the entire function to
          // throw the exception.
          return handle("end");
        }

        if (entry.tryLoc <= this.prev) {
          var hasCatch = hasOwn.call(entry, "catchLoc");
          var hasFinally = hasOwn.call(entry, "finallyLoc");

          if (hasCatch && hasFinally) {
            if (this.prev < entry.catchLoc) {
              return handle(entry.catchLoc, true);
            } else if (this.prev < entry.finallyLoc) {
              return handle(entry.finallyLoc);
            }

          } else if (hasCatch) {
            if (this.prev < entry.catchLoc) {
              return handle(entry.catchLoc, true);
            }

          } else if (hasFinally) {
            if (this.prev < entry.finallyLoc) {
              return handle(entry.finallyLoc);
            }

          } else {
            throw new Error("try statement without catch or finally");
          }
        }
      }
    },

    abrupt: function(type, arg) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc <= this.prev &&
            hasOwn.call(entry, "finallyLoc") &&
            this.prev < entry.finallyLoc) {
          var finallyEntry = entry;
          break;
        }
      }

      if (finallyEntry &&
          (type === "break" ||
           type === "continue") &&
          finallyEntry.tryLoc <= arg &&
          arg <= finallyEntry.finallyLoc) {
        // Ignore the finally entry if control is not jumping to a
        // location outside the try/catch block.
        finallyEntry = null;
      }

      var record = finallyEntry ? finallyEntry.completion : {};
      record.type = type;
      record.arg = arg;

      if (finallyEntry) {
        this.next = finallyEntry.finallyLoc;
      } else {
        this.complete(record);
      }

      return ContinueSentinel;
    },

    complete: function(record, afterLoc) {
      if (record.type === "throw") {
        throw record.arg;
      }

      if (record.type === "break" ||
          record.type === "continue") {
        this.next = record.arg;
      } else if (record.type === "return") {
        this.rval = record.arg;
        this.next = "end";
      } else if (record.type === "normal" && afterLoc) {
        this.next = afterLoc;
      }
    },

    finish: function(finallyLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.finallyLoc === finallyLoc) {
          this.complete(entry.completion, entry.afterLoc);
          resetTryEntry(entry);
          return ContinueSentinel;
        }
      }
    },

    "catch": function(tryLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc === tryLoc) {
          var record = entry.completion;
          if (record.type === "throw") {
            var thrown = record.arg;
            resetTryEntry(entry);
          }
          return thrown;
        }
      }

      // The context.catch method must only be called with a location
      // argument that corresponds to a known catch block.
      throw new Error("illegal catch attempt");
    },

    delegateYield: function(iterable, resultName, nextLoc) {
      this.delegate = {
        iterator: values(iterable),
        resultName: resultName,
        nextLoc: nextLoc
      };

      return ContinueSentinel;
    }
  };
})(
  // Among the various tricks for obtaining a reference to the global
  // object, this seems to be the most reliable technique that does not
  // use indirect eval (which violates Content Security Policy).
  typeof global === "object" ? global :
  typeof window === "object" ? window :
  typeof self === "object" ? self : this
);

}).call(this,require("../process/browser.js"),typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"../process/browser.js":202}],190:[function(require,module,exports){
/*!
Copyright (C) 2013-2015 by Andrea Giammarchi - @WebReflection

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
(function(window){'use strict';
  /* jshint loopfunc: true, noempty: false*/
  // http://www.w3.org/TR/dom/#element

  function createDocumentFragment() {
    return document.createDocumentFragment();
  }

  function createElement(nodeName) {
    return document.createElement(nodeName);
  }

  function mutationMacro(nodes) {
    if (nodes.length === 1) {
      return textNodeIfString(nodes[0]);
    }
    for (var
      fragment = createDocumentFragment(),
      list = slice.call(nodes),
      i = 0; i < nodes.length; i++
    ) {
      fragment.appendChild(textNodeIfString(list[i]));
    }
    return fragment;
  }

  function textNodeIfString(node) {
    return typeof node === 'string' ? document.createTextNode(node) : node;
  }

  for(var
    head,
    property,
    TemporaryPrototype,
    TemporaryTokenList,
    wrapVerifyToken,
    document = window.document,
    defineProperty = Object.defineProperty || function (object, property, descriptor) {
      object.__defineGetter__(property, descriptor.get);
    },
    indexOf = [].indexOf || function indexOf(value){
      var length = this.length;
      while(length--) {
        if (this[length] === value) {
          break;
        }
      }
      return length;
    },
    // http://www.w3.org/TR/domcore/#domtokenlist
    verifyToken = function (token) {
      if (!token) {
        throw 'SyntaxError';
      } else if (spaces.test(token)) {
        throw 'InvalidCharacterError';
      }
      return token;
    },
    DOMTokenList = function (node) {
      var
        className = node.className,
        isSVG = typeof className === 'object',
        value = (isSVG ? className.baseVal : className).replace(trim, '')
      ;
      if (value.length) {
        properties.push.apply(
          this,
          value.split(spaces)
        );
      }
      this._isSVG = isSVG;
      this._ = node;
    },
    classListDescriptor = {
      get: function get() {
        return new DOMTokenList(this);
      },
      set: function(){}
    },
    uid = 'dom4-tmp-'.concat(Math.random() * +new Date()).replace('.','-'),
    trim = /^\s+|\s+$/g,
    spaces = /\s+/,
    SPACE = '\x20',
    CLASS_LIST = 'classList',
    toggle = function toggle(token, force) {
      if (this.contains(token)) {
        if (!force) {
          // force is not true (either false or omitted)
          this.remove(token);
        }
      } else if(force === undefined || force) {
        force = true;
        this.add(token);
      }
      return !!force;
    },
    DocumentFragmentPrototype = window.DocumentFragment && DocumentFragment.prototype,
    Node = window.Node,
    NodePrototype = (Node || Element).prototype,
    CharacterData = window.CharacterData || Node,
    CharacterDataPrototype = CharacterData && CharacterData.prototype,
    DocumentType = window.DocumentType,
    DocumentTypePrototype = DocumentType && DocumentType.prototype,
    ElementPrototype = (window.Element || Node || window.HTMLElement).prototype,
    HTMLSelectElement = window.HTMLSelectElement || createElement('select').constructor,
    selectRemove = HTMLSelectElement.prototype.remove,
    ShadowRoot = window.ShadowRoot,
    SVGElement = window.SVGElement,
    // normalizes multiple ids as CSS query
    idSpaceFinder = / /g,
    idSpaceReplacer = '\\ ',
    createQueryMethod = function (methodName) {
      var createArray = methodName === 'querySelectorAll';
      return function (css) {
        var a, i, id, query, nl, selectors, node = this.parentNode;
        if (node) {
          for (
            id = this.getAttribute('id') || uid,
            query = id === uid ? id : id.replace(idSpaceFinder, idSpaceReplacer),
            selectors = css.split(','),
            i = 0; i < selectors.length; i++
          ) {
            selectors[i] = '#' + query + ' ' + selectors[i];
          }
          css = selectors.join(',');
        }
        if (id === uid) this.setAttribute('id', id);
        nl = (node || this)[methodName](css);
        if (id === uid) this.removeAttribute('id');
        // return a list
        if (createArray) {
          i = nl.length;
          a = new Array(i);
          while (i--) a[i] = nl[i];
        }
        // return node or null
        else {
          a = nl;
        }
        return a;
      };
    },
    addQueryAndAll = function (where) {
      if (!('query' in where)) {
        where.query = ElementPrototype.query;
      }
      if (!('queryAll' in where)) {
        where.queryAll = ElementPrototype.queryAll;
      }
    },
    properties = [
      'matches', (
        ElementPrototype.matchesSelector ||
        ElementPrototype.webkitMatchesSelector ||
        ElementPrototype.khtmlMatchesSelector ||
        ElementPrototype.mozMatchesSelector ||
        ElementPrototype.msMatchesSelector ||
        ElementPrototype.oMatchesSelector ||
        function matches(selector) {
          var parentNode = this.parentNode;
          return !!parentNode && -1 < indexOf.call(
            parentNode.querySelectorAll(selector),
            this
          );
        }
      ),
      'closest', function closest(selector) {
        var parentNode = this, matches;
        while (
          // document has no .matches
          (matches = parentNode && parentNode.matches) &&
          !parentNode.matches(selector)
        ) {
          parentNode = parentNode.parentNode;
        }
        return matches ? parentNode : null;
      },
      'prepend', function prepend() {
        var firstChild = this.firstChild,
            node = mutationMacro(arguments);
        if (firstChild) {
          this.insertBefore(node, firstChild);
        } else {
          this.appendChild(node);
        }
      },
      'append', function append() {
        this.appendChild(mutationMacro(arguments));
      },
      'before', function before() {
        var parentNode = this.parentNode;
        if (parentNode) {
          parentNode.insertBefore(
            mutationMacro(arguments), this
          );
        }
      },
      'after', function after() {
        var parentNode = this.parentNode,
            nextSibling = this.nextSibling,
            node = mutationMacro(arguments);
        if (parentNode) {
          if (nextSibling) {
            parentNode.insertBefore(node, nextSibling);
          } else {
            parentNode.appendChild(node);
          }
        }
      },
      // WARNING - DEPRECATED - use .replaceWith() instead
      'replace', function replace() {
        this.replaceWith.apply(this, arguments);
      },
      'replaceWith', function replaceWith() {
        var parentNode = this.parentNode;
        if (parentNode) {
          parentNode.replaceChild(
            mutationMacro(arguments),
            this
          );
        }
      },
      'remove', function remove() {
        var parentNode = this.parentNode;
        if (parentNode) {
          parentNode.removeChild(this);
        }
      },
      'query', createQueryMethod('querySelector'),
      'queryAll', createQueryMethod('querySelectorAll')
    ],
    slice = properties.slice,
    i = properties.length; i; i -= 2
  ) {
    property = properties[i - 2];
    if (!(property in ElementPrototype)) {
      ElementPrototype[property] = properties[i - 1];
    }
    if (property === 'remove') {
      // see https://github.com/WebReflection/dom4/issues/19
      HTMLSelectElement.prototype[property] = function () {
        return 0 < arguments.length ?
          selectRemove.apply(this, arguments) :
          ElementPrototype.remove.call(this);
      };
    }
    // see https://github.com/WebReflection/dom4/issues/18
    if (/^(?:before|after|replace|replaceWith|remove)$/.test(property)) {
      if (CharacterData && !(property in CharacterDataPrototype)) {
        CharacterDataPrototype[property] = properties[i - 1];
      }
      if (DocumentType && !(property in DocumentTypePrototype)) {
        DocumentTypePrototype[property] = properties[i - 1];
      }
    }
    // see https://github.com/WebReflection/dom4/pull/26
    if (/^(?:append|prepend)$/.test(property)) {
      if (DocumentFragmentPrototype) {
        if (!(property in DocumentFragmentPrototype)) {
          DocumentFragmentPrototype[property] = properties[i - 1];
        }
      } else {
        try {
          createDocumentFragment().constructor.prototype[property] = properties[i - 1];
        } catch(o_O) {}
      }
    }
  }

  // bring query and queryAll to the document too
  addQueryAndAll(document);

  // brings query and queryAll to fragments as well
  if (DocumentFragmentPrototype) {
    addQueryAndAll(DocumentFragmentPrototype);
  } else {
    try {
      addQueryAndAll(createDocumentFragment().constructor.prototype);
    } catch(o_O) {}
  }

  // bring query and queryAll to the ShadowRoot too
  if (ShadowRoot) {
    addQueryAndAll(ShadowRoot.prototype);
  }

  // most likely an IE9 only issue
  // see https://github.com/WebReflection/dom4/issues/6
  if (!createElement('a').matches('a')) {
    ElementPrototype[property] = function(matches){
      return function (selector) {
        return matches.call(
          this.parentNode ?
            this :
            createDocumentFragment().appendChild(this),
          selector
        );
      };
    }(ElementPrototype[property]);
  }

  // used to fix both old webkit and SVG
  DOMTokenList.prototype = {
    length: 0,
    add: function add() {
      for(var j = 0, token; j < arguments.length; j++) {
        token = arguments[j];
        if(!this.contains(token)) {
          properties.push.call(this, property);
        }
      }
      if (this._isSVG) {
        this._.setAttribute('class', '' + this);
      } else {
        this._.className = '' + this;
      }
    },
    contains: (function(indexOf){
      return function contains(token) {
        i = indexOf.call(this, property = verifyToken(token));
        return -1 < i;
      };
    }([].indexOf || function (token) {
      i = this.length;
      while(i-- && this[i] !== token){}
      return i;
    })),
    item: function item(i) {
      return this[i] || null;
    },
    remove: function remove() {
      for(var j = 0, token; j < arguments.length; j++) {
        token = arguments[j];
        if(this.contains(token)) {
          properties.splice.call(this, i, 1);
        }
      }
      if (this._isSVG) {
        this._.setAttribute('class', '' + this);
      } else {
        this._.className = '' + this;
      }
    },
    toggle: toggle,
    toString: function toString() {
      return properties.join.call(this, SPACE);
    }
  };

  if (SVGElement && !(CLASS_LIST in SVGElement.prototype)) {
    defineProperty(SVGElement.prototype, CLASS_LIST, classListDescriptor);
  }

  // http://www.w3.org/TR/dom/#domtokenlist
  // iOS 5.1 has completely screwed this property
  // classList in ElementPrototype is false
  // but it's actually there as getter
  if (!(CLASS_LIST in document.documentElement)) {
    defineProperty(ElementPrototype, CLASS_LIST, classListDescriptor);
  } else {
    // iOS 5.1 and Nokia ASHA do not support multiple add or remove
    // trying to detect and fix that in here
    TemporaryTokenList = createElement('div')[CLASS_LIST];
    TemporaryTokenList.add('a', 'b', 'a');
    if ('a\x20b' != TemporaryTokenList) {
      // no other way to reach original methods in iOS 5.1
      TemporaryPrototype = TemporaryTokenList.constructor.prototype;
      if (!('add' in TemporaryPrototype)) {
        // ASHA double fails in here
        TemporaryPrototype = window.TemporaryTokenList.prototype;
      }
      wrapVerifyToken = function (original) {
        return function () {
          var i = 0;
          while (i < arguments.length) {
            original.call(this, arguments[i++]);
          }
        };
      };
      TemporaryPrototype.add = wrapVerifyToken(TemporaryPrototype.add);
      TemporaryPrototype.remove = wrapVerifyToken(TemporaryPrototype.remove);
      // toggle is broken too ^_^ ... let's fix it
      TemporaryPrototype.toggle = toggle;
    }
  }

  if (!('contains' in NodePrototype)) {
    defineProperty(NodePrototype, 'contains', {
      value: function (el) {
        while (el && el !== this) el = el.parentNode;
        return this === el;
      }
    });
  }

  if (!('head' in document)) {
    defineProperty(document, 'head', {
      get: function () {
        return head || (
          head = document.getElementsByTagName('head')[0]
        );
      }
    });
  }

  // requestAnimationFrame partial polyfill
  (function () {
    for (var
      raf,
      rAF = window.requestAnimationFrame,
      cAF = window.cancelAnimationFrame,
      prefixes = ['o', 'ms', 'moz', 'webkit'],
      i = prefixes.length;
      !cAF && i--;
    ) {
      rAF = rAF || window[prefixes[i] + 'RequestAnimationFrame'];
      cAF = window[prefixes[i] + 'CancelAnimationFrame'] ||
            window[prefixes[i] + 'CancelRequestAnimationFrame'];
    }
    if (!cAF) {
      // some FF apparently implemented rAF but no cAF 
      if (rAF) {
        raf = rAF;
        rAF = function (callback) {
          var goOn = true;
          raf(function () {
            if (goOn) callback.apply(this, arguments);
          });
          return function () {
            goOn = false;
          };
        };
        cAF = function (id) {
          id();
        };
      } else {
        rAF = function (callback) {
          return setTimeout(callback, 15, 15);
        };
        cAF = function (id) {
          clearTimeout(id);
        };
      }
    }
    window.requestAnimationFrame = rAF;
    window.cancelAnimationFrame = cAF;
  }());

  // http://www.w3.org/TR/dom/#customevent
  try{new window.CustomEvent('?');}catch(o_O){
    window.CustomEvent = function(
      eventName,
      defaultInitDict
    ){

      // the infamous substitute
      function CustomEvent(type, eventInitDict) {
        /*jshint eqnull:true */
        var event = document.createEvent(eventName);
        if (typeof type != 'string') {
          throw new Error('An event name must be provided');
        }
        if (eventName == 'Event') {
          event.initCustomEvent = initCustomEvent;
        }
        if (eventInitDict == null) {
          eventInitDict = defaultInitDict;
        }
        event.initCustomEvent(
          type,
          eventInitDict.bubbles,
          eventInitDict.cancelable,
          eventInitDict.detail
        );
        return event;
      }

      // attached at runtime
      function initCustomEvent(
        type, bubbles, cancelable, detail
      ) {
        /*jshint validthis:true*/
        this.initEvent(type, bubbles, cancelable);
        this.detail = detail;
      }

      // that's it
      return CustomEvent;
    }(
      // is this IE9 or IE10 ?
      // where CustomEvent is there
      // but not usable as construtor ?
      window.CustomEvent ?
        // use the CustomEvent interface in such case
        'CustomEvent' : 'Event',
        // otherwise the common compatible one
      {
        bubbles: false,
        cancelable: false,
        detail: null
      }
    );
  }

}(window));
},{}],191:[function(require,module,exports){
(function (global){
(function (global){
/*! loadCSS: load a CSS file asynchronously. [c]2016 @scottjehl, Filament Group, Inc. Licensed MIT */
(function(w){
	"use strict";
	/* exported loadCSS */
	var loadCSS = function( href, before, media ){
		// Arguments explained:
		// `href` [REQUIRED] is the URL for your CSS file.
		// `before` [OPTIONAL] is the element the script should use as a reference for injecting our stylesheet <link> before
			// By default, loadCSS attempts to inject the link after the last stylesheet or script in the DOM. However, you might desire a more specific location in your document.
		// `media` [OPTIONAL] is the media type or query of the stylesheet. By default it will be 'all'
		var doc = w.document;
		var ss = doc.createElement( "link" );
		var newMedia = media || "all";
		var ref;
		if( before ){
			ref = before;
		}
		else {
			var refs = ( doc.body || doc.getElementsByTagName( "head" )[ 0 ] ).childNodes;
			ref = refs[ refs.length - 1];
		}

		var sheets = doc.styleSheets;
		ss.rel = "stylesheet";
		ss.href = href;
		// temporarily set media to something inapplicable to ensure it'll fetch without blocking render
		ss.media = "only x";

		// wait until body is defined before injecting link. This ensures a non-blocking load in IE11.
		function ready( cb ){
			if( doc.body ){
				return cb();
			}
			setTimeout(function(){
				ready( cb );
			});
		}
		// Inject link
			// Note: the ternary preserves the existing behavior of "before" argument, but we could choose to change the argument to "after" in a later release and standardize on ref.nextSibling for all refs
			// Note: `insertBefore` is used instead of `appendChild`, for safety re: http://www.paulirish.com/2011/surefire-dom-element-insertion/
		ready( function(){
			ref.parentNode.insertBefore( ss, ( before ? ref : ref.nextSibling ) );
		});
		// A method (exposed on return object for external use) that mimics onload by polling until document.styleSheets until it includes the new sheet.
		var onloadcssdefined = function( cb ){
			var resolvedHref = ss.href;
			var i = sheets.length;
			while( i-- ){
				if( sheets[ i ].href === resolvedHref ){
					return cb();
				}
			}
			setTimeout(function() {
				onloadcssdefined( cb );
			});
		};

		// once loaded, set link's media back to `all` so that the stylesheet applies once it loads
		if( ss.addEventListener ){
			ss.addEventListener( "load", function(){
				this.media = newMedia;
			});
		}
		ss.onloadcssdefined = onloadcssdefined;
		onloadcssdefined(function() {
			if( ss.media !== newMedia ){
				ss.media = newMedia;
			}
		});
		return ss;
	};
	// commonjs
	if( typeof exports !== "undefined" ){
		exports.loadCSS = loadCSS;
	}
	else {
		w.loadCSS = loadCSS;
	}
}( typeof global !== "undefined" ? global : this ));

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}],192:[function(require,module,exports){
(function(){'use strict';var h=!!document.addEventListener;function k(a,b){h?a.addEventListener("scroll",b,!1):a.attachEvent("scroll",b)}function w(a){document.body?a():h?document.addEventListener("DOMContentLoaded",a):document.onreadystatechange=function(){"interactive"==document.readyState&&a()}};function x(a){this.a=document.createElement("div");this.a.setAttribute("aria-hidden","true");this.a.appendChild(document.createTextNode(a));this.b=document.createElement("span");this.c=document.createElement("span");this.h=document.createElement("span");this.f=document.createElement("span");this.g=-1;this.b.style.cssText="display:inline-block;position:absolute;height:100%;width:100%;overflow:scroll;font-size:16px;";this.c.style.cssText="display:inline-block;position:absolute;height:100%;width:100%;overflow:scroll;font-size:16px;";
this.f.style.cssText="display:inline-block;position:absolute;height:100%;width:100%;overflow:scroll;font-size:16px;";this.h.style.cssText="display:inline-block;width:200%;height:200%;font-size:16px;";this.b.appendChild(this.h);this.c.appendChild(this.f);this.a.appendChild(this.b);this.a.appendChild(this.c)}
function y(a,b){a.a.style.cssText="min-width:20px;min-height:20px;display:inline-block;overflow:hidden;position:absolute;width:auto;margin:0;padding:0;top:-999px;left:-999px;white-space:nowrap;font:"+b+";"}function z(a){var b=a.a.offsetWidth,c=b+100;a.f.style.width=c+"px";a.c.scrollLeft=c;a.b.scrollLeft=a.b.scrollWidth+100;return a.g!==b?(a.g=b,!0):!1}function A(a,b){function c(){var a=l;z(a)&&null!==a.a.parentNode&&b(a.g)}var l=a;k(a.b,c);k(a.c,c);z(a)};function B(a,b){var c=b||{};this.family=a;this.style=c.style||"normal";this.weight=c.weight||"normal";this.stretch=c.stretch||"normal"}var C=null,D=null,H=!!window.FontFace;function I(){if(null===D){var a=document.createElement("div");try{a.style.font="condensed 100px sans-serif"}catch(b){}D=""!==a.style.font}return D}function J(a,b){return[a.style,a.weight,I()?a.stretch:"","100px",b].join(" ")}
B.prototype.a=function(a,b){var c=this,l=a||"BESbswy",E=b||3E3,F=(new Date).getTime();return new Promise(function(a,b){if(H){var q=function(){(new Date).getTime()-F>=E?b(c):document.fonts.load(J(c,c.family),l).then(function(b){1<=b.length?a(c):setTimeout(q,25)},function(){b(c)})};q()}else w(function(){function r(){var b;if(b=-1!=e&&-1!=f||-1!=e&&-1!=g||-1!=f&&-1!=g)(b=e!=f&&e!=g&&f!=g)||(null===C&&(b=/AppleWebKit\/([0-9]+)(?:\.([0-9]+))/.exec(window.navigator.userAgent),C=!!b&&(536>parseInt(b[1],
10)||536===parseInt(b[1],10)&&11>=parseInt(b[2],10))),b=C&&(e==t&&f==t&&g==t||e==u&&f==u&&g==u||e==v&&f==v&&g==v)),b=!b;b&&(null!==d.parentNode&&d.parentNode.removeChild(d),clearTimeout(G),a(c))}function q(){if((new Date).getTime()-F>=E)null!==d.parentNode&&d.parentNode.removeChild(d),b(c);else{var a=document.hidden;if(!0===a||void 0===a)e=m.a.offsetWidth,f=n.a.offsetWidth,g=p.a.offsetWidth,r();G=setTimeout(q,50)}}var m=new x(l),n=new x(l),p=new x(l),e=-1,f=-1,g=-1,t=-1,u=-1,v=-1,d=document.createElement("div"),
G=0;d.dir="ltr";y(m,J(c,"sans-serif"));y(n,J(c,"serif"));y(p,J(c,"monospace"));d.appendChild(m.a);d.appendChild(n.a);d.appendChild(p.a);document.body.appendChild(d);t=m.a.offsetWidth;u=n.a.offsetWidth;v=p.a.offsetWidth;q();A(m,function(a){e=a;r()});y(m,J(c,'"'+c.family+'",sans-serif'));A(n,function(a){f=a;r()});y(n,J(c,'"'+c.family+'",serif'));A(p,function(a){g=a;r()});y(p,J(c,'"'+c.family+'",monospace'))})})};window.FontFaceObserver=B;window.FontFaceObserver.prototype.check=B.prototype.a;"undefined"!==typeof module&&(module.exports=window.FontFaceObserver);}());

},{}],193:[function(require,module,exports){
/**
* @preserve HTML5 Shiv 3.7.3 | @afarkas @jdalton @jon_neal @rem | MIT/GPL2 Licensed
*/
;(function(window, document) {
/*jshint evil:true */
  /** version */
  var version = '3.7.3-pre';

  /** Preset options */
  var options = window.html5 || {};

  /** Used to skip problem elements */
  var reSkip = /^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i;

  /** Not all elements can be cloned in IE **/
  var saveClones = /^(?:a|b|code|div|fieldset|h1|h2|h3|h4|h5|h6|i|label|li|ol|p|q|span|strong|style|table|tbody|td|th|tr|ul)$/i;

  /** Detect whether the browser supports default html5 styles */
  var supportsHtml5Styles;

  /** Name of the expando, to work with multiple documents or to re-shiv one document */
  var expando = '_html5shiv';

  /** The id for the the documents expando */
  var expanID = 0;

  /** Cached data for each document */
  var expandoData = {};

  /** Detect whether the browser supports unknown elements */
  var supportsUnknownElements;

  (function() {
    try {
        var a = document.createElement('a');
        a.innerHTML = '<xyz></xyz>';
        //if the hidden property is implemented we can assume, that the browser supports basic HTML5 Styles
        supportsHtml5Styles = ('hidden' in a);

        supportsUnknownElements = a.childNodes.length == 1 || (function() {
          // assign a false positive if unable to shiv
          (document.createElement)('a');
          var frag = document.createDocumentFragment();
          return (
            typeof frag.cloneNode == 'undefined' ||
            typeof frag.createDocumentFragment == 'undefined' ||
            typeof frag.createElement == 'undefined'
          );
        }());
    } catch(e) {
      // assign a false positive if detection fails => unable to shiv
      supportsHtml5Styles = true;
      supportsUnknownElements = true;
    }

  }());

  /*--------------------------------------------------------------------------*/

  /**
   * Creates a style sheet with the given CSS text and adds it to the document.
   * @private
   * @param {Document} ownerDocument The document.
   * @param {String} cssText The CSS text.
   * @returns {StyleSheet} The style element.
   */
  function addStyleSheet(ownerDocument, cssText) {
    var p = ownerDocument.createElement('p'),
        parent = ownerDocument.getElementsByTagName('head')[0] || ownerDocument.documentElement;

    p.innerHTML = 'x<style>' + cssText + '</style>';
    return parent.insertBefore(p.lastChild, parent.firstChild);
  }

  /**
   * Returns the value of `html5.elements` as an array.
   * @private
   * @returns {Array} An array of shived element node names.
   */
  function getElements() {
    var elements = html5.elements;
    return typeof elements == 'string' ? elements.split(' ') : elements;
  }

  /**
   * Extends the built-in list of html5 elements
   * @memberOf html5
   * @param {String|Array} newElements whitespace separated list or array of new element names to shiv
   * @param {Document} ownerDocument The context document.
   */
  function addElements(newElements, ownerDocument) {
    var elements = html5.elements;
    if(typeof elements != 'string'){
      elements = elements.join(' ');
    }
    if(typeof newElements != 'string'){
      newElements = newElements.join(' ');
    }
    html5.elements = elements +' '+ newElements;
    shivDocument(ownerDocument);
  }

   /**
   * Returns the data associated to the given document
   * @private
   * @param {Document} ownerDocument The document.
   * @returns {Object} An object of data.
   */
  function getExpandoData(ownerDocument) {
    var data = expandoData[ownerDocument[expando]];
    if (!data) {
        data = {};
        expanID++;
        ownerDocument[expando] = expanID;
        expandoData[expanID] = data;
    }
    return data;
  }

  /**
   * returns a shived element for the given nodeName and document
   * @memberOf html5
   * @param {String} nodeName name of the element
   * @param {Document} ownerDocument The context document.
   * @returns {Object} The shived element.
   */
  function createElement(nodeName, ownerDocument, data){
    if (!ownerDocument) {
        ownerDocument = document;
    }
    if(supportsUnknownElements){
        return ownerDocument.createElement(nodeName);
    }
    if (!data) {
        data = getExpandoData(ownerDocument);
    }
    var node;

    if (data.cache[nodeName]) {
        node = data.cache[nodeName].cloneNode();
    } else if (saveClones.test(nodeName)) {
        node = (data.cache[nodeName] = data.createElem(nodeName)).cloneNode();
    } else {
        node = data.createElem(nodeName);
    }

    // Avoid adding some elements to fragments in IE < 9 because
    // * Attributes like `name` or `type` cannot be set/changed once an element
    //   is inserted into a document/fragment
    // * Link elements with `src` attributes that are inaccessible, as with
    //   a 403 response, will cause the tab/window to crash
    // * Script elements appended to fragments will execute when their `src`
    //   or `text` property is set
    return node.canHaveChildren && !reSkip.test(nodeName) && !node.tagUrn ? data.frag.appendChild(node) : node;
  }

  /**
   * returns a shived DocumentFragment for the given document
   * @memberOf html5
   * @param {Document} ownerDocument The context document.
   * @returns {Object} The shived DocumentFragment.
   */
  function createDocumentFragment(ownerDocument, data){
    if (!ownerDocument) {
        ownerDocument = document;
    }
    if(supportsUnknownElements){
        return ownerDocument.createDocumentFragment();
    }
    data = data || getExpandoData(ownerDocument);
    var clone = data.frag.cloneNode(),
        i = 0,
        elems = getElements(),
        l = elems.length;
    for(;i<l;i++){
        clone.createElement(elems[i]);
    }
    return clone;
  }

  /**
   * Shivs the `createElement` and `createDocumentFragment` methods of the document.
   * @private
   * @param {Document|DocumentFragment} ownerDocument The document.
   * @param {Object} data of the document.
   */
  function shivMethods(ownerDocument, data) {
    if (!data.cache) {
        data.cache = {};
        data.createElem = ownerDocument.createElement;
        data.createFrag = ownerDocument.createDocumentFragment;
        data.frag = data.createFrag();
    }


    ownerDocument.createElement = function(nodeName) {
      //abort shiv
      if (!html5.shivMethods) {
          return data.createElem(nodeName);
      }
      return createElement(nodeName, ownerDocument, data);
    };

    ownerDocument.createDocumentFragment = Function('h,f', 'return function(){' +
      'var n=f.cloneNode(),c=n.createElement;' +
      'h.shivMethods&&(' +
        // unroll the `createElement` calls
        getElements().join().replace(/[\w\-:]+/g, function(nodeName) {
          data.createElem(nodeName);
          data.frag.createElement(nodeName);
          return 'c("' + nodeName + '")';
        }) +
      ');return n}'
    )(html5, data.frag);
  }

  /*--------------------------------------------------------------------------*/

  /**
   * Shivs the given document.
   * @memberOf html5
   * @param {Document} ownerDocument The document to shiv.
   * @returns {Document} The shived document.
   */
  function shivDocument(ownerDocument) {
    if (!ownerDocument) {
        ownerDocument = document;
    }
    var data = getExpandoData(ownerDocument);

    if (html5.shivCSS && !supportsHtml5Styles && !data.hasCSS) {
      data.hasCSS = !!addStyleSheet(ownerDocument,
        // corrects block display not defined in IE6/7/8/9
        'article,aside,dialog,figcaption,figure,footer,header,hgroup,main,nav,section{display:block}' +
        // adds styling not present in IE6/7/8/9
        'mark{background:#FF0;color:#000}' +
        // hides non-rendered elements
        'template{display:none}'
      );
    }
    if (!supportsUnknownElements) {
      shivMethods(ownerDocument, data);
    }
    return ownerDocument;
  }

  /*--------------------------------------------------------------------------*/

  /**
   * The `html5` object is exposed so that more elements can be shived and
   * existing shiving can be detected on iframes.
   * @type Object
   * @example
   *
   * // options can be changed before the script is included
   * html5 = { 'elements': 'mark section', 'shivCSS': false, 'shivMethods': false };
   */
  var html5 = {

    /**
     * An array or space separated string of node names of the elements to shiv.
     * @memberOf html5
     * @type Array|String
     */
    'elements': options.elements || 'abbr article aside audio bdi canvas data datalist details dialog figcaption figure footer header hgroup main mark meter nav output picture progress section summary template time video',

    /**
     * current version of html5shiv
     */
    'version': version,

    /**
     * A flag to indicate that the HTML5 style sheet should be inserted.
     * @memberOf html5
     * @type Boolean
     */
    'shivCSS': (options.shivCSS !== false),

    /**
     * Is equal to true if a browser supports creating unknown/HTML5 elements
     * @memberOf html5
     * @type boolean
     */
    'supportsUnknownElements': supportsUnknownElements,

    /**
     * A flag to indicate that the document's `createElement` and `createDocumentFragment`
     * methods should be overwritten.
     * @memberOf html5
     * @type Boolean
     */
    'shivMethods': (options.shivMethods !== false),

    /**
     * A string to describe the type of `html5` object ("default" or "default print").
     * @memberOf html5
     * @type String
     */
    'type': 'default',

    // shivs the document according to the specified `html5` object options
    'shivDocument': shivDocument,

    //creates a shived element
    createElement: createElement,

    //creates a shived documentFragment
    createDocumentFragment: createDocumentFragment,

    //extends list of elements
    addElements: addElements
  };

  /*--------------------------------------------------------------------------*/

  // expose html5
  window.html5 = html5;

  // shiv the document
  shivDocument(document);

  if(typeof module == 'object' && module.exports){
    module.exports = html5;
  }

}(typeof window !== "undefined" ? window : this, document));

},{}],194:[function(require,module,exports){
(function (global){
(function (global){
/*!
Copyright (C) 2013-2015 by WebReflection

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/
(function(window){
  /*! (C) WebReflection Mit Style License */
  if (document.createEvent) return;
  var
    DUNNOABOUTDOMLOADED = true,
    READYEVENTDISPATCHED = false,
    ONREADYSTATECHANGE = 'onreadystatechange',
    DOMCONTENTLOADED = 'DOMContentLoaded',
    SECRET = '__IE8__' + Math.random(),
    // Object = window.Object,
    defineProperty = Object.defineProperty ||
    // just in case ...
    function (object, property, descriptor) {
      object[property] = descriptor.value;
    },
    defineProperties = Object.defineProperties ||
    // IE8 implemented defineProperty but not the plural...
    function (object, descriptors) {
      for(var key in descriptors) {
        if (hasOwnProperty.call(descriptors, key)) {
          try {
            defineProperty(object, key, descriptors[key]);
          } catch(o_O) {
            if (window.console) {
              console.log(key + ' failed on object:', object, o_O.message);
            }
          }
        }
      }
    },
    getOwnPropertyDescriptor = Object.getOwnPropertyDescriptor,
    hasOwnProperty = Object.prototype.hasOwnProperty,
    // here IE7 will break like a charm
    ElementPrototype = window.Element.prototype,
    TextPrototype = window.Text.prototype,
    // none of above native constructors exist/are exposed
    possiblyNativeEvent = /^[a-z]+$/,
    // ^ actually could probably be just /^[a-z]+$/
    readyStateOK = /loaded|complete/,
    types = {},
    div = document.createElement('div'),
    html = document.documentElement,
    removeAttribute = html.removeAttribute,
    setAttribute = html.setAttribute
  ;

  function commonEventLoop(currentTarget, e, $handlers, synthetic) {
    for(var
      continuePropagation,
      handlers = $handlers.slice(),
      evt = enrich(e, currentTarget),
      i = 0, length = handlers.length; i < length; i++
    ) {
      handler = handlers[i];
      if (typeof handler === 'object') {
        if (typeof handler.handleEvent === 'function') {
          handler.handleEvent(evt);
        }
      } else {
        handler.call(currentTarget, evt);
      }
      if (evt.stoppedImmediatePropagation) break;
    }
    continuePropagation = !evt.stoppedPropagation;
    /*
    if (continuePropagation && !synthetic && !live(currentTarget)) {
      evt.cancelBubble = true;
    }
    */
    return (
      synthetic &&
      continuePropagation &&
      currentTarget.parentNode
    ) ?
      currentTarget.parentNode.dispatchEvent(evt) :
      !evt.defaultPrevented
    ;
  }

  function commonDescriptor(get, set) {
    return {
      // if you try with enumerable: true
      // IE8 will miserably fail
      configurable: true,
      get: get,
      set: set
    };
  }

  function commonTextContent(protoDest, protoSource, property) {
    var descriptor = getOwnPropertyDescriptor(
      protoSource || protoDest, property
    );
    defineProperty(
      protoDest,
      'textContent',
      commonDescriptor(
        function () {
          return descriptor.get.call(this);
        },
        function (textContent) {
          descriptor.set.call(this, textContent);
        }
      )
    );
  }

  function enrich(e, currentTarget) {
    e.currentTarget = currentTarget;
    e.eventPhase = (
      // AT_TARGET : BUBBLING_PHASE
      e.target === e.currentTarget ? 2 : 3
    );
    return e;
  }

  function find(array, value) {
    var i = array.length;
    while(i-- && array[i] !== value);
    return i;
  }

  function getTextContent() {
    if (this.tagName === 'BR') return '\n';
    var
      textNode = this.firstChild,
      arrayContent = []
    ;
    while(textNode) {
      if (textNode.nodeType !== 8 && textNode.nodeType !== 7) {
        arrayContent.push(textNode.textContent);
      }
      textNode = textNode.nextSibling;
    }
    return arrayContent.join('');
  }

  function live(self) {
    return self.nodeType !== 9 && html.contains(self);
  }

  function onkeyup(e) {
    var evt = document.createEvent('Event');
    evt.initEvent('input', true, true);
    (e.srcElement || e.fromElement || document).dispatchEvent(evt);
  }

  function onReadyState(e) {
    if (!READYEVENTDISPATCHED && readyStateOK.test(
      document.readyState
    )) {
      READYEVENTDISPATCHED = !READYEVENTDISPATCHED;
      document.detachEvent(ONREADYSTATECHANGE, onReadyState);
      e = document.createEvent('Event');
      e.initEvent(DOMCONTENTLOADED, true, true);
      document.dispatchEvent(e);
    }
  }

  function setTextContent(textContent) {
    var node;
    while ((node = this.lastChild)) {
      this.removeChild(node);
    }
    if (textContent != null) {
      this.appendChild(document.createTextNode(textContent));
    }
  }

  function verify(self, e) {
    if (!e) {
      e = window.event;
    }
    if (!e.target) {
      e.target = e.srcElement || e.fromElement || document;
    }
    if (!e.timeStamp) {
      e.timeStamp = (new Date).getTime();
    }
    return e;
  }

  // normalized textContent for:
  //  comment, script, style, text, title
  commonTextContent(
    window.HTMLCommentElement.prototype,
    ElementPrototype,
    'nodeValue'
  );

  commonTextContent(
    window.HTMLScriptElement.prototype,
    null,
    'text'
  );

  commonTextContent(
    TextPrototype,
    null,
    'nodeValue'
  );

  commonTextContent(
    window.HTMLTitleElement.prototype,
    null,
    'text'
  );

  defineProperty(
    window.HTMLStyleElement.prototype,
    'textContent',
    (function(descriptor){
      return commonDescriptor(
        function () {
          return descriptor.get.call(this.styleSheet);
        },
        function (textContent) {
          descriptor.set.call(this.styleSheet, textContent);
        }
      );
    }(getOwnPropertyDescriptor(window.CSSStyleSheet.prototype, 'cssText')))
  );

  defineProperties(
    ElementPrototype,
    {
      // bonus
      textContent: {
        get: getTextContent,
        set: setTextContent
      },
      // http://www.w3.org/TR/ElementTraversal/#interface-elementTraversal
      firstElementChild: {
        get: function () {
          for(var
            childNodes = this.childNodes || [],
            i = 0, length = childNodes.length;
            i < length; i++
          ) {
            if (childNodes[i].nodeType == 1) return childNodes[i];
          }
        }
      },
      lastElementChild: {
        get: function () {
          for(var
            childNodes = this.childNodes || [],
            i = childNodes.length;
            i--;
          ) {
            if (childNodes[i].nodeType == 1) return childNodes[i];
          }
        }
      },
      oninput: {
        get: function () {
          return this._oninput || null;
        },
        set: function (oninput) {
          if (this._oninput) {
            this.removeEventListener('input', this._oninput);
            this._oninput = oninput;
            if (oninput) {
              this.addEventListener('input', oninput);
            }
          }
        }
      },
      previousElementSibling: {
        get: function () {
          var previousElementSibling = this.previousSibling;
          while (previousElementSibling && previousElementSibling.nodeType != 1) {
            previousElementSibling = previousElementSibling.previousSibling;
          }
          return previousElementSibling;
        }
      },
      nextElementSibling: {
        get: function () {
          var nextElementSibling = this.nextSibling;
          while (nextElementSibling && nextElementSibling.nodeType != 1) {
            nextElementSibling = nextElementSibling.nextSibling;
          }
          return nextElementSibling;
        }
      },
      childElementCount: {
        get: function () {
          for(var
            count = 0,
            childNodes = this.childNodes || [],
            i = childNodes.length; i--; count += childNodes[i].nodeType == 1
          );
          return count;
        }
      },
      /*
      // children would be an override
      // IE8 already supports them but with comments too
      // not just nodeType 1
      children: {
        get: function () {
          for(var
            children = [],
            childNodes = this.childNodes || [],
            i = 0, length = childNodes.length;
            i < length; i++
          ) {
            if (childNodes[i].nodeType == 1) {
              children.push(childNodes[i]);
            }
          }
          return children;
        }
      },
      */
      // DOM Level 2 EventTarget methods and events
      addEventListener: {value: function (type, handler, capture) {
        if (typeof handler !== 'function' && typeof handler !== 'object') return;
        var
          self = this,
          ontype = 'on' + type,
          temple =  self[SECRET] ||
                      defineProperty(
                        self, SECRET, {value: {}}
                      )[SECRET],
          currentType = temple[ontype] || (temple[ontype] = {}),
          handlers  = currentType.h || (currentType.h = []),
          e, attr
        ;
        if (!hasOwnProperty.call(currentType, 'w')) {
          currentType.w = function (e) {
            // e[SECRET] is a silent notification needed to avoid
            // fired events during live test
            return e[SECRET] || commonEventLoop(self, verify(self, e), handlers, false);
          };
          // if not detected yet
          if (!hasOwnProperty.call(types, ontype)) {
            // and potentially a native event
            if(possiblyNativeEvent.test(type)) {
              // do this heavy thing
              try {
                // TODO:  should I consider tagName too so that
                //        INPUT[ontype] could be different ?
                e = document.createEventObject();
                // do not clone ever a node
                // specially a document one ...
                // use the secret to ignore them all
                e[SECRET] = true;
                // document a part if a node has never been
                // added to any other node, fireEvent might
                // behave very weirdly (read: trigger unspecified errors)
                if (self.nodeType != 9) {
                  if (self.parentNode == null) {
                    div.appendChild(self);
                  }
                  if (attr = self.getAttribute(ontype)) {
                    removeAttribute.call(self, ontype);
                  }
                }
                self.fireEvent(ontype, e);
                types[ontype] = true;
              } catch(e) {
                types[ontype] = false;
                while (div.hasChildNodes()) {
                  div.removeChild(div.firstChild);
                }
              }
              if (attr != null) {
                setAttribute.call(self, ontype, attr);
              }
            } else {
              // no need to bother since
              // 'x-event' ain't native for sure
              types[ontype] = false;
            }
          }
          if (currentType.n = types[ontype]) {
            self.attachEvent(ontype, currentType.w);
          }
        }
        if (find(handlers, handler) < 0) {
          handlers[capture ? 'unshift' : 'push'](handler);
        }
        if (type === 'input') {
          self.attachEvent('onkeyup', onkeyup);
        }
      }},
      dispatchEvent: {value: function (e) {
        var
          self = this,
          ontype = 'on' + e.type,
          temple =  self[SECRET],
          currentType = temple && temple[ontype],
          valid = !!currentType,
          parentNode
        ;
        if (!e.target) e.target = self;
        return (valid ? (
          currentType.n /* && live(self) */ ?
            self.fireEvent(ontype, e) :
            commonEventLoop(
              self,
              e,
              currentType.h,
              true
            )
        ) : (
          (parentNode = self.parentNode) /* && live(self) */ ?
            parentNode.dispatchEvent(e) :
            true
        )), !e.defaultPrevented;
      }},
      removeEventListener: {value: function (type, handler, capture) {
        if (typeof handler !== 'function' && typeof handler !== 'object') return;
        var
          self = this,
          ontype = 'on' + type,
          temple =  self[SECRET],
          currentType = temple && temple[ontype],
          handlers = currentType && currentType.h,
          i = handlers ? find(handlers, handler) : -1
        ;
        if (-1 < i) handlers.splice(i, 1);
      }}
    }
  );

  /* this is not needed in IE8
  defineProperties(window.HTMLSelectElement.prototype, {
    value: {
      get: function () {
        return this.options[this.selectedIndex].value;
      }
    }
  });
  //*/

  // EventTarget methods for Text nodes too
  defineProperties(TextPrototype, {
    addEventListener: {value: ElementPrototype.addEventListener},
    dispatchEvent: {value: ElementPrototype.dispatchEvent},
    removeEventListener: {value: ElementPrototype.removeEventListener}
  });

  defineProperties(
    window.XMLHttpRequest.prototype,
    {
      addEventListener: {value: function (type, handler, capture) {
        var
          self = this,
          ontype = 'on' + type,
          temple =  self[SECRET] ||
                      defineProperty(
                        self, SECRET, {value: {}}
                      )[SECRET],
          currentType = temple[ontype] || (temple[ontype] = {}),
          handlers  = currentType.h || (currentType.h = [])
        ;
        if (find(handlers, handler) < 0) {
          if (!self[ontype]) {
            self[ontype] = function () {
              var e = document.createEvent('Event');
              e.initEvent(type, true, true);
              self.dispatchEvent(e);
            };
          }
          handlers[capture ? 'unshift' : 'push'](handler);
        }
      }},
      dispatchEvent: {value: function (e) {
        var
          self = this,
          ontype = 'on' + e.type,
          temple =  self[SECRET],
          currentType = temple && temple[ontype],
          valid = !!currentType
        ;
        return valid && (
          currentType.n /* && live(self) */ ?
            self.fireEvent(ontype, e) :
            commonEventLoop(
              self,
              e,
              currentType.h,
              true
            )
        );
      }},
      removeEventListener: {value: ElementPrototype.removeEventListener}
    }
  );

  defineProperties(
    window.Event.prototype,
    {
      bubbles: {value: true, writable: true},
      cancelable: {value: true, writable: true},
      preventDefault: {value: function () {
        if (this.cancelable) {
          this.defaultPrevented = true;
          this.returnValue = false;
        }
      }},
      stopPropagation: {value: function () {
        this.stoppedPropagation = true;
        this.cancelBubble = true;
      }},
      stopImmediatePropagation: {value: function () {
        this.stoppedImmediatePropagation = true;
        this.stopPropagation();
      }},
      initEvent: {value: function(type, bubbles, cancelable){
        this.type = type;
        this.bubbles = !!bubbles;
        this.cancelable = !!cancelable;
        if (!this.bubbles) {
          this.stopPropagation();
        }
      }}
    }
  );

  defineProperties(
    window.HTMLDocument.prototype,
    {
      defaultView: {
        get: function () {
          return this.parentWindow;
        }
      },
      textContent: {
        get: function () {
          return this.nodeType === 11 ? getTextContent.call(this) : null;
        },
        set: function (textContent) {
          if (this.nodeType === 11) {
            setTextContent.call(this, textContent);
          }
        }
      },
      addEventListener: {value: function(type, handler, capture) {
        var self = this;
        ElementPrototype.addEventListener.call(self, type, handler, capture);
        // NOTE:  it won't fire if already loaded, this is NOT a $.ready() shim!
        //        this behaves just like standard browsers
        if (
          DUNNOABOUTDOMLOADED &&
          type === DOMCONTENTLOADED &&
          !readyStateOK.test(
            self.readyState
          )
        ) {
          DUNNOABOUTDOMLOADED = false;
          self.attachEvent(ONREADYSTATECHANGE, onReadyState);
          if (window == top) {
            (function gonna(e){try{
              self.documentElement.doScroll('left');
              onReadyState();
              }catch(o_O){
              setTimeout(gonna, 50);
            }}());
          }
        }
      }},
      dispatchEvent: {value: ElementPrototype.dispatchEvent},
      removeEventListener: {value: ElementPrototype.removeEventListener},
      createEvent: {value: function(Class){
        var e;
        if (Class !== 'Event') throw new Error('unsupported ' + Class);
        e = document.createEventObject();
        e.timeStamp = (new Date).getTime();
        return e;
      }}
    }
  );

  defineProperties(
    window.Window.prototype,
    {
      getComputedStyle: {value: function(){

        var // partially grabbed from jQuery and Dean's hack
          notpixel = /^(?:[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|))(?!px)[a-z%]+$/,
          position = /^(top|right|bottom|left)$/,
          re = /\-([a-z])/g,
          place = function (match, $1) {
            return $1.toUpperCase();
          }
        ;

        function ComputedStyle(_) {
          this._ = _;
        }

        ComputedStyle.prototype.getPropertyValue = function (name) {
          var
            el = this._,
            style = el.style,
            currentStyle = el.currentStyle,
            runtimeStyle = el.runtimeStyle,
            result,
            left,
            rtLeft
          ;
          name = (name === 'float' ? 'style-float' : name).replace(re, place);
          result = currentStyle ? currentStyle[name] : style[name];
          if (notpixel.test(result) && !position.test(name)) {
            left = style.left;
            rtLeft = runtimeStyle && runtimeStyle.left;
            if (rtLeft) {
              runtimeStyle.left = currentStyle.left;
            }
            style.left = name === 'fontSize' ? '1em' : result;
            result = style.pixelLeft + 'px';
            style.left = left;
            if (rtLeft) {
              runtimeStyle.left = rtLeft;
            }
          }
          return result == null ?
            result : ((result + '') || 'auto');
        };

        // unsupported
        function PseudoComputedStyle() {}
        PseudoComputedStyle.prototype.getPropertyValue = function () {
          return null;
        };

        return function (el, pseudo) {
          return pseudo ?
            new PseudoComputedStyle(el) :
            new ComputedStyle(el);
        };

      }()},

      addEventListener: {value: function (type, handler, capture) {
        var
          self = window,
          ontype = 'on' + type,
          handlers
        ;
        if (!self[ontype]) {
          self[ontype] = function(e) {
            return commonEventLoop(self, verify(self, e), handlers, false);
          };
        }
        handlers = self[ontype][SECRET] || (
          self[ontype][SECRET] = []
        );
        if (find(handlers, handler) < 0) {
          handlers[capture ? 'unshift' : 'push'](handler);
        }
      }},
      dispatchEvent: {value: function (e) {
        var method = window['on' + e.type];
        return method ? method.call(window, e) !== false && !e.defaultPrevented : true;
      }},
      removeEventListener: {value: function (type, handler, capture) {
        var
          ontype = 'on' + type,
          handlers = (window[ontype] || Object)[SECRET],
          i = handlers ? find(handlers, handler) : -1
         ;
        if (-1 < i) handlers.splice(i, 1);
      }}
    }
  );

  (function (styleSheets, HTML5Element, i) {
    for (i = 0; i < HTML5Element.length; i++) document.createElement(HTML5Element[i]);
    if (!styleSheets.length) document.createStyleSheet('');
    styleSheets[0].addRule(HTML5Element.join(','), 'display:block;');
  }(document.styleSheets, ['header', 'nav', 'section', 'article', 'aside', 'footer']));
}(this.window || global));
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}],195:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } }

var _path = require('./path');

var _path2 = _interopRequireDefault(_path);

var _polygon = require('./polygon');

var _polygon2 = _interopRequireDefault(_polygon);

var _ops = require('./ops');

var reflect = function reflect(p, q) {
  return (0, _ops.minus)((0, _ops.times)(2, p), q);
};

exports['default'] = function (_ref) {
  var _Path;

  var points = _ref.points;
  var tension = _ref.tension;

  tension = tension || 0.3;
  var diffs = [];
  var l = points.length;
  if (l <= 2) {
    return (0, _polygon2['default'])({ points: points });
  }
  for (var i = 1; i <= l - 1; i++) {
    diffs.push((0, _ops.times)(tension, (0, _ops.minus)(points[i], points[i - 1])));
  }
  var controlPoints = [(0, _ops.plus)(points[0], reflect(diffs[0], diffs[1]))];
  for (var i = 1; i <= l - 2; i++) {
    controlPoints.push((0, _ops.minus)(points[i], (0, _ops.average)([diffs[i], diffs[i - 1]])));
  }
  controlPoints.push((0, _ops.minus)(points[l - 1], reflect(diffs[l - 2], diffs[l - 3])));
  var c0 = controlPoints[0];
  var c1 = controlPoints[1];
  var p0 = points[0];
  var p1 = points[1];
  var path = (_Path = (0, _path2['default'])()).moveto.apply(_Path, _toConsumableArray(p0)).curveto(c0[0], c0[1], c1[0], c1[1], p1[0], p1[1]);

  return {
    path: (0, _ops.range)(2, l).reduce(function (pt, i) {
      var c = controlPoints[i];
      var p = points[i];
      return pt.smoothcurveto(c[0], c[1], p[0], p[1]);
    }, path),
    centroid: (0, _ops.average)(points)
  };
};

module.exports = exports['default'];
},{"./ops":198,"./path":199,"./polygon":200}],196:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i['return']) _i['return'](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError('Invalid attempt to destructure non-iterable instance'); } }; })();

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

var _linear = require('./linear');

var _linear2 = _interopRequireDefault(_linear);

var _ops = require('./ops');

var epsilon = 1e-5;

var box = function box(datum, accessor) {
  var points = datum.map(accessor);
  var sorted = points.sort(function (_ref, _ref3) {
    var _ref2 = _slicedToArray(_ref, 2);

    var a = _ref2[0];
    var b = _ref2[1];

    var _ref32 = _slicedToArray(_ref3, 2);

    var c = _ref32[0];
    var d = _ref32[1];
    return a - c;
  });
  var l = sorted.length;
  var xmin = sorted[0][0];
  var xmax = sorted[l - 1][0];
  var ymin = (0, _ops.minBy)(sorted, function (p) {
    return p[1];
  });
  var ymax = (0, _ops.maxBy)(sorted, function (p) {
    return p[1];
  });
  if (xmin == xmax) {
    xmax += epsilon;
  }
  if (ymin == ymax) {
    ymax += epsilon;
  }

  return {
    points: sorted,
    xmin: xmin,
    xmax: xmax,
    ymin: ymin,
    ymax: ymax
  };
};

exports['default'] = function (_ref4) {
  var data = _ref4.data;
  var xaccessor = _ref4.xaccessor;
  var yaccessor = _ref4.yaccessor;
  var width = _ref4.width;
  var height = _ref4.height;
  var closed = _ref4.closed;
  var min = _ref4.min;
  var max = _ref4.max;

  if (!xaccessor) {
    xaccessor = function (_ref5) {
      var _ref52 = _slicedToArray(_ref5, 2);

      var x = _ref52[0];
      var y = _ref52[1];
      return x;
    };
  }
  if (!yaccessor) {
    yaccessor = function (_ref6) {
      var _ref62 = _slicedToArray(_ref6, 2);

      var x = _ref62[0];
      var y = _ref62[1];
      return y;
    };
  }
  var f = function f(i) {
    return [xaccessor(i), yaccessor(i)];
  };
  var arranged = data.map(function (datum) {
    return box(datum, f);
  });

  var xmin = (0, _ops.minBy)(arranged, function (d) {
    return d.xmin;
  });
  var xmax = (0, _ops.maxBy)(arranged, function (d) {
    return d.xmax;
  });
  var ymin = min == null ? (0, _ops.minBy)(arranged, function (d) {
    return d.ymin;
  }) : min;
  var ymax = max == null ? (0, _ops.maxBy)(arranged, function (d) {
    return d.ymax;
  }) : max;
  if (closed) {
    ymin = Math.min(ymin, 0);
    ymax = Math.max(ymax, 0);
  }
  var base = closed ? 0 : ymin;
  var xscale = (0, _linear2['default'])([xmin, xmax], [0, width]);
  var yscale = (0, _linear2['default'])([ymin, ymax], [height, 0]);
  var scale = function scale(_ref7) {
    var _ref72 = _slicedToArray(_ref7, 2);

    var x = _ref72[0];
    var y = _ref72[1];
    return [xscale(x), yscale(y)];
  };

  return {
    arranged: arranged,
    scale: scale,
    xscale: xscale,
    yscale: yscale,
    base: base
  };
};

module.exports = exports['default'];
},{"./linear":197,"./ops":198}],197:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; })();

var linear = function linear(_ref, _ref3) {
  var _ref2 = _slicedToArray(_ref, 2);

  var a = _ref2[0];
  var b = _ref2[1];

  var _ref32 = _slicedToArray(_ref3, 2);

  var c = _ref32[0];
  var d = _ref32[1];

  var f = function f(x) {
    return c + (d - c) * (x - a) / (b - a);
  };

  f.inverse = function () {
    return linear([c, d], [a, b]);
  };
  return f;
};

exports["default"] = linear;
module.exports = exports["default"];
},{}],198:[function(require,module,exports){
"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; })();

var sum = function sum(xs) {
  return xs.reduce(function (a, b) {
    return a + b;
  }, 0);
};

var min = function min(xs) {
  return xs.reduce(function (a, b) {
    return Math.min(a, b);
  });
};

var max = function max(xs) {
  return xs.reduce(function (a, b) {
    return Math.max(a, b);
  });
};

var sumBy = function sumBy(xs, f) {
  return xs.reduce(function (a, b) {
    return a + f(b);
  }, 0);
};

var minBy = function minBy(xs, f) {
  return xs.reduce(function (a, b) {
    return Math.min(a, f(b));
  }, Infinity);
};

var maxBy = function maxBy(xs, f) {
  return xs.reduce(function (a, b) {
    return Math.max(a, f(b));
  }, -Infinity);
};

var plus = function plus(_ref, _ref3) {
  var _ref2 = _slicedToArray(_ref, 2);

  var a = _ref2[0];
  var b = _ref2[1];

  var _ref32 = _slicedToArray(_ref3, 2);

  var c = _ref32[0];
  var d = _ref32[1];
  return [a + c, b + d];
};

var minus = function minus(_ref4, _ref5) {
  var _ref42 = _slicedToArray(_ref4, 2);

  var a = _ref42[0];
  var b = _ref42[1];

  var _ref52 = _slicedToArray(_ref5, 2);

  var c = _ref52[0];
  var d = _ref52[1];
  return [a - c, b - d];
};

var times = function times(k, _ref6) {
  var _ref62 = _slicedToArray(_ref6, 2);

  var a = _ref62[0];
  var b = _ref62[1];
  return [k * a, k * b];
};

var length = function length(_ref7) {
  var _ref72 = _slicedToArray(_ref7, 2);

  var a = _ref72[0];
  var b = _ref72[1];
  return Math.sqrt(a * a + b * b);
};

var sumVectors = function sumVectors(xs) {
  return xs.reduce(plus, [0, 0]);
};

var average = function average(points) {
  return times(1 / points.length, points.reduce(plus));
};

var onCircle = function onCircle(r, angle) {
  return times(r, [Math.sin(angle), -Math.cos(angle)]);
};

var enhance = function enhance(compute, curve) {
  var obj = compute || {};
  for (var key in obj) {
    var method = obj[key];
    curve[key] = method(curve.index, curve.item, curve.group);
  }
  return curve;
};

var range = function range(a, b, inclusive) {
  var result = [];
  for (var i = a; i < b; i++) {
    result.push(i);
  }
  if (inclusive) {
    result.push(b);
  }
  return result;
};

var mapObject = function mapObject(obj, f) {
  var result = [];
  var _iteratorNormalCompletion = true;
  var _didIteratorError = false;
  var _iteratorError = undefined;

  try {
    for (var _iterator = Object.keys(obj)[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
      var k = _step.value;

      var v = obj[k];
      result.push(f(k, v));
    }
  } catch (err) {
    _didIteratorError = true;
    _iteratorError = err;
  } finally {
    try {
      if (!_iteratorNormalCompletion && _iterator["return"]) {
        _iterator["return"]();
      }
    } finally {
      if (_didIteratorError) {
        throw _iteratorError;
      }
    }
  }

  return result;
};

var pairs = function pairs(obj) {
  return mapObject(obj, function (k, v) {
    return [k, v];
  });
};

var id = function id(x) {
  return x;
};

exports.sum = sum;
exports.min = min;
exports.max = max;
exports.sumBy = sumBy;
exports.minBy = minBy;
exports.maxBy = maxBy;
exports.plus = plus;
exports.minus = minus;
exports.times = times;
exports.id = id;
exports.length = length;
exports.sumVectors = sumVectors;
exports.average = average;
exports.onCircle = onCircle;
exports.enhance = enhance;
exports.range = range;
exports.mapObject = mapObject;
exports.pairs = pairs;
exports["default"] = { sum: sum, min: min, max: max, sumBy: sumBy, minBy: minBy, maxBy: maxBy, plus: plus, minus: minus, times: times, id: id,
  length: length, sumVectors: sumVectors, average: average, onCircle: onCircle, enhance: enhance, range: range, mapObject: mapObject, pairs: pairs };
},{}],199:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i['return']) _i['return'](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError('Invalid attempt to destructure non-iterable instance'); } }; })();

var Path = function Path(init) {
  var _instructions = init || [];

  var push = function push(arr, el) {
    var copy = arr.slice(0, arr.length);
    copy.push(el);
    return copy;
  };

  var areEqualPoints = function areEqualPoints(_ref, _ref3) {
    var _ref2 = _slicedToArray(_ref, 2);

    var a1 = _ref2[0];
    var b1 = _ref2[1];

    var _ref32 = _slicedToArray(_ref3, 2);

    var a2 = _ref32[0];
    var b2 = _ref32[1];
    return a1 === a2 && b1 === b2;
  };

  var trimZeros = function trimZeros(string, char) {
    var l = string.length;
    while (string.charAt(l - 1) === '0') {
      l = l - 1;
    }
    if (string.charAt(l - 1) === '.') {
      l = l - 1;
    }
    return string.substr(0, l);
  };

  var round = function round(number, digits) {
    var str = number.toFixed(digits);
    return trimZeros(str);
  };

  var printInstrunction = function printInstrunction(_ref4) {
    var command = _ref4.command;
    var params = _ref4.params;

    var numbers = params.map(function (param) {
      return round(param, 6);
    });
    return command + ' ' + numbers.join(' ');
  };

  var point = function point(_ref5, _ref6) {
    var command = _ref5.command;
    var params = _ref5.params;

    var _ref62 = _slicedToArray(_ref6, 2);

    var prevX = _ref62[0];
    var prevY = _ref62[1];

    switch (command) {
      case 'M':
        return [params[0], params[1]];
      case 'L':
        return [params[0], params[1]];
      case 'H':
        return [params[0], prevY];
      case 'V':
        return [prevX, params[0]];
      case 'Z':
        return null;
      case 'C':
        return [params[4], params[5]];
      case 'S':
        return [params[2], params[3]];
      case 'Q':
        return [params[2], params[3]];
      case 'T':
        return [params[0], params[1]];
      case 'A':
        return [params[5], params[6]];
    }
  };

  var verbosify = function verbosify(keys, f) {
    return function (a) {
      var args = typeof a === 'object' ? keys.map(function (k) {
        return a[k];
      }) : arguments;
      return f.apply(null, args);
    };
  };

  var plus = function plus(instruction) {
    return Path(push(_instructions, instruction));
  };

  return {
    moveto: verbosify(['x', 'y'], function (x, y) {
      return plus({
        command: 'M',
        params: [x, y]
      });
    }),
    lineto: verbosify(['x', 'y'], function (x, y) {
      return plus({
        command: 'L',
        params: [x, y]
      });
    }),
    hlineto: verbosify(['x'], function (x) {
      return plus({
        command: 'H',
        params: [x]
      });
    }),
    vlineto: verbosify(['y'], function (y) {
      return plus({
        command: 'V',
        params: [y]
      });
    }),
    closepath: function closepath() {
      return plus({
        command: 'Z',
        params: []
      });
    },
    curveto: verbosify(['x1', 'y1', 'x2', 'y2', 'x', 'y'], function (x1, y1, x2, y2, x, y) {
      return plus({
        command: 'C',
        params: [x1, y1, x2, y2, x, y]
      });
    }),
    smoothcurveto: verbosify(['x2', 'y2', 'x', 'y'], function (x2, y2, x, y) {
      return plus({
        command: 'S',
        params: [x2, y2, x, y]
      });
    }),
    qcurveto: verbosify(['x1', 'y1', 'x', 'y'], function (x1, y1, x, y) {
      return plus({
        command: 'Q',
        params: [x1, y1, x, y]
      });
    }),
    smoothqcurveto: verbosify(['x', 'y'], function (x, y) {
      return plus({
        command: 'T',
        params: [x, y]
      });
    }),
    arc: verbosify(['rx', 'ry', 'xrot', 'largeArcFlag', 'sweepFlag', 'x', 'y'], function (rx, ry, xrot, largeArcFlag, sweepFlag, x, y) {
      return plus({
        command: 'A',
        params: [rx, ry, xrot, largeArcFlag, sweepFlag, x, y]
      });
    }),
    print: function print() {
      return _instructions.map(printInstrunction).join(' ');
    },
    points: function points() {
      var ps = [];
      var prev = [0, 0];
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = _instructions[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var instruction = _step.value;

          var p = point(instruction, prev);
          prev = p;
          if (p) {
            ps.push(p);
          }
        }
      } catch (err) {
        _didIteratorError = true;
        _iteratorError = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion && _iterator['return']) {
            _iterator['return']();
          }
        } finally {
          if (_didIteratorError) {
            throw _iteratorError;
          }
        }
      }

      return ps;
    },
    instructions: function instructions() {
      return _instructions.slice(0, _instructions.length);
    },
    connect: function connect(path) {
      var ps = this.points();
      var last = ps[ps.length - 1];
      var first = path.points()[0];
      var newInstructions = path.instructions().slice(1);
      if (!areEqualPoints(last, first)) {
        newInstructions.unshift({
          command: "L",
          params: first
        });
      }
      return Path(this.instructions().concat(newInstructions));
    }
  };
};

exports['default'] = function () {
  return Path();
};

module.exports = exports['default'];
},{}],200:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } }

var _path = require('./path');

var _path2 = _interopRequireDefault(_path);

var _ops = require('./ops');

exports['default'] = function (_ref) {
  var _Path;

  var points = _ref.points;
  var closed = _ref.closed;

  var l = points.length;
  var head = points[0];
  var tail = points.slice(1, l + 1);
  var path = tail.reduce(function (pt, p) {
    return pt.lineto.apply(pt, _toConsumableArray(p));
  }, (_Path = (0, _path2['default'])()).moveto.apply(_Path, _toConsumableArray(head)));

  return {
    path: closed ? path.closepath() : path,
    centroid: (0, _ops.average)(points)
  };
};

module.exports = exports['default'];
},{"./ops":198,"./path":199}],201:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, '__esModule', {
  value: true
});

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i]; return arr2; } else { return Array.from(arr); } }

var _bezier = require('./bezier');

var _bezier2 = _interopRequireDefault(_bezier);

var _lineChartComp = require('./line-chart-comp');

var _lineChartComp2 = _interopRequireDefault(_lineChartComp);

var _ops = require('./ops');

exports['default'] = function (options) {
  var _comp = (0, _lineChartComp2['default'])(options);

  var arranged = _comp.arranged;
  var scale = _comp.scale;
  var xscale = _comp.xscale;
  var yscale = _comp.yscale;
  var base = _comp.base;

  var i = -1;

  var lines = arranged.map(function (_ref) {
    var _line$path$lineto, _line$path;

    var points = _ref.points;
    var xmin = _ref.xmin;
    var xmax = _ref.xmax;

    var scaledPoints = points.map(scale);
    i += 1;
    var line = (0, _bezier2['default'])({ points: scaledPoints });
    var area = {
      path: (_line$path$lineto = (_line$path = line.path).lineto.apply(_line$path, _toConsumableArray(scale([xmax, base])))).lineto.apply(_line$path$lineto, _toConsumableArray(scale([xmin, base]))).closepath(),
      centroid: (0, _ops.average)([line.centroid, scale([xmin, base]), scale([xmax, base])])
    };

    return (0, _ops.enhance)(options.compute, {
      item: options.data[i],
      line: line,
      area: area,
      index: i
    });
  });

  return {
    curves: lines,
    xscale: xscale,
    yscale: yscale
  };
};

module.exports = exports['default'];
},{"./bezier":195,"./line-chart-comp":196,"./ops":198}],202:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it don't break things.
var cachedSetTimeout = setTimeout;
var cachedClearTimeout = clearTimeout;

var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = cachedSetTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while(len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    cachedClearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        cachedSetTimeout(drainQueue, 0);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function() { return 0; };

},{}],203:[function(require,module,exports){
(function (global, factory) {
	typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports) :
	typeof define === 'function' && define.amd ? define(['exports'], factory) :
	factory(global.Ractive.events)
}(this, function (exports) { 'use strict';

	// TODO can we just declare the keydowhHandler once? using `this`?
	function makeKeyDefinition(code) {
		return function (node, fire) {
			function keydownHandler(event) {
				var which = event.which || event.keyCode;

				if (which === code) {
					event.preventDefault();

					fire({
						node: node,
						original: event
					});
				}
			}

			node.addEventListener('keydown', keydownHandler, false);

			return {
				teardown: function teardown() {
					node.removeEventListener('keydown', keydownHandler, false);
				}
			};
		};
	}

	var enter = makeKeyDefinition(13);
	var tab = makeKeyDefinition(9);
	var ractive_events_keys__escape = makeKeyDefinition(27);
	var space = makeKeyDefinition(32);

	var leftarrow = makeKeyDefinition(37);
	var rightarrow = makeKeyDefinition(39);
	var downarrow = makeKeyDefinition(40);
	var uparrow = makeKeyDefinition(38);

	exports.enter = enter;
	exports.tab = tab;
	exports.escape = ractive_events_keys__escape;
	exports.space = space;
	exports.leftarrow = leftarrow;
	exports.rightarrow = rightarrow;
	exports.downarrow = downarrow;
	exports.uparrow = uparrow;

}));
},{}],204:[function(require,module,exports){
(function (global, factory) {
	typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
	typeof define === 'function' && define.amd ? define(factory) :
	global.Ractive.transitions.fade = factory();
}(this, function () { 'use strict';

	var DEFAULTS = {
		delay: 0,
		duration: 300,
		easing: 'linear'
	};

	function fade(t, params) {
		var targetOpacity;

		params = t.processParams(params, DEFAULTS);

		if (t.isIntro) {
			targetOpacity = t.getStyle('opacity');
			t.setStyle('opacity', 0);
		} else {
			targetOpacity = 0;
		}

		t.animateStyle('opacity', targetOpacity, params).then(t.complete);
	}

	return fade;

}));
},{}],205:[function(require,module,exports){
(function (global){
(function (global){
/*
	Ractive.js v0.8.1
	Sun Jun 12 2016 06:39:02 GMT-0700 (Pacific Daylight Time) - commit 590cb66aaa2e7857925939e5109b1d7cf2d1267d

	http://ractivejs.org
	http://twitter.com/RactiveJS

	Released under the MIT License.
*/


(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  ((function() { var current = global.Ractive; var next = factory(); next.noConflict = function() { global.Ractive = current; return next; }; return global.Ractive = next; })());
}(this, function () { 'use strict';

  var defaults = {
  	// render placement:
  	el:                     void 0,
  	append:				    false,

  	// template:
  	template:               null,

  	// parse:
  	delimiters:             [ '{{', '}}' ],
  	tripleDelimiters:       [ '{{{', '}}}' ],
  	staticDelimiters:       [ '[[', ']]' ],
  	staticTripleDelimiters: [ '[[[', ']]]' ],
  	csp: 					true,
  	interpolate:            false,
  	preserveWhitespace:     false,
  	sanitize:               false,
  	stripComments:          true,

  	// data & binding:
  	data:                   {},
  	computed:               {},
  	magic:                  false,
  	modifyArrays:           true,
  	adapt:                  [],
  	isolated:               false,
  	twoway:                 true,
  	lazy:                   false,

  	// transitions:
  	noIntro:                false,
  	transitionsEnabled:     true,
  	complete:               void 0,

  	// css:
  	css:                    null,
  	noCssTransform:         false
  };

  // These are a subset of the easing equations found at
  // https://raw.github.com/danro/easing-js - license info
  // follows:

  // --------------------------------------------------
  // easing.js v0.5.4
  // Generic set of easing functions with AMD support
  // https://github.com/danro/easing-js
  // This code may be freely distributed under the MIT license
  // http://danro.mit-license.org/
  // --------------------------------------------------
  // All functions adapted from Thomas Fuchs & Jeremy Kahn
  // Easing Equations (c) 2003 Robert Penner, BSD license
  // https://raw.github.com/danro/easing-js/master/LICENSE
  // --------------------------------------------------

  // In that library, the functions named easeIn, easeOut, and
  // easeInOut below are named easeInCubic, easeOutCubic, and
  // (you guessed it) easeInOutCubic.
  //
  // You can add additional easing functions to this list, and they
  // will be globally available.


  var easing = {
  	linear: function ( pos ) { return pos; },
  	easeIn: function ( pos ) { return Math.pow( pos, 3 ); },
  	easeOut: function ( pos ) { return ( Math.pow( ( pos - 1 ), 3 ) + 1 ); },
  	easeInOut: function ( pos ) {
  		if ( ( pos /= 0.5 ) < 1 ) { return ( 0.5 * Math.pow( pos, 3 ) ); }
  		return ( 0.5 * ( Math.pow( ( pos - 2 ), 3 ) + 2 ) );
  	}
  };

  /*global console, navigator */

  var win = typeof window !== 'undefined' ? window : null;
  var doc = win ? document : null;

  var isClient = !!doc;
  var isJsdom = ( typeof navigator !== 'undefined' && /jsDom/.test( navigator.appName ) );
  var hasConsole = ( typeof console !== 'undefined' && typeof console.warn === 'function' && typeof console.warn.apply === 'function' );

  var magicSupported;
  try {
  	Object.defineProperty({}, 'test', { value: 0 });
  	magicSupported = true;
  } catch ( e ) {
  	magicSupported = false;
  }

  var svg = doc ?
  	doc.implementation.hasFeature( 'http://www.w3.org/TR/SVG11/feature#BasicStructure', '1.1' ) :
  	false;

  var vendors = [ 'o', 'ms', 'moz', 'webkit' ];

  function noop () {}

  var exportedShims;

  if ( !win ) {
  	exportedShims = null;
  } else {
  	exportedShims = {};

  	// Shims for older browsers

  	if ( !Date.now ) {
  		Date.now = function () { return +new Date(); };
  	}

  	if ( !String.prototype.trim ) {
  		String.prototype.trim = function () {
  			return this.replace(/^\s+/, '').replace(/\s+$/, '');
  		};
  	}

  	// Polyfill for Object.create
  	if ( !Object.create ) {
  		Object.create = (function () {
  			var Temp = function () {};
  			return function ( prototype, properties ) {
  				if ( typeof prototype !== 'object' ) {
  					throw new TypeError( 'Prototype must be an object' );
  				}
  				Temp.prototype = prototype;
  				var result = new Temp();
  				defineProperties( result, properties );
  				Temp.prototype = null;
  				return result;
  			};
  		})();
  	}

  	// Polyfill Object.defineProperty
  	if ( !Object.defineProperty ) {
  		Object.defineProperty = defineProperty;
  	}

  	if ( !Object.freeze ) {
  		Object.freeze = function () { 'LOL'; };
  	}

  	// Polyfill for Object.keys
  	// https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Object/keys
  	if ( !Object.keys ) {
  		Object.keys = (function () {
  			var hasOwnProperty = Object.prototype.hasOwnProperty,
  				hasDontEnumBug = !({toString: null}).propertyIsEnumerable('toString'),
  				dontEnums = [
  					'toString',
  					'toLocaleString',
  					'valueOf',
  					'hasOwnProperty',
  					'isPrototypeOf',
  					'propertyIsEnumerable',
  					'constructor'
  				],
  				dontEnumsLength = dontEnums.length;

  			return function ( obj ) {
  				if ( typeof obj !== 'object' && typeof obj !== 'function' || obj === null ) {
  					throw new TypeError( 'Object.keys called on non-object' );
  				}

  				var result = [];

  				for ( var prop in obj ) {
  					if ( hasOwnProperty.call( obj, prop ) ){
  						result.push( prop );
  					}
  				}

  				if ( hasDontEnumBug ) {
  					for ( var i=0; i < dontEnumsLength; i++ ) {
  						if ( hasOwnProperty.call( obj, dontEnums[i] ) ){
  							result.push( dontEnums[i] );
  						}
  					}
  				}
  				return result;
  			};
  		}());
  	}

  	// TODO: use defineProperty to make these non-enumerable

  	// Array extras
  	if ( !Array.prototype.indexOf ) {
  		Array.prototype.indexOf = function ( needle, i ) {
  			var this$1 = this;

  			var len;

  			if ( i === undefined ) {
  				i = 0;
  			}

  			if ( i < 0 ) {
  				i+= this.length;
  			}

  			if ( i < 0 ) {
  				i = 0;
  			}

  			for ( len = this$1.length; i<len; i++ ) {
  				if ( this$1.hasOwnProperty( i ) && this$1[i] === needle ) {
  					return i;
  				}
  			}

  			return -1;
  		};
  	}

  	if ( !Array.prototype.forEach ) {
  		Array.prototype.forEach = function ( callback, context ) {
  			var this$1 = this;

  			var i, len;

  			for ( i=0, len=this$1.length; i<len; i+=1 ) {
  				if ( this$1.hasOwnProperty( i ) ) {
  					callback.call( context, this$1[i], i, this$1 );
  				}
  			}
  		};
  	}

  	if ( !Array.prototype.map ) {
  		Array.prototype.map = function ( mapper, context ) {
  			var array = this, i, len, mapped = [], isActuallyString;

  			// incredibly, if you do something like
  			// Array.prototype.map.call( someString, iterator )
  			// then `this` will become an instance of String in IE8.
  			// And in IE8, you then can't do string[i]. Facepalm.
  			if ( array instanceof String ) {
  				array = array.toString();
  				isActuallyString = true;
  			}

  			for ( i=0, len=array.length; i<len; i+=1 ) {
  				if ( array.hasOwnProperty( i ) || isActuallyString ) {
  					mapped[i] = mapper.call( context, array[i], i, array );
  				}
  			}

  			return mapped;
  		};
  	}

  	if ( typeof Array.prototype.reduce !== 'function' ) {
  		Array.prototype.reduce = function(callback, opt_initialValue){
  			var this$1 = this;

  			var i, value, len, valueIsSet;

  			if ('function' !== typeof callback) {
  				throw new TypeError(callback + ' is not a function');
  			}

  			len = this.length;
  			valueIsSet = false;

  			if ( arguments.length > 1 ) {
  				value = opt_initialValue;
  				valueIsSet = true;
  			}

  			for ( i = 0; i < len; i += 1) {
  				if ( this$1.hasOwnProperty( i ) ) {
  					if ( valueIsSet ) {
  						value = callback(value, this$1[i], i, this$1);
  					}
  				} else {
  					value = this$1[i];
  					valueIsSet = true;
  				}
  			}

  			if ( !valueIsSet ) {
  				throw new TypeError( 'Reduce of empty array with no initial value' );
  			}

  			return value;
  		};
  	}

  	if ( !Array.prototype.filter ) {
  		Array.prototype.filter = function ( filter, context ) {
  			var this$1 = this;

  			var i, len, filtered = [];

  			for ( i=0, len=this$1.length; i<len; i+=1 ) {
  				if ( this$1.hasOwnProperty( i ) && filter.call( context, this$1[i], i, this$1 ) ) {
  					filtered[ filtered.length ] = this$1[i];
  				}
  			}

  			return filtered;
  		};
  	}

  	if ( !Array.prototype.every ) {
  		Array.prototype.every = function ( iterator, context ) {
  			var t, len, i;

  			if ( this == null ) {
  				throw new TypeError();
  			}

  			t = Object( this );
  			len = t.length >>> 0;

  			if ( typeof iterator !== 'function' ) {
  				throw new TypeError();
  			}

  			for ( i = 0; i < len; i += 1 ) {
  				if ( i in t && !iterator.call( context, t[i], i, t) ) {
  					return false;
  				}
  			}

  			return true;
  		};
  	}

  	if ( typeof Function.prototype.bind !== 'function' ) {
  		Function.prototype.bind = function ( context ) {
  			var args, fn, Empty, bound, slice = [].slice;

  			if ( typeof this !== 'function' ) {
  				throw new TypeError( 'Function.prototype.bind called on non-function' );
  			}

  			args = slice.call( arguments, 1 );
  			fn = this;
  			Empty = function () {};

  			bound = function () {
  				var ctx = this instanceof Empty && context ? this : context;
  				return fn.apply( ctx, args.concat( slice.call( arguments ) ) );
  			};

  			Empty.prototype = this.prototype;
  			bound.prototype = new Empty();

  			return bound;
  		};
  	}

  	// https://gist.github.com/Rich-Harris/6010282 via https://gist.github.com/jonathantneal/2869388
  	// addEventListener polyfill IE6+
  	if ( !win.addEventListener ) {
  		((function(win, doc) {
  			var Event, addEventListener, removeEventListener, head, style, origCreateElement;

  			// because sometimes inquiring minds want to know
  			win.appearsToBeIELessEqual8 = true;

  			Event = function ( e, element ) {
  				var property, instance = this;

  				for ( property in e ) {
  					instance[ property ] = e[ property ];
  				}

  				instance.currentTarget =  element;
  				instance.target = e.srcElement || element;
  				instance.timeStamp = +new Date();

  				instance.preventDefault = function () {
  					e.returnValue = false;
  				};

  				instance.stopPropagation = function () {
  					e.cancelBubble = true;
  				};
  			};

  			addEventListener = function ( type, listener ) {
  				var element = this, listeners, i;

  				listeners = element.listeners || ( element.listeners = [] );
  				i = listeners.length;

  				listeners[i] = [ listener, function (e) {
  					listener.call( element, new Event( e, element ) );
  				}];

  				element.attachEvent( 'on' + type, listeners[i][1] );
  			};

  			removeEventListener = function ( type, listener ) {
  				var element = this, listeners, i;

  				if ( !element.listeners ) {
  					return;
  				}

  				listeners = element.listeners;
  				i = listeners.length;

  				while ( i-- ) {
  					if (listeners[i][0] === listener) {
  						element.detachEvent( 'on' + type, listeners[i][1] );
  					}
  				}
  			};

  			win.addEventListener = doc.addEventListener = addEventListener;
  			win.removeEventListener = doc.removeEventListener = removeEventListener;

  			if ( 'Element' in win ) {
  				win.Element.prototype.addEventListener = addEventListener;
  				win.Element.prototype.removeEventListener = removeEventListener;
  			} else {
  				// First, intercept any calls to document.createElement - this is necessary
  				// because the CSS hack (see below) doesn't come into play until after a
  				// node is added to the DOM, which is too late for a lot of Ractive setup work
  				origCreateElement = doc.createElement;

  				doc.createElement = function ( tagName ) {
  					var el = origCreateElement( tagName );
  					el.addEventListener = addEventListener;
  					el.removeEventListener = removeEventListener;
  					return el;
  				};

  				// Then, mop up any additional elements that weren't created via
  				// document.createElement (i.e. with innerHTML).
  				head = doc.getElementsByTagName('head')[0];
  				style = doc.createElement('style');

  				head.insertBefore( style, head.firstChild );

  				//style.styleSheet.cssText = '*{-ms-event-prototype:expression(!this.addEventListener&&(this.addEventListener=addEventListener)&&(this.removeEventListener=removeEventListener))}';
  			}
  		})( win, doc ));
  	}

  	// The getComputedStyle polyfill interacts badly with jQuery, so we don't attach
  	// it to window. Instead, we export it for other modules to use as needed

  	// https://github.com/jonathantneal/Polyfills-for-IE8/blob/master/getComputedStyle.js
  	if ( !win.getComputedStyle ) {
  		exportedShims.getComputedStyle = (function () {
  			var borderSizes = {};

  			function getPixelSize ( element, style, property, fontSize ) {
  				var sizeWithSuffix = style[property];
  				var size = parseFloat(sizeWithSuffix);
  				var suffix = sizeWithSuffix.split(/\d/)[0];

  				if ( isNaN( size ) ) {
  					if ( /^thin|medium|thick$/.test( sizeWithSuffix ) ) {
  						size = getBorderPixelSize( sizeWithSuffix );
  						suffix = '';
  					}

  					else {
  						// TODO...
  					}
  				}

  				fontSize = fontSize != null ? fontSize : /%|em/.test(suffix) && element.parentElement ? getPixelSize(element.parentElement, element.parentElement.currentStyle, 'fontSize', null) : 16;
  				var rootSize = property == 'fontSize' ? fontSize : /width/i.test(property) ? element.clientWidth : element.clientHeight;

  				return (suffix == 'em') ? size * fontSize : (suffix == 'in') ? size * 96 : (suffix == 'pt') ? size * 96 / 72 : (suffix == '%') ? size / 100 * rootSize : size;
  			}

  			function getBorderPixelSize ( size ) {
  				var div, bcr;

  				// `thin`, `medium` and `thick` vary between browsers. (Don't ever use them.)
  				if ( !borderSizes[ size ] ) {
  					div = doc.createElement( 'div' );
  					div.style.display = 'block';
  					div.style.position = 'fixed';
  					div.style.width = div.style.height = '0';
  					div.style.borderRight = size + ' solid black';

  					doc.getElementsByTagName( 'body' )[0].appendChild( div );
  					bcr = div.getBoundingClientRect();

  					borderSizes[ size ] = bcr.right - bcr.left;
  				}

  				return borderSizes[ size ];
  			}

  			function setShortStyleProperty(style, property) {
  				var borderSuffix = property == 'border' ? 'Width' : '';
  				var t = "" + property + "Top" + borderSuffix;
  				var r = "" + property + "Right" + borderSuffix;
  				var b = "" + property + "Bottom" + borderSuffix;
  				var l = "" + property + "Left" + borderSuffix;

  				style[property] = (style[t] == style[r] == style[b] == style[l] ? [style[t]]
  				: style[t] == style[b] && style[l] == style[r] ? [style[t], style[r]]
  				: style[l] == style[r] ? [style[t], style[r], style[b]]
  				: [style[t], style[r], style[b], style[l]]).join(' ');
  			}

  			var normalProps = {
  				fontWeight: 400,
  				lineHeight: 1.2, // actually varies depending on font-family, but is generally close enough...
  				letterSpacing: 0
  			};

  			function CSSStyleDeclaration(element) {
  				var currentStyle, style, fontSize, property;

  				currentStyle = element.currentStyle;
  				style = this;
  				fontSize = getPixelSize(element, currentStyle, 'fontSize', null);

  				// TODO tidy this up, test it, send PR to jonathantneal!
  				for (property in currentStyle) {
  					if ( currentStyle[property] === 'normal' && normalProps.hasOwnProperty( property ) ) {
  						style[ property ] = normalProps[ property ];
  					} else if ( /width|height|margin.|padding.|border.+W/.test(property) ) {
  						if ( currentStyle[ property ] === 'auto' ) {
  							if ( /^width|height/.test( property ) ) {
  								// just use clientWidth/clientHeight...
  								style[ property ] = ( property === 'width' ? element.clientWidth : element.clientHeight ) + 'px';
  							}

  							else if ( /(?:padding)?Top|Bottom$/.test( property ) ) {
  								style[ property ] = '0px';
  							}
  						}

  						else {
  							style[ property ] = getPixelSize(element, currentStyle, property, fontSize) + 'px';
  						}
  					} else if (property === 'styleFloat') {
  						style.float = currentStyle[property];
  					} else {
  						style[property] = currentStyle[property];
  					}
  				}

  				setShortStyleProperty(style, 'margin');
  				setShortStyleProperty(style, 'padding');
  				setShortStyleProperty(style, 'border');

  				style.fontSize = fontSize + 'px';

  				return style;
  			}

  			CSSStyleDeclaration.prototype = {
  				constructor: CSSStyleDeclaration,
  				getPropertyPriority: noop,
  				getPropertyValue: function ( prop ) {
  					return this[prop] || '';
  				},
  				item: noop,
  				removeProperty: noop,
  				setProperty: noop,
  				getPropertyCSSValue: noop
  			};

  			function getComputedStyle(element) {
  				return new CSSStyleDeclaration(element);
  			}

  			return getComputedStyle;
  		}());
  	}
  }

  var legacy = exportedShims;

  var html   = 'http://www.w3.org/1999/xhtml';
  var mathml = 'http://www.w3.org/1998/Math/MathML';
  var svg$1    = 'http://www.w3.org/2000/svg';
  var xlink  = 'http://www.w3.org/1999/xlink';
  var xml    = 'http://www.w3.org/XML/1998/namespace';
  var xmlns  = 'http://www.w3.org/2000/xmlns';

  var namespaces = { html: html, mathml: mathml, svg: svg$1, xlink: xlink, xml: xml, xmlns: xmlns };

  var createElement;
  var matches;
  var div;
  var methodNames;
  var unprefixed;
  var prefixed;
  var i;
  var j;
  var makeFunction;
  // Test for SVG support
  if ( !svg ) {
  	createElement = function ( type, ns, extend ) {
  		if ( ns && ns !== html ) {
  			throw 'This browser does not support namespaces other than http://www.w3.org/1999/xhtml. The most likely cause of this error is that you\'re trying to render SVG in an older browser. See http://docs.ractivejs.org/latest/svg-and-older-browsers for more information';
  		}

  		return extend ?
  			doc.createElement( type, extend ) :
  			doc.createElement( type );
  	};
  } else {
  	createElement = function ( type, ns, extend ) {
  		if ( !ns || ns === html ) {
  			return extend ?
  				doc.createElement( type, extend ) :
  				doc.createElement( type );
  		}

  		return extend ?
  			doc.createElementNS( ns, type, extend ) :
  			doc.createElementNS( ns, type );
  	};
  }

  function createDocumentFragment () {
  	return doc.createDocumentFragment();
  }

  function getElement ( input ) {
  	var output;

  	if ( !input || typeof input === 'boolean' ) { return; }

  	if ( !win || !doc || !input ) {
  		return null;
  	}

  	// We already have a DOM node - no work to do. (Duck typing alert!)
  	if ( input.nodeType ) {
  		return input;
  	}

  	// Get node from string
  	if ( typeof input === 'string' ) {
  		// try ID first
  		output = doc.getElementById( input );

  		// then as selector, if possible
  		if ( !output && doc.querySelector ) {
  			output = doc.querySelector( input );
  		}

  		// did it work?
  		if ( output && output.nodeType ) {
  			return output;
  		}
  	}

  	// If we've been given a collection (jQuery, Zepto etc), extract the first item
  	if ( input[0] && input[0].nodeType ) {
  		return input[0];
  	}

  	return null;
  }

  if ( !isClient ) {
  	matches = null;
  } else {
  	div = createElement( 'div' );
  	methodNames = [ 'matches', 'matchesSelector' ];

  	makeFunction = function ( methodName ) {
  		return function ( node, selector ) {
  			return node[ methodName ]( selector );
  		};
  	};

  	i = methodNames.length;

  	while ( i-- && !matches ) {
  		unprefixed = methodNames[i];

  		if ( div[ unprefixed ] ) {
  			matches = makeFunction( unprefixed );
  		} else {
  			j = vendors.length;
  			while ( j-- ) {
  				prefixed = vendors[i] + unprefixed.substr( 0, 1 ).toUpperCase() + unprefixed.substring( 1 );

  				if ( div[ prefixed ] ) {
  					matches = makeFunction( prefixed );
  					break;
  				}
  			}
  		}
  	}

  	// IE8...
  	if ( !matches ) {
  		matches = function ( node, selector ) {
  			var nodes, parentNode, i;

  			parentNode = node.parentNode;

  			if ( !parentNode ) {
  				// empty dummy <div>
  				div.innerHTML = '';

  				parentNode = div;
  				node = node.cloneNode();

  				div.appendChild( node );
  			}

  			nodes = parentNode.querySelectorAll( selector );

  			i = nodes.length;
  			while ( i-- ) {
  				if ( nodes[i] === node ) {
  					return true;
  				}
  			}

  			return false;
  		};
  	}
  }

  function detachNode ( node ) {
  	if ( node && typeof node.parentNode !== 'unknown' && node.parentNode ) {
  		node.parentNode.removeChild( node );
  	}

  	return node;
  }

  function safeToStringValue ( value ) {
  	return ( value == null || !value.toString ) ? '' : '' + value;
  }

  function safeAttributeString ( string ) {
  	return safeToStringValue( string )
  		.replace( /&/g, '&amp;' )
  		.replace( /"/g, '&quot;' )
  		.replace( /'/g, '&#39;' );
  }

  var camel = /(-.)/g;
  function camelize ( string ) {
  	return string.replace( camel, function ( s ) { return s.charAt( 1 ).toUpperCase(); } );
  }

  var decamel = /[A-Z]/g;
  function decamelize ( string ) {
  	return string.replace( decamel, function ( s ) { return ("-" + (s.toLowerCase())); } );
  }

  var create;
  var defineProperty;
  var defineProperties;
  try {
  	Object.defineProperty({}, 'test', { get: function() {}, set: function() {} });

  	if ( doc ) {
  		Object.defineProperty( createElement( 'div' ), 'test', { value: 0 });
  	}

  	defineProperty = Object.defineProperty;
  } catch ( err ) {
  	// Object.defineProperty doesn't exist, or we're in IE8 where you can
  	// only use it with DOM objects (what were you smoking, MSFT?)
  	defineProperty = function ( obj, prop, desc ) {
  		if ( desc.get ) obj[ prop ] = desc.get();
  		else obj[ prop ] = desc.value;
  	};
  }

  try {
  	try {
  		Object.defineProperties({}, { test: { value: 0 } });
  	} catch ( err ) {
  		// TODO how do we account for this? noMagic = true;
  		throw err;
  	}

  	if ( doc ) {
  		Object.defineProperties( createElement( 'div' ), { test: { value: 0 } });
  	}

  	defineProperties = Object.defineProperties;
  } catch ( err ) {
  	defineProperties = function ( obj, props ) {
  		var prop;

  		for ( prop in props ) {
  			if ( props.hasOwnProperty( prop ) ) {
  				defineProperty( obj, prop, props[ prop ] );
  			}
  		}
  	};
  }

  try {
  	Object.create( null );

  	create = Object.create;
  } catch ( err ) {
  	// sigh
  	create = (function () {
  		var F = function () {};

  		return function ( proto, props ) {
  			var obj;

  			if ( proto === null ) {
  				return {};
  			}

  			F.prototype = proto;
  			obj = new F();

  			if ( props ) {
  				Object.defineProperties( obj, props );
  			}

  			return obj;
  		};
  	}());
  }

  function extendObj ( target ) {
  	var sources = [], len = arguments.length - 1;
  	while ( len-- > 0 ) sources[ len ] = arguments[ len + 1 ];

  	var prop;

  	sources.forEach( function ( source ) {
  		for ( prop in source ) {
  			if ( hasOwn.call( source, prop ) ) {
  				target[ prop ] = source[ prop ];
  			}
  		}
  	});

  	return target;
  }

  function fillGaps ( target ) {
  	var sources = [], len = arguments.length - 1;
  	while ( len-- > 0 ) sources[ len ] = arguments[ len + 1 ];

  	sources.forEach( function ( s ) {
  		for ( var key in s ) {
  			if ( hasOwn.call( s, key ) && !( key in target ) ) {
  				target[ key ] = s[ key ];
  			}
  		}
  	});

  	return target;
  }

  var hasOwn = Object.prototype.hasOwnProperty;

  var toString = Object.prototype.toString;
  // thanks, http://perfectionkills.com/instanceof-considered-harmful-or-how-to-write-a-robust-isarray/
  function isArray ( thing ) {
  	return toString.call( thing ) === '[object Array]';
  }

  function isEqual ( a, b ) {
  	if ( a === null && b === null ) {
  		return true;
  	}

  	if ( typeof a === 'object' || typeof b === 'object' ) {
  		return false;
  	}

  	return a === b;
  }

  // http://stackoverflow.com/questions/18082/validate-numbers-in-javascript-isnumeric
  function isNumeric ( thing ) {
  	return !isNaN( parseFloat( thing ) ) && isFinite( thing );
  }

  function isObject ( thing ) {
  	return ( thing && toString.call( thing ) === '[object Object]' );
  }

  var alreadyWarned = {};
  var log;
  var printWarning;
  var welcome;
  if ( hasConsole ) {
  	var welcomeIntro = [
  		("%cRactive.js %c0.8.1 %cin debug mode, %cmore..."),
  		'color: rgb(114, 157, 52); font-weight: normal;',
  		'color: rgb(85, 85, 85); font-weight: normal;',
  		'color: rgb(85, 85, 85); font-weight: normal;',
  		'color: rgb(82, 140, 224); font-weight: normal; text-decoration: underline;'
  	];
  	var welcomeMessage = "You're running Ractive 0.8.1 in debug mode - messages will be printed to the console to help you fix problems and optimise your application.\n\nTo disable debug mode, add this line at the start of your app:\n  Ractive.DEBUG = false;\n\nTo disable debug mode when your app is minified, add this snippet:\n  Ractive.DEBUG = /unminified/.test(function(){/*unminified*/});\n\nGet help and support:\n  http://docs.ractivejs.org\n  http://stackoverflow.com/questions/tagged/ractivejs\n  http://groups.google.com/forum/#!forum/ractive-js\n  http://twitter.com/ractivejs\n\nFound a bug? Raise an issue:\n  https://github.com/ractivejs/ractive/issues\n\n";

  	welcome = function () {
  		var hasGroup = !!console.groupCollapsed;
  		console[ hasGroup ? 'groupCollapsed' : 'log' ].apply( console, welcomeIntro );
  		console.log( welcomeMessage );
  		if ( hasGroup ) {
  			console.groupEnd( welcomeIntro );
  		}

  		welcome = noop;
  	};

  	printWarning = function ( message, args ) {
  		welcome();

  		// extract information about the instance this message pertains to, if applicable
  		if ( typeof args[ args.length - 1 ] === 'object' ) {
  			var options = args.pop();
  			var ractive = options ? options.ractive : null;

  			if ( ractive ) {
  				// if this is an instance of a component that we know the name of, add
  				// it to the message
  				var name;
  				if ( ractive.component && ( name = ractive.component.name ) ) {
  					message = "<" + name + "> " + message;
  				}

  				var node;
  				if ( node = ( options.node || ( ractive.fragment && ractive.fragment.rendered && ractive.find( '*' ) ) ) ) {
  					args.push( node );
  				}
  			}
  		}

  		console.warn.apply( console, [ '%cRactive.js: %c' + message, 'color: rgb(114, 157, 52);', 'color: rgb(85, 85, 85);' ].concat( args ) );
  	};

  	log = function () {
  		console.log.apply( console, arguments );
  	};
  } else {
  	printWarning = log = welcome = noop;
  }

  function format ( message, args ) {
  	return message.replace( /%s/g, function () { return args.shift(); } );
  }

  function fatal ( message ) {
  	var args = [], len = arguments.length - 1;
  	while ( len-- > 0 ) args[ len ] = arguments[ len + 1 ];

  	message = format( message, args );
  	throw new Error( message );
  }

  function logIfDebug () {
  	if ( Ractive.DEBUG ) {
  		log.apply( null, arguments );
  	}
  }

  function warn ( message ) {
  	var args = [], len = arguments.length - 1;
  	while ( len-- > 0 ) args[ len ] = arguments[ len + 1 ];

  	message = format( message, args );
  	printWarning( message, args );
  }

  function warnOnce ( message ) {
  	var args = [], len = arguments.length - 1;
  	while ( len-- > 0 ) args[ len ] = arguments[ len + 1 ];

  	message = format( message, args );

  	if ( alreadyWarned[ message ] ) {
  		return;
  	}

  	alreadyWarned[ message ] = true;
  	printWarning( message, args );
  }

  function warnIfDebug () {
  	if ( Ractive.DEBUG ) {
  		warn.apply( null, arguments );
  	}
  }

  function warnOnceIfDebug () {
  	if ( Ractive.DEBUG ) {
  		warnOnce.apply( null, arguments );
  	}
  }

  // Error messages that are used (or could be) in multiple places
  var badArguments = 'Bad arguments';
  var noRegistryFunctionReturn = 'A function was specified for "%s" %s, but no %s was returned';
  var missingPlugin = function ( name, type ) { return ("Missing \"" + name + "\" " + type + " plugin. You may need to download a plugin via http://docs.ractivejs.org/latest/plugins#" + type + "s"); };

  function findInViewHierarchy ( registryName, ractive, name ) {
  	var instance = findInstance( registryName, ractive, name );
  	return instance ? instance[ registryName ][ name ] : null;
  }

  function findInstance ( registryName, ractive, name ) {
  	while ( ractive ) {
  		if ( name in ractive[ registryName ] ) {
  			return ractive;
  		}

  		if ( ractive.isolated ) {
  			return null;
  		}

  		ractive = ractive.parent;
  	}
  }

  function interpolate ( from, to, ractive, type ) {
  	if ( from === to ) return null;

  	if ( type ) {
  		var interpol = findInViewHierarchy( 'interpolators', ractive, type );
  		if ( interpol ) return interpol( from, to ) || null;

  		fatal( missingPlugin( type, 'interpolator' ) );
  	}

  	return interpolators.number( from, to ) ||
  	       interpolators.array( from, to ) ||
  	       interpolators.object( from, to ) ||
  	       null;
  }

  function snap ( to ) {
  	return function () { return to; };
  }

  var interpolators = {
  	number: function ( from, to ) {
  		var delta;

  		if ( !isNumeric( from ) || !isNumeric( to ) ) {
  			return null;
  		}

  		from = +from;
  		to = +to;

  		delta = to - from;

  		if ( !delta ) {
  			return function () { return from; };
  		}

  		return function ( t ) {
  			return from + ( t * delta );
  		};
  	},

  	array: function ( from, to ) {
  		var intermediate, interpolators, len, i;

  		if ( !isArray( from ) || !isArray( to ) ) {
  			return null;
  		}

  		intermediate = [];
  		interpolators = [];

  		i = len = Math.min( from.length, to.length );
  		while ( i-- ) {
  			interpolators[i] = interpolate( from[i], to[i] );
  		}

  		// surplus values - don't interpolate, but don't exclude them either
  		for ( i=len; i<from.length; i+=1 ) {
  			intermediate[i] = from[i];
  		}

  		for ( i=len; i<to.length; i+=1 ) {
  			intermediate[i] = to[i];
  		}

  		return function ( t ) {
  			var i = len;

  			while ( i-- ) {
  				intermediate[i] = interpolators[i]( t );
  			}

  			return intermediate;
  		};
  	},

  	object: function ( from, to ) {
  		var properties, len, interpolators, intermediate, prop;

  		if ( !isObject( from ) || !isObject( to ) ) {
  			return null;
  		}

  		properties = [];
  		intermediate = {};
  		interpolators = {};

  		for ( prop in from ) {
  			if ( hasOwn.call( from, prop ) ) {
  				if ( hasOwn.call( to, prop ) ) {
  					properties.push( prop );
  					interpolators[ prop ] = interpolate( from[ prop ], to[ prop ] ) || snap( to[ prop ] );
  				}

  				else {
  					intermediate[ prop ] = from[ prop ];
  				}
  			}
  		}

  		for ( prop in to ) {
  			if ( hasOwn.call( to, prop ) && !hasOwn.call( from, prop ) ) {
  				intermediate[ prop ] = to[ prop ];
  			}
  		}

  		len = properties.length;

  		return function ( t ) {
  			var i = len, prop;

  			while ( i-- ) {
  				prop = properties[i];

  				intermediate[ prop ] = interpolators[ prop ]( t );
  			}

  			return intermediate;
  		};
  	}
  };

  var refPattern = /\[\s*(\*|[0-9]|[1-9][0-9]+)\s*\]/g;
  var splitPattern = /([^\\](?:\\\\)*)\./;
  var escapeKeyPattern = /\\|\./g;
  var unescapeKeyPattern = /((?:\\)+)\1|\\(\.)/g;

  function escapeKey ( key ) {
  	if ( typeof key === 'string' ) {
  		return key.replace( escapeKeyPattern, '\\$&' );
  	}

  	return key;
  }

  function normalise ( ref ) {
  	return ref ? ref.replace( refPattern, '.$1' ) : '';
  }

  function splitKeypathI ( keypath ) {
  	var result = [],
  		match;

  	keypath = normalise( keypath );

  	while ( match = splitPattern.exec( keypath ) ) {
  		var index = match.index + match[1].length;
  		result.push( keypath.substr( 0, index ) );
  		keypath = keypath.substr( index + 1 );
  	}

  	result.push(keypath);

  	return result;
  }

  function unescapeKey ( key ) {
  	if ( typeof key === 'string' ) {
  		return key.replace( unescapeKeyPattern, '$1$2' );
  	}

  	return key;
  }

  var errorMessage = 'Cannot add to a non-numeric value';

  function add ( ractive, keypath, d ) {
  	if ( typeof keypath !== 'string' || !isNumeric( d ) ) {
  		throw new Error( 'Bad arguments' );
  	}

  	var changes;

  	if ( /\*/.test( keypath ) ) {
  		changes = {};

  		ractive.viewmodel.findMatches( splitKeypathI( keypath ) ).forEach( function ( model ) {
  			var value = model.get();

  			if ( !isNumeric( value ) ) throw new Error( errorMessage );

  			changes[ model.getKeypath() ] = value + d;
  		});

  		return ractive.set( changes );
  	}

  	var value = ractive.get( keypath );

  	if ( !isNumeric( value ) ) {
  		throw new Error( errorMessage );
  	}

  	return ractive.set( keypath, +value + d );
  }

  function Ractive$add ( keypath, d ) {
  	return add( this, keypath, ( d === undefined ? 1 : +d ) );
  }

  // TODO: deprecate in future release
  var deprecations = {
  	construct: {
  		deprecated: 'beforeInit',
  		replacement: 'onconstruct'
  	},
  	render: {
  		deprecated: 'init',
  		message: 'The "init" method has been deprecated ' +
  			'and will likely be removed in a future release. ' +
  			'You can either use the "oninit" method which will fire ' +
  			'only once prior to, and regardless of, any eventual ractive ' +
  			'instance being rendered, or if you need to access the ' +
  			'rendered DOM, use "onrender" instead. ' +
  			'See http://docs.ractivejs.org/latest/migrating for more information.'
  	},
  	complete: {
  		deprecated: 'complete',
  		replacement: 'oncomplete'
  	}
  };

  var Hook = function Hook ( event ) {
  	this.event = event;
  	this.method = 'on' + event;
  	this.deprecate = deprecations[ event ];
  };

  Hook.prototype.call = function call ( method, ractive, arg ) {
  	if ( ractive[ method ] ) {
  		arg ? ractive[ method ]( arg ) : ractive[ method ]();
  		return true;
  	}
  };

  Hook.prototype.fire = function fire ( ractive, arg ) {
  	this.call( this.method, ractive, arg );

  	// handle deprecations
  	if ( !ractive[ this.method ] && this.deprecate && this.call( this.deprecate.deprecated, ractive, arg ) ) {
  		if ( this.deprecate.message ) {
  			warnIfDebug( this.deprecate.message );
  		} else {
  			warnIfDebug( 'The method "%s" has been deprecated in favor of "%s" and will likely be removed in a future release. See http://docs.ractivejs.org/latest/migrating for more information.', this.deprecate.deprecated, this.deprecate.replacement );
  		}
  	}

  	// TODO should probably use internal method, in case ractive.fire was overwritten
  	arg ? ractive.fire( this.event, arg ) : ractive.fire( this.event );
  };

  function addToArray ( array, value ) {
  	var index = array.indexOf( value );

  	if ( index === -1 ) {
  		array.push( value );
  	}
  }

  function arrayContains ( array, value ) {
  	for ( var i = 0, c = array.length; i < c; i++ ) {
  		if ( array[i] == value ) {
  			return true;
  		}
  	}

  	return false;
  }

  function arrayContentsMatch ( a, b ) {
  	var i;

  	if ( !isArray( a ) || !isArray( b ) ) {
  		return false;
  	}

  	if ( a.length !== b.length ) {
  		return false;
  	}

  	i = a.length;
  	while ( i-- ) {
  		if ( a[i] !== b[i] ) {
  			return false;
  		}
  	}

  	return true;
  }

  function ensureArray ( x ) {
  	if ( typeof x === 'string' ) {
  		return [ x ];
  	}

  	if ( x === undefined ) {
  		return [];
  	}

  	return x;
  }

  function lastItem ( array ) {
  	return array[ array.length - 1 ];
  }

  function removeFromArray ( array, member ) {
  	if ( !array ) {
  		return;
  	}

  	var index = array.indexOf( member );

  	if ( index !== -1 ) {
  		array.splice( index, 1 );
  	}
  }

  function toArray ( arrayLike ) {
  	var array = [], i = arrayLike.length;
  	while ( i-- ) {
  		array[i] = arrayLike[i];
  	}

  	return array;
  }

  var _Promise;
  var PENDING = {};
  var FULFILLED = {};
  var REJECTED = {};
  if ( typeof Promise === 'function' ) {
  	// use native Promise
  	_Promise = Promise;
  } else {
  	_Promise = function ( callback ) {
  		var fulfilledHandlers = [],
  			rejectedHandlers = [],
  			state = PENDING,

  			result,
  			dispatchHandlers,
  			makeResolver,
  			fulfil,
  			reject,

  			promise;

  		makeResolver = function ( newState ) {
  			return function ( value ) {
  				if ( state !== PENDING ) {
  					return;
  				}

  				result = value;
  				state = newState;

  				dispatchHandlers = makeDispatcher( ( state === FULFILLED ? fulfilledHandlers : rejectedHandlers ), result );

  				// dispatch onFulfilled and onRejected handlers asynchronously
  				wait( dispatchHandlers );
  			};
  		};

  		fulfil = makeResolver( FULFILLED );
  		reject = makeResolver( REJECTED );

  		try {
  			callback( fulfil, reject );
  		} catch ( err ) {
  			reject( err );
  		}

  		promise = {
  			// `then()` returns a Promise - 2.2.7
  			then: function ( onFulfilled, onRejected ) {
  				var promise2 = new _Promise( function ( fulfil, reject ) {

  					var processResolutionHandler = function ( handler, handlers, forward ) {

  						// 2.2.1.1
  						if ( typeof handler === 'function' ) {
  							handlers.push( function ( p1result ) {
  								var x;

  								try {
  									x = handler( p1result );
  									resolve( promise2, x, fulfil, reject );
  								} catch ( err ) {
  									reject( err );
  								}
  							});
  						} else {
  							// Forward the result of promise1 to promise2, if resolution handlers
  							// are not given
  							handlers.push( forward );
  						}
  					};

  					// 2.2
  					processResolutionHandler( onFulfilled, fulfilledHandlers, fulfil );
  					processResolutionHandler( onRejected, rejectedHandlers, reject );

  					if ( state !== PENDING ) {
  						// If the promise has resolved already, dispatch the appropriate handlers asynchronously
  						wait( dispatchHandlers );
  					}

  				});

  				return promise2;
  			}
  		};

  		promise[ 'catch' ] = function ( onRejected ) {
  			return this.then( null, onRejected );
  		};

  		return promise;
  	};

  	_Promise.all = function ( promises ) {
  		return new _Promise( function ( fulfil, reject ) {
  			var result = [], pending, i, processPromise;

  			if ( !promises.length ) {
  				fulfil( result );
  				return;
  			}

  			processPromise = function ( promise, i ) {
  				if ( promise && typeof promise.then === 'function' ) {
  					promise.then( function ( value ) {
  						result[i] = value;
  						--pending || fulfil( result );
  					}, reject );
  				}

  				else {
  					result[i] = promise;
  					--pending || fulfil( result );
  				}
  			};

  			pending = i = promises.length;
  			while ( i-- ) {
  				processPromise( promises[i], i );
  			}
  		});
  	};

  	_Promise.resolve = function ( value ) {
  		return new _Promise( function ( fulfil ) {
  			fulfil( value );
  		});
  	};

  	_Promise.reject = function ( reason ) {
  		return new _Promise( function ( fulfil, reject ) {
  			reject( reason );
  		});
  	};
  }

  var Promise$1 = _Promise;

  // TODO use MutationObservers or something to simulate setImmediate
  function wait ( callback ) {
  	setTimeout( callback, 0 );
  }

  function makeDispatcher ( handlers, result ) {
  	return function () {
  		var handler;

  		while ( handler = handlers.shift() ) {
  			handler( result );
  		}
  	};
  }

  function resolve ( promise, x, fulfil, reject ) {
  	// Promise Resolution Procedure
  	var then;

  	// 2.3.1
  	if ( x === promise ) {
  		throw new TypeError( 'A promise\'s fulfillment handler cannot return the same promise' );
  	}

  	// 2.3.2
  	if ( x instanceof _Promise ) {
  		x.then( fulfil, reject );
  	}

  	// 2.3.3
  	else if ( x && ( typeof x === 'object' || typeof x === 'function' ) ) {
  		try {
  			then = x.then; // 2.3.3.1
  		} catch ( e ) {
  			reject( e ); // 2.3.3.2
  			return;
  		}

  		// 2.3.3.3
  		if ( typeof then === 'function' ) {
  			var called, resolvePromise, rejectPromise;

  			resolvePromise = function ( y ) {
  				if ( called ) {
  					return;
  				}
  				called = true;
  				resolve( promise, y, fulfil, reject );
  			};

  			rejectPromise = function ( r ) {
  				if ( called ) {
  					return;
  				}
  				called = true;
  				reject( r );
  			};

  			try {
  				then.call( x, resolvePromise, rejectPromise );
  			} catch ( e ) {
  				if ( !called ) { // 2.3.3.3.4.1
  					reject( e ); // 2.3.3.3.4.2
  					called = true;
  					return;
  				}
  			}
  		}

  		else {
  			fulfil( x );
  		}
  	}

  	else {
  		fulfil( x );
  	}
  }

  var TransitionManager = function TransitionManager ( callback, parent ) {
  	this.callback = callback;
  	this.parent = parent;

  	this.intros = [];
  	this.outros = [];

  	this.children = [];
  	this.totalChildren = this.outroChildren = 0;

  	this.detachQueue = [];
  	this.outrosComplete = false;

  	if ( parent ) {
  		parent.addChild( this );
  	}
  };

  TransitionManager.prototype.add = function add ( transition ) {
  	var list = transition.isIntro ? this.intros : this.outros;
  	list.push( transition );
  };

  TransitionManager.prototype.addChild = function addChild ( child ) {
  	this.children.push( child );

  	this.totalChildren += 1;
  	this.outroChildren += 1;
  };

  TransitionManager.prototype.decrementOutros = function decrementOutros () {
  	this.outroChildren -= 1;
  	check( this );
  };

  TransitionManager.prototype.decrementTotal = function decrementTotal () {
  	this.totalChildren -= 1;
  	check( this );
  };

  TransitionManager.prototype.detachNodes = function detachNodes () {
  	this.detachQueue.forEach( detach );
  	this.children.forEach( _detachNodes );
  };

  TransitionManager.prototype.remove = function remove ( transition ) {
  	var list = transition.isIntro ? this.intros : this.outros;
  	removeFromArray( list, transition );
  	check( this );
  };

  TransitionManager.prototype.start = function start () {
  	detachImmediate( this );
  	this.intros.concat( this.outros ).forEach( function ( t ) { return t.start(); } );
  	this.ready = true;
  	check( this );
  };

  function detach ( element ) {
  	element.detach();
  }

  function _detachNodes ( tm ) { // _ to avoid transpiler quirk
  	tm.detachNodes();
  }

  function check ( tm ) {
  	if ( !tm.ready || tm.outros.length || tm.outroChildren ) return;

  	// If all outros are complete, and we haven't already done this,
  	// we notify the parent if there is one, otherwise
  	// start detaching nodes
  	if ( !tm.outrosComplete ) {
  		if ( tm.parent && !tm.parent.outrosComplete ) {
  			tm.parent.decrementOutros( tm );
  		} else {
  			tm.detachNodes();
  		}

  		tm.outrosComplete = true;
  	}

  	// Once everything is done, we can notify parent transition
  	// manager and call the callback
  	if ( !tm.intros.length && !tm.totalChildren ) {
  		if ( typeof tm.callback === 'function' ) {
  			tm.callback();
  		}

  		if ( tm.parent ) {
  			tm.parent.decrementTotal();
  		}
  	}
  }

  // check through the detach queue to see if a node is up or downstream from a
  // transition and if not, go ahead and detach it
  function detachImmediate ( manager ) {
  	var queue = manager.detachQueue;
  	var outros = collectAllOutros( manager );

  	var i = queue.length, j = 0, node, trans;
  	start: while ( i-- ) {
  		node = queue[i].node;
  		j = outros.length;
  		while ( j-- ) {
  			trans = outros[j].node;
  			// check to see if the node is, contains, or is contained by the transitioning node
  			if ( trans === node || trans.contains( node ) || node.contains( trans ) ) continue start;
  		}

  		// no match, we can drop it
  		queue[i].detach();
  		queue.splice( i, 1 );
  	}
  }

  function collectAllOutros ( manager, list ) {
  	if ( !list ) {
  		list = [];
  		var parent = manager;
  		while ( parent.parent ) parent = parent.parent;
  		return collectAllOutros( parent, list );
  	} else {
  		var i = manager.children.length;
  		while ( i-- ) {
  			list = collectAllOutros( manager.children[i], list );
  		}
  		list = list.concat( manager.outros );
  		return list;
  	}
  }

  var changeHook = new Hook( 'change' );

  var batch;

  var runloop = {
  	start: function ( instance, returnPromise ) {
  		var promise, fulfilPromise;

  		if ( returnPromise ) {
  			promise = new Promise$1( function ( f ) { return ( fulfilPromise = f ); } );
  		}

  		batch = {
  			previousBatch: batch,
  			transitionManager: new TransitionManager( fulfilPromise, batch && batch.transitionManager ),
  			fragments: [],
  			tasks: [],
  			immediateObservers: [],
  			deferredObservers: [],
  			ractives: [],
  			instance: instance
  		};

  		return promise;
  	},

  	end: function () {
  		flushChanges();
  		batch = batch.previousBatch;
  	},

  	addFragment: function ( fragment ) {
  		addToArray( batch.fragments, fragment );
  	},

  	// TODO: come up with a better way to handle fragments that trigger their own update
  	addFragmentToRoot: function ( fragment ) {
  		if ( !batch ) return;

  		var b = batch;
  		while ( b.previousBatch ) {
  			b = b.previousBatch;
  		}

  		addToArray( b.fragments, fragment );
  	},

  	addInstance: function ( instance ) {
  		if ( batch ) addToArray( batch.ractives, instance );
  	},

  	addObserver: function ( observer, defer ) {
  		addToArray( defer ? batch.deferredObservers : batch.immediateObservers, observer );
  	},

  	registerTransition: function ( transition ) {
  		transition._manager = batch.transitionManager;
  		batch.transitionManager.add( transition );
  	},

  	// synchronise node detachments with transition ends
  	detachWhenReady: function ( thing ) {
  		batch.transitionManager.detachQueue.push( thing );
  	},

  	scheduleTask: function ( task, postRender ) {
  		var _batch;

  		if ( !batch ) {
  			task();
  		} else {
  			_batch = batch;
  			while ( postRender && _batch.previousBatch ) {
  				// this can't happen until the DOM has been fully updated
  				// otherwise in some situations (with components inside elements)
  				// transitions and decorators will initialise prematurely
  				_batch = _batch.previousBatch;
  			}

  			_batch.tasks.push( task );
  		}
  	}
  };

  function dispatch ( observer ) {
  	observer.dispatch();
  }

  function flushChanges () {
  	var which = batch.immediateObservers;
  	batch.immediateObservers = [];
  	which.forEach( dispatch );

  	// Now that changes have been fully propagated, we can update the DOM
  	// and complete other tasks
  	var i = batch.fragments.length;
  	var fragment;

  	which = batch.fragments;
  	batch.fragments = [];
  	var ractives = batch.ractives;
  	batch.ractives = [];

  	while ( i-- ) {
  		fragment = which[i];

  		// TODO deprecate this. It's annoying and serves no useful function
  		var ractive = fragment.ractive;
  		changeHook.fire( ractive, ractive.viewmodel.changes );
  		ractive.viewmodel.changes = {};
  		removeFromArray( ractives, ractive );

  		fragment.update();
  	}

  	i = ractives.length;
  	while ( i-- ) {
  		var ractive$1 = ractives[i];
  		changeHook.fire( ractive$1, ractive$1.viewmodel.changes );
  		ractive$1.viewmodel.changes = {};
  	}

  	batch.transitionManager.start();

  	which = batch.deferredObservers;
  	batch.deferredObservers = [];
  	which.forEach( dispatch );

  	var tasks = batch.tasks;
  	batch.tasks = [];

  	for ( i = 0; i < tasks.length; i += 1 ) {
  		tasks[i]();
  	}

  	// If updating the view caused some model blowback - e.g. a triple
  	// containing <option> elements caused the binding on the <select>
  	// to update - then we start over
  	if ( batch.fragments.length || batch.immediateObservers.length || batch.deferredObservers.length || batch.ractives.length ) return flushChanges();
  }

  var noAnimation = Promise$1.resolve();
  defineProperty( noAnimation, 'stop', { value: noop });

  var linear = easing.linear;

  function getOptions ( options, instance ) {
  	options = options || {};

  	var easing;
  	if ( options.easing ) {
  		easing = typeof options.easing === 'function' ?
  			options.easing :
  			instance.easing[ options.easing ];
  	}

  	return {
  		easing: easing || linear,
  		duration: 'duration' in options ? options.duration : 400,
  		complete: options.complete || noop,
  		step: options.step || noop
  	};
  }

  function Ractive$animate ( keypath, to, options ) {
  	if ( typeof keypath === 'object' ) {
  		var keys = Object.keys( keypath );

  		throw new Error( ("ractive.animate(...) no longer supports objects. Instead of ractive.animate({\n  " + (keys.map( function ( key ) { return ("'" + key + "': " + (keypath[ key ])); } ).join( '\n  ' )) + "\n}, {...}), do\n\n" + (keys.map( function ( key ) { return ("ractive.animate('" + key + "', " + (keypath[ key ]) + ", {...});"); } ).join( '\n' )) + "\n") );
  	}

  	options = getOptions( options, this );

  	var model = this.viewmodel.joinAll( splitKeypathI( keypath ) );
  	var from = model.get();

  	// don't bother animating values that stay the same
  	if ( isEqual( from, to ) ) {
  		options.complete( options.to );
  		return noAnimation; // TODO should this have .then and .catch methods?
  	}

  	var interpolator = interpolate( from, to, this, options.interpolator );

  	// if we can't interpolate the value, set it immediately
  	if ( !interpolator ) {
  		runloop.start();
  		model.set( to );
  		runloop.end();

  		return noAnimation;
  	}

  	return model.animate( from, to, options, interpolator );
  }

  var detachHook = new Hook( 'detach' );

  function Ractive$detach () {
  	if ( this.isDetached ) {
  		return this.el;
  	}

  	if ( this.el ) {
  		removeFromArray( this.el.__ractive_instances__, this );
  	}

  	this.el = this.fragment.detach();
  	this.isDetached = true;

  	detachHook.fire( this );
  	return this.el;
  }

  function Ractive$find ( selector ) {
  	if ( !this.el ) throw new Error( ("Cannot call ractive.find('" + selector + "') unless instance is rendered to the DOM") );

  	return this.fragment.find( selector );
  }

  function sortByDocumentPosition ( node, otherNode ) {
  	if ( node.compareDocumentPosition ) {
  		var bitmask = node.compareDocumentPosition( otherNode );
  		return ( bitmask & 2 ) ? 1 : -1;
  	}

  	// In old IE, we can piggy back on the mechanism for
  	// comparing component positions
  	return sortByItemPosition( node, otherNode );
  }

  function sortByItemPosition ( a, b ) {
  	var ancestryA = getAncestry( a.component || a._ractive.proxy );
  	var ancestryB = getAncestry( b.component || b._ractive.proxy );

  	var oldestA = lastItem( ancestryA );
  	var oldestB = lastItem( ancestryB );
  	var mutualAncestor;

  	// remove items from the end of both ancestries as long as they are identical
  	// - the final one removed is the closest mutual ancestor
  	while ( oldestA && ( oldestA === oldestB ) ) {
  		ancestryA.pop();
  		ancestryB.pop();

  		mutualAncestor = oldestA;

  		oldestA = lastItem( ancestryA );
  		oldestB = lastItem( ancestryB );
  	}

  	// now that we have the mutual ancestor, we can find which is earliest
  	oldestA = oldestA.component || oldestA;
  	oldestB = oldestB.component || oldestB;

  	var fragmentA = oldestA.parentFragment;
  	var fragmentB = oldestB.parentFragment;

  	// if both items share a parent fragment, our job is easy
  	if ( fragmentA === fragmentB ) {
  		var indexA = fragmentA.items.indexOf( oldestA );
  		var indexB = fragmentB.items.indexOf( oldestB );

  		// if it's the same index, it means one contains the other,
  		// so we see which has the longest ancestry
  		return ( indexA - indexB ) || ancestryA.length - ancestryB.length;
  	}

  	// if mutual ancestor is a section, we first test to see which section
  	// fragment comes first
  	var fragments = mutualAncestor.iterations;
  	if ( fragments ) {
  		var indexA$1 = fragments.indexOf( fragmentA );
  		var indexB$1 = fragments.indexOf( fragmentB );

  		return ( indexA$1 - indexB$1 ) || ancestryA.length - ancestryB.length;
  	}

  	throw new Error( 'An unexpected condition was met while comparing the position of two components. Please file an issue at https://github.com/ractivejs/ractive/issues - thanks!' );
  }

  function getParent ( item ) {
  	var parentFragment = item.parentFragment;

  	if ( parentFragment ) return parentFragment.owner;

  	if ( item.component && ( parentFragment = item.component.parentFragment ) ) {
  		return parentFragment.owner;
  	}
  }

  function getAncestry ( item ) {
  	var ancestry = [ item ];
  	var ancestor = getParent( item );

  	while ( ancestor ) {
  		ancestry.push( ancestor );
  		ancestor = getParent( ancestor );
  	}

  	return ancestry;
  }


  var Query = function Query ( ractive, selector, live, isComponentQuery ) {
  	this.ractive = ractive;
  	this.selector = selector;
  	this.live = live;
  	this.isComponentQuery = isComponentQuery;

  	this.result = [];

  	this.dirty = true;
  };

  Query.prototype.add = function add ( item ) {
  	this.result.push( item );
  	this.makeDirty();
  };

  Query.prototype.cancel = function cancel () {
  	var liveQueries = this._root[ this.isComponentQuery ? 'liveComponentQueries' : 'liveQueries' ];
  	var selector = this.selector;

  	var index = liveQueries.indexOf( selector );

  	if ( index !== -1 ) {
  		liveQueries.splice( index, 1 );
  		liveQueries[ selector ] = null;
  	}
  };

  Query.prototype.init = function init () {
  	this.dirty = false;
  };

  Query.prototype.makeDirty = function makeDirty () {
  	var this$1 = this;

  		if ( !this.dirty ) {
  		this.dirty = true;

  		// Once the DOM has been updated, ensure the query
  		// is correctly ordered
  		runloop.scheduleTask( function () { return this$1.update(); } );
  	}
  };

  Query.prototype.remove = function remove ( nodeOrComponent ) {
  	var index = this.result.indexOf( this.isComponentQuery ? nodeOrComponent.instance : nodeOrComponent );
  	if ( index !== -1 ) this.result.splice( index, 1 );
  };

  Query.prototype.update = function update () {
  	this.result.sort( this.isComponentQuery ? sortByItemPosition : sortByDocumentPosition );
  	this.dirty = false;
  };

  Query.prototype.test = function test ( item ) {
  	return this.isComponentQuery ?
  		( !this.selector || item.name === this.selector ) :
  		( item ? matches( item, this.selector ) : null );
  };

  function Ractive$findAll ( selector, options ) {
  	if ( !this.el ) throw new Error( ("Cannot call ractive.findAll('" + selector + "', ...) unless instance is rendered to the DOM") );

  	options = options || {};
  	var liveQueries = this._liveQueries;

  	// Shortcut: if we're maintaining a live query with this
  	// selector, we don't need to traverse the parallel DOM
  	var query = liveQueries[ selector ];
  	if ( query ) {
  		// Either return the exact same query, or (if not live) a snapshot
  		return ( options && options.live ) ? query : query.slice();
  	}

  	query = new Query( this, selector, !!options.live, false );

  	// Add this to the list of live queries Ractive needs to maintain,
  	// if applicable
  	if ( query.live ) {
  		liveQueries.push( selector );
  		liveQueries[ '_' + selector ] = query;
  	}

  	this.fragment.findAll( selector, query );

  	query.init();
  	return query.result;
  }

  function Ractive$findAllComponents ( selector, options ) {
  	options = options || {};
  	var liveQueries = this._liveComponentQueries;

  	// Shortcut: if we're maintaining a live query with this
  	// selector, we don't need to traverse the parallel DOM
  	var query = liveQueries[ selector ];
  	if ( query ) {
  		// Either return the exact same query, or (if not live) a snapshot
  		return ( options && options.live ) ? query : query.slice();
  	}

  	query = new Query( this, selector, !!options.live, true );

  	// Add this to the list of live queries Ractive needs to maintain,
  	// if applicable
  	if ( query.live ) {
  		liveQueries.push( selector );
  		liveQueries[ '_' + selector ] = query;
  	}

  	this.fragment.findAllComponents( selector, query );

  	query.init();
  	return query.result;
  }

  function Ractive$findComponent ( selector ) {
  	return this.fragment.findComponent( selector );
  }

  function Ractive$findContainer ( selector ) {
  	if ( this.container ) {
  		if ( this.container.component && this.container.component.name === selector ) {
  			return this.container;
  		} else {
  			return this.container.findContainer( selector );
  		}
  	}

  	return null;
  }

  function Ractive$findParent ( selector ) {

  	if ( this.parent ) {
  		if ( this.parent.component && this.parent.component.name === selector ) {
  			return this.parent;
  		} else {
  			return this.parent.findParent ( selector );
  		}
  	}

  	return null;
  }

  function enqueue ( ractive, event ) {
  	if ( ractive.event ) {
  		ractive._eventQueue.push( ractive.event );
  	}

  	ractive.event = event;
  }

  function dequeue ( ractive ) {
  	if ( ractive._eventQueue.length ) {
  		ractive.event = ractive._eventQueue.pop();
  	} else {
  		ractive.event = null;
  	}
  }

  var starMaps = {};

  // This function takes a keypath such as 'foo.bar.baz', and returns
  // all the variants of that keypath that include a wildcard in place
  // of a key, such as 'foo.bar.*', 'foo.*.baz', 'foo.*.*' and so on.
  // These are then checked against the dependants map (ractive.viewmodel.depsMap)
  // to see if any pattern observers are downstream of one or more of
  // these wildcard keypaths (e.g. 'foo.bar.*.status')
  function getPotentialWildcardMatches ( keypath ) {
  	var keys, starMap, mapper, i, result, wildcardKeypath;

  	keys = splitKeypathI( keypath );
  	if( !( starMap = starMaps[ keys.length ]) ) {
  		starMap = getStarMap( keys.length );
  	}

  	result = [];

  	mapper = function ( star, i ) {
  		return star ? '*' : keys[i];
  	};

  	i = starMap.length;
  	while ( i-- ) {
  		wildcardKeypath = starMap[i].map( mapper ).join( '.' );

  		if ( !result.hasOwnProperty( wildcardKeypath ) ) {
  			result.push( wildcardKeypath );
  			result[ wildcardKeypath ] = true;
  		}
  	}

  	return result;
  }

  // This function returns all the possible true/false combinations for
  // a given number - e.g. for two, the possible combinations are
  // [ true, true ], [ true, false ], [ false, true ], [ false, false ].
  // It does so by getting all the binary values between 0 and e.g. 11
  function getStarMap ( num ) {
  	var ones = '', max, binary, starMap, mapper, i, j, l, map;

  	if ( !starMaps[ num ] ) {
  		starMap = [];

  		while ( ones.length < num ) {
  			ones += 1;
  		}

  		max = parseInt( ones, 2 );

  		mapper = function ( digit ) {
  			return digit === '1';
  		};

  		for ( i = 0; i <= max; i += 1 ) {
  			binary = i.toString( 2 );
  			while ( binary.length < num ) {
  				binary = '0' + binary;
  			}

  			map = [];
  			l = binary.length;
  			for (j = 0; j < l; j++) {
  				map.push( mapper( binary[j] ) );
  			}
  			starMap[i] = map;
  		}

  		starMaps[ num ] = starMap;
  	}

  	return starMaps[ num ];
  }

  var wildcardCache = {};

  function fireEvent ( ractive, eventName, options ) {
  	if ( options === void 0 ) options = {};

  	if ( !eventName ) { return; }

  	if ( !options.event ) {
  		options.event = {
  			name: eventName,
  			// until event not included as argument default
  			_noArg: true
  		};
  	} else {
  		options.event.name = eventName;
  	}

  	var eventNames = getWildcardNames( eventName );

  	fireEventAs( ractive, eventNames, options.event, options.args, true );
  }

  function getWildcardNames ( eventName ) {
  	if ( wildcardCache.hasOwnProperty( eventName ) ) {
  		return wildcardCache[ eventName ];
  	} else {
  		return wildcardCache[ eventName ] = getPotentialWildcardMatches( eventName );
  	}
  }

  function fireEventAs  ( ractive, eventNames, event, args, initialFire ) {

  	if ( initialFire === void 0 ) initialFire = false;

  	var subscribers, i, bubble = true;

  	enqueue( ractive, event );

  	for ( i = eventNames.length; i >= 0; i-- ) {
  		subscribers = ractive._subs[ eventNames[ i ] ];

  		if ( subscribers ) {
  			bubble = notifySubscribers( ractive, subscribers, event, args ) && bubble;
  		}
  	}

  	dequeue( ractive );

  	if ( ractive.parent && bubble ) {

  		if ( initialFire && ractive.component ) {
  			var fullName = ractive.component.name + '.' + eventNames[ eventNames.length-1 ];
  			eventNames = getWildcardNames( fullName );

  			if( event && !event.component ) {
  				event.component = ractive;
  			}
  		}

  		fireEventAs( ractive.parent, eventNames, event, args );
  	}
  }

  function notifySubscribers ( ractive, subscribers, event, args ) {
  	var originalEvent = null, stopEvent = false;

  	if ( event && !event._noArg ) {
  		args = [ event ].concat( args );
  	}

  	// subscribers can be modified inflight, e.g. "once" functionality
  	// so we need to copy to make sure everyone gets called
  	subscribers = subscribers.slice();

  	for ( var i = 0, len = subscribers.length; i < len; i += 1 ) {
  		if ( subscribers[ i ].apply( ractive, args ) === false ) {
  			stopEvent = true;
  		}
  	}

  	if ( event && !event._noArg && stopEvent && ( originalEvent = event.original ) ) {
  		originalEvent.preventDefault && originalEvent.preventDefault();
  		originalEvent.stopPropagation && originalEvent.stopPropagation();
  	}

  	return !stopEvent;
  }

  function Ractive$fire ( eventName ) {
  	var args = [], len = arguments.length - 1;
  	while ( len-- > 0 ) args[ len ] = arguments[ len + 1 ];

  	fireEvent( this, eventName, { args: args });
  }

  function badReference ( key ) {
  	throw new Error( ("An index or key reference (" + key + ") cannot have child properties") );
  }

  function resolveAmbiguousReference ( fragment, ref ) {
  	var localViewmodel = fragment.findContext().root;
  	var keys = splitKeypathI( ref );
  	var key = keys[0];

  	var hasContextChain;
  	var crossedComponentBoundary;
  	var aliases;

  	while ( fragment ) {
  		// repeated fragments
  		if ( fragment.isIteration ) {
  			if ( key === fragment.parent.keyRef ) {
  				if ( keys.length > 1 ) badReference( key );
  				return fragment.context.getKeyModel();
  			}

  			if ( key === fragment.parent.indexRef ) {
  				if ( keys.length > 1 ) badReference( key );
  				return fragment.context.getIndexModel( fragment.index );
  			}
  		}

  		// alias node or iteration
  		if ( ( ( aliases = fragment.owner.aliases ) || ( aliases = fragment.aliases ) ) && aliases.hasOwnProperty( key ) ) {
  			var model = aliases[ key ];

  			if ( keys.length === 1 ) return model;
  			else if ( typeof model.joinAll === 'function' ) {
  				return model.joinAll( keys.slice( 1 ) );
  			}
  		}

  		if ( fragment.context ) {
  			// TODO better encapsulate the component check
  			if ( !fragment.isRoot || fragment.ractive.component ) hasContextChain = true;

  			if ( fragment.context.has( key ) ) {
  				if ( crossedComponentBoundary ) {
  					localViewmodel.map( key, fragment.context.joinKey( key ) );
  				}

  				return fragment.context.joinAll( keys );
  			}
  		}

  		if ( fragment.componentParent && !fragment.ractive.isolated ) {
  			// ascend through component boundary
  			fragment = fragment.componentParent;
  			crossedComponentBoundary = true;
  		} else {
  			fragment = fragment.parent;
  		}
  	}

  	if ( !hasContextChain ) {
  		return localViewmodel.joinAll( keys );
  	}
  }

  var stack = [];
  var captureGroup;

  function startCapturing () {
  	stack.push( captureGroup = [] );
  }

  function stopCapturing () {
  	var dependencies = stack.pop();
  	captureGroup = stack[ stack.length - 1 ];
  	return dependencies;
  }

  function capture ( model ) {
  	if ( captureGroup ) {
  		captureGroup.push( model );
  	}
  }

  function bind               ( x ) { x.bind(); }
  function cancel             ( x ) { x.cancel(); }
  function handleChange       ( x ) { x.handleChange(); }
  function mark               ( x ) { x.mark(); }
  function render             ( x ) { x.render(); }
  function rebind             ( x ) { x.rebind(); }
  function teardown           ( x ) { x.teardown(); }
  function unbind             ( x ) { x.unbind(); }
  function unrender           ( x ) { x.unrender(); }
  function unrenderAndDestroy ( x ) { x.unrender( true ); }
  function update             ( x ) { x.update(); }
  function toString$1           ( x ) { return x.toString(); }
  function toEscapedString    ( x ) { return x.toString( true ); }

  var requestAnimationFrame;

  // If window doesn't exist, we don't need requestAnimationFrame
  if ( !win ) {
  	requestAnimationFrame = null;
  } else {
  	// https://gist.github.com/paulirish/1579671
  	(function(vendors, lastTime, win) {

  		var x, setTimeout;

  		if ( win.requestAnimationFrame ) {
  			return;
  		}

  		for ( x = 0; x < vendors.length && !win.requestAnimationFrame; ++x ) {
  			win.requestAnimationFrame = win[vendors[x]+'RequestAnimationFrame'];
  		}

  		if ( !win.requestAnimationFrame ) {
  			setTimeout = win.setTimeout;

  			win.requestAnimationFrame = function(callback) {
  				var currTime, timeToCall, id;

  				currTime = Date.now();
  				timeToCall = Math.max( 0, 16 - (currTime - lastTime ) );
  				id = setTimeout( function() { callback(currTime + timeToCall); }, timeToCall );

  				lastTime = currTime + timeToCall;
  				return id;
  			};
  		}

  	}( vendors, 0, win ));

  	requestAnimationFrame = win.requestAnimationFrame;
  }

  var rAF = requestAnimationFrame;

  var getTime = ( win && win.performance && typeof win.performance.now === 'function' ) ?
  	function () { return win.performance.now(); } :
  	function () { return Date.now(); };

  // TODO what happens if a transition is aborted?

  var tickers = [];
  var running = false;

  function tick () {
  	runloop.start();

  	var now = getTime();

  	var i;
  	var ticker;

  	for ( i = 0; i < tickers.length; i += 1 ) {
  		ticker = tickers[i];

  		if ( !ticker.tick( now ) ) {
  			// ticker is complete, remove it from the stack, and decrement i so we don't miss one
  			tickers.splice( i--, 1 );
  		}
  	}

  	runloop.end();

  	if ( tickers.length ) {
  		rAF( tick );
  	} else {
  		running = false;
  	}
  }

  var Ticker = function Ticker ( options ) {
  	this.duration = options.duration;
  	this.step = options.step;
  	this.complete = options.complete;
  	this.easing = options.easing;

  	this.start = getTime();
  	this.end = this.start + this.duration;

  	this.running = true;

  	tickers.push( this );
  	if ( !running ) rAF( tick );
  };

  Ticker.prototype.tick = function tick$1 ( now ) {
  	if ( !this.running ) return false;

  	if ( now > this.end ) {
  		if ( this.step ) this.step( 1 );
  		if ( this.complete ) this.complete( 1 );

  		return false;
  	}

  	var elapsed = now - this.start;
  	var eased = this.easing( elapsed / this.duration );

  	if ( this.step ) this.step( eased );

  	return true;
  };

  Ticker.prototype.stop = function stop () {
  	if ( this.abort ) this.abort();
  	this.running = false;
  };

  var prefixers = {};

  // TODO this is legacy. sooner we can replace the old adaptor API the better
  function prefixKeypath ( obj, prefix ) {
  	var prefixed = {}, key;

  	if ( !prefix ) {
  		return obj;
  	}

  	prefix += '.';

  	for ( key in obj ) {
  		if ( obj.hasOwnProperty( key ) ) {
  			prefixed[ prefix + key ] = obj[ key ];
  		}
  	}

  	return prefixed;
  }

  function getPrefixer ( rootKeypath ) {
  	var rootDot;

  	if ( !prefixers[ rootKeypath ] ) {
  		rootDot = rootKeypath ? rootKeypath + '.' : '';

  		prefixers[ rootKeypath ] = function ( relativeKeypath, value ) {
  			var obj;

  			if ( typeof relativeKeypath === 'string' ) {
  				obj = {};
  				obj[ rootDot + relativeKeypath ] = value;
  				return obj;
  			}

  			if ( typeof relativeKeypath === 'object' ) {
  				// 'relativeKeypath' is in fact a hash, not a keypath
  				return rootDot ? prefixKeypath( relativeKeypath, rootKeypath ) : relativeKeypath;
  			}
  		};
  	}

  	return prefixers[ rootKeypath ];
  }

  var KeyModel = function KeyModel ( key ) {
  	this.value = key;
  	this.isReadonly = true;
  	this.dependants = [];
  };

  KeyModel.prototype.get = function get () {
  	return unescapeKey( this.value );
  };

  KeyModel.prototype.getKeypath = function getKeypath () {
  	return unescapeKey( this.value );
  };

  KeyModel.prototype.rebind = function rebind ( key ) {
  	this.value = key;
  	this.dependants.forEach( handleChange );
  };

  KeyModel.prototype.register = function register ( dependant ) {
  	this.dependants.push( dependant );
  };

  KeyModel.prototype.unregister = function unregister ( dependant ) {
  	removeFromArray( this.dependants, dependant );
  };

  var KeypathModel = function KeypathModel ( parent, ractive ) {
  	this.parent = parent;
  	this.ractive = ractive;
  	this.value = ractive ? parent.getKeypath( ractive ) : parent.getKeypath();
  	this.dependants = [];
  	this.children = [];
  };

  KeypathModel.prototype.addChild = function addChild( model ) {
  	this.children.push( model );
  	model.owner = this;
  };

  KeypathModel.prototype.get = function get () {
  	return this.value;
  };

  KeypathModel.prototype.getKeypath = function getKeypath () {
  	return this.value;
  };

  KeypathModel.prototype.handleChange = function handleChange$1 () {
  	this.value = this.ractive ? this.parent.getKeypath( this.ractive ) : this.parent.getKeypath();
  	if ( this.ractive && this.owner ) {
  		this.ractive.viewmodel.keypathModels[ this.owner.value ] = this;
  	}
  	this.children.forEach( handleChange );
  	this.dependants.forEach( handleChange );
  };

  KeypathModel.prototype.register = function register ( dependant ) {
  	this.dependants.push( dependant );
  };

  KeypathModel.prototype.removeChild = function removeChild( model ) {
  	removeFromArray( this.children, model );
  };

  KeypathModel.prototype.teardown = function teardown$1 () {
  	if ( this.owner ) this.owner.removeChild( this );
  	this.children.forEach( teardown );
  };

  KeypathModel.prototype.unregister = function unregister ( dependant ) {
  	removeFromArray( this.dependants, dependant );
  };

  var hasProp = Object.prototype.hasOwnProperty;

  function updateFromBindings ( model ) {
  	model.updateFromBindings( true );
  }

  function updateKeypathDependants ( model ) {
  	model.updateKeypathDependants();
  }

  var originatingModel = null;

  var Model = function Model ( parent, key ) {
  	this.deps = [];

  	this.children = [];
  	this.childByKey = {};

  	this.indexModels = [];

  	this.unresolved = [];
  	this.unresolvedByKey = {};

  	this.bindings = [];
  	this.patternObservers = [];

  	this.value = undefined;

  	this.ticker = null;

  	if ( parent ) {
  		this.parent = parent;
  		this.root = parent.root;
  		this.key = unescapeKey( key );
  		this.isReadonly = parent.isReadonly;

  		if ( parent.value ) {
  			this.value = parent.value[ this.key ];
  			this.adapt();
  		}
  	}
  };

  Model.prototype.adapt = function adapt () {
  	var this$1 = this;

  		var adaptors = this.root.adaptors;
  	var len = adaptors.length;

  	this.rewrap = false;

  	// Exit early if no adaptors
  	if ( len === 0 ) return;

  	var value = this.value;

  	// TODO remove this legacy nonsense
  	var ractive = this.root.ractive;
  	var keypath = this.getKeypath();

  	// tear previous adaptor down if present
  	if ( this.wrapper ) {
  		var shouldTeardown = !this.wrapper.reset || this.wrapper.reset( value ) === false;

  		if ( shouldTeardown ) {
  			this.wrapper.teardown();
  			this.wrapper = null;

  			// don't branch for undefined values
  			if ( this.value !== undefined ) {
  				var parentValue = this.parent.value || this.parent.createBranch( this.key );
  				if ( parentValue[ this.key ] !== this.value ) parentValue[ this.key ] = value;
  			}
  		} else {
  			this.value = this.wrapper.get();
  			return;
  		}
  	}

  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		var adaptor = adaptors[i];
  		if ( adaptor.filter( value, keypath, ractive ) ) {
  			this$1.wrapper = adaptor.wrap( ractive, value, keypath, getPrefixer( keypath ) );
  			this$1.wrapper.value = this$1.value;
  			this$1.wrapper.__model = this$1; // massive temporary hack to enable array adaptor

  			this$1.value = this$1.wrapper.get();

  			break;
  		}
  	}
  };

  Model.prototype.addUnresolved = function addUnresolved ( key, resolver ) {
  	if ( !this.unresolvedByKey[ key ] ) {
  		this.unresolved.push( key );
  		this.unresolvedByKey[ key ] = [];
  	}

  	this.unresolvedByKey[ key ].push( resolver );
  };

  Model.prototype.animate = function animate ( from, to, options, interpolator ) {
  	var this$1 = this;

  		if ( this.ticker ) this.ticker.stop();

  	var fulfilPromise;
  	var promise = new Promise$1( function ( fulfil ) { return fulfilPromise = fulfil; } );

  	this.ticker = new Ticker({
  		duration: options.duration,
  		easing: options.easing,
  		step: function ( t ) {
  			var value = interpolator( t );
  			this$1.applyValue( value );
  			if ( options.step ) options.step( t, value );
  		},
  		complete: function () {
  			this$1.applyValue( to );
  			if ( options.complete ) options.complete( to );

  			this$1.ticker = null;
  			fulfilPromise();
  		}
  	});

  	promise.stop = this.ticker.stop;
  	return promise;
  };

  Model.prototype.applyValue = function applyValue ( value ) {
  	if ( isEqual( value, this.value ) ) return;

  	// TODO deprecate this nonsense
  	this.registerChange( this.getKeypath(), value );

  	if ( this.parent.wrapper && this.parent.wrapper.set ) {
  		this.parent.wrapper.set( this.key, value );
  		this.parent.value = this.parent.wrapper.get();

  		this.value = this.parent.value[ this.key ];
  		this.adapt();
  	} else if ( this.wrapper ) {
  		this.value = value;
  		this.adapt();
  	} else {
  		var parentValue = this.parent.value || this.parent.createBranch( this.key );
  		parentValue[ this.key ] = value;

  		this.value = value;
  		this.adapt();
  	}

  	this.parent.clearUnresolveds();
  	this.clearUnresolveds();

  	// notify dependants
  	var previousOriginatingModel = originatingModel; // for the array.length special case
  	originatingModel = this;

  	this.children.forEach( mark );
  	this.deps.forEach( handleChange );

  	this.notifyUpstream();

  	originatingModel = previousOriginatingModel;
  };

  Model.prototype.clearUnresolveds = function clearUnresolveds ( specificKey ) {
  	var this$1 = this;

  		var i = this.unresolved.length;

  	while ( i-- ) {
  		var key = this$1.unresolved[i];

  		if ( specificKey && key !== specificKey ) continue;

  		var resolvers = this$1.unresolvedByKey[ key ];
  		var hasKey = this$1.has( key );

  		var j = resolvers.length;
  		while ( j-- ) {
  			if ( hasKey ) resolvers[j].attemptResolution();
  			if ( resolvers[j].resolved ) resolvers.splice( j, 1 );
  		}

  		if ( !resolvers.length ) {
  			this$1.unresolved.splice( i, 1 );
  			this$1.unresolvedByKey[ key ] = null;
  		}
  	}
  };

  Model.prototype.createBranch = function createBranch ( key ) {
  	var branch = isNumeric( key ) ? [] : {};
  	this.set( branch );

  	return branch;
  };

  Model.prototype.findMatches = function findMatches ( keys ) {
  	var len = keys.length;

  	var existingMatches = [ this ];
  	var matches;
  	var i;

  	var loop = function (  ) {
  		var key = keys[i];

  		if ( key === '*' ) {
  			matches = [];
  			existingMatches.forEach( function ( model ) {
  				matches.push.apply( matches, model.getValueChildren( model.get() ) );
  			});
  		} else {
  			matches = existingMatches.map( function ( model ) { return model.joinKey( key ); } );
  		}

  		existingMatches = matches;
  	};

  		for ( i = 0; i < len; i += 1 ) loop(  );

  	return matches;
  };

  Model.prototype.get = function get ( shouldCapture ) {
  	if ( shouldCapture ) capture( this );
  	// if capturing, this value needs to be unwrapped because it's for external use
  	return shouldCapture && this.wrapper ? this.wrapper.value : this.value;
  };

  Model.prototype.getIndexModel = function getIndexModel ( fragmentIndex ) {
  	var indexModels = this.parent.indexModels;

  	// non-numeric keys are a special of a numeric index in a object iteration
  	if ( typeof this.key === 'string' && fragmentIndex !== undefined ) {
  		return new KeyModel( fragmentIndex );
  	} else if ( !indexModels[ this.key ] ) {
  		indexModels[ this.key ] = new KeyModel( this.key );
  	}

  	return indexModels[ this.key ];
  };

  Model.prototype.getKeyModel = function getKeyModel () {
  	// TODO... different to IndexModel because key can never change
  	return new KeyModel( escapeKey( this.key ) );
  };

  Model.prototype.getKeypathModel = function getKeypathModel ( ractive ) {
  	var keypath = this.getKeypath(), model = this.keypathModel || ( this.keypathModel = new KeypathModel( this ) );

  	if ( ractive && ractive.component ) {
  		var mapped = this.getKeypath( ractive );
  		if ( mapped !== keypath ) {
  			var map = ractive.viewmodel.keypathModels || ( ractive.viewmodel.keypathModels = {} );
  			var child = map[ keypath ] || ( map[ keypath ] = new KeypathModel( this, ractive ) );
  			model.addChild( child );
  			return child;
  		}
  	}

  	return model;
  };

  Model.prototype.getKeypath = function getKeypath ( ractive ) {
  	var root = this.parent.isRoot ? escapeKey( this.key ) : this.parent.getKeypath() + '.' + escapeKey( this.key );

  	if ( ractive && ractive.component ) {
  		var map = ractive.viewmodel.mappings;
  		for ( var k in map ) {
  			if ( root.indexOf( map[ k ].getKeypath() ) >= 0 ) {
  				root = root.replace( map[ k ].getKeypath(), k );
  				break;
  			}
  		}
  	}

  	return root;
  };

  Model.prototype.getValueChildren = function getValueChildren ( value ) {
  	var this$1 = this;

  		var children;
  	if ( isArray( value ) ) {
  		children = [];
  		// special case - array.length. This is a horrible kludge, but
  		// it'll do for now. Alternatives welcome
  		if ( originatingModel && originatingModel.parent === this && originatingModel.key === 'length' ) {
  			children.push( originatingModel );
  		}
  		value.forEach( function ( m, i ) {
  			children.push( this$1.joinKey( i ) );
  		});

  	}

  	else if ( isObject( value ) || typeof value === 'function' ) {
  		children = Object.keys( value ).map( function ( key ) { return this$1.joinKey( key ); } );
  	}

  	else if ( value != null ) {
  		return [];
  	}

  	return children;
  };

  Model.prototype.has = function has ( key ) {
  	var value = this.get();
  	if ( !value ) return false;

  	key = unescapeKey( key );
  	if ( hasProp.call( value, key ) ) return true;

  	// We climb up the constructor chain to find if one of them contains the key
  	var constructor = value.constructor;
  	while ( constructor !== Function && constructor !== Array && constructor !== Object ) {
  		if ( hasProp.call( constructor.prototype, key ) ) return true;
  		constructor = constructor.constructor;
  	}

  	return false;
  };

  Model.prototype.joinKey = function joinKey ( key ) {
  	if ( key === undefined || key === '' ) return this;

  	if ( !this.childByKey.hasOwnProperty( key ) ) {
  		var child = new Model( this, key );
  		this.children.push( child );
  		this.childByKey[ key ] = child;
  	}

  	return this.childByKey[ key ];
  };

  Model.prototype.joinAll = function joinAll ( keys ) {
  	var model = this;
  	for ( var i = 0; i < keys.length; i += 1 ) {
  		model = model.joinKey( keys[i] );
  	}

  	return model;
  };

  Model.prototype.mark = function mark$1 () {
  	var value = this.retrieve();

  	if ( !isEqual( value, this.value ) ) {
  		var old = this.value;
  		this.value = value;

  		// make sure the wrapper stays in sync
  		if ( old !== value || this.rewrap ) this.adapt();

  		this.children.forEach( mark );

  		this.deps.forEach( handleChange );
  		this.clearUnresolveds();
  	}
  };

  Model.prototype.merge = function merge ( array, comparator ) {
  	var oldArray = comparator ? this.value.map( comparator ) : this.value;
  	var newArray = comparator ? array.map( comparator ) : array;

  	var oldLength = oldArray.length;

  	var usedIndices = {};
  	var firstUnusedIndex = 0;

  	var newIndices = oldArray.map( function ( item ) {
  		var index;
  		var start = firstUnusedIndex;

  		do {
  			index = newArray.indexOf( item, start );

  			if ( index === -1 ) {
  				return -1;
  			}

  			start = index + 1;
  		} while ( ( usedIndices[ index ] === true ) && start < oldLength );

  		// keep track of the first unused index, so we don't search
  		// the whole of newArray for each item in oldArray unnecessarily
  		if ( index === firstUnusedIndex ) {
  			firstUnusedIndex += 1;
  		}
  		// allow next instance of next "equal" to be found item
  		usedIndices[ index ] = true;
  		return index;
  	});

  	this.parent.value[ this.key ] = array;
  	this._merged = true;
  	this.shuffle( newIndices );
  };

  Model.prototype.notifyUpstream = function notifyUpstream () {
  	var parent = this.parent, prev = this;
  	while ( parent ) {
  		if ( parent.patternObservers.length ) parent.patternObservers.forEach( function ( o ) { return o.notify( prev.key ); } );
  		parent.deps.forEach( handleChange );
  		prev = parent;
  		parent = parent.parent;
  	}
  };

  Model.prototype.register = function register ( dep ) {
  	this.deps.push( dep );
  };

  Model.prototype.registerChange = function registerChange ( key, value ) {
  	if ( !this.isRoot ) {
  		this.root.registerChange( key, value );
  	} else {
  		this.changes[ key ] = value;
  		runloop.addInstance( this.root.ractive );
  	}
  };

  Model.prototype.registerPatternObserver = function registerPatternObserver ( observer ) {
  	this.patternObservers.push( observer );
  	this.register( observer );
  };

  Model.prototype.registerTwowayBinding = function registerTwowayBinding ( binding ) {
  	this.bindings.push( binding );
  };

  Model.prototype.removeUnresolved = function removeUnresolved ( key, resolver ) {
  	var resolvers = this.unresolvedByKey[ key ];

  	if ( resolvers ) {
  		removeFromArray( resolvers, resolver );
  	}
  };

  Model.prototype.retrieve = function retrieve () {
  	return this.parent.value ? this.parent.value[ this.key ] : undefined;
  };

  Model.prototype.set = function set ( value ) {
  	if ( this.ticker ) this.ticker.stop();
  	this.applyValue( value );
  };

  Model.prototype.shuffle = function shuffle ( newIndices ) {
  	var this$1 = this;

  		var indexModels = [];

  	newIndices.forEach( function ( newIndex, oldIndex ) {
  		if ( newIndex !== oldIndex && this$1.childByKey[oldIndex] ) this$1.childByKey[oldIndex].shuffled();

  		if ( !~newIndex ) return;

  		var model = this$1.indexModels[ oldIndex ];

  		if ( !model ) return;

  		indexModels[ newIndex ] = model;

  		if ( newIndex !== oldIndex ) {
  			model.rebind( newIndex );
  		}
  	});

  	this.indexModels = indexModels;

  	// shuffles need to happen before marks...
  	this.deps.forEach( function ( dep ) {
  		if ( dep.shuffle ) dep.shuffle( newIndices );
  	});

  	this.updateKeypathDependants();
  	this.mark();

  	// ...but handleChange must happen after (TODO document why)
  	this.deps.forEach( function ( dep ) {
  		if ( !dep.shuffle ) dep.handleChange();
  	});
  };

  Model.prototype.shuffled = function shuffled () {
  	var this$1 = this;

  		var i = this.children.length;
  	while ( i-- ) {
  		this$1.children[i].shuffled();
  	}
  	if ( this.wrapper ) {
  		this.wrapper.teardown();
  		this.wrapper = null;
  		this.rewrap = true;
  	}
  };

  Model.prototype.teardown = function teardown$1 () {
  	this.children.forEach( teardown );
  	if ( this.wrapper ) this.wrapper.teardown();
  	if ( this.keypathModels ) {
  		for ( var k in this.keypathModels ) {
  			this.keypathModels[ k ].teardown();
  		}
  	}
  };

  Model.prototype.unregister = function unregister ( dependant ) {
  	removeFromArray( this.deps, dependant );
  };

  Model.prototype.unregisterPatternObserver = function unregisterPatternObserver ( observer ) {
  	removeFromArray( this.patternObservers, observer );
  	this.unregister( observer );
  };

  Model.prototype.unregisterTwowayBinding = function unregisterTwowayBinding ( binding ) {
  	removeFromArray( this.bindings, binding );
  };

  Model.prototype.updateFromBindings = function updateFromBindings$1 ( cascade ) {
  	var this$1 = this;

  		var i = this.bindings.length;
  	while ( i-- ) {
  		var value = this$1.bindings[i].getValue();
  		if ( value !== this$1.value ) this$1.set( value );
  	}

  	if ( cascade ) {
  		this.children.forEach( updateFromBindings );
  	}
  };

  Model.prototype.updateKeypathDependants = function updateKeypathDependants$1 () {
  	this.children.forEach( updateKeypathDependants );
  	if ( this.keypathModel ) this.keypathModel.handleChange();
  };

  var GlobalModel = (function (Model) {
  	function GlobalModel ( ) {
  		Model.call( this, null, '@global' );
  		this.value = typeof global !== 'undefined' ? global : window;
  		this.isRoot = true;
  		this.root = this;
  		this.adaptors = [];
  	}

  	GlobalModel.prototype = Object.create( Model && Model.prototype );
  	GlobalModel.prototype.constructor = GlobalModel;

  	GlobalModel.prototype.getKeypath = function getKeypath() {
  		return '@global';
  	};

  	// global model doesn't contribute changes events because it has no instance
  	GlobalModel.prototype.registerChange = function registerChange () {};

  	return GlobalModel;
  }(Model));

  var GlobalModel$1 = new GlobalModel();

  var keypathExpr = /^@[^\(]+\(([^\)]+)\)/;

  function resolveReference ( fragment, ref ) {
  	var context = fragment.findContext();

  	// special references
  	// TODO does `this` become `.` at parse time?
  	if ( ref === '.' || ref === 'this' ) return context;
  	if ( ref.indexOf( '@keypath' ) === 0 ) {
  		var match = keypathExpr.exec( ref );
  		if ( match && match[1] ) {
  			var model = resolveReference( fragment, match[1] );
  			if ( model ) return model.getKeypathModel( fragment.ractive );
  		}
  		return context.getKeypathModel( fragment.ractive );
  	}
  	if ( ref.indexOf( '@rootpath' ) === 0 ) {
  		var match$1 = keypathExpr.exec( ref );
  		if ( match$1 && match$1[1] ) {
  			var model$1 = resolveReference( fragment, match$1[1] );
  			if ( model$1 ) return model$1.getKeypathModel();
  		}
  		return context.getKeypathModel();
  	}
  	if ( ref === '@index' ) {
  		var repeater = fragment.findRepeatingFragment();
  		// make sure the found fragment is actually an iteration
  		if ( !repeater.isIteration ) return;
  		return repeater.context.getIndexModel( repeater.index );
  	}
  	if ( ref === '@key' ) return fragment.findRepeatingFragment().context.getKeyModel();
  	if ( ref === '@this' ) {
  		return fragment.ractive.viewmodel.getRactiveModel();
  	}
  	if ( ref === '@global' ) {
  		return GlobalModel$1;
  	}

  	// ancestor references
  	if ( ref[0] === '~' ) return fragment.ractive.viewmodel.joinAll( splitKeypathI( ref.slice( 2 ) ) );
  	if ( ref[0] === '.' ) {
  		var parts = ref.split( '/' );

  		while ( parts[0] === '.' || parts[0] === '..' ) {
  			var part = parts.shift();

  			if ( part === '..' ) {
  				context = context.parent;
  			}
  		}

  		ref = parts.join( '/' );

  		// special case - `{{.foo}}` means the same as `{{./foo}}`
  		if ( ref[0] === '.' ) ref = ref.slice( 1 );
  		return context.joinAll( splitKeypathI( ref ) );
  	}

  	return resolveAmbiguousReference( fragment, ref );
  }

  function Ractive$get ( keypath ) {
  	if ( !keypath ) return this.viewmodel.get( true );

  	var keys = splitKeypathI( keypath );
  	var key = keys[0];

  	var model;

  	if ( !this.viewmodel.has( key ) ) {
  		// if this is an inline component, we may need to create
  		// an implicit mapping
  		if ( this.component && !this.isolated ) {
  			model = resolveReference( this.component.parentFragment, key );

  			if ( model ) {
  				this.viewmodel.map( key, model );
  			}
  		}
  	}

  	model = this.viewmodel.joinAll( keys );
  	return model.get( true );
  }

  function gatherRefs( fragment ) {
  	var key = {}, index = {};

  	// walk up the template gather refs as we go
  	while ( fragment ) {
  		if ( fragment.parent && ( fragment.parent.indexRef || fragment.parent.keyRef ) ) {
  			var ref = fragment.parent.indexRef;
  			if ( ref && !( ref in index ) ) index[ref] = fragment.index;
  			ref = fragment.parent.keyRef;
  			if ( ref && !( ref in key ) ) key[ref] = fragment.key;
  		}

  		if ( fragment.componentParent && !fragment.ractive.isolated ) {
  			fragment = fragment.componentParent;
  		} else {
  			fragment = fragment.parent;
  		}
  	}

  	return { key: key, index: index };
  }

  // get relative keypaths and values
  function get ( keypath ) {
  	if ( !keypath ) return this._element.parentFragment.findContext().get( true );

  	var model = resolveReference( this._element.parentFragment, keypath );

  	return model ? model.get( true ) : undefined;
  }

  function resolve$1 ( path, ractive ) {
  	var frag = this._element.parentFragment;

  	if ( typeof path !== 'string' ) {
  		return frag.findContext().getKeypath( path === undefined ? frag.ractive : path );
  	}

  	var model = resolveReference( frag, path );

  	return model ? model.getKeypath( ractive === undefined ? frag.ractive : ractive ) : path;
  }

  // the usual mutation suspects
  function add$1 ( keypath, value ) {
  	return this.ractive.add( this.resolve( keypath ), value );
  }

  function animate ( keypath, value, options ) {
  	return this.ractive.animate( this.resolve( keypath ), value, options );
  }

  function link ( source, dest ) {
  	return this.ractive.link( this.resolve( source ), this.resolve( dest ) );
  }

  function merge ( keypath, array ) {
  	return this.ractive.merge( this.resolve( keypath ), array );
  }

  function pop ( keypath ) {
  	return this.ractive.pop( this.resolve( keypath ) );
  }

  function push ( keypath ) {
  	var values = [], len = arguments.length - 1;
  	while ( len-- > 0 ) values[ len ] = arguments[ len + 1 ];

  	values.unshift( this.resolve( keypath ) );
  	return this.ractive.push.apply( this.ractive, values );
  }

  function set ( keypath, value ) {
  	return this.ractive.set( this.resolve( keypath ), value );
  }

  function shift ( keypath ) {
  	return this.ractive.shift( this.resolve( keypath ) );
  }

  function splice ( keypath, index, drop ) {
  	var add = [], len = arguments.length - 3;
  	while ( len-- > 0 ) add[ len ] = arguments[ len + 3 ];

  	add.unshift( this.resolve( keypath ), index, drop );
  	return this.ractive.splice.apply( this.ractive, add );
  }

  function subtract ( keypath, value ) {
  	return this.ractive.subtract( this.resolve( keypath ), value );
  }

  function toggle ( keypath ) {
  	return this.ractive.toggle( this.resolve( keypath ) );
  }

  function unlink ( dest ) {
  	return this.ractive.unlink( dest );
  }

  function unshift ( keypath ) {
  	var add = [], len = arguments.length - 1;
  	while ( len-- > 0 ) add[ len ] = arguments[ len + 1 ];

  	add.unshift( this.resolve( keypath ) );
  	return this.ractive.unshift.apply( this.ractive, add );
  }

  function update$1 ( keypath ) {
  	return this.ractive.update( this.resolve( keypath ) );
  }

  function updateModel ( keypath, cascade ) {
  	return this.ractive.updateModel( this.resolve( keypath ), cascade );
  }

  // two-way binding related helpers
  function isBound () {
  	var el = this._element;

  	if ( el.binding ) return true;
  	else return false;
  }

  function getBindingPath ( ractive ) {
  	var el = this._element;

  	if ( el.binding && el.binding.model ) return el.binding.model.getKeypath( ractive || el.parentFragment.ractive );
  }

  function getBinding () {
  	var el = this._element;

  	if ( el.binding && el.binding.model ) return el.binding.model.get( true );
  }

  function setBinding ( value ) {
  	return this.ractive.set( this.getBindingPath(), value );
  }

  // deprecated getters
  function keypath () {
  	warnOnceIfDebug( ("Object property keypath is deprecated, please use resolve() instead.") );
  	return this.resolve();
  }

  function rootpath () {
  	warnOnceIfDebug( ("Object property rootpath is deprecated, please use resolve( ractive.root ) instead.") );
  	return this.resolve( this.ractive.root );
  }

  function context () {
  	warnOnceIfDebug( ("Object property context is deprecated, please use get() instead.") );
  	return this.get();
  }

  function index () {
  	warnOnceIfDebug( ("Object property index is deprecated, you can use get( \"indexName\" ) instead.") );
  	return gatherRefs( this._element.parentFragment ).index;
  }

  function key () {
  	warnOnceIfDebug( ("Object property key is deprecated, you can use get( \"keyName\" ) instead.") );
  	return gatherRefs( this._element.parentFragment ).key;
  }

  function addHelpers ( obj, element ) {
  	defineProperties( obj, {
  		_element: { value: element },
  		ractive: { value: element.parentFragment.ractive },
  		resolve: { value: resolve$1 },
  		get: { value: get },

  		add: { value: add$1 },
  		animate: { value: animate },
  		link: { value: link },
  		merge: { value: merge },
  		pop: { value: pop },
  		push: { value: push },
  		set: { value: set },
  		shift: { value: shift },
  		splice: { value: splice },
  		subtract: { value: subtract },
  		toggle: { value: toggle },
  		unlink: { value: unlink },
  		unshift: { value: unshift },
  		update: { value: update$1 },
  		updateModel: { value: updateModel },

  		isBound: { value: isBound },
  		getBindingPath: { value: getBindingPath },
  		getBinding: { value: getBinding },
  		setBinding: { value: setBinding },

  		keypath: { get: keypath },
  		rootpath: { get: rootpath },
  		context: { get: context },
  		index: { get: index },
  		key: { get: key }
  	});

  	return obj;
  }

  var query = doc && doc.querySelector;

  function staticInfo( node ) {
  	if ( typeof node === 'string' && query ) {
  		node = query.call( document, node );
  	}

  	if ( !node || !node._ractive ) return {};

  	var storage = node._ractive;

  	return addHelpers( {}, storage.proxy );
  }

  function getNodeInfo( node ) {
  	if ( typeof node === 'string' ) {
  		node = this.find( node );
  	}

  	return staticInfo( node );
  }

  var insertHook = new Hook( 'insert' );

  function Ractive$insert ( target, anchor ) {
  	if ( !this.fragment.rendered ) {
  		// TODO create, and link to, documentation explaining this
  		throw new Error( 'The API has changed - you must call `ractive.render(target[, anchor])` to render your Ractive instance. Once rendered you can use `ractive.insert()`.' );
  	}

  	target = getElement( target );
  	anchor = getElement( anchor ) || null;

  	if ( !target ) {
  		throw new Error( 'You must specify a valid target to insert into' );
  	}

  	target.insertBefore( this.detach(), anchor );
  	this.el = target;

  	( target.__ractive_instances__ || ( target.__ractive_instances__ = [] ) ).push( this );
  	this.isDetached = false;

  	fireInsertHook( this );
  }

  function fireInsertHook( ractive ) {
  	insertHook.fire( ractive );

  	ractive.findAllComponents('*').forEach( function ( child ) {
  		fireInsertHook( child.instance );
  	});
  }

  function link$1( there, here ) {
  	if ( here === there || (there + '.').indexOf( here + '.' ) === 0 || (here + '.').indexOf( there + '.' ) === 0 ) {
  		throw new Error( 'A keypath cannot be linked to itself.' );
  	}

  	var promise = runloop.start();

  	var model;
  	var ln = this._links[ here ];

  	if ( ln ) {
  		if ( ln.source.model.str !== there || ln.dest.model.str !== here ) {
  			ln.unlink();
  			delete this._links[ here ];
  			this.viewmodel.joinAll( splitKeypathI( here ) ).set( ln.initialValue );
  		} else { // already linked, so nothing to do
  			runloop.end();
  			return promise;
  		}
  	}

  	// may need to allow a mapping to resolve implicitly
  	var sourcePath = splitKeypathI( there );
  	if ( !this.viewmodel.has( sourcePath[0] ) && this.component ) {
  		model = resolveReference( this.component.parentFragment, sourcePath[0] );

  		if ( model ) {
  			this.viewmodel.map( sourcePath[0], model );
  		}
  	}

  	ln = new Link( this.viewmodel.joinAll( sourcePath ), this.viewmodel.joinAll( splitKeypathI( here ) ), this );
  	this._links[ here ] = ln;
  	ln.source.handleChange();

  	runloop.end();

  	return promise;
  }

  var Link = function Link ( source, dest, ractive ) {
  	this.source = new LinkSide( source, this );
  	this.dest = new LinkSide( dest, this );
  	this.ractive = ractive;
  	this.locked = false;
  	this.initialValue = dest.get();
  };

  Link.prototype.sync = function sync ( side ) {
  	if ( !this.locked ) {
  		this.locked = true;

  		if ( side === this.dest ) {
  			this.source.model.set( this.dest.model.get() );
  		} else {
  			this.dest.model.set( this.source.model.get() );
  		}

  		this.locked = false;
  	}
  };

  Link.prototype.unlink = function unlink () {
  	this.source.model.unregister( this.source );
  	this.dest.model.unregister( this.dest );
  };

  var LinkSide = function LinkSide ( model, owner ) {
  	this.model = model;
  	this.owner = owner;
  	model.register( this );
  };

  LinkSide.prototype.handleChange = function handleChange () {
  	this.owner.sync( this );
  };

  var comparators = {};

  function getComparator ( option ) {
  	if ( !option ) return null; // use existing arrays
  	if ( option === true ) return JSON.stringify;
  	if ( typeof option === 'function' ) return option;

  	if ( typeof option === 'string' ) {
  		return comparators[ option ] || ( comparators[ option ] = function ( thing ) { return thing[ option ]; } );
  	}

  	throw new Error( 'If supplied, options.compare must be a string, function, or `true`' ); // TODO link to docs
  }

  function Ractive$merge ( keypath, array, options ) {
  	var model = this.viewmodel.joinAll( splitKeypathI( keypath ) );
  	var promise = runloop.start( this, true );
  	var value = model.get();

  	if ( array === value ) {
  		throw new Error( 'You cannot merge an array with itself' ); // TODO link to docs
  	} else if ( !isArray( value ) || !isArray( array ) ) {
  		throw new Error( 'You cannot merge an array with a non-array' );
  	}

  	var comparator = getComparator( options && options.compare );
  	model.merge( array, comparator );

  	runloop.end();
  	return promise;
  }

  function observe ( keypath, callback, options ) {
  	var this$1 = this;

  	var observers = [];
  	var map;

  	if ( isObject( keypath ) ) {
  		map = keypath;
  		options = callback || {};

  		Object.keys( map ).forEach( function ( keypath ) {
  			var callback = map[ keypath ];

  			keypath.split( ' ' ).forEach( function ( keypath ) {
  				observers.push( createObserver( this$1, keypath, callback, options ) );
  			});
  		});
  	}

  	else {
  		var keypaths;

  		if ( typeof keypath === 'function' ) {
  			options = callback;
  			callback = keypath;
  			keypaths = [ '' ];
  		} else {
  			keypaths = keypath.split( ' ' );
  		}

  		keypaths.forEach( function ( keypath ) {
  			observers.push( createObserver( this$1, keypath, callback, options || {} ) );
  		});
  	}

  	// add observers to the Ractive instance, so they can be
  	// cancelled on ractive.teardown()
  	this._observers.push.apply( this._observers, observers );

  	return {
  		cancel: function () {
  			observers.forEach( function ( observer ) {
  				removeFromArray ( this$1._observers, observer );
  				observer.cancel();
  			} );
  		}
  	};
  }

  function createObserver ( ractive, keypath, callback, options ) {
  	var viewmodel = ractive.viewmodel;

  	var keys = splitKeypathI( keypath );
  	var wildcardIndex = keys.indexOf( '*' );

  	// normal keypath - no wildcards
  	if ( !~wildcardIndex ) {
  		var key = keys[0];

  		// if not the root model itself, check if viewmodel has key.
  		if ( key !== '' && !viewmodel.has( key ) ) {
  			// if this is an inline component, we may need to create an implicit mapping
  			if ( ractive.component ) {
  				var model = resolveReference( ractive.component.parentFragment, key );
  				if ( model ) viewmodel.map( key, model );
  			}
  		}

  		var model$1 = viewmodel.joinAll( keys );
  		return new Observer( ractive, model$1, callback, options );
  	}

  	// pattern observers - more complex case
  	var baseModel = wildcardIndex === 0 ?
  		viewmodel :
  		viewmodel.joinAll( keys.slice( 0, wildcardIndex ) );

  	return new PatternObserver( ractive, baseModel, keys.splice( wildcardIndex ), callback, options );
  }

  var Observer = function Observer ( ractive, model, callback, options ) {
  	this.context = options.context || ractive;
  	this.model = model;
  	this.keypath = model.getKeypath( ractive );
  	this.callback = callback;

  	this.oldValue = undefined;
  	this.newValue = model.get();

  	this.defer = options.defer;
  	this.once = options.once;
  	this.strict = options.strict;

  	this.dirty = false;

  	if ( options.init !== false ) {
  		this.dispatch();
  	} else {
  		this.oldValue = this.newValue;
  	}

  	model.register( this );
  };

  Observer.prototype.cancel = function cancel () {
  	this.model.unregister( this );
  };

  Observer.prototype.dispatch = function dispatch () {
  	this.callback.call( this.context, this.newValue, this.oldValue, this.keypath );
  	this.oldValue = this.newValue;
  	this.dirty = false;
  };

  Observer.prototype.handleChange = function handleChange () {
  	if ( !this.dirty ) {
  		this.newValue = this.model.get();

  		if ( this.strict && this.newValue === this.oldValue ) return;

  		runloop.addObserver( this, this.defer );
  		this.dirty = true;

  		if ( this.once ) this.cancel();
  	}
  };

  var PatternObserver = function PatternObserver ( ractive, baseModel, keys, callback, options ) {
  	var this$1 = this;

  		this.context = options.context || ractive;
  	this.ractive = ractive;
  	this.baseModel = baseModel;
  	this.keys = keys;
  	this.callback = callback;

  	var pattern = keys.join( '\\.' ).replace( /\*/g, '(.+)' );
  	var baseKeypath = baseModel.getKeypath( ractive );
  	this.pattern = new RegExp( ("^" + (baseKeypath ? baseKeypath + '\\.' : '') + "" + pattern + "$") );

  	this.oldValues = {};
  	this.newValues = {};

  	this.defer = options.defer;
  	this.once = options.once;
  	this.strict = options.strict;

  	this.dirty = false;
  	this.changed = [];
  	this.partial = false;

  	var models = baseModel.findMatches( this.keys );

  	models.forEach( function ( model ) {
  		this$1.newValues[ model.getKeypath( this$1.ractive ) ] = model.get();
  	});

  	if ( options.init !== false ) {
  		this.dispatch();
  	} else {
  		this.oldValues = this.newValues;
  	}

  	baseModel.registerPatternObserver( this );
  };

  PatternObserver.prototype.cancel = function cancel () {
  	this.baseModel.unregisterPatternObserver( this );
  };

  PatternObserver.prototype.dispatch = function dispatch () {
  	var this$1 = this;

  		Object.keys( this.newValues ).forEach( function ( keypath ) {
  		if ( this$1.newKeys && !this$1.newKeys[ keypath ] ) return;

  		var newValue = this$1.newValues[ keypath ];
  		var oldValue = this$1.oldValues[ keypath ];

  		if ( this$1.strict && newValue === oldValue ) return;
  		if ( isEqual( newValue, oldValue ) ) return;

  		var args = [ newValue, oldValue, keypath ];
  		if ( keypath ) {
  			var wildcards = this$1.pattern.exec( keypath ).slice( 1 );
  			args = args.concat( wildcards );
  		}

  		this$1.callback.apply( this$1.context, args );
  	});

  	if ( this.partial ) {
  		for ( var k in this.newValues ) {
  			this.oldValues[k] = this.newValues[k];
  		}
  	} else {
  		this.oldValues = this.newValues;
  	}

  	this.newKeys = null;
  	this.dirty = false;
  };

  PatternObserver.prototype.notify = function notify ( key ) {
  	this.changed.push( key );
  };

  PatternObserver.prototype.shuffle = function shuffle ( newIndices ) {
  	var this$1 = this;

  		if ( !isArray( this.baseModel.value ) ) return;

  	var base = this.baseModel.getKeypath( this.ractive );
  	var max = this.baseModel.value.length;
  	var suffix = this.keys.length > 1 ? '.' + this.keys.slice( 1 ).join( '.' ) : '';

  	this.newKeys = {};
  	for ( var i = 0; i < newIndices.length; i++ ) {
  		if ( newIndices[ i ] === -1 || newIndices[ i ] === i ) continue;
  		this$1.newKeys[ ("" + base + "." + i + "" + suffix) ] = true;
  	}

  	for ( var i$1 = newIndices.touchedFrom; i$1 < max; i$1++ ) {
  		this$1.newKeys[ ("" + base + "." + i$1 + "" + suffix) ] = true;
  	}
  };

  PatternObserver.prototype.handleChange = function handleChange () {
  	var this$1 = this;

  		if ( !this.dirty ) {
  		this.newValues = {};

  		// handle case where previously extant keypath no longer exists -
  		// observer should still fire, with undefined as new value
  		// TODO huh. according to the test suite that's not the case...
  		// Object.keys( this.oldValues ).forEach( keypath => {
  		// this.newValues[ keypath ] = undefined;
  		// });

  		if ( !this.changed.length ) {
  			this.baseModel.findMatches( this.keys ).forEach( function ( model ) {
  				var keypath = model.getKeypath( this$1.ractive );
  				this$1.newValues[ keypath ] = model.get();
  			});
  			this.partial = false;
  		} else {
  			var ok = this.baseModel.isRoot ?
  				this.changed :
  				this.changed.map( function ( key ) { return this$1.baseModel.getKeypath( this$1.ractive ) + '.' + escapeKey( key ); } );

  			this.baseModel.findMatches( this.keys ).forEach( function ( model ) {
  				var keypath = model.getKeypath( this$1.ractive );
  				// is this model on a changed keypath?
  				if ( ok.filter( function ( k ) { return keypath.indexOf( k ) === 0 && ( keypath.length === k.length || keypath[k.length] === '.' ); } ).length ) {
  					this$1.newValues[ keypath ] = model.get();
  				}
  			});
  			this.partial = true;
  		}

  		runloop.addObserver( this, this.defer );
  		this.dirty = true;
  		this.changed.length = 0;

  		if ( this.once ) this.cancel();
  	}
  };

  function observeList ( keypath, callback, options ) {
  	if ( typeof keypath !== 'string' ) {
  		throw new Error( 'ractive.observeList() must be passed a string as its first argument' );
  	}

  	var model = this.viewmodel.joinAll( splitKeypathI( keypath ) );
  	var observer = new ListObserver( this, model, callback, options || {} );

  	// add observer to the Ractive instance, so it can be
  	// cancelled on ractive.teardown()
  	this._observers.push( observer );

  	return {
  		cancel: function () {
  			observer.cancel();
  		}
  	};
  }

  function negativeOne () {
  	return -1;
  }

  var ListObserver = function ListObserver ( context, model, callback, options ) {
  	this.context = context;
  	this.model = model;
  	this.keypath = model.getKeypath();
  	this.callback = callback;

  	this.pending = null;

  	model.register( this );

  	if ( options.init !== false ) {
  		this.sliced = [];
  		this.shuffle([]);
  		this.handleChange();
  	} else {
  		this.sliced = this.slice();
  	}
  };

  ListObserver.prototype.handleChange = function handleChange () {
  	if ( this.pending ) {
  		// post-shuffle
  		this.callback( this.pending );
  		this.pending = null;
  	}

  	else {
  		// entire array changed
  		this.shuffle( this.sliced.map( negativeOne ) );
  		this.handleChange();
  	}
  };

  ListObserver.prototype.shuffle = function shuffle ( newIndices ) {
  	var this$1 = this;

  		var newValue = this.slice();

  	var inserted = [];
  	var deleted = [];
  	var start;

  	var hadIndex = {};

  	newIndices.forEach( function ( newIndex, oldIndex ) {
  		hadIndex[ newIndex ] = true;

  		if ( newIndex !== oldIndex && start === undefined ) {
  			start = oldIndex;
  		}

  		if ( newIndex === -1 ) {
  			deleted.push( this$1.sliced[ oldIndex ] );
  		}
  	});

  	if ( start === undefined ) start = newIndices.length;

  	var len = newValue.length;
  	for ( var i = 0; i < len; i += 1 ) {
  		if ( !hadIndex[i] ) inserted.push( newValue[i] );
  	}

  	this.pending = { inserted: inserted, deleted: deleted, start: start };
  	this.sliced = newValue;
  };

  ListObserver.prototype.slice = function slice () {
  	var value = this.model.get();
  	return isArray( value ) ? value.slice() : [];
  };

  var onceOptions = { init: false, once: true };

  function observeOnce ( keypath, callback, options ) {
  	if ( isObject( keypath ) || typeof keypath === 'function' ) {
  		options = extendObj( callback || {}, onceOptions );
  		return this.observe( keypath, options );
  	}

  	options = extendObj( options || {}, onceOptions );
  	return this.observe( keypath, callback, options );
  }

  function trim ( str ) { return str.trim(); };

  function notEmptyString ( str ) { return str !== ''; };

  function Ractive$off ( eventName, callback ) {
  	// if no arguments specified, remove all callbacks
  	var this$1 = this;

  	if ( !eventName ) {
  		// TODO use this code instead, once the following issue has been resolved
  		// in PhantomJS (tests are unpassable otherwise!)
  		// https://github.com/ariya/phantomjs/issues/11856
  		// defineProperty( this, '_subs', { value: create( null ), configurable: true });
  		for ( eventName in this._subs ) {
  			delete this._subs[ eventName ];
  		}
  	}

  	else {
  		// Handle multiple space-separated event names
  		var eventNames = eventName.split( ' ' ).map( trim ).filter( notEmptyString );

  		eventNames.forEach( function ( eventName ) {
  			var subscribers = this$1._subs[ eventName ];

  			// If we have subscribers for this event...
  			if ( subscribers ) {
  				// ...if a callback was specified, only remove that
  				if ( callback ) {
  					var index = subscribers.indexOf( callback );
  					if ( index !== -1 ) {
  						subscribers.splice( index, 1 );
  					}
  				}

  				// ...otherwise remove all callbacks
  				else {
  					this$1._subs[ eventName ] = [];
  				}
  			}
  		});
  	}

  	return this;
  }

  function Ractive$on ( eventName, callback ) {
  	// allow multiple listeners to be bound in one go
  	var this$1 = this;

  	if ( typeof eventName === 'object' ) {
  		var listeners = [];
  		var n;

  		for ( n in eventName ) {
  			if ( eventName.hasOwnProperty( n ) ) {
  				listeners.push( this.on( n, eventName[ n ] ) );
  			}
  		}

  		return {
  			cancel: function () {
  				var listener;
  				while ( listener = listeners.pop() ) listener.cancel();
  			}
  		};
  	}

  	// Handle multiple space-separated event names
  	var eventNames = eventName.split( ' ' ).map( trim ).filter( notEmptyString );

  	eventNames.forEach( function ( eventName ) {
  		( this$1._subs[ eventName ] || ( this$1._subs[ eventName ] = [] ) ).push( callback );
  	});

  	return {
  		cancel: function () { return this$1.off( eventName, callback ); }
  	};
  }

  function Ractive$once ( eventName, handler ) {
  	var listener = this.on( eventName, function () {
  		handler.apply( this, arguments );
  		listener.cancel();
  	});

  	// so we can still do listener.cancel() manually
  	return listener;
  }

  // This function takes an array, the name of a mutator method, and the
  // arguments to call that mutator method with, and returns an array that
  // maps the old indices to their new indices.

  // So if you had something like this...
  //
  //     array = [ 'a', 'b', 'c', 'd' ];
  //     array.push( 'e' );
  //
  // ...you'd get `[ 0, 1, 2, 3 ]` - in other words, none of the old indices
  // have changed. If you then did this...
  //
  //     array.unshift( 'z' );
  //
  // ...the indices would be `[ 1, 2, 3, 4, 5 ]` - every item has been moved
  // one higher to make room for the 'z'. If you removed an item, the new index
  // would be -1...
  //
  //     array.splice( 2, 2 );
  //
  // ...this would result in [ 0, 1, -1, -1, 2, 3 ].
  //
  // This information is used to enable fast, non-destructive shuffling of list
  // sections when you do e.g. `ractive.splice( 'items', 2, 2 );

  function getNewIndices ( length, methodName, args ) {
  	var spliceArguments, newIndices = [], removeStart, removeEnd, balance, i;

  	spliceArguments = getSpliceEquivalent( length, methodName, args );

  	if ( !spliceArguments ) {
  		return null; // TODO support reverse and sort?
  	}

  	balance = ( spliceArguments.length - 2 ) - spliceArguments[1];

  	removeStart = Math.min( length, spliceArguments[0] );
  	removeEnd = removeStart + spliceArguments[1];

  	for ( i = 0; i < removeStart; i += 1 ) {
  		newIndices.push( i );
  	}

  	for ( ; i < removeEnd; i += 1 ) {
  		newIndices.push( -1 );
  	}

  	for ( ; i < length; i += 1 ) {
  		newIndices.push( i + balance );
  	}

  	// there is a net shift for the rest of the array starting with index + balance
  	if ( balance !== 0 ) {
  		newIndices.touchedFrom = spliceArguments[0];
  	} else {
  		newIndices.touchedFrom = length;
  	}

  	return newIndices;
  }


  // The pop, push, shift an unshift methods can all be represented
  // as an equivalent splice
  function getSpliceEquivalent ( length, methodName, args ) {
  	switch ( methodName ) {
  		case 'splice':
  			if ( args[0] !== undefined && args[0] < 0 ) {
  				args[0] = length + Math.max( args[0], -length );
  			}

  			while ( args.length < 2 ) {
  				args.push( length - args[0] );
  			}

  			if ( typeof args[1] !== 'number' ) {
  				args[1] = length - args[0];
  			}

  			// ensure we only remove elements that exist
  			args[1] = Math.min( args[1], length - args[0] );

  			return args;

  		case 'sort':
  		case 'reverse':
  			return null;

  		case 'pop':
  			if ( length ) {
  				return [ length - 1, 1 ];
  			}
  			return [ 0, 0 ];

  		case 'push':
  			return [ length, 0 ].concat( args );

  		case 'shift':
  			return [ 0, length ? 1 : 0 ];

  		case 'unshift':
  			return [ 0, 0 ].concat( args );
  	}
  }

  var arrayProto = Array.prototype;

  function makeArrayMethod ( methodName ) {
  	return function ( keypath ) {
  		var args = [], len = arguments.length - 1;
  		while ( len-- > 0 ) args[ len ] = arguments[ len + 1 ];

  		var model = this.viewmodel.joinAll( splitKeypathI( keypath ) );
  		var array = model.get();

  		if ( !isArray( array ) ) {
  			if ( array === undefined ) {
  				array = [];
  				var result$1 = arrayProto[ methodName ].apply( array, args );
  				return this.set( keypath, array ).then( function () { return result$1; } );
  			} else {
  				throw new Error( ("shuffle array method " + methodName + " called on non-array at " + (model.getKeypath())) );
  			}
  		}

  		var newIndices = getNewIndices( array.length, methodName, args );
  		var result = arrayProto[ methodName ].apply( array, args );

  		var promise = runloop.start( this, true ).then( function () { return result; } );
  		promise.result = result;

  		if ( newIndices ) {
  			model.shuffle( newIndices );
  		} else {
  			model.set( result );
  		}

  		runloop.end();

  		return promise;
  	};
  }

  var pop$1 = makeArrayMethod( 'pop' );

  var push$1 = makeArrayMethod( 'push' );

  var PREFIX = '/* Ractive.js component styles */';

  // Holds current definitions of styles.
  var styleDefinitions = [];

  // Flag to tell if we need to update the CSS
  var isDirty = false;

  // These only make sense on the browser. See additional setup below.
  var styleElement = null;
  var useCssText = null;

  function addCSS( styleDefinition ) {
  	styleDefinitions.push( styleDefinition );
  	isDirty = true;
  }

  function applyCSS() {

  	// Apply only seems to make sense when we're in the DOM. Server-side renders
  	// can call toCSS to get the updated CSS.
  	if ( !doc || !isDirty ) return;

  	if ( useCssText ) {
  		styleElement.styleSheet.cssText = getCSS( null );
  	} else {
  		styleElement.innerHTML = getCSS( null );
  	}

  	isDirty = false;
  }

  function getCSS( cssIds ) {

  	var filteredStyleDefinitions = cssIds ? styleDefinitions.filter( function ( style ) { return ~cssIds.indexOf( style.id ); } ) : styleDefinitions;

  	return filteredStyleDefinitions.reduce( function ( styles, style ) { return ("" + styles + "\n\n/* {" + (style.id) + "} */\n" + (style.styles)); }, PREFIX );

  }

  // If we're on the browser, additional setup needed.
  if ( doc && ( !styleElement || !styleElement.parentNode ) ) {

  	styleElement = doc.createElement( 'style' );
  	styleElement.type = 'text/css';

  	doc.getElementsByTagName( 'head' )[ 0 ].appendChild( styleElement );

  	useCssText = !!styleElement.styleSheet;
  }

  var renderHook = new Hook( 'render' );
  var completeHook = new Hook( 'complete' );

  function render$1 ( ractive, target, anchor, occupants ) {
  	// if `noIntro` is `true`, temporarily disable transitions
  	var transitionsEnabled = ractive.transitionsEnabled;
  	if ( ractive.noIntro ) ractive.transitionsEnabled = false;

  	var promise = runloop.start( ractive, true );
  	runloop.scheduleTask( function () { return renderHook.fire( ractive ); }, true );

  	if ( ractive.fragment.rendered ) {
  		throw new Error( 'You cannot call ractive.render() on an already rendered instance! Call ractive.unrender() first' );
  	}

  	anchor = getElement( anchor ) || ractive.anchor;

  	ractive.el = target;
  	ractive.anchor = anchor;

  	// ensure encapsulated CSS is up-to-date
  	if ( ractive.cssId ) applyCSS();

  	if ( target ) {
  		( target.__ractive_instances__ || ( target.__ractive_instances__ = [] ) ).push( ractive );

  		if ( anchor ) {
  			var docFrag = doc.createDocumentFragment();
  			ractive.fragment.render( docFrag );
  			target.insertBefore( docFrag, anchor );
  		} else {
  			ractive.fragment.render( target, occupants );
  		}
  	}

  	runloop.end();
  	ractive.transitionsEnabled = transitionsEnabled;

  	return promise.then( function () { return completeHook.fire( ractive ); } );
  }

  function Ractive$render ( target, anchor ) {
  	target = getElement( target ) || this.el;

  	if ( !this.append && target ) {
  		// Teardown any existing instances *before* trying to set up the new one -
  		// avoids certain weird bugs
  		var others = target.__ractive_instances__;
  		if ( others ) others.forEach( teardown );

  		// make sure we are the only occupants
  		if ( !this.enhance ) {
  			target.innerHTML = ''; // TODO is this quicker than removeChild? Initial research inconclusive
  		}
  	}

  	var occupants = this.enhance ? toArray( target.childNodes ) : null;
  	var promise = render$1( this, target, anchor, occupants );

  	if ( occupants ) {
  		while ( occupants.length ) target.removeChild( occupants.pop() );
  	}

  	return promise;
  }

  var adaptConfigurator = {
  	extend: function ( Parent, proto, options ) {
  		proto.adapt = combine( proto.adapt, ensureArray( options.adapt ) );
  	},

  	init: function () {}
  };

  function combine ( a, b ) {
  	var c = a.slice();
  	var i = b.length;

  	while ( i-- ) {
  		if ( !~c.indexOf( b[i] ) ) {
  			c.push( b[i] );
  		}
  	}

  	return c;
  }

  var selectorsPattern = /(?:^|\})?\s*([^\{\}]+)\s*\{/g;
  var commentsPattern = /\/\*.*?\*\//g;
  var selectorUnitPattern = /((?:(?:\[[^\]+]\])|(?:[^\s\+\>~:]))+)((?:::?[^\s\+\>\~\(:]+(?:\([^\)]+\))?)*\s*[\s\+\>\~]?)\s*/g;
  var excludePattern = /^(?:@|\d+%)/;
  var dataRvcGuidPattern = /\[data-ractive-css~="\{[a-z0-9-]+\}"]/g;

  function trim$1 ( str ) {
  	return str.trim();
  }

  function extractString ( unit ) {
  	return unit.str;
  }

  function transformSelector ( selector, parent ) {
  	var selectorUnits = [];
  	var match;

  	while ( match = selectorUnitPattern.exec( selector ) ) {
  		selectorUnits.push({
  			str: match[0],
  			base: match[1],
  			modifiers: match[2]
  		});
  	}

  	// For each simple selector within the selector, we need to create a version
  	// that a) combines with the id, and b) is inside the id
  	var base = selectorUnits.map( extractString );

  	var transformed = [];
  	var i = selectorUnits.length;

  	while ( i-- ) {
  		var appended = base.slice();

  		// Pseudo-selectors should go after the attribute selector
  		var unit = selectorUnits[i];
  		appended[i] = unit.base + parent + unit.modifiers || '';

  		var prepended = base.slice();
  		prepended[i] = parent + ' ' + prepended[i];

  		transformed.push( appended.join( ' ' ), prepended.join( ' ' ) );
  	}

  	return transformed.join( ', ' );
  }

  function transformCss ( css, id ) {
  	var dataAttr = "[data-ractive-css~=\"{" + id + "}\"]";

  	var transformed;

  	if ( dataRvcGuidPattern.test( css ) ) {
  		transformed = css.replace( dataRvcGuidPattern, dataAttr );
  	} else {
  		transformed = css
  		.replace( commentsPattern, '' )
  		.replace( selectorsPattern, function ( match, $1 ) {
  			// don't transform at-rules and keyframe declarations
  			if ( excludePattern.test( $1 ) ) return match;

  			var selectors = $1.split( ',' ).map( trim$1 );
  			var transformed = selectors
  				.map( function ( selector ) { return transformSelector( selector, dataAttr ); } )
  				.join( ', ' ) + ' ';

  			return match.replace( $1, transformed );
  		});
  	}

  	return transformed;
  }

  function s4() {
  	return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
  }

  function uuid() {
  	return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
  }

  var cssConfigurator = {
  	name: 'css',

  	// Called when creating a new component definition
  	extend: function ( Parent, proto, options ) {
  		if ( !options.css ) return;

  		var id = uuid();
  		var styles = options.noCssTransform ? options.css : transformCss( options.css, id );

  		proto.cssId = id;

  		addCSS( { id: id, styles: styles } );

  	},

  	// Called when creating a new component instance
  	init: function ( Parent, target, options ) {
  		if ( !options.css ) return;

  		warnIfDebug( ("\nThe css option is currently not supported on a per-instance basis and will be discarded. Instead, we recommend instantiating from a component definition with a css option.\n\nconst Component = Ractive.extend({\n\t...\n\tcss: '/* your css */',\n\t...\n});\n\nconst componentInstance = new Component({ ... })\n\t\t") );
  	}

  };

  function bind$1 ( fn, context ) {
  	if ( !/this/.test( fn.toString() ) ) return fn;

  	var bound = fn.bind( context );
  	for ( var prop in fn ) bound[ prop ] = fn[ prop ];

  	return bound;
  }

  function validate ( data ) {
  	// Warn if userOptions.data is a non-POJO
  	if ( data && data.constructor !== Object ) {
  		if ( typeof data === 'function' ) {
  			// TODO do we need to support this in the new Ractive() case?
  		} else if ( typeof data !== 'object' ) {
  			fatal( ("data option must be an object or a function, `" + data + "` is not valid") );
  		} else {
  			warnIfDebug( 'If supplied, options.data should be a plain JavaScript object - using a non-POJO as the root object may work, but is discouraged' );
  		}
  	}
  }

  var dataConfigurator = {
  	name: 'data',

  	extend: function ( Parent, proto, options ) {
  		var key;
  		var value;

  		// check for non-primitives, which could cause mutation-related bugs
  		if ( options.data && isObject( options.data ) ) {
  			for ( key in options.data ) {
  				value = options.data[ key ];

  				if ( value && typeof value === 'object' ) {
  					if ( isObject( value ) || isArray( value ) ) {
  						warnIfDebug( ("Passing a `data` option with object and array properties to Ractive.extend() is discouraged, as mutating them is likely to cause bugs. Consider using a data function instead:\n\n  // this...\n  data: function () {\n    return {\n      myObject: {}\n    };\n  })\n\n  // instead of this:\n  data: {\n    myObject: {}\n  }") );
  					}
  				}
  			}
  		}

  		proto.data = combine$1( proto.data, options.data );
  	},

  	init: function ( Parent, ractive, options ) {
  		var result = combine$1( Parent.prototype.data, options.data );

  		if ( typeof result === 'function' ) result = result.call( ractive );

  		// bind functions to the ractive instance at the top level,
  		// unless it's a non-POJO (in which case alarm bells should ring)
  		if ( result && result.constructor === Object ) {
  			for ( var prop in result ) {
  				if ( typeof result[ prop ] === 'function' ) result[ prop ] = bind$1( result[ prop ], ractive );
  			}
  		}

  		return result || {};
  	},

  	reset: function ( ractive ) {
  		var result = this.init( ractive.constructor, ractive, ractive.viewmodel );
  		ractive.viewmodel.root.set( result );
  		return true;
  	}
  };

  function combine$1 ( parentValue, childValue ) {
  	validate( childValue );

  	var parentIsFn = typeof parentValue === 'function';
  	var childIsFn = typeof childValue === 'function';

  	// Very important, otherwise child instance can become
  	// the default data object on Ractive or a component.
  	// then ractive.set() ends up setting on the prototype!
  	if ( !childValue && !parentIsFn ) {
  		childValue = {};
  	}

  	// Fast path, where we just need to copy properties from
  	// parent to child
  	if ( !parentIsFn && !childIsFn ) {
  		return fromProperties( childValue, parentValue );
  	}

  	return function () {
  		var child = childIsFn ? callDataFunction( childValue, this ) : childValue;
  		var parent = parentIsFn ? callDataFunction( parentValue, this ) : parentValue;

  		return fromProperties( child, parent );
  	};
  }

  function callDataFunction ( fn, context ) {
  	var data = fn.call( context );

  	if ( !data ) return;

  	if ( typeof data !== 'object' ) {
  		fatal( 'Data function must return an object' );
  	}

  	if ( data.constructor !== Object ) {
  		warnOnceIfDebug( 'Data function returned something other than a plain JavaScript object. This might work, but is strongly discouraged' );
  	}

  	return data;
  }

  function fromProperties ( primary, secondary ) {
  	if ( primary && secondary ) {
  		for ( var key in secondary ) {
  			if ( !( key in primary ) ) {
  				primary[ key ] = secondary[ key ];
  			}
  		}

  		return primary;
  	}

  	return primary || secondary;
  }

  var TEMPLATE_VERSION = 3;

  var pattern = /\$\{([^\}]+)\}/g;

  function fromExpression ( body, length ) {
  	if ( length === void 0 ) length = 0;

  	var args = new Array( length );

  	while ( length-- ) {
  		args[length] = "_" + length;
  	}

  	// Functions created directly with new Function() look like this:
  	//     function anonymous (_0 /**/) { return _0*2 }
  	//
  	// With this workaround, we get a little more compact:
  	//     function (_0){return _0*2}
  	return new Function( [], ("return function (" + (args.join(',')) + "){return(" + body + ");};") )();
  }

  function fromComputationString ( str, bindTo ) {
  	var hasThis;

  	var functionBody = 'return (' + str.replace( pattern, function ( match, keypath ) {
  		hasThis = true;
  		return ("__ractive.get(\"" + keypath + "\")");
  	}) + ');';

  	if ( hasThis ) functionBody = "var __ractive = this; " + functionBody;
  	var fn = new Function( functionBody );
  	return hasThis ? fn.bind( bindTo ) : fn;
  }

  var functions = create( null );

  function getFunction ( str, i ) {
  	if ( functions[ str ] ) return functions[ str ];
  	return functions[ str ] = createFunction( str, i );
  }

  function addFunctions( template ) {
  	if ( !template ) return;

  	var exp = template.e;

  	if ( !exp ) return;

  	Object.keys( exp ).forEach( function ( str ) {
  		if ( functions[ str ] ) return;
  		functions[ str ] = exp[ str ];
  	});
  }

  var parse = null;

  var parseOptions = [
  	'delimiters',
  	'tripleDelimiters',
  	'staticDelimiters',
  	'staticTripleDelimiters',
  	'csp',
  	'interpolate',
  	'preserveWhitespace',
  	'sanitize',
  	'stripComments'
  ];

  var TEMPLATE_INSTRUCTIONS = "Either preparse or use a ractive runtime source that includes the parser. ";

  var COMPUTATION_INSTRUCTIONS = "Either use:\n\n\tRactive.parse.computedStrings( component.computed )\n\nat build time to pre-convert the strings to functions, or use functions instead of strings in computed properties.";


  function throwNoParse ( method, error, instructions ) {
  	if ( !method ) {
  		fatal( ("Missing Ractive.parse - cannot parse " + error + ". " + instructions) );
  	}
  }

  function createFunction ( body, length ) {
  	throwNoParse( fromExpression, 'new expression function', TEMPLATE_INSTRUCTIONS );
  	return fromExpression( body, length );
  }

  function createFunctionFromString ( str, bindTo ) {
  	throwNoParse( fromComputationString, 'compution string "${str}"', COMPUTATION_INSTRUCTIONS );
  	return fromComputationString( str, bindTo );
  }

  var parser = {

  	fromId: function ( id, options ) {
  		if ( !doc ) {
  			if ( options && options.noThrow ) { return; }
  			throw new Error( ("Cannot retrieve template #" + id + " as Ractive is not running in a browser.") );
  		}

  		if ( id ) id = id.replace( /^#/, '' );

  		var template;

  		if ( !( template = doc.getElementById( id ) )) {
  			if ( options && options.noThrow ) { return; }
  			throw new Error( ("Could not find template element with id #" + id) );
  		}

  		if ( template.tagName.toUpperCase() !== 'SCRIPT' ) {
  			if ( options && options.noThrow ) { return; }
  			throw new Error( ("Template element with id #" + id + ", must be a <script> element") );
  		}

  		return ( 'textContent' in template ? template.textContent : template.innerHTML );

  	},

  	isParsed: function ( template) {
  		return !( typeof template === 'string' );
  	},

  	getParseOptions: function ( ractive ) {
  		// Could be Ractive or a Component
  		if ( ractive.defaults ) { ractive = ractive.defaults; }

  		return parseOptions.reduce( function ( val, key ) {
  			val[ key ] = ractive[ key ];
  			return val;
  		}, {});
  	},

  	parse: function ( template, options ) {
  		throwNoParse( parse, 'template', TEMPLATE_INSTRUCTIONS );
  		var parsed = parse( template, options );
  		addFunctions( parsed );
  		return parsed;
  	},

  	parseFor: function( template, ractive ) {
  		return this.parse( template, this.getParseOptions( ractive ) );
  	}
  };

  var templateConfigurator = {
  	name: 'template',

  	extend: function ( Parent, proto, options ) {
  		// only assign if exists
  		if ( 'template' in options ) {
  			var template = options.template;

  			if ( typeof template === 'function' ) {
  				proto.template = template;
  			} else {
  				proto.template = parseTemplate( template, proto );
  			}
  		}
  	},

  	init: function ( Parent, ractive, options ) {
  		// TODO because of prototypal inheritance, we might just be able to use
  		// ractive.template, and not bother passing through the Parent object.
  		// At present that breaks the test mocks' expectations
  		var template = 'template' in options ? options.template : Parent.prototype.template;
  		template = template || { v: TEMPLATE_VERSION, t: [] };

  		if ( typeof template === 'function' ) {
  			var fn = template;
  			template = getDynamicTemplate( ractive, fn );

  			ractive._config.template = {
  				fn: fn,
  				result: template
  			};
  		}

  		template = parseTemplate( template, ractive );

  		// TODO the naming of this is confusing - ractive.template refers to [...],
  		// but Component.prototype.template refers to {v:1,t:[],p:[]}...
  		// it's unnecessary, because the developer never needs to access
  		// ractive.template
  		ractive.template = template.t;

  		if ( template.p ) {
  			extendPartials( ractive.partials, template.p );
  		}
  	},

  	reset: function ( ractive ) {
  		var result = resetValue( ractive );

  		if ( result ) {
  			var parsed = parseTemplate( result, ractive );

  			ractive.template = parsed.t;
  			extendPartials( ractive.partials, parsed.p, true );

  			return true;
  		}
  	}
  };

  function resetValue ( ractive ) {
  	var initial = ractive._config.template;

  	// If this isn't a dynamic template, there's nothing to do
  	if ( !initial || !initial.fn ) {
  		return;
  	}

  	var result = getDynamicTemplate( ractive, initial.fn );

  	// TODO deep equality check to prevent unnecessary re-rendering
  	// in the case of already-parsed templates
  	if ( result !== initial.result ) {
  		initial.result = result;
  		return result;
  	}
  }

  function getDynamicTemplate ( ractive, fn ) {
  	return fn.call( ractive, {
  		fromId: parser.fromId,
  		isParsed: parser.isParsed,
  		parse: function ( template, options ) {
  			if ( options === void 0 ) options = parser.getParseOptions( ractive );

  			return parser.parse( template, options );
  		}
  	});
  }

  function parseTemplate ( template, ractive ) {
  	if ( typeof template === 'string' ) {
  		// parse will validate and add expression functions
  		template = parseAsString( template, ractive );
  	}
  	else {
  		// need to validate and add exp for already parsed template
  		validate$1( template );
  		addFunctions( template );
  	}

  	return template;
  }

  function parseAsString ( template, ractive ) {
  	// ID of an element containing the template?
  	if ( template[0] === '#' ) {
  		template = parser.fromId( template );
  	}

  	return parser.parseFor( template, ractive );
  }

  function validate$1( template ) {

  	// Check that the template even exists
  	if ( template == undefined ) {
  		throw new Error( ("The template cannot be " + template + ".") );
  	}

  	// Check the parsed template has a version at all
  	else if ( typeof template.v !== 'number' ) {
  		throw new Error( 'The template parser was passed a non-string template, but the template doesn\'t have a version.  Make sure you\'re passing in the template you think you are.' );
  	}

  	// Check we're using the correct version
  	else if ( template.v !== TEMPLATE_VERSION ) {
  		throw new Error( ("Mismatched template version (expected " + TEMPLATE_VERSION + ", got " + (template.v) + ") Please ensure you are using the latest version of Ractive.js in your build process as well as in your app") );
  	}
  }

  function extendPartials ( existingPartials, newPartials, overwrite ) {
  	if ( !newPartials ) return;

  	// TODO there's an ambiguity here - we need to overwrite in the `reset()`
  	// case, but not initially...

  	for ( var key in newPartials ) {
  		if ( overwrite || !existingPartials.hasOwnProperty( key ) ) {
  			existingPartials[ key ] = newPartials[ key ];
  		}
  	}
  }

  var registryNames = [
  	'adaptors',
  	'components',
  	'computed',
  	'decorators',
  	'easing',
  	'events',
  	'interpolators',
  	'partials',
  	'transitions'
  ];

  var Registry = function Registry ( name, useDefaults ) {
  	this.name = name;
  	this.useDefaults = useDefaults;
  };

  Registry.prototype.extend = function extend ( Parent, proto, options ) {
  	this.configure(
  		this.useDefaults ? Parent.defaults : Parent,
  		this.useDefaults ? proto : proto.constructor,
  		options );
  };

  Registry.prototype.init = function init () {
  	// noop
  };

  Registry.prototype.configure = function configure ( Parent, target, options ) {
  	var name = this.name;
  	var option = options[ name ];

  	var registry = create( Parent[name] );

  	for ( var key in option ) {
  		registry[ key ] = option[ key ];
  	}

  	target[ name ] = registry;
  };

  Registry.prototype.reset = function reset ( ractive ) {
  	var registry = ractive[ this.name ];
  	var changed = false;

  	Object.keys( registry ).forEach( function ( key ) {
  		var item = registry[ key ];
  			
  		if ( item._fn ) {
  			if ( item._fn.isOwner ) {
  				registry[key] = item._fn;
  			} else {
  				delete registry[key];
  			}
  			changed = true;
  		}
  	});

  	return changed;
  };

  var registries = registryNames.map( function ( name ) { return new Registry( name, name === 'computed' ); } );

  function wrap ( parent, name, method ) {
  	if ( !/_super/.test( method ) ) return method;

  	function wrapper () {
  		var superMethod = getSuperMethod( wrapper._parent, name );
  		var hasSuper = '_super' in this;
  		var oldSuper = this._super;

  		this._super = superMethod;

  		var result = method.apply( this, arguments );

  		if ( hasSuper ) {
  			this._super = oldSuper;
  		} else {
  			delete this._super;
  		}

  		return result;
  	}

  	wrapper._parent = parent;
  	wrapper._method = method;

  	return wrapper;
  }

  function getSuperMethod ( parent, name ) {
  	if ( name in parent ) {
  		var value = parent[ name ];

  		return typeof value === 'function' ?
  			value :
  			function () { return value; };
  	}

  	return noop;
  }

  function getMessage( deprecated, correct, isError ) {
  	return "options." + deprecated + " has been deprecated in favour of options." + correct + "."
  		+ ( isError ? (" You cannot specify both options, please use options." + correct + ".") : '' );
  }

  function deprecateOption ( options, deprecatedOption, correct ) {
  	if ( deprecatedOption in options ) {
  		if( !( correct in options ) ) {
  			warnIfDebug( getMessage( deprecatedOption, correct ) );
  			options[ correct ] = options[ deprecatedOption ];
  		} else {
  			throw new Error( getMessage( deprecatedOption, correct, true ) );
  		}
  	}
  }

  function deprecate ( options ) {
  	deprecateOption( options, 'beforeInit', 'onconstruct' );
  	deprecateOption( options, 'init', 'onrender' );
  	deprecateOption( options, 'complete', 'oncomplete' );
  	deprecateOption( options, 'eventDefinitions', 'events' );

  	// Using extend with Component instead of options,
  	// like Human.extend( Spider ) means adaptors as a registry
  	// gets copied to options. So we have to check if actually an array
  	if ( isArray( options.adaptors ) ) {
  		deprecateOption( options, 'adaptors', 'adapt' );
  	}
  }

  var custom = {
  	adapt: adaptConfigurator,
  	css: cssConfigurator,
  	data: dataConfigurator,
  	template: templateConfigurator
  };

  var defaultKeys = Object.keys( defaults );

  var isStandardKey = makeObj( defaultKeys.filter( function ( key ) { return !custom[ key ]; } ) );

  // blacklisted keys that we don't double extend
  var isBlacklisted = makeObj( defaultKeys.concat( registries.map( function ( r ) { return r.name; } ) ) );

  var order = [].concat(
  	defaultKeys.filter( function ( key ) { return !registries[ key ] && !custom[ key ]; } ),
  	registries,
  	//custom.data,
  	custom.template,
  	custom.css
  );

  var config = {
  	extend: function ( Parent, proto, options ) { return configure( 'extend', Parent, proto, options ); },

  	init: function ( Parent, ractive, options ) { return configure( 'init', Parent, ractive, options ); },

  	reset: function ( ractive ) {
  		return order.filter( function ( c ) {
  			return c.reset && c.reset( ractive );
  		}).map( function ( c ) { return c.name; } );
  	},

  	// this defines the order. TODO this isn't used anywhere in the codebase,
  	// only in the test suite - should get rid of it
  	order: order
  };

  function configure ( method, Parent, target, options ) {
  	deprecate( options );

  	for ( var key in options ) {
  		if ( isStandardKey.hasOwnProperty( key ) ) {
  			var value = options[ key ];

  			// warn the developer if they passed a function and ignore its value

  			// NOTE: we allow some functions on "el" because we duck type element lists
  			// and some libraries or ef'ed-up virtual browsers (phantomJS) return a
  			// function object as the result of querySelector methods
  			if ( key !== 'el' && typeof value === 'function' ) {
  				warnIfDebug( ("" + key + " is a Ractive option that does not expect a function and will be ignored"),
  					method === 'init' ? target : null );
  			}
  			else {
  				target[ key ] = value;
  			}
  		}
  	}

  	// disallow combination of `append` and `enhance`
  	if ( options.append && options.enhance ) {
  		throw new Error( 'Cannot use append and enhance at the same time' );
  	}

  	registries.forEach( function ( registry ) {
  		registry[ method ]( Parent, target, options );
  	});

  	adaptConfigurator[ method ]( Parent, target, options );
  	templateConfigurator[ method ]( Parent, target, options );
  	cssConfigurator[ method ]( Parent, target, options );

  	extendOtherMethods( Parent.prototype, target, options );
  }

  function extendOtherMethods ( parent, target, options ) {
  	for ( var key in options ) {
  		if ( !isBlacklisted[ key ] && options.hasOwnProperty( key ) ) {
  			var member = options[ key ];

  			// if this is a method that overwrites a method, wrap it:
  			if ( typeof member === 'function' ) {
  				member = wrap( parent, key, member );
  			}

  			target[ key ] = member;
  		}
  	}
  }

  function makeObj ( array ) {
  	var obj = {};
  	array.forEach( function ( x ) { return obj[x] = true; } );
  	return obj;
  }

  var shouldRerender = [ 'template', 'partials', 'components', 'decorators', 'events' ];

  var completeHook$1 = new Hook( 'complete' );
  var resetHook = new Hook( 'reset' );
  var renderHook$1 = new Hook( 'render' );
  var unrenderHook = new Hook( 'unrender' );

  function Ractive$reset ( data ) {
  	data = data || {};

  	if ( typeof data !== 'object' ) {
  		throw new Error( 'The reset method takes either no arguments, or an object containing new data' );
  	}

  	// TEMP need to tidy this up
  	data = dataConfigurator.init( this.constructor, this, { data: data });

  	var promise = runloop.start( this, true );

  	// If the root object is wrapped, try and use the wrapper's reset value
  	var wrapper = this.viewmodel.wrapper;
  	if ( wrapper && wrapper.reset ) {
  		if ( wrapper.reset( data ) === false ) {
  			// reset was rejected, we need to replace the object
  			this.viewmodel.set( data );
  		}
  	} else {
  		this.viewmodel.set( data );
  	}

  	// reset config items and track if need to rerender
  	var changes = config.reset( this );
  	var rerender;

  	var i = changes.length;
  	while ( i-- ) {
  		if ( shouldRerender.indexOf( changes[i] ) > -1 ) {
  			rerender = true;
  			break;
  		}
  	}

  	if ( rerender ) {
  		unrenderHook.fire( this );
  		this.fragment.resetTemplate( this.template );
  		renderHook$1.fire( this );
  		completeHook$1.fire( this );
  	}

  	runloop.end();

  	resetHook.fire( this, data );

  	return promise;
  }

  var TEXT              = 1;
  var INTERPOLATOR      = 2;
  var TRIPLE            = 3;
  var SECTION           = 4;
  var ELEMENT           = 7;
  var PARTIAL           = 8;
  var COMPONENT         = 15;
  var YIELDER           = 16;
  var DOCTYPE           = 18;
  var ALIAS             = 19;

  var NUMBER_LITERAL    = 20;
  var STRING_LITERAL    = 21;
  var REFERENCE         = 30;
  var SECTION_IF        = 50;
  var SECTION_UNLESS    = 51;
  var SECTION_EACH      = 52;
  var SECTION_WITH      = 53;
  var SECTION_IF_WITH   = 54;

  function collect( source, name, dest ) {
  	source.forEach( function ( item ) {
  		// queue to rerender if the item is a partial and the current name matches
  		if ( item.type === PARTIAL && ( item.refName ===  name || item.name === name ) ) {
  			dest.push( item );
  			return; // go no further
  		}

  		// if it has a fragment, process its items
  		if ( item.fragment ) {
  			collect( item.fragment.iterations || item.fragment.items, name, dest );
  		}

  		// or if it is itself a fragment, process its items
  		else if ( isArray( item.items ) ) {
  			collect( item.items, name, dest );
  		}

  		// or if it is a component, step in and process its items
  		else if ( item.type === COMPONENT && item.instance ) {
  			// ...unless the partial is shadowed
  			if ( item.instance.partials[ name ] ) return;
  			collect( item.instance.fragment.items, name, dest );
  		}

  		// if the item is an element, process its attributes too
  		if ( item.type === ELEMENT ) {
  			if ( isArray( item.attributes ) ) {
  				collect( item.attributes, name, dest );
  			}

  			if ( isArray( item.conditionalAttributes ) ) {
  				collect( item.conditionalAttributes, name, dest );
  			}
  		}
  	});
  }

  function forceResetTemplate ( partial ) {
  	partial.forceResetTemplate();
  }

  function resetPartial ( name, partial ) {
  	var collection = [];
  	collect( this.fragment.items, name, collection );

  	var promise = runloop.start( this, true );

  	this.partials[ name ] = partial;
  	collection.forEach( forceResetTemplate );

  	runloop.end();

  	return promise;
  }

  var Item = function Item ( options ) {
  	this.parentFragment = options.parentFragment;
  	this.ractive = options.parentFragment.ractive;

  	this.template = options.template;
  	this.index = options.index;
  	this.type = options.template.t;

  	this.dirty = false;
  };

  Item.prototype.bubble = function bubble () {
  	if ( !this.dirty ) {
  		this.dirty = true;
  		this.parentFragment.bubble();
  	}
  };

  Item.prototype.find = function find () {
  	return null;
  };

  Item.prototype.findAll = function findAll () {
  	// noop
  };

  Item.prototype.findComponent = function findComponent () {
  	return null;
  };

  Item.prototype.findAllComponents = function findAllComponents () {
  	// noop;
  };

  Item.prototype.findNextNode = function findNextNode () {
  	return this.parentFragment.findNextNode( this );
  };

  Item.prototype.valueOf = function valueOf () {
  	return this.toString();
  };

  var ComputationChild = (function (Model) {
  	function ComputationChild () {
  		Model.apply(this, arguments);
  	}

  	ComputationChild.prototype = Object.create( Model && Model.prototype );
  	ComputationChild.prototype.constructor = ComputationChild;

  	ComputationChild.prototype.get = function get ( shouldCapture ) {
  		if ( shouldCapture ) capture( this );

  		var parentValue = this.parent.get();
  		return parentValue ? parentValue[ this.key ] : undefined;
  	};

  	ComputationChild.prototype.handleChange = function handleChange$1 () {
  		this.dirty = true;

  		this.deps.forEach( handleChange );
  		this.children.forEach( handleChange );
  		this.clearUnresolveds(); // TODO is this necessary?
  	};

  	ComputationChild.prototype.joinKey = function joinKey ( key ) {
  		if ( key === undefined || key === '' ) return this;

  		if ( !this.childByKey.hasOwnProperty( key ) ) {
  			var child = new ComputationChild( this, key );
  			this.children.push( child );
  			this.childByKey[ key ] = child;
  		}

  		return this.childByKey[ key ];
  	};

  	return ComputationChild;
  }(Model));

  function getValue ( model ) {
  	return model ? model.get( true, true ) : undefined;
  }

  var ExpressionProxy = (function (Model) {
  	function ExpressionProxy ( fragment, template ) {
  		var this$1 = this;

  		Model.call( this, fragment.ractive.viewmodel, null );

  		this.fragment = fragment;
  		this.template = template;

  		this.isReadonly = true;

  		this.fn = getFunction( template.s, template.r.length );
  		this.computation = null;

  		this.resolvers = [];
  		this.models = this.template.r.map( function ( ref, index ) {
  			var model = resolveReference( this$1.fragment, ref );
  			var resolver;

  			if ( !model ) {
  				resolver = this$1.fragment.resolve( ref, function ( model ) {
  					removeFromArray( this$1.resolvers, resolver );
  					this$1.models[ index ] = model;
  					this$1.bubble();
  				});

  				this$1.resolvers.push( resolver );
  			}

  			return model;
  		});

  		this.bubble();
  	}

  	ExpressionProxy.prototype = Object.create( Model && Model.prototype );
  	ExpressionProxy.prototype.constructor = ExpressionProxy;

  	ExpressionProxy.prototype.bubble = function bubble () {
  		var this$1 = this;

  		var ractive = this.fragment.ractive;

  		// TODO the @ prevents computed props from shadowing keypaths, but the real
  		// question is why it's a computed prop in the first place... (hint, it's
  		// to do with {{else}} blocks)
  		var key = '@' + this.template.s.replace( /_(\d+)/g, function ( match, i ) {
  			if ( i >= this$1.models.length ) return match;

  			var model = this$1.models[i];
  			return model ? model.getKeypath() : '@undefined';
  		});

  		// TODO can/should we reuse computations?
  		var signature = {
  			getter: function () {
  				var values = this$1.models.map( getValue );
  				return this$1.fn.apply( ractive, values );
  			},
  			getterString: key
  		};

  		var computation = ractive.viewmodel.compute( key, signature );

  		this.value = computation.get(); // TODO should not need this, eventually

  		if ( this.computation ) {
  			this.computation.unregister( this );
  			// notify children...
  		}

  		this.computation = computation;
  		computation.register( this );

  		this.handleChange();
  	};

  	ExpressionProxy.prototype.get = function get ( shouldCapture ) {
  		return this.computation.get( shouldCapture );
  	};

  	ExpressionProxy.prototype.getKeypath = function getKeypath () {
  		return this.computation ? this.computation.getKeypath() : '@undefined';
  	};

  	ExpressionProxy.prototype.handleChange = function handleChange$1 () {
  		this.deps.forEach( handleChange );
  		this.children.forEach( handleChange );

  		this.clearUnresolveds();
  	};

  	ExpressionProxy.prototype.joinKey = function joinKey ( key ) {
  		if ( key === undefined || key === '' ) return this;

  		if ( !this.childByKey.hasOwnProperty( key ) ) {
  			var child = new ComputationChild( this, key );
  			this.children.push( child );
  			this.childByKey[ key ] = child;
  		}

  		return this.childByKey[ key ];
  	};

  	ExpressionProxy.prototype.mark = function mark () {
  		this.handleChange();
  	};

  	ExpressionProxy.prototype.retrieve = function retrieve () {
  		return this.get();
  	};

  	ExpressionProxy.prototype.teardown = function teardown () {
  		this.unbind();
  		this.fragment = undefined;
  		if ( this.computation ) {
  			this.computation.teardown();
  		}
  		this.computation = undefined;
  		Model.prototype.teardown.call(this);
  	};

  	ExpressionProxy.prototype.unregister = function unregister( dep ) {
  		Model.prototype.unregister.call( this, dep );
  		if ( !this.deps.length ) this.teardown();
  	};

  	ExpressionProxy.prototype.unbind = function unbind$1 () {
  		var this$1 = this;

  		this.resolvers.forEach( unbind );

  		var i = this.models.length;
  		while ( i-- ) {
  			if ( this$1.models[i] ) this$1.models[i].unregister( this$1 );
  		}
  	};

  	return ExpressionProxy;
  }(Model));

  var ReferenceExpressionChild = (function (Model) {
  	function ReferenceExpressionChild ( parent, key ) {
  		Model.call ( this, parent, key );
  	}

  	ReferenceExpressionChild.prototype = Object.create( Model && Model.prototype );
  	ReferenceExpressionChild.prototype.constructor = ReferenceExpressionChild;

  	ReferenceExpressionChild.prototype.applyValue = function applyValue ( value ) {
  		if ( isEqual( value, this.value ) ) return;

  		var parent = this.parent, keys = [ this.key ];
  		while ( parent ) {
  			if ( parent.base ) {
  				var target = parent.model.joinAll( keys );
  				target.applyValue( value );
  				break;
  			}

  			keys.unshift( parent.key );

  			parent = parent.parent;
  		}
  	};

  	ReferenceExpressionChild.prototype.joinKey = function joinKey ( key ) {
  		if ( key === undefined || key === '' ) return this;

  		if ( !this.childByKey.hasOwnProperty( key ) ) {
  			var child = new ReferenceExpressionChild( this, key );
  			this.children.push( child );
  			this.childByKey[ key ] = child;
  		}

  		return this.childByKey[ key ];
  	};

  	return ReferenceExpressionChild;
  }(Model));

  var ReferenceExpressionProxy = (function (Model) {
  	function ReferenceExpressionProxy ( fragment, template ) {
  		var this$1 = this;

  		Model.call( this, null, null );
  		this.root = fragment.ractive.viewmodel;

  		this.resolvers = [];

  		this.base = resolve$2( fragment, template );
  		var baseResolver;

  		if ( !this.base ) {
  			baseResolver = fragment.resolve( template.r, function ( model ) {
  				this$1.base = model;
  				this$1.bubble();

  				removeFromArray( this$1.resolvers, baseResolver );
  			});

  			this.resolvers.push( baseResolver );
  		}

  		var intermediary = {
  			handleChange: function () { return this$1.bubble(); }
  		};

  		this.members = template.m.map( function ( template, i ) {
  			if ( typeof template === 'string' ) {
  				return { get: function () { return template; } };
  			}

  			var model;
  			var resolver;

  			if ( template.t === REFERENCE ) {
  				model = resolveReference( fragment, template.n );

  				if ( model ) {
  					model.register( intermediary );
  				} else {
  					resolver = fragment.resolve( template.n, function ( model ) {
  						this$1.members[i] = model;

  						model.register( intermediary );
  						this$1.bubble();

  						removeFromArray( this$1.resolvers, resolver );
  					});

  					this$1.resolvers.push( resolver );
  				}

  				return model;
  			}

  			model = new ExpressionProxy( fragment, template );
  			model.register( intermediary );
  			return model;
  		});

  		this.isUnresolved = true;
  		this.bubble();
  	}

  	ReferenceExpressionProxy.prototype = Object.create( Model && Model.prototype );
  	ReferenceExpressionProxy.prototype.constructor = ReferenceExpressionProxy;

  	ReferenceExpressionProxy.prototype.bubble = function bubble () {
  		var this$1 = this;

  		if ( !this.base ) return;

  		// if some members are not resolved, abort
  		var i = this.members.length;
  		while ( i-- ) {
  			if ( !this$1.members[i] ) return;
  		}

  		this.isUnresolved = false;

  		var keys = this.members.map( function ( model ) { return escapeKey( String( model.get() ) ); } );
  		var model = this.base.joinAll( keys );

  		if ( this.model ) {
  			this.model.unregister( this );
  			this.model.unregisterTwowayBinding( this );
  		}

  		this.model = model;
  		this.parent = model.parent;

  		model.register( this );
  		model.registerTwowayBinding( this );

  		if ( this.keypathModel ) this.keypathModel.handleChange();

  		this.mark();
  	};

  	ReferenceExpressionProxy.prototype.forceResolution = function forceResolution () {
  		this.resolvers.forEach( function ( resolver ) { return resolver.forceResolution(); } );
  		this.bubble();
  	};

  	ReferenceExpressionProxy.prototype.get = function get ( shouldCapture ) {
  		return this.model ? this.model.get( shouldCapture ) : undefined;
  	};

  	// indirect two-way bindings
  	ReferenceExpressionProxy.prototype.getValue = function getValue () {
  		var this$1 = this;

  		var i = this.bindings.length;
  		while ( i-- ) {
  			var value = this$1.bindings[i].getValue();
  			if ( value !== this$1.value ) return value;
  		}

  		return this.value;
  	};

  	ReferenceExpressionProxy.prototype.getKeypath = function getKeypath () {
  		return this.model ? this.model.getKeypath() : '@undefined';
  	};

  	ReferenceExpressionProxy.prototype.handleChange = function handleChange () {
  		this.mark();
  	};

  	ReferenceExpressionProxy.prototype.joinKey = function joinKey ( key ) {
  		if ( key === undefined || key === '' ) return this;

  		if ( !this.childByKey.hasOwnProperty( key ) ) {
  			var child = new ReferenceExpressionChild( this, key );
  			this.children.push( child );
  			this.childByKey[ key ] = child;
  		}

  		return this.childByKey[ key ];
  	};

  	ReferenceExpressionProxy.prototype.retrieve = function retrieve () {
  		return this.get();
  	};

  	ReferenceExpressionProxy.prototype.set = function set ( value ) {
  		if ( !this.model ) throw new Error( 'Unresolved reference expression. This should not happen!' );
  		this.model.set( value );
  	};

  	ReferenceExpressionProxy.prototype.unbind = function unbind$1 () {
  		this.resolvers.forEach( unbind );
  	};

  	return ReferenceExpressionProxy;
  }(Model));

  function resolve$2 ( fragment, template ) {
  	if ( template.r ) {
  		return resolveReference( fragment, template.r );
  	}

  	else if ( template.x ) {
  		return new ExpressionProxy( fragment, template.x );
  	}

  	else {
  		return new ReferenceExpressionProxy( fragment, template.rx );
  	}
  }

  function resolveAliases( section ) {
  	if ( section.template.z ) {
  		section.aliases = {};

  		var refs = section.template.z;
  		for ( var i = 0; i < refs.length; i++ ) {
  			section.aliases[ refs[i].n ] = resolve$2( section.parentFragment, refs[i].x );
  		}
  	}
  }

  var Alias = (function (Item) {
  	function Alias ( options ) {
  		Item.call( this, options );

  		this.fragment = null;
  	}

  	Alias.prototype = Object.create( Item && Item.prototype );
  	Alias.prototype.constructor = Alias;

  	Alias.prototype.bind = function bind () {
  		resolveAliases( this );

  		this.fragment = new Fragment({
  			owner: this,
  			template: this.template.f
  		}).bind();
  	};

  	Alias.prototype.detach = function detach () {
  		return this.fragment ? this.fragment.detach() : createDocumentFragment();
  	};

  	Alias.prototype.find = function find ( selector ) {
  		if ( this.fragment ) {
  			return this.fragment.find( selector );
  		}
  	};

  	Alias.prototype.findAll = function findAll ( selector, query ) {
  		if ( this.fragment ) {
  			this.fragment.findAll( selector, query );
  		}
  	};

  	Alias.prototype.findComponent = function findComponent ( name ) {
  		if ( this.fragment ) {
  			return this.fragment.findComponent( name );
  		}
  	};

  	Alias.prototype.findAllComponents = function findAllComponents ( name, query ) {
  		if ( this.fragment ) {
  			this.fragment.findAllComponents( name, query );
  		}
  	};

  	Alias.prototype.firstNode = function firstNode ( skipParent ) {
  		return this.fragment && this.fragment.firstNode( skipParent );
  	};

  	Alias.prototype.rebind = function rebind () {
  		resolveAliases( this );
  		if ( this.fragment ) this.fragment.rebind();
  	};

  	Alias.prototype.render = function render ( target ) {
  		this.rendered = true;
  		if ( this.fragment ) this.fragment.render( target );
  	};

  	Alias.prototype.toString = function toString ( escape ) {
  		return this.fragment ? this.fragment.toString( escape ) : '';
  	};

  	Alias.prototype.unbind = function unbind () {
  		this.aliases = {};
  		if ( this.fragment ) this.fragment.unbind();
  	};

  	Alias.prototype.unrender = function unrender ( shouldDestroy ) {
  		if ( this.rendered && this.fragment ) this.fragment.unrender( shouldDestroy );
  		this.rendered = false;
  	};

  	Alias.prototype.update = function update () {
  		if ( this.dirty ) {
  			this.dirty = false;
  			this.fragment.update();
  		}
  	};

  	return Alias;
  }(Item));

  function processWrapper ( wrapper, array, methodName, newIndices ) {
  	var __model = wrapper.__model;

  	if ( newIndices ) {
  		__model.shuffle( newIndices );
  	} else {
  		// If this is a sort or reverse, we just do root.set()...
  		// TODO use merge logic?
  		//root.viewmodel.mark( keypath );
  	}
  }

  var mutatorMethods = [ 'pop', 'push', 'reverse', 'shift', 'sort', 'splice', 'unshift' ];
  var patchedArrayProto = [];

  mutatorMethods.forEach( function ( methodName ) {
  	var method = function () {
  		var this$1 = this;
  		var args = [], len = arguments.length;
  		while ( len-- ) args[ len ] = arguments[ len ];

  		var newIndices = getNewIndices( this.length, methodName, args );

  		// apply the underlying method
  		var result = Array.prototype[ methodName ].apply( this, arguments );

  		// trigger changes
  		runloop.start();

  		this._ractive.setting = true;
  		var i = this._ractive.wrappers.length;
  		while ( i-- ) {
  			processWrapper( this$1._ractive.wrappers[i], this$1, methodName, newIndices );
  		}

  		runloop.end();

  		this._ractive.setting = false;
  		return result;
  	};

  	defineProperty( patchedArrayProto, methodName, {
  		value: method
  	});
  });

  var patchArrayMethods;
  var unpatchArrayMethods;

  // can we use prototype chain injection?
  // http://perfectionkills.com/how-ecmascript-5-still-does-not-allow-to-subclass-an-array/#wrappers_prototype_chain_injection
  if ( ({}).__proto__ ) {
  	// yes, we can
  	patchArrayMethods = function ( array ) { return array.__proto__ = patchedArrayProto; };
  	unpatchArrayMethods = function ( array ) { return array.__proto__ = Array.prototype; };
  }

  else {
  	// no, we can't
  	patchArrayMethods = function ( array ) {
  		var i = mutatorMethods.length;
  		while ( i-- ) {
  			var methodName = mutatorMethods[i];
  			defineProperty( array, methodName, {
  				value: patchedArrayProto[ methodName ],
  				configurable: true
  			});
  		}
  	};

  	unpatchArrayMethods = function ( array ) {
  		var i = mutatorMethods.length;
  		while ( i-- ) {
  			delete array[ mutatorMethods[i] ];
  		}
  	};
  }

  patchArrayMethods.unpatch = unpatchArrayMethods; // TODO export separately?
  var patch = patchArrayMethods;

  var errorMessage$1 = 'Something went wrong in a rather interesting way';

  var arrayAdaptor = {
  	filter: function ( object ) {
  		// wrap the array if a) b) it's an array, and b) either it hasn't been wrapped already,
  		// or the array didn't trigger the get() itself
  		return isArray( object ) && ( !object._ractive || !object._ractive.setting );
  	},
  	wrap: function ( ractive, array, keypath ) {
  		return new ArrayWrapper( ractive, array, keypath );
  	}
  };

  var ArrayWrapper = function ArrayWrapper ( ractive, array ) {
  	this.root = ractive;
  	this.value = array;
  	this.__model = null; // filled in later

  	// if this array hasn't already been ractified, ractify it
  	if ( !array._ractive ) {
  		// define a non-enumerable _ractive property to store the wrappers
  		defineProperty( array, '_ractive', {
  			value: {
  				wrappers: [],
  				instances: [],
  				setting: false
  			},
  			configurable: true
  		});

  		patch( array );
  	}

  	// store the ractive instance, so we can handle transitions later
  	if ( !array._ractive.instances[ ractive._guid ] ) {
  		array._ractive.instances[ ractive._guid ] = 0;
  		array._ractive.instances.push( ractive );
  	}

  	array._ractive.instances[ ractive._guid ] += 1;
  	array._ractive.wrappers.push( this );
  };

  ArrayWrapper.prototype.get = function get () {
  	return this.value;
  };

  ArrayWrapper.prototype.reset = function reset ( value ) {
  	return this.value === value;
  };

  ArrayWrapper.prototype.teardown = function teardown () {
  	var array, storage, wrappers, instances, index;

  	array = this.value;
  	storage = array._ractive;
  	wrappers = storage.wrappers;
  	instances = storage.instances;

  	// if teardown() was invoked because we're clearing the cache as a result of
  	// a change that the array itself triggered, we can save ourselves the teardown
  	// and immediate setup
  	if ( storage.setting ) {
  		return false; // so that we don't remove it from cached wrappers
  	}

  	index = wrappers.indexOf( this );
  	if ( index === -1 ) {
  		throw new Error( errorMessage$1 );
  	}

  	wrappers.splice( index, 1 );

  	// if nothing else depends on this array, we can revert it to its
  	// natural state
  	if ( !wrappers.length ) {
  		delete array._ractive;
  		patch.unpatch( this.value );
  	}

  	else {
  		// remove ractive instance if possible
  		instances[ this.root._guid ] -= 1;
  		if ( !instances[ this.root._guid ] ) {
  			index = instances.indexOf( this.root );

  			if ( index === -1 ) {
  				throw new Error( errorMessage$1 );
  			}

  			instances.splice( index, 1 );
  		}
  	}
  };

  var magicAdaptor;

  try {
  	Object.defineProperty({}, 'test', { get: function() {}, set: function() {} });

  	magicAdaptor = {
  		filter: function ( value ) {
  			return value && typeof value === 'object';
  		},
  		wrap: function ( ractive, value, keypath ) {
  			return new MagicWrapper( ractive, value, keypath );
  		}
  	};
  } catch ( err ) {
  	magicAdaptor = false;
  }

  var magicAdaptor$1 = magicAdaptor;

  function createOrWrapDescriptor ( originalDescriptor, ractive, keypath ) {
  	if ( originalDescriptor.set && originalDescriptor.set.__magic ) {
  		originalDescriptor.set.__magic.dependants.push({ ractive: ractive, keypath: keypath });
  		return originalDescriptor;
  	}

  	var setting;

  	var dependants = [{ ractive: ractive, keypath: keypath }];

  	var descriptor = {
  		get: function () {
  			return 'value' in originalDescriptor ? originalDescriptor.value : originalDescriptor.get();
  		},
  		set: function ( value ) {
  			if ( setting ) return;

  			if ( 'value' in originalDescriptor ) {
  				originalDescriptor.value = value;
  			} else {
  				originalDescriptor.set( value );
  			}

  			setting = true;
  			dependants.forEach( function (ref) {
  				var ractive = ref.ractive;
  				var keypath = ref.keypath;

  				ractive.set( keypath, value );
  			});
  			setting = false;
  		},
  		enumerable: true
  	};

  	descriptor.set.__magic = { dependants: dependants, originalDescriptor: originalDescriptor };

  	return descriptor;
  }

  function revert ( descriptor, ractive, keypath ) {
  	if ( !descriptor.set || !descriptor.set.__magic ) return true;

  	var dependants = descriptor.set.__magic;
  	var i = dependants.length;
  	while ( i-- ) {
  		var dependant = dependants[i];
  		if ( dependant.ractive === ractive && dependant.keypath === keypath ) {
  			dependants.splice( i, 1 );
  			return false;
  		}
  	}
  }

  var MagicWrapper = function MagicWrapper ( ractive, value, keypath ) {
  	var this$1 = this;

  		this.ractive = ractive;
  	this.value = value;
  	this.keypath = keypath;

  	this.originalDescriptors = {};

  	// wrap all properties with getters
  	Object.keys( value ).forEach( function ( key ) {
  		var originalDescriptor = Object.getOwnPropertyDescriptor( this$1.value, key );
  		this$1.originalDescriptors[ key ] = originalDescriptor;

  		var childKeypath = keypath ? ("" + keypath + "." + (escapeKey( key ))) : escapeKey( key );

  		var descriptor = createOrWrapDescriptor( originalDescriptor, ractive, childKeypath );



  		Object.defineProperty( this$1.value, key, descriptor );
  	});
  };

  MagicWrapper.prototype.get = function get () {
  	return this.value;
  };

  MagicWrapper.prototype.reset = function reset ( value ) {
  	return this.value === value;
  };

  MagicWrapper.prototype.set = function set ( key, value ) {
  	this.value[ key ] = value;
  };

  MagicWrapper.prototype.teardown = function teardown () {
  	var this$1 = this;

  		Object.keys( this.value ).forEach( function ( key ) {
  		var descriptor = Object.getOwnPropertyDescriptor( this$1.value, key );
  		if ( !descriptor.set || !descriptor.set.__magic ) return;

  		revert( descriptor );

  		if ( descriptor.set.__magic.dependants.length === 1 ) {
  			Object.defineProperty( this$1.value, key, descriptor.set.__magic.originalDescriptor );
  		}
  	});
  };

  var MagicArrayWrapper = function MagicArrayWrapper ( ractive, array, keypath ) {
  	this.value = array;

  	this.magic = true;

  	this.magicWrapper = magicAdaptor$1.wrap( ractive, array, keypath );
  	this.arrayWrapper = arrayAdaptor.wrap( ractive, array, keypath );

  	// ugh, this really is a terrible hack
  	Object.defineProperty( this, '__model', {
  		get: function () {
  			return this.arrayWrapper.__model;
  		},
  		set: function ( model ) {
  			this.arrayWrapper.__model = model;
  		}
  	});
  };

  MagicArrayWrapper.prototype.get = function get () {
  	return this.value;
  };

  MagicArrayWrapper.prototype.teardown = function teardown () {
  	this.arrayWrapper.teardown();
  	this.magicWrapper.teardown();
  };

  MagicArrayWrapper.prototype.reset = function reset ( value ) {
  	return this.arrayWrapper.reset( value ) && this.magicWrapper.reset( value );
  };

  var magicArrayAdaptor = {
  	filter: function ( object, keypath, ractive ) {
  		return magicAdaptor$1.filter( object, keypath, ractive ) && arrayAdaptor.filter( object );
  	},

  	wrap: function ( ractive, array, keypath ) {
  		return new MagicArrayWrapper( ractive, array, keypath );
  	}
  };

  // TODO this is probably a bit anal, maybe we should leave it out
  function prettify ( fnBody ) {
  	var lines = fnBody
  		.replace( /^\t+/gm, function ( tabs ) { return tabs.split( '\t' ).join( '  ' ); } )
  		.split( '\n' );

  	var minIndent = lines.length < 2 ? 0 :
  		lines.slice( 1 ).reduce( function ( prev, line ) {
  			return Math.min( prev, /^\s*/.exec( line )[0].length );
  		}, Infinity );

  	return lines.map( function ( line, i ) {
  		return '    ' + ( i ? line.substring( minIndent ) : line );
  	}).join( '\n' );
  }

  // Ditto. This function truncates the stack to only include app code
  function truncateStack ( stack ) {
  	if ( !stack ) return '';

  	var lines = stack.split( '\n' );
  	var name = Computation.name + '.getValue';

  	var truncated = [];

  	var len = lines.length;
  	for ( var i = 1; i < len; i += 1 ) {
  		var line = lines[i];

  		if ( ~line.indexOf( name ) ) {
  			return truncated.join( '\n' );
  		} else {
  			truncated.push( line );
  		}
  	}
  }

  var Computation = (function (Model) {
  	function Computation ( viewmodel, signature, key ) {
  		Model.call( this, null, null );

  		this.root = this.parent = viewmodel;
  		this.signature = signature;

  		this.key = key; // not actually used, but helps with debugging
  		this.isExpression = key && key[0] === '@';

  		this.isReadonly = !this.signature.setter;

  		this.context = viewmodel.computationContext;

  		this.dependencies = [];

  		this.children = [];
  		this.childByKey = {};

  		this.deps = [];

  		this.boundsSensitive = true;
  		this.dirty = true;

  		// TODO: is there a less hackish way to do this?
  		this.shuffle = undefined;
  	}

  	Computation.prototype = Object.create( Model && Model.prototype );
  	Computation.prototype.constructor = Computation;

  	Computation.prototype.get = function get ( shouldCapture ) {
  		if ( shouldCapture ) capture( this );

  		if ( this.dirty ) {
  			this.dirty = false;
  			this.value = this.getValue();
  			this.adapt();
  		}

  		// if capturing, this value needs to be unwrapped because it's for external use
  		return shouldCapture && this.wrapper ? this.wrapper.value : this.value;
  	};

  	Computation.prototype.getValue = function getValue () {
  		startCapturing();
  		var result;

  		try {
  			result = this.signature.getter.call( this.context );
  		} catch ( err ) {
  			warnIfDebug( ("Failed to compute " + (this.getKeypath()) + ": " + (err.message || err)) );

  			// TODO this is all well and good in Chrome, but...
  			// ...also, should encapsulate this stuff better, and only
  			// show it if Ractive.DEBUG
  			if ( hasConsole ) {
  				if ( console.groupCollapsed ) console.groupCollapsed( '%cshow details', 'color: rgb(82, 140, 224); font-weight: normal; text-decoration: underline;' );
  				var functionBody = prettify( this.signature.getterString );
  				var stack = this.signature.getterUseStack ? '\n\n' + truncateStack( err.stack ) : '';
  				console.error( ("" + (err.name) + ": " + (err.message) + "\n\n" + functionBody + "" + stack) );
  				if ( console.groupCollapsed ) console.groupEnd();
  			}
  		}

  		var dependencies = stopCapturing();
  		this.setDependencies( dependencies );

  		return result;
  	};

  	Computation.prototype.handleChange = function handleChange$1 () {
  		this.dirty = true;

  		this.deps.forEach( handleChange );
  		this.children.forEach( handleChange );
  		this.clearUnresolveds(); // TODO same question as on Model - necessary for primitives?
  	};

  	Computation.prototype.joinKey = function joinKey ( key ) {
  		if ( key === undefined || key === '' ) return this;

  		if ( !this.childByKey.hasOwnProperty( key ) ) {
  			var child = new ComputationChild( this, key );
  			this.children.push( child );
  			this.childByKey[ key ] = child;
  		}

  		return this.childByKey[ key ];
  	};

  	Computation.prototype.mark = function mark () {
  		this.handleChange();
  	};

  	Computation.prototype.set = function set ( value ) {
  		if ( !this.signature.setter ) {
  			throw new Error( ("Cannot set read-only computed value '" + (this.key) + "'") );
  		}

  		this.signature.setter( value );
  	};

  	Computation.prototype.setDependencies = function setDependencies ( dependencies ) {
  		// unregister any soft dependencies we no longer have
  		var this$1 = this;

  		var i = this.dependencies.length;
  		while ( i-- ) {
  			var model = this$1.dependencies[i];
  			if ( !~dependencies.indexOf( model ) ) model.unregister( this$1 );
  		}

  		// and add any new ones
  		i = dependencies.length;
  		while ( i-- ) {
  			var model$1 = dependencies[i];
  			if ( !~this$1.dependencies.indexOf( model$1 ) ) model$1.register( this$1 );
  		}

  		this.dependencies = dependencies;
  	};

  	Computation.prototype.teardown = function teardown () {
  		var this$1 = this;

  		var i = this.dependencies.length;
  		while ( i-- ) {
  			if ( this$1.dependencies[i] ) this$1.dependencies[i].unregister( this$1 );
  		}
  		if ( this.root.computations[this.key] === this ) delete this.root.computations[this.key];
  		Model.prototype.teardown.call(this);
  	};

  	return Computation;
  }(Model));

  var RactiveModel = (function (Model) {
  	function RactiveModel ( ractive ) {
  		Model.call( this, null, '' );
  		this.value = ractive;
  		this.isRoot = true;
  		this.root = this;
  		this.adaptors = [];
  		this.ractive = ractive;
  		this.changes = {};
  	}

  	RactiveModel.prototype = Object.create( Model && Model.prototype );
  	RactiveModel.prototype.constructor = RactiveModel;

  	RactiveModel.prototype.getKeypath = function getKeypath() {
  		return '@this';
  	};

  	return RactiveModel;
  }(Model));

  var hasProp$1 = Object.prototype.hasOwnProperty;

  var RootModel = (function (Model) {
  	function RootModel ( options ) {
  		Model.call( this, null, null );

  		// TODO deprecate this
  		this.changes = {};

  		this.isRoot = true;
  		this.root = this;
  		this.ractive = options.ractive; // TODO sever this link

  		this.value = options.data;
  		this.adaptors = options.adapt;
  		this.adapt();

  		this.mappings = {};

  		this.computationContext = options.ractive;
  		this.computations = {};
  	}

  	RootModel.prototype = Object.create( Model && Model.prototype );
  	RootModel.prototype.constructor = RootModel;

  	RootModel.prototype.applyChanges = function applyChanges () {
  		this._changeHash = {};
  		this.flush();

  		return this._changeHash;
  	};

  	RootModel.prototype.compute = function compute ( key, signature ) {
  		var computation = new Computation( this, signature, key );
  		this.computations[ key ] = computation;

  		return computation;
  	};

  	RootModel.prototype.extendChildren = function extendChildren ( fn ) {
  		var mappings = this.mappings;
  		Object.keys( mappings ).forEach( function ( key ) {
  			fn( key, mappings[ key ] );
  		});

  		var computations = this.computations;
  		Object.keys( computations ).forEach( function ( key ) {
  			var computation = computations[ key ];
  			// exclude template expressions
  			if ( !computation.isExpression ) {
  				fn( key, computation );
  			}
  		});
  	};

  	RootModel.prototype.get = function get ( shouldCapture ) {
  		if ( shouldCapture ) capture( this );
  		var result = extendObj( {}, this.value );

  		this.extendChildren( function ( key, model ) {
  			result[ key ] = model.value;
  		});

  		return result;
  	};

  	RootModel.prototype.getKeypath = function getKeypath () {
  		return '';
  	};

  	RootModel.prototype.getRactiveModel = function getRactiveModel() {
  		return this.ractiveModel || ( this.ractiveModel = new RactiveModel( this.ractive ) );
  	};

  	RootModel.prototype.getValueChildren = function getValueChildren () {
  		var children = Model.prototype.getValueChildren.call( this, this.value );

  		this.extendChildren( function ( key, model ) {
  			children.push( model );
  		});

  		return children;
  	};

  	RootModel.prototype.handleChange = function handleChange$1 () {
  		this.deps.forEach( handleChange );
  	};

  	RootModel.prototype.has = function has ( key ) {
  		if ( ( key in this.mappings ) || ( key in this.computations ) ) return true;

  		var value = this.value;

  		key = unescapeKey( key );
  		if ( hasProp$1.call( value, key ) ) return true;

  		// We climb up the constructor chain to find if one of them contains the key
  		var constructor = value.constructor;
  		while ( constructor !== Function && constructor !== Array && constructor !== Object ) {
  			if ( hasProp$1.call( constructor.prototype, key ) ) return true;
  			constructor = constructor.constructor;
  		}

  		return false;
  	};

  	RootModel.prototype.joinKey = function joinKey ( key ) {
  		if ( key === '@global' ) return GlobalModel$1;
  		if ( key === '@this' ) return this.getRactiveModel();

  		return this.mappings.hasOwnProperty( key ) ? this.mappings[ key ] :
  		       this.computations.hasOwnProperty( key ) ? this.computations[ key ] :
  		       Model.prototype.joinKey.call( this, key );
  	};

  	RootModel.prototype.map = function map ( localKey, origin ) {
  		// TODO remapping
  		this.mappings[ localKey ] = origin;
  		origin.register( this );
  	};

  	RootModel.prototype.set = function set ( value ) {
  		// TODO wrapping root node is a baaaad idea. We should prevent this
  		var wrapper = this.wrapper;
  		if ( wrapper ) {
  			var shouldTeardown = !wrapper.reset || wrapper.reset( value ) === false;

  			if ( shouldTeardown ) {
  				wrapper.teardown();
  				this.wrapper = null;
  				this.value = value;
  				this.adapt();
  			}
  		} else {
  			this.value = value;
  			this.adapt();
  		}

  		this.deps.forEach( handleChange );
  		this.children.forEach( mark );
  		this.clearUnresolveds(); // TODO do we need to do this with primitive values? if not, what about e.g. unresolved `length` property of null -> string?
  	};

  	RootModel.prototype.retrieve = function retrieve () {
  		return this.value;
  	};

  	RootModel.prototype.teardown = function teardown () {
  		var this$1 = this;

  		var keys = Object.keys( this.mappings );
  		var i = keys.length;
  		while ( i-- ){
  			if ( this$1.mappings[ keys[i] ] ) this$1.mappings[ keys[i] ].unregister( this$1 );
  		}

  		Model.prototype.teardown.call(this);
  	};

  	RootModel.prototype.update = function update () {
  		// noop
  	};

  	RootModel.prototype.updateFromBindings = function updateFromBindings ( cascade ) {
  		var this$1 = this;

  		Model.prototype.updateFromBindings.call( this, cascade );

  		if ( cascade ) {
  			// TODO computations as well?
  			Object.keys( this.mappings ).forEach( function ( key ) {
  				var model = this$1.mappings[ key ];
  				model.updateFromBindings( cascade );
  			});
  		}
  	};

  	return RootModel;
  }(Model));

  function getComputationSignature ( ractive, key, signature ) {
  	var getter;
  	var setter;

  	// useful for debugging
  	var getterString;
  	var getterUseStack;
  	var setterString;

  	if ( typeof signature === 'function' ) {
  		getter = bind$1( signature, ractive );
  		getterString = signature.toString();
  		getterUseStack = true;
  	}

  	if ( typeof signature === 'string' ) {
  		getter = createFunctionFromString( signature, ractive );
  		getterString = signature;
  	}

  	if ( typeof signature === 'object' ) {
  		if ( typeof signature.get === 'string' ) {
  			getter = createFunctionFromString( signature.get, ractive );
  			getterString = signature.get;
  		} else if ( typeof signature.get === 'function' ) {
  			getter = bind$1( signature.get, ractive );
  			getterString = signature.get.toString();
  			getterUseStack = true;
  		} else {
  			fatal( '`%s` computation must have a `get()` method', key );
  		}

  		if ( typeof signature.set === 'function' ) {
  			setter = bind$1( signature.set, ractive );
  			setterString = signature.set.toString();
  		}
  	}

  	return {
  		getter: getter,
  		setter: setter,
  		getterString: getterString,
  		setterString: setterString,
  		getterUseStack: getterUseStack
  	};
  }

  var constructHook = new Hook( 'construct' );

  var registryNames$1 = [
  	'adaptors',
  	'components',
  	'decorators',
  	'easing',
  	'events',
  	'interpolators',
  	'partials',
  	'transitions'
  ];

  var uid = 0;

  function construct ( ractive, options ) {
  	if ( Ractive.DEBUG ) welcome();

  	initialiseProperties( ractive );

  	// TODO remove this, eventually
  	defineProperty( ractive, 'data', { get: deprecateRactiveData });

  	// TODO don't allow `onconstruct` with `new Ractive()`, there's no need for it
  	constructHook.fire( ractive, options );

  	// Add registries
  	registryNames$1.forEach( function ( name ) {
  		ractive[ name ] = extendObj( create( ractive.constructor[ name ] || null ), options[ name ] );
  	});

  	// Create a viewmodel
  	var viewmodel = new RootModel({
  		adapt: getAdaptors( ractive, ractive.adapt, options ),
  		data: dataConfigurator.init( ractive.constructor, ractive, options ),
  		ractive: ractive
  	});

  	ractive.viewmodel = viewmodel;

  	// Add computed properties
  	var computed = extendObj( create( ractive.constructor.prototype.computed ), options.computed );

  	for ( var key in computed ) {
  		var signature = getComputationSignature( ractive, key, computed[ key ] );
  		viewmodel.compute( key, signature );
  	}
  }

  function combine$2 ( a, b ) {
  	var c = a.slice();
  	var i = b.length;

  	while ( i-- ) {
  		if ( !~c.indexOf( b[i] ) ) {
  			c.push( b[i] );
  		}
  	}

  	return c;
  }

  function getAdaptors ( ractive, protoAdapt, options ) {
  	protoAdapt = protoAdapt.map( lookup );
  	var adapt = ensureArray( options.adapt ).map( lookup );

  	adapt = combine$2( protoAdapt, adapt );

  	var magic = 'magic' in options ? options.magic : ractive.magic;
  	var modifyArrays = 'modifyArrays' in options ? options.modifyArrays : ractive.modifyArrays;

  	if ( magic ) {
  		if ( !magicSupported ) {
  			throw new Error( 'Getters and setters (magic mode) are not supported in this browser' );
  		}

  		if ( modifyArrays ) {
  			adapt.push( magicArrayAdaptor );
  		}

  		adapt.push( magicAdaptor$1 );
  	}

  	if ( modifyArrays ) {
  		adapt.push( arrayAdaptor );
  	}

  	return adapt;


  	function lookup ( adaptor ) {
  		if ( typeof adaptor === 'string' ) {
  			adaptor = findInViewHierarchy( 'adaptors', ractive, adaptor );

  			if ( !adaptor ) {
  				fatal( missingPlugin( adaptor, 'adaptor' ) );
  			}
  		}

  		return adaptor;
  	}
  }

  function initialiseProperties ( ractive ) {
  	// Generate a unique identifier, for places where you'd use a weak map if it
  	// existed
  	ractive._guid = 'r-' + uid++;

  	// events
  	ractive._subs = create( null );

  	// storage for item configuration from instantiation to reset,
  	// like dynamic functions or original values
  	ractive._config = {};

  	// nodes registry
  	ractive.nodes = {};

  	// events
  	ractive.event = null;
  	ractive._eventQueue = [];

  	// live queries
  	ractive._liveQueries = [];
  	ractive._liveComponentQueries = [];

  	// observers
  	ractive._observers = [];

  	// links
  	ractive._links = {};

  	if(!ractive.component){
  		ractive.root = ractive;
  		ractive.parent = ractive.container = null; // TODO container still applicable?
  	}

  }

  function deprecateRactiveData () {
  	throw new Error( 'Using `ractive.data` is no longer supported - you must use the `ractive.get()` API instead' );
  }

  function getChildQueue ( queue, ractive ) {
  	return queue[ ractive._guid ] || ( queue[ ractive._guid ] = [] );
  }

  function fire ( hookQueue, ractive ) {
  	var childQueue = getChildQueue( hookQueue.queue, ractive );

  	hookQueue.hook.fire( ractive );

  	// queue is "live" because components can end up being
  	// added while hooks fire on parents that modify data values.
  	while ( childQueue.length ) {
  		fire( hookQueue, childQueue.shift() );
  	}

  	delete hookQueue.queue[ ractive._guid ];
  }

  var HookQueue = function HookQueue ( event ) {
  	this.hook = new Hook( event );
  	this.inProcess = {};
  	this.queue = {};
  };

  HookQueue.prototype.begin = function begin ( ractive ) {
  	this.inProcess[ ractive._guid ] = true;
  };

  HookQueue.prototype.end = function end ( ractive ) {
  	var parent = ractive.parent;

  	// If this is *isn't* a child of a component that's in process,
  	// it should call methods or fire at this point
  	if ( !parent || !this.inProcess[ parent._guid ] ) {
  		fire( this, ractive );
  	}
  	// elsewise, handoff to parent to fire when ready
  	else {
  		getChildQueue( this.queue, parent ).push( ractive );
  	}

  	delete this.inProcess[ ractive._guid ];
  };

  var configHook = new Hook( 'config' );
  var initHook = new HookQueue( 'init' );

  function initialise ( ractive, userOptions, options ) {
  	Object.keys( ractive.viewmodel.computations ).forEach( function ( key ) {
  		var computation = ractive.viewmodel.computations[ key ];

  		if ( ractive.viewmodel.value.hasOwnProperty( key ) ) {
  			computation.set( ractive.viewmodel.value[ key ] );
  		}
  	});

  	// init config from Parent and options
  	config.init( ractive.constructor, ractive, userOptions );

  	configHook.fire( ractive );
  	initHook.begin( ractive );

  	var fragment;

  	// Render virtual DOM
  	if ( ractive.template ) {
  		var cssIds;

  		if ( options.cssIds || ractive.cssId ) {
  			cssIds = options.cssIds ? options.cssIds.slice() : [];

  			if ( ractive.cssId ) {
  				cssIds.push( ractive.cssId );
  			}
  		}

  		ractive.fragment = fragment = new Fragment({
  			owner: ractive,
  			template: ractive.template,
  			cssIds: cssIds
  		}).bind( ractive.viewmodel );
  	}

  	initHook.end( ractive );

  	if ( fragment ) {
  		// render automatically ( if `el` is specified )
  		var el = getElement( ractive.el );
  		if ( el ) {
  			var promise = ractive.render( el, ractive.append );

  			if ( Ractive.DEBUG_PROMISES ) {
  				promise['catch']( function ( err ) {
  					warnOnceIfDebug( 'Promise debugging is enabled, to help solve errors that happen asynchronously. Some browsers will log unhandled promise rejections, in which case you can safely disable promise debugging:\n  Ractive.DEBUG_PROMISES = false;' );
  					warnIfDebug( 'An error happened during rendering', { ractive: ractive });
  					logIfDebug( err );

  					throw err;
  				});
  			}
  		}
  	}
  }

  var Parser;
  var ParseError;
  var leadingWhitespace = /^\s+/;
  ParseError = function ( message ) {
  	this.name = 'ParseError';
  	this.message = message;
  	try {
  		throw new Error(message);
  	} catch (e) {
  		this.stack = e.stack;
  	}
  };

  ParseError.prototype = Error.prototype;

  Parser = function ( str, options ) {
  	var this$1 = this;

  	var items, item, lineStart = 0;

  	this.str = str;
  	this.options = options || {};
  	this.pos = 0;

  	this.lines = this.str.split( '\n' );
  	this.lineEnds = this.lines.map( function ( line ) {
  		var lineEnd = lineStart + line.length + 1; // +1 for the newline

  		lineStart = lineEnd;
  		return lineEnd;
  	}, 0 );

  	// Custom init logic
  	if ( this.init ) this.init( str, options );

  	items = [];

  	while ( ( this$1.pos < this$1.str.length ) && ( item = this$1.read() ) ) {
  		items.push( item );
  	}

  	this.leftover = this.remaining();
  	this.result = this.postProcess ? this.postProcess( items, options ) : items;
  };

  Parser.prototype = {
  	read: function ( converters ) {
  		var this$1 = this;

  		var pos, i, len, item;

  		if ( !converters ) converters = this.converters;

  		pos = this.pos;

  		len = converters.length;
  		for ( i = 0; i < len; i += 1 ) {
  			this$1.pos = pos; // reset for each attempt

  			if ( item = converters[i]( this$1 ) ) {
  				return item;
  			}
  		}

  		return null;
  	},

  	getLinePos: function ( char ) {
  		var this$1 = this;

  		var lineNum = 0, lineStart = 0, columnNum;

  		while ( char >= this$1.lineEnds[ lineNum ] ) {
  			lineStart = this$1.lineEnds[ lineNum ];
  			lineNum += 1;
  		}

  		columnNum = char - lineStart;
  		return [ lineNum + 1, columnNum + 1, char ]; // line/col should be one-based, not zero-based!
  	},

  	error: function ( message ) {
  		var pos = this.getLinePos( this.pos );
  		var lineNum = pos[0];
  		var columnNum = pos[1];

  		var line = this.lines[ pos[0] - 1 ];
  		var numTabs = 0;
  		var annotation = line.replace( /\t/g, function ( match, char ) {
  			if ( char < pos[1] ) {
  				numTabs += 1;
  			}

  			return '  ';
  		}) + '\n' + new Array( pos[1] + numTabs ).join( ' ' ) + '^----';

  		var error = new ParseError( ("" + message + " at line " + lineNum + " character " + columnNum + ":\n" + annotation) );

  		error.line = pos[0];
  		error.character = pos[1];
  		error.shortMessage = message;

  		throw error;
  	},

  	matchString: function ( string ) {
  		if ( this.str.substr( this.pos, string.length ) === string ) {
  			this.pos += string.length;
  			return string;
  		}
  	},

  	matchPattern: function ( pattern ) {
  		var match;

  		if ( match = pattern.exec( this.remaining() ) ) {
  			this.pos += match[0].length;
  			return match[1] || match[0];
  		}
  	},

  	allowWhitespace: function () {
  		this.matchPattern( leadingWhitespace );
  	},

  	remaining: function () {
  		return this.str.substring( this.pos );
  	},

  	nextChar: function () {
  		return this.str.charAt( this.pos );
  	}
  };

  Parser.extend = function ( proto ) {
  	var Parent = this, Child, key;

  	Child = function ( str, options ) {
  		Parser.call( this, str, options );
  	};

  	Child.prototype = create( Parent.prototype );

  	for ( key in proto ) {
  		if ( hasOwn.call( proto, key ) ) {
  			Child.prototype[ key ] = proto[ key ];
  		}
  	}

  	Child.extend = Parser.extend;
  	return Child;
  };

  var Parser$1 = Parser;

  var stringMiddlePattern;
  var escapeSequencePattern;
  var lineContinuationPattern;
  // Match one or more characters until: ", ', \, or EOL/EOF.
  // EOL/EOF is written as (?!.) (meaning there's no non-newline char next).
  stringMiddlePattern = /^(?=.)[^"'\\]+?(?:(?!.)|(?=["'\\]))/;

  // Match one escape sequence, including the backslash.
  escapeSequencePattern = /^\\(?:['"\\bfnrt]|0(?![0-9])|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|(?=.)[^ux0-9])/;

  // Match one ES5 line continuation (backslash + line terminator).
  lineContinuationPattern = /^\\(?:\r\n|[\u000A\u000D\u2028\u2029])/;

  // Helper for defining getDoubleQuotedString and getSingleQuotedString.
  function makeQuotedStringMatcher ( okQuote ) {
  	return function ( parser ) {
  		var literal = '"';
  		var done = false;
  		var next;

  		while ( !done ) {
  			next = ( parser.matchPattern( stringMiddlePattern ) || parser.matchPattern( escapeSequencePattern ) ||
  				parser.matchString( okQuote ) );
  			if ( next ) {
  				if ( next === ("\"") ) {
  					literal += "\\\"";
  				} else if ( next === ("\\'") ) {
  					literal += "'";
  				} else {
  					literal += next;
  				}
  			} else {
  				next = parser.matchPattern( lineContinuationPattern );
  				if ( next ) {
  					// convert \(newline-like) into a \u escape, which is allowed in JSON
  					literal += '\\u' + ( '000' + next.charCodeAt(1).toString(16) ).slice( -4 );
  				} else {
  					done = true;
  				}
  			}
  		}

  		literal += '"';

  		// use JSON.parse to interpret escapes
  		return JSON.parse( literal );
  	};
  }

  var getSingleQuotedString = makeQuotedStringMatcher( ("\"") );
  var getDoubleQuotedString = makeQuotedStringMatcher( ("'") );

  function readStringLiteral ( parser ) {
  	var start, string;

  	start = parser.pos;

  	if ( parser.matchString( '"' ) ) {
  		string = getDoubleQuotedString( parser );

  		if ( !parser.matchString( '"' ) ) {
  			parser.pos = start;
  			return null;
  		}

  		return {
  			t: STRING_LITERAL,
  			v: string
  		};
  	}

  	if ( parser.matchString( ("'") ) ) {
  		string = getSingleQuotedString( parser );

  		if ( !parser.matchString( ("'") ) ) {
  			parser.pos = start;
  			return null;
  		}

  		return {
  			t: STRING_LITERAL,
  			v: string
  		};
  	}

  	return null;
  }

  // bulletproof number regex from https://gist.github.com/Rich-Harris/7544330
  var numberPattern$1 = /^(?:[+-]?)0*(?:(?:(?:[1-9]\d*)?\.\d+)|(?:(?:0|[1-9]\d*)\.)|(?:0|[1-9]\d*))(?:[eE][+-]?\d+)?/;

  function readNumberLiteral ( parser ) {
  	var result;

  	if ( result = parser.matchPattern( numberPattern$1 ) ) {
  		return {
  			t: NUMBER_LITERAL,
  			v: result
  		};
  	}

  	return null;
  }

  var name = /^[a-zA-Z_$][a-zA-Z_$0-9]*/;

  var identifier = /^[a-zA-Z_$][a-zA-Z_$0-9]*$/;

  // http://mathiasbynens.be/notes/javascript-properties
  // can be any name, string literal, or number literal
  function readKey ( parser ) {
  	var token;

  	if ( token = readStringLiteral( parser ) ) {
  		return identifier.test( token.v ) ? token.v : '"' + token.v.replace( /"/g, '\\"' ) + '"';
  	}

  	if ( token = readNumberLiteral( parser ) ) {
  		return token.v;
  	}

  	if ( token = parser.matchPattern( name ) ) {
  		return token;
  	}

  	return null;
  }

  // simple JSON parser, without the restrictions of JSON parse
  // (i.e. having to double-quote keys).
  //
  // If passed a hash of values as the second argument, ${placeholders}
  // will be replaced with those values

  var specials = {
  	'true': true,
  	'false': false,
  	'null': null,
  	undefined: undefined
  };

  var specialsPattern = new RegExp( '^(?:' + Object.keys( specials ).join( '|' ) + ')' );
  var numberPattern = /^(?:[+-]?)(?:(?:(?:0|[1-9]\d*)?\.\d+)|(?:(?:0|[1-9]\d*)\.)|(?:0|[1-9]\d*))(?:[eE][+-]?\d+)?/;
  var placeholderPattern = /\$\{([^\}]+)\}/g;
  var placeholderAtStartPattern = /^\$\{([^\}]+)\}/;
  var onlyWhitespace = /^\s*$/;

  var JsonParser = Parser$1.extend({
  	init: function ( str, options ) {
  		this.values = options.values;
  		this.allowWhitespace();
  	},

  	postProcess: function ( result ) {
  		if ( result.length !== 1 || !onlyWhitespace.test( this.leftover ) ) {
  			return null;
  		}

  		return { value: result[0].v };
  	},

  	converters: [
  		function getPlaceholder ( parser ) {
  			if ( !parser.values ) return null;

  			var placeholder = parser.matchPattern( placeholderAtStartPattern );

  			if ( placeholder && ( parser.values.hasOwnProperty( placeholder ) ) ) {
  				return { v: parser.values[ placeholder ] };
  			}
  		},

  		function getSpecial ( parser ) {
  			var special = parser.matchPattern( specialsPattern );
  			if ( special ) return { v: specials[ special ] };
  		},

  		function getNumber ( parser ) {
  			var number = parser.matchPattern( numberPattern );
  			if ( number ) return { v: +number };
  		},

  		function getString ( parser ) {
  			var stringLiteral = readStringLiteral( parser );
  			var values = parser.values;

  			if ( stringLiteral && values ) {
  				return {
  					v: stringLiteral.v.replace( placeholderPattern, function ( match, $1 ) { return ( $1 in values ? values[ $1 ] : $1 ); } )
  				};
  			}

  			return stringLiteral;
  		},

  		function getObject ( parser ) {
  			if ( !parser.matchString( '{' ) ) return null;

  			var result = {};

  			parser.allowWhitespace();

  			if ( parser.matchString( '}' ) ) {
  				return { v: result };
  			}

  			var pair;
  			while ( pair = getKeyValuePair( parser ) ) {
  				result[ pair.key ] = pair.value;

  				parser.allowWhitespace();

  				if ( parser.matchString( '}' ) ) {
  					return { v: result };
  				}

  				if ( !parser.matchString( ',' ) ) {
  					return null;
  				}
  			}

  			return null;
  		},

  		function getArray ( parser ) {
  			if ( !parser.matchString( '[' ) ) return null;

  			var result = [];

  			parser.allowWhitespace();

  			if ( parser.matchString( ']' ) ) {
  				return { v: result };
  			}

  			var valueToken;
  			while ( valueToken = parser.read() ) {
  				result.push( valueToken.v );

  				parser.allowWhitespace();

  				if ( parser.matchString( ']' ) ) {
  					return { v: result };
  				}

  				if ( !parser.matchString( ',' ) ) {
  					return null;
  				}

  				parser.allowWhitespace();
  			}

  			return null;
  		}
  	]
  });

  function getKeyValuePair ( parser ) {
  	parser.allowWhitespace();

  	var key = readKey( parser );

  	if ( !key ) return null;

  	var pair = { key: key };

  	parser.allowWhitespace();
  	if ( !parser.matchString( ':' ) ) {
  		return null;
  	}
  	parser.allowWhitespace();

  	var valueToken = parser.read();

  	if ( !valueToken ) return null;

  	pair.value = valueToken.v;
  	return pair;
  }

  function parseJSON ( str, values ) {
  	var parser = new JsonParser( str, { values: values });
  	return parser.result;
  }

  var specialPattern = /^(event|arguments)(\..+)?$/;
  var dollarArgsPattern = /^\$(\d+)(\..+)?$/;

  var EventDirective = function EventDirective ( owner, event, template ) {
  	this.owner = owner;
  	this.event = event;
  	this.template = template;

  	this.ractive = owner.parentFragment.ractive;
  	this.parentFragment = owner.parentFragment;

  	this.context = null;

  	// method calls
  	this.resolvers = null;
  	this.models = null;

  	// handler directive
  	this.action = null;
  	this.args = null;
  };

  EventDirective.prototype.bind = function bind () {
  	var this$1 = this;

  		this.context = this.parentFragment.findContext();

  	var template = this.template;

  	if ( template.x ) {
  		this.fn = getFunction( template.x.s, template.x.r.length );
  		this.resolvers = [];
  		this.models = template.x.r.map( function ( ref, i ) {
  			var specialMatch = specialPattern.exec( ref );
  			if ( specialMatch ) {
  				// on-click="foo(event.node)"
  				return {
  					special: specialMatch[1],
  					keys: specialMatch[2] ? splitKeypathI( specialMatch[2].substr(1) ) : []
  				};
  			}

  			var dollarMatch = dollarArgsPattern.exec( ref );
  			if ( dollarMatch ) {
  				// on-click="foo($1)"
  				return {
  					special: 'arguments',
  					keys: [ dollarMatch[1] - 1 ].concat( dollarMatch[2] ? splitKeypathI( dollarMatch[2].substr( 1 ) ) : [] )
  				};
  			}

  			var resolver;

  			var model = resolveReference( this$1.parentFragment, ref );
  			if ( !model ) {
  				resolver = this$1.parentFragment.resolve( ref, function ( model ) {
  					this$1.models[i] = model;
  					removeFromArray( this$1.resolvers, resolver );
  				});

  				this$1.resolvers.push( resolver );
  			}

  			return model;
  		});
  	}

  	else {
  		// TODO deprecate this style of directive
  		this.action = typeof template === 'string' ? // on-click='foo'
  			template :
  			typeof template.n === 'string' ? // on-click='{{dynamic}}'
  				template.n :
  				new Fragment({
  					owner: this,
  					template: template.n
  				});

  		this.args = template.a ? // static arguments
  			( typeof template.a === 'string' ? [ template.a ] : template.a ) :
  			template.d ? // dynamic arguments
  				new Fragment({
  					owner: this,
  					template: template.d
  				}) :
  				[]; // no arguments
  	}

  	if ( this.template.n && typeof this.template.n !== 'string' ) this.action.bind();
  	if ( this.template.d ) this.args.bind();
  };

  EventDirective.prototype.bubble = function bubble () {
  	if ( !this.dirty ) {
  		this.dirty = true;
  		this.owner.bubble();
  	}
  };

  EventDirective.prototype.fire = function fire ( event, passedArgs ) {

  	// augment event object
  	if ( passedArgs === void 0 ) passedArgs = [];

  		if ( event && !event.hasOwnProperty( '_element' ) ) {
  		   addHelpers( event, this.owner );
  	}

  	if ( this.fn ) {
  		var values = [];

  		if ( event ) passedArgs.unshift( event );

  		if ( this.models ) {
  			this.models.forEach( function ( model ) {
  				if ( !model ) return values.push( undefined );

  				if ( model.special ) {
  					var obj = model.special === 'event' ? event : passedArgs;
  					var keys = model.keys.slice();

  					while ( keys.length ) obj = obj[ keys.shift() ];
  					return values.push( obj );
  				}

  				if ( model.wrapper ) {
  					return values.push( model.wrapper.value );
  				}

  				values.push( model.get() );
  			});
  		}

  		// make event available as `this.event`
  		var ractive = this.ractive;
  		var oldEvent = ractive.event;

  		ractive.event = event;
  		var result = this.fn.apply( ractive, values ).pop();

  		// Auto prevent and stop if return is explicitly false
  		var original;
  		if ( result === false && ( original = event.original ) ) {
  			original.preventDefault && original.preventDefault();
  			original.stopPropagation && original.stopPropagation();
  		}

  		ractive.event = oldEvent;
  	}

  	else {
  		var action = this.action.toString();
  		var args = this.template.d ? this.args.getArgsList() : this.args;

  		if ( passedArgs.length ) args = args.concat( passedArgs );

  		if ( event ) event.name = action;

  		fireEvent( this.ractive, action, {
  			event: event,
  			args: args
  		});
  	}
  };

  EventDirective.prototype.rebind = function rebind () {
  	this.unbind();
  	this.bind();
  };

  EventDirective.prototype.render = function render () {
  	this.event.listen( this );
  };

  EventDirective.prototype.unbind = function unbind$1 () {
  	if ( this.resolvers ) this.resolvers.forEach( unbind );
  	if ( this.action && this.action.unbind ) this.action.unbind();
  	if ( this.args && this.args.unbind ) this.args.unbind();
  };

  EventDirective.prototype.unrender = function unrender () {
  	this.event.unlisten();
  };

  EventDirective.prototype.update = function update () {
  	if ( this.method || !this.dirty ) return; // nothing to do

  	this.dirty = false;

  	// ugh legacy
  	if ( this.action && this.action.update ) this.action.update();
  	if ( this.args && this.args.update ) this.args.update();
  };

  var RactiveEvent = function RactiveEvent ( ractive, name ) {
  	this.ractive = ractive;
  	this.name = name;
  	this.handler = null;
  };

  RactiveEvent.prototype.listen = function listen ( directive ) {
  	var ractive = this.ractive;

  	this.handler = ractive.on( this.name, function () {
  		var event;

  		// semi-weak test, but what else? tag the event obj ._isEvent ?
  		if ( arguments.length && arguments[0] && arguments[0].node ) {
  			event = Array.prototype.shift.call( arguments );
  			event.component = ractive;
  		}

  		var args = Array.prototype.slice.call( arguments );
  		directive.fire( event, args );

  		// cancel bubbling
  		return false;
  	});
  };

  RactiveEvent.prototype.unlisten = function unlisten () {
  	this.handler.cancel();
  };

  // TODO it's unfortunate that this has to run every time a
  // component is rendered... is there a better way?
  function updateLiveQueries ( component ) {
  	// Does this need to be added to any live queries?
  	var instance = component.ractive;

  	do {
  		var liveQueries = instance._liveComponentQueries;

  		var i = liveQueries.length;
  		while ( i-- ) {
  			var name = liveQueries[i];
  			var query = liveQueries[ ("_" + name) ];

  			if ( query.test( component ) ) {
  				query.add( component.instance );
  				// keep register of applicable selectors, for when we teardown
  				component.liveQueries.push( query );
  			}
  		}
  	} while ( instance = instance.parent );
  }

  function removeFromLiveComponentQueries ( component ) {
  	var instance = component.ractive;

  	while ( instance ) {
  		var query = instance._liveComponentQueries[ ("_" + (component.name)) ];
  		if ( query ) query.remove( component );

  		instance = instance.parent;
  	}
  }

  function makeDirty ( query ) {
  	query.makeDirty();
  }

  var teardownHook = new Hook( 'teardown' );

  var Component = (function (Item) {
  	function Component ( options, ComponentConstructor ) {
  		Item.call( this, options );
  		this.type = COMPONENT; // override ELEMENT from super

  		var instance = create( ComponentConstructor.prototype );

  		this.instance = instance;
  		this.name = options.template.e;
  		this.parentFragment = options.parentFragment;
  		this.complexMappings = [];

  		this.liveQueries = [];

  		if ( instance.el ) {
  			warnIfDebug( ("The <" + (this.name) + "> component has a default 'el' property; it has been disregarded") );
  		}

  		var partials = options.template.p || {};
  		if ( !( 'content' in partials ) ) partials.content = options.template.f || [];
  		this._partials = partials; // TEMP

  		this.yielders = {};

  		// find container
  		var fragment = options.parentFragment;
  		var container;
  		while ( fragment ) {
  			if ( fragment.owner.type === YIELDER ) {
  				container = fragment.owner.container;
  				break;
  			}

  			fragment = fragment.parent;
  		}

  		// add component-instance-specific properties
  		instance.parent = this.parentFragment.ractive;
  		instance.container = container || null;
  		instance.root = instance.parent.root;
  		instance.component = this;

  		construct( this.instance, { partials: partials });

  		// for hackability, this could be an open option
  		// for any ractive instance, but for now, just
  		// for components and just for ractive...
  		instance._inlinePartials = partials;

  		this.eventHandlers = [];
  		if ( this.template.v ) this.setupEvents();
  	}

  	Component.prototype = Object.create( Item && Item.prototype );
  	Component.prototype.constructor = Component;

  	Component.prototype.bind = function bind$1 () {
  		var this$1 = this;

  		var viewmodel = this.instance.viewmodel;
  		var childData = viewmodel.value;

  		// determine mappings
  		if ( this.template.a ) {
  			Object.keys( this.template.a ).forEach( function ( localKey ) {
  				var template = this$1.template.a[ localKey ];
  				var model;
  				var fragment;

  				if ( template === 0 ) {
  					// empty attributes are `true`
  					viewmodel.joinKey( localKey ).set( true );
  				}

  				else if ( typeof template === 'string' ) {
  					var parsed = parseJSON( template );
  					viewmodel.joinKey( localKey ).set( parsed ? parsed.value : template );
  				}

  				else if ( isArray( template ) ) {
  					if ( template.length === 1 && template[0].t === INTERPOLATOR ) {
  						model = resolve$2( this$1.parentFragment, template[0] );

  						if ( !model ) {
  							warnOnceIfDebug( ("The " + localKey + "='{{" + (template[0].r) + "}}' mapping is ambiguous, and may cause unexpected results. Consider initialising your data to eliminate the ambiguity"), { ractive: this$1.instance }); // TODO add docs page explaining this
  							this$1.parentFragment.ractive.get( localKey ); // side-effect: create mappings as necessary
  							model = this$1.parentFragment.findContext().joinKey( localKey );
  						}

  						viewmodel.map( localKey, model );

  						if ( model.get() === undefined && localKey in childData ) {
  							model.set( childData[ localKey ] );
  						}
  					}

  					else {
  						fragment = new Fragment({
  							owner: this$1,
  							template: template
  						}).bind();

  						model = viewmodel.joinKey( localKey );
  						model.set( fragment.valueOf() );

  						// this is a *bit* of a hack
  						fragment.bubble = function () {
  							Fragment.prototype.bubble.call( fragment );
  							fragment.update();
  							model.set( fragment.valueOf() );
  						};

  						this$1.complexMappings.push( fragment );
  					}
  				}
  			});
  		}

  		initialise( this.instance, {
  			partials: this._partials
  		}, {
  			cssIds: this.parentFragment.cssIds
  		});

  		this.eventHandlers.forEach( bind );
  	};

  	Component.prototype.bubble = function bubble () {
  		if ( !this.dirty ) {
  			this.dirty = true;
  			this.parentFragment.bubble();
  		}
  	};

  	Component.prototype.checkYielders = function checkYielders () {
  		var this$1 = this;

  		Object.keys( this.yielders ).forEach( function ( name ) {
  			if ( this$1.yielders[ name ].length > 1 ) {
  				runloop.end();
  				throw new Error( ("A component template can only have one {{yield" + (name ? ' ' + name : '') + "}} declaration at a time") );
  			}
  		});
  	};

  	Component.prototype.detach = function detach () {
  		return this.instance.fragment.detach();
  	};

  	Component.prototype.find = function find ( selector ) {
  		return this.instance.fragment.find( selector );
  	};

  	Component.prototype.findAll = function findAll ( selector, query ) {
  		this.instance.fragment.findAll( selector, query );
  	};

  	Component.prototype.findComponent = function findComponent ( name ) {
  		if ( !name || this.name === name ) return this.instance;

  		if ( this.instance.fragment ) {
  			return this.instance.fragment.findComponent( name );
  		}
  	};

  	Component.prototype.findAllComponents = function findAllComponents ( name, query ) {
  		if ( query.test( this ) ) {
  			query.add( this.instance );

  			if ( query.live ) {
  				this.liveQueries.push( query );
  			}
  		}

  		this.instance.fragment.findAllComponents( name, query );
  	};

  	Component.prototype.firstNode = function firstNode ( skipParent ) {
  		return this.instance.fragment.firstNode( skipParent );
  	};

  	Component.prototype.rebind = function rebind$1 () {
  		var this$1 = this;

  		this.complexMappings.forEach( rebind );

  		this.liveQueries.forEach( makeDirty );

  		// update relevant mappings
  		var viewmodel = this.instance.viewmodel;
  		viewmodel.mappings = {};

  		if ( this.template.a ) {
  			Object.keys( this.template.a ).forEach( function ( localKey ) {
  				var template = this$1.template.a[ localKey ];
  				var model;

  				if ( isArray( template ) && template.length === 1 && template[0].t === INTERPOLATOR ) {
  					model = resolve$2( this$1.parentFragment, template[0] );

  					if ( !model ) {
  						// TODO is this even possible?
  						warnOnceIfDebug( ("The " + localKey + "='{{" + (template[0].r) + "}}' mapping is ambiguous, and may cause unexpected results. Consider initialising your data to eliminate the ambiguity"), { ractive: this$1.instance });
  						this$1.parentFragment.ractive.get( localKey ); // side-effect: create mappings as necessary
  						model = this$1.parentFragment.findContext().joinKey( localKey );
  					}

  					viewmodel.map( localKey, model );
  				}
  			});
  		}

  		this.instance.fragment.rebind( viewmodel );
  	};

  	Component.prototype.render = function render$1$$ ( target, occupants ) {
  		render$1( this.instance, target, null, occupants );

  		this.checkYielders();
  		this.eventHandlers.forEach( render );
  		updateLiveQueries( this );

  		this.rendered = true;
  	};

  	Component.prototype.setupEvents = function setupEvents () {
  		var this$1 = this;

  		var handlers = this.eventHandlers;

  		Object.keys( this.template.v ).forEach( function ( key ) {
  			var eventNames = key.split( '-' );
  			var template = this$1.template.v[ key ];

  			eventNames.forEach( function ( eventName ) {
  				var event = new RactiveEvent( this$1.instance, eventName );
  				handlers.push( new EventDirective( this$1, event, template ) );
  			});
  		});
  	};

  	Component.prototype.toString = function toString () {
  		return this.instance.toHTML();
  	};

  	Component.prototype.unbind = function unbind$1 () {
  		this.complexMappings.forEach( unbind );

  		var instance = this.instance;
  		instance.viewmodel.teardown();
  		instance.fragment.unbind();
  		instance._observers.forEach( cancel );

  		removeFromLiveComponentQueries( this );

  		if ( instance.fragment.rendered && instance.el.__ractive_instances__ ) {
  			removeFromArray( instance.el.__ractive_instances__, instance );
  		}

  		Object.keys( instance._links ).forEach( function ( k ) { return instance._links[k].unlink(); } );

  		teardownHook.fire( instance );
  	};

  	Component.prototype.unrender = function unrender$1 ( shouldDestroy ) {
  		var this$1 = this;

  		this.shouldDestroy = shouldDestroy;
  		this.instance.unrender();
  		this.eventHandlers.forEach( unrender );
  		this.liveQueries.forEach( function ( query ) { return query.remove( this$1.instance ); } );
  	};

  	Component.prototype.update = function update$1 () {
  		this.dirty = false;
  		this.instance.fragment.update();
  		this.checkYielders();
  		this.eventHandlers.forEach( update );
  		this.complexMappings.forEach( update );
  	};

  	return Component;
  }(Item));

  var Doctype = (function (Item) {
  	function Doctype () {
  		Item.apply(this, arguments);
  	}

  	Doctype.prototype = Object.create( Item && Item.prototype );
  	Doctype.prototype.constructor = Doctype;

  	Doctype.prototype.bind = function bind () {
  		// noop
  	};

  	Doctype.prototype.render = function render () {
  		// noop
  	};

  	Doctype.prototype.teardown = function teardown () {
  		// noop
  	};

  	Doctype.prototype.toString = function toString () {
  		return '<!DOCTYPE' + this.template.a + '>';
  	};

  	Doctype.prototype.unbind = function unbind () {
  		// noop
  	};

  	Doctype.prototype.unrender = function unrender () {
  		// noop
  	};

  	return Doctype;
  }(Item));

  function camelCase ( hyphenatedStr ) {
  	return hyphenatedStr.replace( /-([a-zA-Z])/g, function ( match, $1 ) {
  		return $1.toUpperCase();
  	});
  }

  var space = /\s+/;
  var specials$1 = { 'float': 'cssFloat' };
  var remove = /\/\*(?:[\s\S]*?)\*\//g;
  var escape = /url\(\s*(['"])(?:\\[\s\S]|(?!\1).)*\1\s*\)|url\((?:\\[\s\S]|[^)])*\)|(['"])(?:\\[\s\S]|(?!\1).)*\2/gi;
  var value = /\0(\d+)/g;

  function readStyle ( css ) {
      var values = [];

      if ( typeof css !== 'string' ) return {};

      return css.replace( escape, function ( match ) { return ("\u0000" + (values.push( match ) - 1)); })
          .replace( remove, '' )
          .split( ';' )
          .filter( function ( rule ) { return !!rule.trim(); } )
          .map( function ( rule ) { return rule.replace( value, function ( match, n ) { return values[ n ]; } ); } )
          .reduce(function ( rules, rule ) {
              var i = rule.indexOf(':');
              var name = camelCase( rule.substr( 0, i ).trim() );
              rules[ specials$1[ name ] || name ] = rule.substr( i + 1 ).trim();
              return rules;
          }, {});
  }

  function readClass ( str ) {
    var list = str.split( space );

    // remove any empty entries
    var i = list.length;
    while ( i-- ) {
      if ( !list[i] ) list.splice( i, 1 );
    }

    return list;
  }

  var textTypes = [ undefined, 'text', 'search', 'url', 'email', 'hidden', 'password', 'search', 'reset', 'submit' ];

  function getUpdateDelegate ( attribute ) {
  	var element = attribute.element, name = attribute.name;

  	if ( name === 'id' ) return updateId;

  	if ( name === 'value' ) {
  		// special case - selects
  		if ( element.name === 'select' && name === 'value' ) {
  			return element.getAttribute( 'multiple' ) ? updateMultipleSelectValue : updateSelectValue;
  		}

  		if ( element.name === 'textarea' ) return updateStringValue;

  		// special case - contenteditable
  		if ( element.getAttribute( 'contenteditable' ) != null ) return updateContentEditableValue;

  		// special case - <input>
  		if ( element.name === 'input' ) {
  			var type = element.getAttribute( 'type' );

  			// type='file' value='{{fileList}}'>
  			if ( type === 'file' ) return noop; // read-only

  			// type='radio' name='{{twoway}}'
  			if ( type === 'radio' && element.binding && element.binding.attribute.name === 'name' ) return updateRadioValue;

  			if ( ~textTypes.indexOf( type ) ) return updateStringValue;
  		}

  		return updateValue;
  	}

  	var node = element.node;

  	// special case - <input type='radio' name='{{twoway}}' value='foo'>
  	if ( attribute.isTwoway && name === 'name' ) {
  		if ( node.type === 'radio' ) return updateRadioName;
  		if ( node.type === 'checkbox' ) return updateCheckboxName;
  	}

  	if ( name === 'style' ) return updateStyleAttribute;

  	if ( name.indexOf( 'style-' ) === 0 ) return updateInlineStyle;

  	// special case - class names. IE fucks things up, again
  	if ( name === 'class' && ( !node.namespaceURI || node.namespaceURI === html ) ) return updateClassName;

  	if ( name.indexOf( 'class-' ) === 0 ) return updateInlineClass;

  	if ( attribute.isBoolean ) return updateBoolean;

  	if ( attribute.namespace && attribute.namespace !== attribute.node.namespaceURI ) return updateNamespacedAttribute;

  	return updateAttribute;
  }

  function updateId () {
  	var ref = this, node = ref.node;
  	var value = this.getValue();

  	delete this.ractive.nodes[ node.id ];
  	this.ractive.nodes[ value ] = node;

  	node.id = value;
  }

  function updateMultipleSelectValue () {
  	var value = this.getValue();

  	if ( !isArray( value ) ) value = [ value ];

  	var options = this.node.options;
  	var i = options.length;

  	while ( i-- ) {
  		var option = options[i];
  		var optionValue = option._ractive ?
  			option._ractive.value :
  			option.value; // options inserted via a triple don't have _ractive

  		option.selected = arrayContains( value, optionValue );
  	}
  }

  function updateSelectValue () {
  	var value = this.getValue();

  	if ( !this.locked ) { // TODO is locked still a thing?
  		this.node._ractive.value = value;

  		var options = this.node.options;
  		var i = options.length;

  		while ( i-- ) {
  			var option = options[i];
  			var optionValue = option._ractive ?
  				option._ractive.value :
  				option.value; // options inserted via a triple don't have _ractive

  			if ( optionValue == value ) { // double equals as we may be comparing numbers with strings
  				option.selected = true;
  				return;
  			}
  		}

  		this.node.selectedIndex = -1;
  	}
  }


  function updateContentEditableValue () {
  	var value = this.getValue();

  	if ( !this.locked ) {
  		this.node.innerHTML = value === undefined ? '' : value;
  	}
  }

  function updateRadioValue () {
  	var node = this.node;
  	var wasChecked = node.checked;

  	var value = this.getValue();

  	//node.value = this.element.getAttribute( 'value' );
  	node.value = this.node._ractive.value = value;
  	node.checked = value === this.element.getAttribute( 'name' );

  	// This is a special case - if the input was checked, and the value
  	// changed so that it's no longer checked, the twoway binding is
  	// most likely out of date. To fix it we have to jump through some
  	// hoops... this is a little kludgy but it works
  	if ( wasChecked && !node.checked && this.element.binding && this.element.binding.rendered ) {
  		this.element.binding.group.model.set( this.element.binding.group.getValue() );
  	}
  }

  function updateValue () {
  	if ( !this.locked ) {
  		var value = this.getValue();

  		this.node.value = this.node._ractive.value = value;
  		this.node.setAttribute( 'value', value );
  	}
  }

  function updateStringValue () {
  	if ( !this.locked ) {
  		var value = this.getValue();

  		this.node._ractive.value = value;

  		this.node.value = safeToStringValue( value );
  		this.node.setAttribute( 'value', safeToStringValue( value ) );
  	}
  }

  function updateRadioName () {
  	this.node.checked = ( this.getValue() == this.node._ractive.value );
  }

  function updateCheckboxName () {
  	var ref = this, element = ref.element, node = ref.node;
  	var binding = element.binding;

  	var value = this.getValue();
  	var valueAttribute = element.getAttribute( 'value' );

  	if ( !isArray( value ) ) {
  		binding.isChecked = node.checked = ( value == valueAttribute );
  	} else {
  		var i = value.length;
  		while ( i-- ) {
  			if ( valueAttribute == value[i] ) {
  				binding.isChecked = node.checked = true;
  				return;
  			}
  		}
  		binding.isChecked = node.checked = false;
  	}
  }

  function updateStyleAttribute () {
  	var props = readStyle( this.getValue() || '' );
  	var style = this.node.style;
  	var keys = Object.keys( props );
  	var prev = this.previous || [];

  	var i = 0;
  	while ( i < keys.length ) {
  		if ( keys[i] in style ) style[ keys[i] ] = props[ keys[i] ];
  		i++;
  	}

  	// remove now-missing attrs
  	i = prev.length;
  	while ( i-- ) {
  		if ( !~keys.indexOf( prev[i] ) && prev[i] in style ) style[ prev[i] ] = '';
  	}

  	this.previous = keys;
  }

  function updateInlineStyle () {
  	if ( !this.styleName ) {
  		this.styleName = camelize( this.name.substr( 6 ) );
  	}

  	this.node.style[ this.styleName ] = this.getValue();
  }

  function updateClassName () {
  	var value = readClass( safeToStringValue( this.getValue() ) );
  	var attr = readClass( this.node.className );
  	var prev = this.previous || attr.slice( 0 );

  	// TODO: if/when conditional attrs land, avoid this by shifting class attrs to the front
  	if ( !this.directives ) {
  		this.directives = this.element.attributes.filter( function ( a ) { return a.name.substr( 0, 6 ) === 'class-'; } );
  	}
  	value.push.apply( value, this.directives.map( function ( d ) { return d.inlineClass; } ) );

  	var i = 0;
  	while ( i < value.length ) {
  		if ( !~attr.indexOf( value[i] ) ) attr.push( value[i] );
  		i++;
  	}

  	// remove now-missing classes
  	i = prev.length;
  	while ( i-- ) {
  		if ( !~value.indexOf( prev[i] ) ) {
  			var idx = attr.indexOf( prev[i] );
  			if ( ~idx ) attr.splice( idx, 1 );
  		}
  	}

  	var className = attr.join( ' ' );

  	if ( className !== this.node.className ) {
  		this.node.className = className;
  	}

  	this.previous = value;
  }

  function updateInlineClass () {
  	var name = this.name.substr( 6 );
  	var attr = readClass( this.node.className );
  	var value = this.getValue();

  	if ( !this.inlineClass ) this.inlineClass = name;

  	if ( value && !~attr.indexOf( name ) ) attr.push( name );
  	else if ( !value && ~attr.indexOf( name ) ) attr.splice( attr.indexOf( name ), 1 );

  	this.node.className = attr.join( ' ' );
  }

  function updateBoolean () {
  	// with two-way binding, only update if the change wasn't initiated by the user
  	// otherwise the cursor will often be sent to the wrong place
  	if ( !this.locked ) {
  		if ( this.useProperty ) {
  			this.node[ this.propertyName ] = this.getValue();
  		} else {
  			if ( this.getValue() ) {
  				this.node.setAttribute( this.propertyName, '' );
  			} else {
  				this.node.removeAttribute( this.propertyName );
  			}
  		}
  	}
  }

  function updateAttribute () {
  	this.node.setAttribute( this.name, safeToStringValue( this.getString() ) );
  }

  function updateNamespacedAttribute () {
  	this.node.setAttributeNS( this.namespace, this.name.slice( this.name.indexOf( ':' ) + 1 ), safeToStringValue( this.getString() ) );
  }

  var propertyNames = {
  	'accept-charset': 'acceptCharset',
  	accesskey: 'accessKey',
  	bgcolor: 'bgColor',
  	'class': 'className',
  	codebase: 'codeBase',
  	colspan: 'colSpan',
  	contenteditable: 'contentEditable',
  	datetime: 'dateTime',
  	dirname: 'dirName',
  	'for': 'htmlFor',
  	'http-equiv': 'httpEquiv',
  	ismap: 'isMap',
  	maxlength: 'maxLength',
  	novalidate: 'noValidate',
  	pubdate: 'pubDate',
  	readonly: 'readOnly',
  	rowspan: 'rowSpan',
  	tabindex: 'tabIndex',
  	usemap: 'useMap'
  };

  // https://github.com/kangax/html-minifier/issues/63#issuecomment-37763316
  var booleanAttributes = /^(allowFullscreen|async|autofocus|autoplay|checked|compact|controls|declare|default|defaultChecked|defaultMuted|defaultSelected|defer|disabled|enabled|formNoValidate|hidden|indeterminate|inert|isMap|itemScope|loop|multiple|muted|noHref|noResize|noShade|noValidate|noWrap|open|pauseOnExit|readOnly|required|reversed|scoped|seamless|selected|sortable|translate|trueSpeed|typeMustMatch|visible)$/i;
  var voidElementNames = /^(?:area|base|br|col|command|doctype|embed|hr|img|input|keygen|link|meta|param|source|track|wbr)$/i;

  var htmlEntities = { quot: 34, amp: 38, apos: 39, lt: 60, gt: 62, nbsp: 160, iexcl: 161, cent: 162, pound: 163, curren: 164, yen: 165, brvbar: 166, sect: 167, uml: 168, copy: 169, ordf: 170, laquo: 171, not: 172, shy: 173, reg: 174, macr: 175, deg: 176, plusmn: 177, sup2: 178, sup3: 179, acute: 180, micro: 181, para: 182, middot: 183, cedil: 184, sup1: 185, ordm: 186, raquo: 187, frac14: 188, frac12: 189, frac34: 190, iquest: 191, Agrave: 192, Aacute: 193, Acirc: 194, Atilde: 195, Auml: 196, Aring: 197, AElig: 198, Ccedil: 199, Egrave: 200, Eacute: 201, Ecirc: 202, Euml: 203, Igrave: 204, Iacute: 205, Icirc: 206, Iuml: 207, ETH: 208, Ntilde: 209, Ograve: 210, Oacute: 211, Ocirc: 212, Otilde: 213, Ouml: 214, times: 215, Oslash: 216, Ugrave: 217, Uacute: 218, Ucirc: 219, Uuml: 220, Yacute: 221, THORN: 222, szlig: 223, agrave: 224, aacute: 225, acirc: 226, atilde: 227, auml: 228, aring: 229, aelig: 230, ccedil: 231, egrave: 232, eacute: 233, ecirc: 234, euml: 235, igrave: 236, iacute: 237, icirc: 238, iuml: 239, eth: 240, ntilde: 241, ograve: 242, oacute: 243, ocirc: 244, otilde: 245, ouml: 246, divide: 247, oslash: 248, ugrave: 249, uacute: 250, ucirc: 251, uuml: 252, yacute: 253, thorn: 254, yuml: 255, OElig: 338, oelig: 339, Scaron: 352, scaron: 353, Yuml: 376, fnof: 402, circ: 710, tilde: 732, Alpha: 913, Beta: 914, Gamma: 915, Delta: 916, Epsilon: 917, Zeta: 918, Eta: 919, Theta: 920, Iota: 921, Kappa: 922, Lambda: 923, Mu: 924, Nu: 925, Xi: 926, Omicron: 927, Pi: 928, Rho: 929, Sigma: 931, Tau: 932, Upsilon: 933, Phi: 934, Chi: 935, Psi: 936, Omega: 937, alpha: 945, beta: 946, gamma: 947, delta: 948, epsilon: 949, zeta: 950, eta: 951, theta: 952, iota: 953, kappa: 954, lambda: 955, mu: 956, nu: 957, xi: 958, omicron: 959, pi: 960, rho: 961, sigmaf: 962, sigma: 963, tau: 964, upsilon: 965, phi: 966, chi: 967, psi: 968, omega: 969, thetasym: 977, upsih: 978, piv: 982, ensp: 8194, emsp: 8195, thinsp: 8201, zwnj: 8204, zwj: 8205, lrm: 8206, rlm: 8207, ndash: 8211, mdash: 8212, lsquo: 8216, rsquo: 8217, sbquo: 8218, ldquo: 8220, rdquo: 8221, bdquo: 8222, dagger: 8224, Dagger: 8225, bull: 8226, hellip: 8230, permil: 8240, prime: 8242, Prime: 8243, lsaquo: 8249, rsaquo: 8250, oline: 8254, frasl: 8260, euro: 8364, image: 8465, weierp: 8472, real: 8476, trade: 8482, alefsym: 8501, larr: 8592, uarr: 8593, rarr: 8594, darr: 8595, harr: 8596, crarr: 8629, lArr: 8656, uArr: 8657, rArr: 8658, dArr: 8659, hArr: 8660, forall: 8704, part: 8706, exist: 8707, empty: 8709, nabla: 8711, isin: 8712, notin: 8713, ni: 8715, prod: 8719, sum: 8721, minus: 8722, lowast: 8727, radic: 8730, prop: 8733, infin: 8734, ang: 8736, and: 8743, or: 8744, cap: 8745, cup: 8746, 'int': 8747, there4: 8756, sim: 8764, cong: 8773, asymp: 8776, ne: 8800, equiv: 8801, le: 8804, ge: 8805, sub: 8834, sup: 8835, nsub: 8836, sube: 8838, supe: 8839, oplus: 8853, otimes: 8855, perp: 8869, sdot: 8901, lceil: 8968, rceil: 8969, lfloor: 8970, rfloor: 8971, lang: 9001, rang: 9002, loz: 9674, spades: 9824, clubs: 9827, hearts: 9829, diams: 9830	};
  var controlCharacters = [ 8364, 129, 8218, 402, 8222, 8230, 8224, 8225, 710, 8240, 352, 8249, 338, 141, 381, 143, 144, 8216, 8217, 8220, 8221, 8226, 8211, 8212, 732, 8482, 353, 8250, 339, 157, 382, 376 ];
  var entityPattern = new RegExp( '&(#?(?:x[\\w\\d]+|\\d+|' + Object.keys( htmlEntities ).join( '|' ) + '));?', 'g' );
  var codePointSupport = typeof String.fromCodePoint === 'function';
  var codeToChar = codePointSupport ? String.fromCodePoint : String.fromCharCode;

  function decodeCharacterReferences ( html ) {
  	return html.replace( entityPattern, function ( match, entity ) {
  		var code;

  		// Handle named entities
  		if ( entity[0] !== '#' ) {
  			code = htmlEntities[ entity ];
  		} else if ( entity[1] === 'x' ) {
  			code = parseInt( entity.substring( 2 ), 16 );
  		} else {
  			code = parseInt( entity.substring( 1 ), 10 );
  		}

  		if ( !code ) {
  			return match;
  		}

  		return codeToChar( validateCode( code ) );
  	});
  }

  var lessThan = /</g;
  var greaterThan = />/g;
  var amp = /&/g;
  var invalid = 65533;

  function escapeHtml ( str ) {
  	return str
  		.replace( amp, '&amp;' )
  		.replace( lessThan, '&lt;' )
  		.replace( greaterThan, '&gt;' );
  }

  // some code points are verboten. If we were inserting HTML, the browser would replace the illegal
  // code points with alternatives in some cases - since we're bypassing that mechanism, we need
  // to replace them ourselves
  //
  // Source: http://en.wikipedia.org/wiki/Character_encodings_in_HTML#Illegal_characters
  function validateCode ( code ) {
  	if ( !code ) {
  		return invalid;
  	}

  	// line feed becomes generic whitespace
  	if ( code === 10 ) {
  		return 32;
  	}

  	// ASCII range. (Why someone would use HTML entities for ASCII characters I don't know, but...)
  	if ( code < 128 ) {
  		return code;
  	}

  	// code points 128-159 are dealt with leniently by browsers, but they're incorrect. We need
  	// to correct the mistake or we'll end up with missing € signs and so on
  	if ( code <= 159 ) {
  		return controlCharacters[ code - 128 ];
  	}

  	// basic multilingual plane
  	if ( code < 55296 ) {
  		return code;
  	}

  	// UTF-16 surrogate halves
  	if ( code <= 57343 ) {
  		return invalid;
  	}

  	// rest of the basic multilingual plane
  	if ( code <= 65535 ) {
  		return code;
  	} else if ( !codePointSupport ) {
  		return invalid;
  	}

  	// supplementary multilingual plane 0x10000 - 0x1ffff
  	if ( code >= 65536 && code <= 131071 ) {
  		return code;
  	}

  	// supplementary ideographic plane 0x20000 - 0x2ffff
  	if ( code >= 131072 && code <= 196607 ) {
  		return code;
  	}

  	return invalid;
  }

  function lookupNamespace ( node, prefix ) {
  	var qualified = "xmlns:" + prefix;

  	while ( node ) {
  		if ( node.hasAttribute( qualified ) ) return node.getAttribute( qualified );
  		node = node.parentNode;
  	}

  	return namespaces[ prefix ];
  }

  var Attribute = (function (Item) {
  	function Attribute ( options ) {
  		Item.call( this, options );

  		this.name = options.name;
  		this.namespace = null;
  		this.element = options.element;
  		this.parentFragment = options.element.parentFragment; // shared
  		this.ractive = this.parentFragment.ractive;

  		this.rendered = false;
  		this.updateDelegate = null;
  		this.fragment = null;
  		this.value = null;

  		if ( !isArray( options.template ) ) {
  			this.value = options.template;
  			if ( this.value === 0 ) {
  				this.value = '';
  			}
  		} else {
  			this.fragment = new Fragment({
  				owner: this,
  				template: options.template
  			});
  		}

  		this.interpolator = this.fragment &&
  		                    this.fragment.items.length === 1 &&
  		                    this.fragment.items[0].type === INTERPOLATOR &&
  		                    this.fragment.items[0];
  	}

  	Attribute.prototype = Object.create( Item && Item.prototype );
  	Attribute.prototype.constructor = Attribute;

  	Attribute.prototype.bind = function bind () {
  		if ( this.fragment ) {
  			this.fragment.bind();
  		}
  	};

  	Attribute.prototype.bubble = function bubble () {
  		if ( !this.dirty ) {
  			this.element.bubble();
  			this.dirty = true;
  		}
  	};

  	Attribute.prototype.getString = function getString () {
  		return this.fragment ?
  			this.fragment.toString() :
  			this.value != null ? '' + this.value : '';
  	};

  	// TODO could getValue ever be called for a static attribute,
  	// or can we assume that this.fragment exists?
  	Attribute.prototype.getValue = function getValue () {
  		return this.fragment ? this.fragment.valueOf() : booleanAttributes.test( this.name ) ? true : this.value;
  	};

  	Attribute.prototype.rebind = function rebind () {
  		if (this.fragment) this.fragment.rebind();
  	};

  	Attribute.prototype.render = function render () {
  		var node = this.element.node;
  		this.node = node;

  		// should we use direct property access, or setAttribute?
  		if ( !node.namespaceURI || node.namespaceURI === namespaces.html ) {
  			this.propertyName = propertyNames[ this.name ] || this.name;

  			if ( node[ this.propertyName ] !== undefined ) {
  				this.useProperty = true;
  			}

  			// is attribute a boolean attribute or 'value'? If so we're better off doing e.g.
  			// node.selected = true rather than node.setAttribute( 'selected', '' )
  			if ( booleanAttributes.test( this.name ) || this.isTwoway ) {
  				this.isBoolean = true;
  			}

  			if ( this.propertyName === 'value' ) {
  				node._ractive.value = this.value;
  			}
  		}

  		if ( node.namespaceURI ) {
  			var index = this.name.indexOf( ':' );
  			if ( index !== -1 ) {
  				this.namespace = lookupNamespace( node, this.name.slice( 0, index ) );
  			} else {
  				this.namespace = node.namespaceURI;
  			}
  		}

  		this.rendered = true;
  		this.updateDelegate = getUpdateDelegate( this );
  		this.updateDelegate();
  	};

  	Attribute.prototype.toString = function toString () {
  		var value = this.getValue();

  		// Special case - select and textarea values (should not be stringified)
  		if ( this.name === 'value' && ( this.element.getAttribute( 'contenteditable' ) !== undefined || ( this.element.name === 'select' || this.element.name === 'textarea' ) ) ) {
  			return;
  		}

  		// Special case – bound radio `name` attributes
  		if ( this.name === 'name' && this.element.name === 'input' && this.interpolator && this.element.getAttribute( 'type' ) === 'radio' ) {
  			return ("name=\"{{" + (this.interpolator.model.getKeypath()) + "}}\"");
  		}

  		// Special case - style and class attributes and directives
  		if ( this.name === 'style' || this.name === 'class' || this.styleName || this.inlineClass ) {
  			return;
  		}

  		if ( booleanAttributes.test( this.name ) ) return value ? this.name : '';
  		if ( value == null ) return '';

  		var str = safeAttributeString( this.getString() );
  		return str ?
  			("" + (this.name) + "=\"" + str + "\"") :
  			this.name;
  	};

  	Attribute.prototype.unbind = function unbind () {
  		if ( this.fragment ) this.fragment.unbind();
  	};

  	Attribute.prototype.update = function update () {
  		if ( this.dirty ) {
  			this.dirty = false;
  			if ( this.fragment ) this.fragment.update();
  			if ( this.rendered ) this.updateDelegate();
  		}
  	};

  	return Attribute;
  }(Item));

  var div$1 = doc ? createElement( 'div' ) : null;

  var ConditionalAttribute = (function (Item) {
  	function ConditionalAttribute ( options ) {
  		Item.call( this, options );

  		this.attributes = [];

  		this.owner = options.owner;

  		this.fragment = new Fragment({
  			ractive: this.ractive,
  			owner: this,
  			template: [ this.template ]
  		});

  		this.dirty = false;
  	}

  	ConditionalAttribute.prototype = Object.create( Item && Item.prototype );
  	ConditionalAttribute.prototype.constructor = ConditionalAttribute;

  	ConditionalAttribute.prototype.bind = function bind () {
  		this.fragment.bind();
  	};

  	ConditionalAttribute.prototype.bubble = function bubble () {
  		if ( !this.dirty ) {
  			this.dirty = true;
  			this.owner.bubble();
  		}
  	};

  	ConditionalAttribute.prototype.rebind = function rebind () {
  		this.fragment.rebind();
  	};

  	ConditionalAttribute.prototype.render = function render () {
  		this.node = this.owner.node;
  		this.isSvg = this.node.namespaceURI === svg$1;

  		this.rendered = true;
  		this.dirty = true; // TODO this seems hacky, but necessary for tests to pass in browser AND node.js
  		this.update();
  	};

  	ConditionalAttribute.prototype.toString = function toString () {
  		return this.fragment.toString();
  	};

  	ConditionalAttribute.prototype.unbind = function unbind () {
  		this.fragment.unbind();
  	};

  	ConditionalAttribute.prototype.unrender = function unrender () {
  		this.rendered = false;
  	};

  	ConditionalAttribute.prototype.update = function update () {
  		var this$1 = this;

  		var str;
  		var attrs;

  		if ( this.dirty ) {
  			this.dirty = false;

  			this.fragment.update();

  			if ( this.rendered ) {
  				str = this.fragment.toString();
  				attrs = parseAttributes( str, this.isSvg );

  				// any attributes that previously existed but no longer do
  				// must be removed
  				this.attributes.filter( function ( a ) { return notIn( attrs, a ); } ).forEach( function ( a ) {
  					this$1.node.removeAttribute( a.name );
  				});

  				attrs.forEach( function ( a ) {
  					this$1.node.setAttribute( a.name, a.value );
  				});

  				this.attributes = attrs;
  			}
  		}
  	};

  	return ConditionalAttribute;
  }(Item));

  function parseAttributes ( str, isSvg ) {
  	var tagName = isSvg ? 'svg' : 'div';
  	return str
  		? (div$1.innerHTML = "<" + tagName + " " + str + "></" + tagName + ">") &&
  			toArray(div$1.childNodes[0].attributes)
  		: [];
  }

  function notIn ( haystack, needle ) {
  	var i = haystack.length;

  	while ( i-- ) {
  		if ( haystack[i].name === needle.name ) {
  			return false;
  		}
  	}

  	return true;
  }

  var missingDecorator = {
  	update: noop,
  	teardown: noop
  };

  var Decorator = function Decorator ( owner, template ) {
  	this.owner = owner;
  	this.template = template;

  	this.parentFragment = owner.parentFragment;
  	this.ractive = owner.ractive;

  	this.dynamicName = typeof template.n === 'object';
  	this.dynamicArgs = !!template.d;

  	if ( this.dynamicName ) {
  		this.nameFragment = new Fragment({
  			owner: this,
  			template: template.n
  		});
  	} else {
  		this.name = template.n || template;
  	}

  	if ( this.dynamicArgs ) {
  		this.argsFragment = new Fragment({
  			owner: this,
  			template: template.d
  		});
  	} else {
  		this.args = template.a || [];
  	}

  	this.node = null;
  	this.intermediary = null;
  };

  Decorator.prototype.bind = function bind () {
  	if ( this.dynamicName ) {
  		this.nameFragment.bind();
  		this.name = this.nameFragment.toString();
  	}

  	if ( this.dynamicArgs ) this.argsFragment.bind();
  };

  Decorator.prototype.bubble = function bubble () {
  	if ( !this.dirty ) {
  		this.dirty = true;
  		this.owner.bubble();
  	}
  };

  Decorator.prototype.rebind = function rebind () {
  	if ( this.dynamicName ) this.nameFragment.rebind();
  	if ( this.dynamicArgs ) this.argsFragment.rebind();
  };

  Decorator.prototype.render = function render () {
  	var fn = findInViewHierarchy( 'decorators', this.ractive, this.name );

  	if ( !fn ) {
  		warnOnce( missingPlugin( this.name, 'decorator' ) );
  		this.intermediary = missingDecorator;
  		return;
  	}

  	this.node = this.owner.node;

  	var args = this.dynamicArgs ? this.argsFragment.getArgsList() : this.args;
  	this.intermediary = fn.apply( this.ractive, [ this.node ].concat( args ) );

  	if ( !this.intermediary || !this.intermediary.teardown ) {
  		throw new Error( ("The '" + (this.name) + "' decorator must return an object with a teardown method") );
  	}
  };

  Decorator.prototype.unbind = function unbind () {
  	if ( this.dynamicName ) this.nameFragment.unbind();
  	if ( this.dynamicArgs ) this.argsFragment.unbind();
  };

  Decorator.prototype.unrender = function unrender () {
  	if ( this.intermediary ) this.intermediary.teardown();
  };

  Decorator.prototype.update = function update () {
  	if ( !this.dirty ) return;

  	this.dirty = false;

  	var nameChanged = false;

  	if ( this.dynamicName && this.nameFragment.dirty ) {
  		var name = this.nameFragment.toString();
  		nameChanged = name !== this.name;
  		this.name = name;
  	}

  	if ( this.intermediary ) {
  		if ( nameChanged || !this.intermediary.update ) {
  			this.unrender();
  			this.render();
  		}
  		else {
  			if ( this.dynamicArgs ) {
  				if ( this.argsFragment.dirty ) {
  					var args = this.argsFragment.getArgsList();
  					this.intermediary.update.apply( this.ractive, args );
  				}
  			}
  			else {
  				this.intermediary.update.apply( this.ractive, this.args );
  			}
  		}
  	}

  	// need to run these for unrender/render cases
  	// so can't just be in conditional if above

  	if ( this.dynamicName && this.nameFragment.dirty ) {
  		this.nameFragment.update();
  	}

  	if ( this.dynamicArgs && this.argsFragment.dirty ) {
  		this.argsFragment.update();
  	}
  };

  var DOMEvent = function DOMEvent ( name, owner ) {
  	if ( name.indexOf( '*' ) !== -1 ) {
  		fatal( ("Only component proxy-events may contain \"*\" wildcards, <" + (owner.name) + " on-" + name + "=\"...\"/> is not valid") );
  	}

  	this.name = name;
  	this.owner = owner;
  	this.node = null;
  	this.handler = null;
  };

  DOMEvent.prototype.listen = function listen ( directive ) {
  	var node = this.node = this.owner.node;
  	var name = this.name;

  	if ( !( ("on" + name) in node ) ) {
  			warnOnce( missingPlugin( name, 'events' ) );
  		}

  	node.addEventListener( name, this.handler = function( event ) {
  		directive.fire({
  			node: node,
  				original: event
  			});
  	}, false );
  };

  DOMEvent.prototype.unlisten = function unlisten () {
  	this.node.removeEventListener( this.name, this.handler, false );
  };

  var CustomEvent = function CustomEvent ( eventPlugin, owner ) {
  	this.eventPlugin = eventPlugin;
  	this.owner = owner;
  	this.handler = null;
  };

  CustomEvent.prototype.listen = function listen ( directive ) {
  	var node = this.owner.node;

  	this.handler = this.eventPlugin( node, function ( event ) {
  		if ( event === void 0 ) event = {};

  			event.node = event.node || node;
  		directive.fire( event );
  	});
  };

  CustomEvent.prototype.unlisten = function unlisten () {
  	this.handler.teardown();
  };

  var prefix;

  if ( !isClient ) {
  	prefix = null;
  } else {
  	var prefixCache = {};
  	var testStyle = createElement( 'div' ).style;

  	prefix = function ( prop ) {
  		prop = camelCase( prop );

  		if ( !prefixCache[ prop ] ) {
  			if ( testStyle[ prop ] !== undefined ) {
  				prefixCache[ prop ] = prop;
  			}

  			else {
  				// test vendors...
  				var capped = prop.charAt( 0 ).toUpperCase() + prop.substring( 1 );

  				var i = vendors.length;
  				while ( i-- ) {
  					var vendor = vendors[i];
  					if ( testStyle[ vendor + capped ] !== undefined ) {
  						prefixCache[ prop ] = vendor + capped;
  						break;
  					}
  				}
  			}
  		}

  		return prefixCache[ prop ];
  	};
  }

  var prefix$1 = prefix;

  var visible;
  var hidden = 'hidden';

  if ( doc ) {
  	var prefix$2;

  	if ( hidden in doc ) {
  		prefix$2 = '';
  	} else {
  		var i$1 = vendors.length;
  		while ( i$1-- ) {
  			var vendor = vendors[i$1];
  			hidden = vendor + 'Hidden';

  			if ( hidden in doc ) {
  				prefix$2 = vendor;
  				break;
  			}
  		}
  	}

  	if ( prefix$2 !== undefined ) {
  		doc.addEventListener( prefix$2 + 'visibilitychange', onChange );
  		onChange();
  	} else {
  		// gah, we're in an old browser
  		if ( 'onfocusout' in doc ) {
  			doc.addEventListener( 'focusout', onHide );
  			doc.addEventListener( 'focusin', onShow );
  		}

  		else {
  			win.addEventListener( 'pagehide', onHide );
  			win.addEventListener( 'blur', onHide );

  			win.addEventListener( 'pageshow', onShow );
  			win.addEventListener( 'focus', onShow );
  		}

  		visible = true; // until proven otherwise. Not ideal but hey
  	}
  }

  function onChange () {
  	visible = !doc[ hidden ];
  }

  function onHide () {
  	visible = false;
  }

  function onShow () {
  	visible = true;
  }

  var unprefixPattern = new RegExp( '^-(?:' + vendors.join( '|' ) + ')-' );

  function unprefix ( prop ) {
  	return prop.replace( unprefixPattern, '' );
  }

  var vendorPattern = new RegExp( '^(?:' + vendors.join( '|' ) + ')([A-Z])' );

  function hyphenate ( str ) {
  	if ( !str ) return ''; // edge case

  	if ( vendorPattern.test( str ) ) str = '-' + str;

  	return str.replace( /[A-Z]/g, function ( match ) { return '-' + match.toLowerCase(); } );
  }

  var createTransitions;

  if ( !isClient ) {
  	createTransitions = null;
  } else {
  	var testStyle$1 = createElement( 'div' ).style;
  	var linear$1 = function ( x ) { return x; };

  	var canUseCssTransitions = {};
  	var cannotUseCssTransitions = {};

  	// determine some facts about our environment
  	var TRANSITION;
  	var TRANSITIONEND;
  	var CSS_TRANSITIONS_ENABLED;
  	var TRANSITION_DURATION;
  	var TRANSITION_PROPERTY;
  	var TRANSITION_TIMING_FUNCTION;

  	if ( testStyle$1.transition !== undefined ) {
  		TRANSITION = 'transition';
  		TRANSITIONEND = 'transitionend';
  		CSS_TRANSITIONS_ENABLED = true;
  	} else if ( testStyle$1.webkitTransition !== undefined ) {
  		TRANSITION = 'webkitTransition';
  		TRANSITIONEND = 'webkitTransitionEnd';
  		CSS_TRANSITIONS_ENABLED = true;
  	} else {
  		CSS_TRANSITIONS_ENABLED = false;
  	}

  	if ( TRANSITION ) {
  		TRANSITION_DURATION = TRANSITION + 'Duration';
  		TRANSITION_PROPERTY = TRANSITION + 'Property';
  		TRANSITION_TIMING_FUNCTION = TRANSITION + 'TimingFunction';
  	}

  	createTransitions = function ( t, to, options, changedProperties, resolve ) {

  		// Wait a beat (otherwise the target styles will be applied immediately)
  		// TODO use a fastdom-style mechanism?
  		setTimeout( function () {
  			var jsTransitionsComplete;
  			var cssTransitionsComplete;

  			function checkComplete () {
  				if ( jsTransitionsComplete && cssTransitionsComplete ) {
  					// will changes to events and fire have an unexpected consequence here?
  					t.ractive.fire( t.name + ':end', t.node, t.isIntro );
  					resolve();
  				}
  			}

  			// this is used to keep track of which elements can use CSS to animate
  			// which properties
  			var hashPrefix = ( t.node.namespaceURI || '' ) + t.node.tagName;

  			// need to reset transition properties
  			var style = t.node.style;
  			var previous = {
  				property: style[ TRANSITION_PROPERTY ],
  				timing: style[ TRANSITION_TIMING_FUNCTION ],
  				duration: style[ TRANSITION_DURATION ]
  			};

  			style[ TRANSITION_PROPERTY ] = changedProperties.map( prefix$1 ).map( hyphenate ).join( ',' );
  			style[ TRANSITION_TIMING_FUNCTION ] = hyphenate( options.easing || 'linear' );
  			style[ TRANSITION_DURATION ] = ( options.duration / 1000 ) + 's';

  			function transitionEndHandler ( event ) {
  				var index = changedProperties.indexOf( camelCase( unprefix( event.propertyName ) ) );

  				if ( index !== -1 ) {
  					changedProperties.splice( index, 1 );
  				}

  				if ( changedProperties.length ) {
  					// still transitioning...
  					return;
  				}

  				style[ TRANSITION_PROPERTY ] = previous.property;
  				style[ TRANSITION_TIMING_FUNCTION ] = previous.duration;
  				style[ TRANSITION_DURATION ] = previous.timing;

  				t.node.removeEventListener( TRANSITIONEND, transitionEndHandler, false );

  				cssTransitionsComplete = true;
  				checkComplete();
  			}

  			t.node.addEventListener( TRANSITIONEND, transitionEndHandler, false );

  			setTimeout( function () {
  				var i = changedProperties.length;
  				var hash;
  				var originalValue;
  				var index;
  				var propertiesToTransitionInJs = [];
  				var prop;
  				var suffix;
  				var interpolator;

  				while ( i-- ) {
  					prop = changedProperties[i];
  					hash = hashPrefix + prop;

  					if ( CSS_TRANSITIONS_ENABLED && !cannotUseCssTransitions[ hash ] ) {
  						style[ prefix$1( prop ) ] = to[ prop ];

  						// If we're not sure if CSS transitions are supported for
  						// this tag/property combo, find out now
  						if ( !canUseCssTransitions[ hash ] ) {
  							originalValue = t.getStyle( prop );

  							// if this property is transitionable in this browser,
  							// the current style will be different from the target style
  							canUseCssTransitions[ hash ] = ( t.getStyle( prop ) != to[ prop ] );
  							cannotUseCssTransitions[ hash ] = !canUseCssTransitions[ hash ];

  							// Reset, if we're going to use timers after all
  							if ( cannotUseCssTransitions[ hash ] ) {
  								style[ prefix$1( prop ) ] = originalValue;
  							}
  						}
  					}

  					if ( !CSS_TRANSITIONS_ENABLED || cannotUseCssTransitions[ hash ] ) {
  						// we need to fall back to timer-based stuff
  						if ( originalValue === undefined ) {
  							originalValue = t.getStyle( prop );
  						}

  						// need to remove this from changedProperties, otherwise transitionEndHandler
  						// will get confused
  						index = changedProperties.indexOf( prop );
  						if ( index === -1 ) {
  							warnIfDebug( 'Something very strange happened with transitions. Please raise an issue at https://github.com/ractivejs/ractive/issues - thanks!', { node: t.node });
  						} else {
  							changedProperties.splice( index, 1 );
  						}

  						// TODO Determine whether this property is animatable at all

  						suffix = /[^\d]*$/.exec( to[ prop ] )[0];
  						interpolator = interpolate( parseFloat( originalValue ), parseFloat( to[ prop ] ) ) || ( function () { return to[ prop ]; } );

  						// ...then kick off a timer-based transition
  						propertiesToTransitionInJs.push({
  							name: prefix$1( prop ),
  							interpolator: interpolator,
  							suffix: suffix
  						});
  					}
  				}

  				// javascript transitions
  				if ( propertiesToTransitionInJs.length ) {
  					var easing;

  					if ( typeof options.easing === 'string' ) {
  						easing = t.ractive.easing[ options.easing ];

  						if ( !easing ) {
  							warnOnceIfDebug( missingPlugin( options.easing, 'easing' ) );
  							easing = linear$1;
  						}
  					} else if ( typeof options.easing === 'function' ) {
  						easing = options.easing;
  					} else {
  						easing = linear$1;
  					}

  					new Ticker({
  						duration: options.duration,
  						easing: easing,
  						step: function ( pos ) {
  							var i = propertiesToTransitionInJs.length;
  							while ( i-- ) {
  								var prop = propertiesToTransitionInJs[i];
  								t.node.style[ prop.name ] = prop.interpolator( pos ) + prop.suffix;
  							}
  						},
  						complete: function () {
  							jsTransitionsComplete = true;
  							checkComplete();
  						}
  					});
  				} else {
  					jsTransitionsComplete = true;
  				}

  				if ( !changedProperties.length ) {
  					// We need to cancel the transitionEndHandler, and deal with
  					// the fact that it will never fire
  					t.node.removeEventListener( TRANSITIONEND, transitionEndHandler, false );
  					cssTransitionsComplete = true;
  					checkComplete();
  				}
  			}, 0 );
  		}, options.delay || 0 );
  	};
  }

  var createTransitions$1 = createTransitions;

  function resetStyle ( node, style ) {
  	if ( style ) {
  		node.setAttribute( 'style', style );
  	} else {
  		// Next line is necessary, to remove empty style attribute!
  		// See http://stackoverflow.com/a/7167553
  		node.getAttribute( 'style' );
  		node.removeAttribute( 'style' );
  	}
  }

  var getComputedStyle = win && ( win.getComputedStyle || legacy.getComputedStyle );
  var resolved = Promise$1.resolve();

  var Transition = function Transition ( ractive, node, name, params, eventName ) {
  	this.ractive = ractive;
  	this.node = node;
  	this.name = name;
  	this.params = params;

  	// TODO this will need to change...
  	this.eventName = eventName;
  	this.isIntro = eventName !== 'outro';

  	if ( typeof name === 'function' ) {
  		this._fn = name;
  	}
  	else {
  		this._fn = findInViewHierarchy( 'transitions', ractive, name );

  		if ( !this._fn ) {
  			warnOnceIfDebug( missingPlugin( name, 'transition' ), { ractive: ractive });
  		}
  	}
  };

  Transition.prototype.animateStyle = function animateStyle ( style, value, options ) {
  	var this$1 = this;

  		if ( arguments.length === 4 ) {
  		throw new Error( 't.animateStyle() returns a promise - use .then() instead of passing a callback' );
  	}

  	// Special case - page isn't visible. Don't animate anything, because
  	// that way you'll never get CSS transitionend events
  	if ( !visible ) {
  		this.setStyle( style, value );
  		return resolved;
  	}

  	var to;

  	if ( typeof style === 'string' ) {
  		to = {};
  		to[ style ] = value;
  	} else {
  		to = style;

  		// shuffle arguments
  		options = value;
  	}

  	// As of 0.3.9, transition authors should supply an `option` object with
  	// `duration` and `easing` properties (and optional `delay`), plus a
  	// callback function that gets called after the animation completes

  	// TODO remove this check in a future version
  	if ( !options ) {
  		warnOnceIfDebug( 'The "%s" transition does not supply an options object to `t.animateStyle()`. This will break in a future version of Ractive. For more info see https://github.com/RactiveJS/Ractive/issues/340', this.name );
  		options = this;
  	}

  	return new Promise$1( function ( fulfil ) {
  		// Edge case - if duration is zero, set style synchronously and complete
  		if ( !options.duration ) {
  			this$1.setStyle( to );
  			fulfil();
  			return;
  		}

  		// Get a list of the properties we're animating
  		var propertyNames = Object.keys( to );
  		var changedProperties = [];

  		// Store the current styles
  		var computedStyle = getComputedStyle( this$1.node );

  		var i = propertyNames.length;
  		while ( i-- ) {
  			var prop = propertyNames[i];
  			var current = computedStyle[ prefix$1( prop ) ];

  			if ( current === '0px' ) current = 0;

  			// we need to know if we're actually changing anything
  			if ( current != to[ prop ] ) { // use != instead of !==, so we can compare strings with numbers
  				changedProperties.push( prop );

  				// make the computed style explicit, so we can animate where
  				// e.g. height='auto'
  				this$1.node.style[ prefix$1( prop ) ] = current;
  			}
  		}

  		// If we're not actually changing anything, the transitionend event
  		// will never fire! So we complete early
  		if ( !changedProperties.length ) {
  			fulfil();
  			return;
  		}

  		createTransitions$1( this$1, to, options, changedProperties, fulfil );
  	});
  };

  Transition.prototype.getStyle = function getStyle ( props ) {
  	var computedStyle = getComputedStyle( this.node );

  	if ( typeof props === 'string' ) {
  		var value = computedStyle[ prefix$1( props ) ];
  		return value === '0px' ? 0 : value;
  	}

  	if ( !isArray( props ) ) {
  		throw new Error( 'Transition$getStyle must be passed a string, or an array of strings representing CSS properties' );
  	}

  	var styles = {};

  	var i = props.length;
  	while ( i-- ) {
  		var prop = props[i];
  		var value$1 = computedStyle[ prefix$1( prop ) ];

  		if ( value$1 === '0px' ) value$1 = 0;
  		styles[ prop ] = value$1;
  	}

  	return styles;
  };

  Transition.prototype.processParams = function processParams ( params, defaults ) {
  	if ( typeof params === 'number' ) {
  		params = { duration: params };
  	}

  	else if ( typeof params === 'string' ) {
  		if ( params === 'slow' ) {
  			params = { duration: 600 };
  		} else if ( params === 'fast' ) {
  			params = { duration: 200 };
  		} else {
  			params = { duration: 400 };
  		}
  	} else if ( !params ) {
  		params = {};
  	}

  	return extendObj( {}, defaults, params );
  };

  Transition.prototype.setStyle = function setStyle ( style, value ) {
  	if ( typeof style === 'string' ) {
  		this.node.style[ prefix$1( style ) ] = value;
  	}

  	else {
  		var prop;
  		for ( prop in style ) {
  			if ( style.hasOwnProperty( prop ) ) {
  				this.node.style[ prefix$1( prop ) ] = style[ prop ];
  			}
  		}
  	}

  	return this;
  };

  Transition.prototype.start = function start () {
  	var this$1 = this;

  		var node = this.node;
  	var originalStyle = node.getAttribute( 'style' );

  	var completed;

  	// create t.complete() - we don't want this on the prototype,
  	// because we don't want `this` silliness when passing it as
  	// an argument
  	this.complete = function ( noReset ) {
  		if ( completed ) {
  			return;
  		}

  		if ( !noReset && this$1.eventName === 'intro' ) {
  			resetStyle( node, originalStyle);
  		}

  		this$1._manager.remove( this$1 );

  		completed = true;
  	};

  	// If the transition function doesn't exist, abort
  	if ( !this._fn ) {
  		this.complete();
  		return;
  	}

  	var promise = this._fn.apply( this.ractive, [ this ].concat( this.params ) );
  	if ( promise ) promise.then( this.complete );
  };

  function updateLiveQueries$1 ( element ) {
  	// Does this need to be added to any live queries?
  	var node = element.node;
  	var instance = element.ractive;

  	do {
  		var liveQueries = instance._liveQueries;

  		var i = liveQueries.length;
  		while ( i-- ) {
  			var selector = liveQueries[i];
  			var query = liveQueries[ ("_" + selector) ];

  			if ( query.test( node ) ) {
  				query.add( node );
  				// keep register of applicable selectors, for when we teardown
  				element.liveQueries.push( query );
  			}
  		}
  	} while ( instance = instance.parent );
  }

  // TODO element.parent currently undefined
  function findParentForm ( element ) {
  	while ( element = element.parent ) {
  		if ( element.name === 'form' ) {
  			return element;
  		}
  	}
  }

  function warnAboutAmbiguity ( description, ractive ) {
  	warnOnceIfDebug( ("The " + description + " being used for two-way binding is ambiguous, and may cause unexpected results. Consider initialising your data to eliminate the ambiguity"), { ractive: ractive });
  }

  var Binding = function Binding ( element, name ) {
  	if ( name === void 0 ) name = 'value';

  		this.element = element;
  	this.ractive = element.ractive;
  	this.attribute = element.attributeByName[ name ];

  	var interpolator = this.attribute.interpolator;
  	interpolator.twowayBinding = this;

  	var model = interpolator.model;

  	// not bound?
  	if ( !model ) {
  		// try to force resolution
  		interpolator.resolver.forceResolution();
  		model = interpolator.model;

  		warnAboutAmbiguity( ("'" + (interpolator.template.r) + "' reference"), this.ractive );
  	}

  	else if ( model.isUnresolved ) {
  		// reference expressions (e.g. foo[bar])
  		model.forceResolution();
  		warnAboutAmbiguity( 'expression', this.ractive );
  	}

  	// TODO include index/key/keypath refs as read-only
  		else if ( model.isReadonly ) {
  		var keypath = model.getKeypath().replace( /^@/, '' );
  			warnOnceIfDebug( ("Cannot use two-way binding on <" + (element.name) + "> element: " + keypath + " is read-only. To suppress this warning use <" + (element.name) + " twoway='false'...>"), { ractive: this.ractive });
  		return false;
  	}

  	this.attribute.isTwoway = true;
  	this.model = model;

  	// initialise value, if it's undefined
  	var value = model.get();
  	this.wasUndefined = value === undefined;

  	if ( value === undefined && this.getInitialValue ) {
  		value = this.getInitialValue();
  		model.set( value );
  	}

  	var parentForm = findParentForm( element );
  	if ( parentForm ) {
  		this.resetValue = value;
  		parentForm.formBindings.push( this );
  	}
  };

  Binding.prototype.bind = function bind () {
  	this.model.registerTwowayBinding( this );
  };

  Binding.prototype.handleChange = function handleChange () {
  	var this$1 = this;

  		runloop.start( this.root );
  	this.attribute.locked = true;
  	this.model.set( this.getValue() );
  	runloop.scheduleTask( function () { return this$1.attribute.locked = false; } );
  	runloop.end();
  };

  Binding.prototype.rebind = function rebind () {
  	// TODO what does this work with CheckboxNameBinding et al?
  	this.unbind();
  	this.model = this.attribute.interpolator.model;
  	this.bind();
  };

  Binding.prototype.render = function render () {
  	this.node = this.element.node;
  	this.node._ractive.binding = this;
  	this.rendered = true; // TODO is this used anywhere?
  };

  Binding.prototype.setFromNode = function setFromNode ( node ) {
  	this.model.set( node.value );
  };

  Binding.prototype.unbind = function unbind () {
  	this.model.unregisterTwowayBinding( this );
  };

  Binding.prototype.unrender = function unrender () {
  	// noop?
  };

  // This is the handler for DOM events that would lead to a change in the model
  // (i.e. change, sometimes, input, and occasionally click and keyup)
  function handleDomEvent () {
  	this._ractive.binding.handleChange();
  }

  var CheckboxBinding = (function (Binding) {
  	function CheckboxBinding ( element ) {
  		Binding.call( this, element, 'checked' );
  	}

  	CheckboxBinding.prototype = Object.create( Binding && Binding.prototype );
  	CheckboxBinding.prototype.constructor = CheckboxBinding;

  	CheckboxBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		this.node.addEventListener( 'change', handleDomEvent, false );

  		if ( this.node.attachEvent ) {
  			this.node.addEventListener( 'click', handleDomEvent, false );
  		}
  	};

  	CheckboxBinding.prototype.unrender = function unrender () {
  		this.node.removeEventListener( 'change', handleDomEvent, false );
  		this.node.removeEventListener( 'click', handleDomEvent, false );
  	};

  	CheckboxBinding.prototype.getInitialValue = function getInitialValue () {
  		return !!this.element.getAttribute( 'checked' );
  	};

  	CheckboxBinding.prototype.getValue = function getValue () {
  		return this.node.checked;
  	};

  	CheckboxBinding.prototype.setFromNode = function setFromNode ( node ) {
  		this.model.set( node.checked );
  	};

  	return CheckboxBinding;
  }(Binding));

  function getBindingGroup ( group, model, getValue ) {
  	var hash = "" + group + "-bindingGroup";
  	return model[hash] || ( model[ hash ] = new BindingGroup( hash, model, getValue ) );
  }

  var BindingGroup = function BindingGroup ( hash, model, getValue ) {
  	var this$1 = this;

  		this.model = model;
  	this.hash = hash;
  	this.getValue = function () {
  		this$1.value = getValue.call(this$1);
  		return this$1.value;
  	};

  	this.bindings = [];
  };

  BindingGroup.prototype.add = function add ( binding ) {
  	this.bindings.push( binding );
  };

  BindingGroup.prototype.bind = function bind () {
  	this.value = this.model.get();
  		this.model.registerTwowayBinding( this );
  	this.bound = true;
  };

  BindingGroup.prototype.remove = function remove ( binding ) {
  	removeFromArray( this.bindings, binding );
  	if ( !this.bindings.length ) {
  		this.unbind();
  	}
  };

  BindingGroup.prototype.unbind = function unbind () {
  	this.model.unregisterTwowayBinding( this );
  	this.bound = false;
  	delete this.model[this.hash];
  };

  var push$2 = [].push;

  function getValue$1() {
  	var all = this.bindings.filter(function ( b ) { return b.node && b.node.checked; }).map(function ( b ) { return b.element.getAttribute( 'value' ); });
  	var res = [];
  	all.forEach(function ( v ) { if ( !arrayContains( res, v ) ) res.push( v ); });
  	return res;
  }

  var CheckboxNameBinding = (function (Binding) {
  	function CheckboxNameBinding ( element ) {
  		Binding.call( this, element, 'name' );

  		this.checkboxName = true; // so that ractive.updateModel() knows what to do with this

  		// Each input has a reference to an array containing it and its
  		// group, as two-way binding depends on being able to ascertain
  		// the status of all inputs within the group
  		this.group = getBindingGroup( 'checkboxes', this.model, getValue$1 );
  		this.group.add( this );

  		if ( this.noInitialValue ) {
  			this.group.noInitialValue = true;
  		}

  		// If no initial value was set, and this input is checked, we
  		// update the model
  		if ( this.group.noInitialValue && this.element.getAttribute( 'checked' ) ) {
  			var existingValue = this.model.get();
  			var bindingValue = this.element.getAttribute( 'value' );

  			if ( !arrayContains( existingValue, bindingValue ) ) {
  				push$2.call( existingValue, bindingValue ); // to avoid triggering runloop with array adaptor
  			}
  		}
  	}

  	CheckboxNameBinding.prototype = Object.create( Binding && Binding.prototype );
  	CheckboxNameBinding.prototype.constructor = CheckboxNameBinding;

  	CheckboxNameBinding.prototype.bind = function bind () {
  		if ( !this.group.bound ) {
  			this.group.bind();
  		}
  	};

  	CheckboxNameBinding.prototype.changed = function changed () {
  		var wasChecked = !!this.isChecked;
  		this.isChecked = this.node.checked;
  		return this.isChecked === wasChecked;
  	};

  	CheckboxNameBinding.prototype.getInitialValue = function getInitialValue () {
  		// This only gets called once per group (of inputs that
  		// share a name), because it only gets called if there
  		// isn't an initial value. By the same token, we can make
  		// a note of that fact that there was no initial value,
  		// and populate it using any `checked` attributes that
  		// exist (which users should avoid, but which we should
  		// support anyway to avoid breaking expectations)
  		this.noInitialValue = true; // TODO are noInitialValue and wasUndefined the same thing?
  		return [];
  	};

  	CheckboxNameBinding.prototype.getValue = function getValue$1 () {
  		return this.group.value;
  	};

  	CheckboxNameBinding.prototype.handleChange = function handleChange () {
  		this.isChecked = this.element.node.checked;
  		this.group.value = this.model.get();
  		var value = this.element.getAttribute( 'value' );
  		if ( this.isChecked && !arrayContains( this.group.value, value ) ) {
  			this.group.value.push( value );
  		} else if ( !this.isChecked && arrayContains( this.group.value, value ) ) {
  			removeFromArray( this.group.value, value );
  		}
  		Binding.prototype.handleChange.call(this);
  	};

  	CheckboxNameBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		var node = this.node;

  		var existingValue = this.model.get();
  		var bindingValue = this.element.getAttribute( 'value' );

  		if ( isArray( existingValue ) ) {
  			this.isChecked = arrayContains( existingValue, bindingValue );
  		} else {
  			this.isChecked = existingValue == bindingValue;
  		}

  		node.name = '{{' + this.model.getKeypath() + '}}';
  		node.checked = this.isChecked;

  		node.addEventListener( 'change', handleDomEvent, false );

  		// in case of IE emergency, bind to click event as well
  		if ( node.attachEvent ) {
  			node.addEventListener( 'click', handleDomEvent, false );
  		}
  	};

  	CheckboxNameBinding.prototype.setFromNode = function setFromNode ( node ) {
  		this.group.bindings.forEach( function ( binding ) { return binding.wasUndefined = true; } );

  		if ( node.checked ) {
  			var valueSoFar = this.group.getValue();
  			valueSoFar.push( this.element.getAttribute( 'value' ) );

  			this.group.model.set( valueSoFar );
  		}
  	};

  	CheckboxNameBinding.prototype.unbind = function unbind () {
  		this.group.remove( this );
  	};

  	CheckboxNameBinding.prototype.unrender = function unrender () {
  		var node = this.element.node;

  		node.removeEventListener( 'change', handleDomEvent, false );
  		node.removeEventListener( 'click', handleDomEvent, false );
  	};

  	return CheckboxNameBinding;
  }(Binding));

  var ContentEditableBinding = (function (Binding) {
  	function ContentEditableBinding () {
  		Binding.apply(this, arguments);
  	}

  	ContentEditableBinding.prototype = Object.create( Binding && Binding.prototype );
  	ContentEditableBinding.prototype.constructor = ContentEditableBinding;

  	ContentEditableBinding.prototype.getInitialValue = function getInitialValue () {
  		return this.element.fragment ? this.element.fragment.toString() : '';
  	};

  	ContentEditableBinding.prototype.getValue = function getValue () {
  		return this.element.node.innerHTML;
  	};

  	ContentEditableBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		var node = this.node;

  		node.addEventListener( 'change', handleDomEvent, false );
  		node.addEventListener( 'blur', handleDomEvent, false );

  		if ( !this.ractive.lazy ) {
  			node.addEventListener( 'input', handleDomEvent, false );

  			if ( node.attachEvent ) {
  				node.addEventListener( 'keyup', handleDomEvent, false );
  			}
  		}
  	};

  	ContentEditableBinding.prototype.setFromNode = function setFromNode ( node ) {
  		this.model.set( node.innerHTML );
  	};

  	ContentEditableBinding.prototype.unrender = function unrender () {
  		var node = this.node;

  		node.removeEventListener( 'blur', handleDomEvent, false );
  		node.removeEventListener( 'change', handleDomEvent, false );
  		node.removeEventListener( 'input', handleDomEvent, false );
  		node.removeEventListener( 'keyup', handleDomEvent, false );
  	};

  	return ContentEditableBinding;
  }(Binding));

  function handleBlur () {
  	handleDomEvent.call( this );

  	var value = this._ractive.binding.model.get();
  	this.value = value == undefined ? '' : value;
  }

  function handleDelay ( delay ) {
  	var timeout;

  	return function () {
  		var this$1 = this;

  		if ( timeout ) clearTimeout( timeout );

  		timeout = setTimeout( function () {
  			var binding = this$1._ractive.binding;
  			if ( binding.rendered ) handleDomEvent.call( this$1 );
  			timeout = null;
  		}, delay );
  	};
  }

  var GenericBinding = (function (Binding) {
  	function GenericBinding () {
  		Binding.apply(this, arguments);
  	}

  	GenericBinding.prototype = Object.create( Binding && Binding.prototype );
  	GenericBinding.prototype.constructor = GenericBinding;

  	GenericBinding.prototype.getInitialValue = function getInitialValue () {
  		return '';
  	};

  	GenericBinding.prototype.getValue = function getValue () {
  		return this.node.value;
  	};

  	GenericBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		// any lazy setting for this element overrides the root
  		// if the value is a number, it's a timeout
  		var lazy = this.ractive.lazy;
  		var timeout = false;

  		// TODO handle at parse time
  		if ( this.element.template.a && ( 'lazy' in this.element.template.a ) ) {
  			lazy = this.element.template.a.lazy;
  			if ( lazy === 0 ) lazy = true; // empty attribute
  		}

  		// TODO handle this at parse time as well?
  		if ( lazy === 'false' ) lazy = false;

  		if ( isNumeric( lazy ) ) {
  			timeout = +lazy;
  			lazy = false;
  		}

  		this.handler = timeout ? handleDelay( timeout ) : handleDomEvent;

  		var node = this.node;

  		node.addEventListener( 'change', handleDomEvent, false );

  		if ( !lazy ) {
  			node.addEventListener( 'input', this.handler, false );

  			if ( node.attachEvent ) {
  				node.addEventListener( 'keyup', this.handler, false );
  			}
  		}

  		node.addEventListener( 'blur', handleBlur, false );
  	};

  	GenericBinding.prototype.unrender = function unrender () {
  		var node = this.element.node;
  		this.rendered = false;

  		node.removeEventListener( 'change', handleDomEvent, false );
  		node.removeEventListener( 'input', this.handler, false );
  		node.removeEventListener( 'keyup', this.handler, false );
  		node.removeEventListener( 'blur', handleBlur, false );
  	};

  	return GenericBinding;
  }(Binding));

  function getSelectedOptions ( select ) {
      return select.selectedOptions
  		? toArray( select.selectedOptions )
  		: select.options
  			? toArray( select.options ).filter( function ( option ) { return option.selected; } )
  			: [];
  }

  var MultipleSelectBinding = (function (Binding) {
  	function MultipleSelectBinding () {
  		Binding.apply(this, arguments);
  	}

  	MultipleSelectBinding.prototype = Object.create( Binding && Binding.prototype );
  	MultipleSelectBinding.prototype.constructor = MultipleSelectBinding;

  	MultipleSelectBinding.prototype.forceUpdate = function forceUpdate () {
  		var this$1 = this;

  		var value = this.getValue();

  		if ( value !== undefined ) {
  			this.attribute.locked = true;
  			runloop.scheduleTask( function () { return this$1.attribute.locked = false; } );
  			this.model.set( value );
  		}
  	};

  	MultipleSelectBinding.prototype.getInitialValue = function getInitialValue () {
  		return this.element.options
  			.filter( function ( option ) { return option.getAttribute( 'selected' ); } )
  			.map( function ( option ) { return option.getAttribute( 'value' ); } );
  	};

  	MultipleSelectBinding.prototype.getValue = function getValue () {
  		var options = this.element.node.options;
  		var len = options.length;

  		var selectedValues = [];

  		for ( var i = 0; i < len; i += 1 ) {
  			var option = options[i];

  			if ( option.selected ) {
  				var optionValue = option._ractive ? option._ractive.value : option.value;
  				selectedValues.push( optionValue );
  			}
  		}

  		return selectedValues;
  	};

  	MultipleSelectBinding.prototype.handleChange = function handleChange () {
  		var attribute = this.attribute;
  		var previousValue = attribute.getValue();

  		var value = this.getValue();

  		if ( previousValue === undefined || !arrayContentsMatch( value, previousValue ) ) {
  			Binding.prototype.handleChange.call(this);
  		}

  		return this;
  	};

  	MultipleSelectBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		this.node.addEventListener( 'change', handleDomEvent, false );

  		if ( this.model.get() === undefined ) {
  			// get value from DOM, if possible
  			this.handleChange();
  		}
  	};

  	MultipleSelectBinding.prototype.setFromNode = function setFromNode ( node ) {
  		var selectedOptions = getSelectedOptions( node );
  		var i = selectedOptions.length;
  		var result = new Array( i );

  		while ( i-- ) {
  			var option = selectedOptions[i];
  			result[i] = option._ractive ? option._ractive.value : option.value;
  		}

  		this.model.set( result );
  	};

  	MultipleSelectBinding.prototype.setValue = function setValue () {
  		throw new Error( 'TODO not implemented yet' );
  	};

  	MultipleSelectBinding.prototype.unrender = function unrender () {
  		this.node.removeEventListener( 'change', handleDomEvent, false );
  	};

  	MultipleSelectBinding.prototype.updateModel = function updateModel () {
  		if ( this.attribute.value === undefined || !this.attribute.value.length ) {
  			this.keypath.set( this.initialValue );
  		}
  	};

  	return MultipleSelectBinding;
  }(Binding));

  var NumericBinding = (function (GenericBinding) {
  	function NumericBinding () {
  		GenericBinding.apply(this, arguments);
  	}

  	NumericBinding.prototype = Object.create( GenericBinding && GenericBinding.prototype );
  	NumericBinding.prototype.constructor = NumericBinding;

  	NumericBinding.prototype.getInitialValue = function getInitialValue () {
  		return undefined;
  	};

  	NumericBinding.prototype.getValue = function getValue () {
  		var value = parseFloat( this.node.value );
  		return isNaN( value ) ? undefined : value;
  	};

  	NumericBinding.prototype.setFromNode = function setFromNode( node ) {
  		var value = parseFloat( node.value );
  		if ( !isNaN( value ) ) this.model.set( value );
  	};

  	return NumericBinding;
  }(GenericBinding));

  var siblings = {};

  function getSiblings ( hash ) {
  	return siblings[ hash ] || ( siblings[ hash ] = [] );
  }

  var RadioBinding = (function (Binding) {
  	function RadioBinding ( element ) {
  		Binding.call( this, element, 'checked' );

  		this.siblings = getSiblings( this.ractive._guid + this.element.getAttribute( 'name' ) );
  		this.siblings.push( this );
  	}

  	RadioBinding.prototype = Object.create( Binding && Binding.prototype );
  	RadioBinding.prototype.constructor = RadioBinding;

  	RadioBinding.prototype.getValue = function getValue () {
  		return this.node.checked;
  	};

  	RadioBinding.prototype.handleChange = function handleChange () {
  		runloop.start( this.root );

  		this.siblings.forEach( function ( binding ) {
  			binding.model.set( binding.getValue() );
  		});

  		runloop.end();
  	};

  	RadioBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		this.node.addEventListener( 'change', handleDomEvent, false );

  		if ( this.node.attachEvent ) {
  			this.node.addEventListener( 'click', handleDomEvent, false );
  		}
  	};

  	RadioBinding.prototype.setFromNode = function setFromNode ( node ) {
  		this.model.set( node.checked );
  	};

  	RadioBinding.prototype.unbind = function unbind () {
  		removeFromArray( this.siblings, this );
  	};

  	RadioBinding.prototype.unrender = function unrender () {
  		this.node.removeEventListener( 'change', handleDomEvent, false );
  		this.node.removeEventListener( 'click', handleDomEvent, false );
  	};

  	return RadioBinding;
  }(Binding));

  function getValue$2() {
  	var checked = this.bindings.filter( function ( b ) { return b.node.checked; } );
  	if ( checked.length > 0 ) {
  		return checked[0].element.getAttribute( 'value' );
  	}
  }

  var RadioNameBinding = (function (Binding) {
  	function RadioNameBinding ( element ) {
  		Binding.call( this, element, 'name' );

  		this.group = getBindingGroup( 'radioname', this.model, getValue$2 );
  		this.group.add( this );

  		if ( element.checked ) {
  			this.group.value = this.getValue();
  		}
  	}

  	RadioNameBinding.prototype = Object.create( Binding && Binding.prototype );
  	RadioNameBinding.prototype.constructor = RadioNameBinding;

  	RadioNameBinding.prototype.bind = function bind () {
  		var this$1 = this;

  		if ( !this.group.bound ) {
  			this.group.bind();
  		}

  		// update name keypath when necessary
  		this.nameAttributeBinding = {
  			handleChange: function () { return this$1.node.name = "{{" + (this$1.model.getKeypath()) + "}}"; }
  		};

  		this.model.getKeypathModel().register( this.nameAttributeBinding );
  	};

  	RadioNameBinding.prototype.getInitialValue = function getInitialValue () {
  		if ( this.element.getAttribute( 'checked' ) ) {
  			return this.element.getAttribute( 'value' );
  		}
  	};

  	RadioNameBinding.prototype.getValue = function getValue$1 () {
  		return this.element.getAttribute( 'value' );
  	};

  	RadioNameBinding.prototype.handleChange = function handleChange () {
  		// If this <input> is the one that's checked, then the value of its
  		// `name` model gets set to its value
  		if ( this.node.checked ) {
  			this.group.value = this.getValue();
  			Binding.prototype.handleChange.call(this);
  		}
  	};

  	RadioNameBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);

  		var node = this.node;

  		node.name = "{{" + (this.model.getKeypath()) + "}}";
  		node.checked = this.model.get() == this.element.getAttribute( 'value' );

  		node.addEventListener( 'change', handleDomEvent, false );

  		if ( node.attachEvent ) {
  			node.addEventListener( 'click', handleDomEvent, false );
  		}
  	};

  	RadioNameBinding.prototype.setFromNode = function setFromNode ( node ) {
  		if ( node.checked ) {
  			this.group.model.set( this.element.getAttribute( 'value' ) );
  		}
  	};

  	RadioNameBinding.prototype.unbind = function unbind () {
  		this.group.remove( this );

  		this.model.getKeypathModel().unregister( this.nameAttributeBinding );
  	};

  	RadioNameBinding.prototype.unrender = function unrender () {
  		var node = this.node;

  		node.removeEventListener( 'change', handleDomEvent, false );
  		node.removeEventListener( 'click', handleDomEvent, false );
  	};

  	return RadioNameBinding;
  }(Binding));

  var SingleSelectBinding = (function (Binding) {
  	function SingleSelectBinding () {
  		Binding.apply(this, arguments);
  	}

  	SingleSelectBinding.prototype = Object.create( Binding && Binding.prototype );
  	SingleSelectBinding.prototype.constructor = SingleSelectBinding;

  	SingleSelectBinding.prototype.forceUpdate = function forceUpdate () {
  		var this$1 = this;

  		var value = this.getValue();

  		if ( value !== undefined ) {
  			this.attribute.locked = true;
  			runloop.scheduleTask( function () { return this$1.attribute.locked = false; } );
  			this.model.set( value );
  		}
  	};

  	SingleSelectBinding.prototype.getInitialValue = function getInitialValue () {
  		if ( this.element.getAttribute( 'value' ) !== undefined ) {
  			return;
  		}

  		var options = this.element.options;
  		var len = options.length;

  		if ( !len ) return;

  		var value;
  		var optionWasSelected;
  		var i = len;

  		// take the final selected option...
  		while ( i-- ) {
  			var option = options[i];

  			if ( option.getAttribute( 'selected' ) ) {
  				if ( !option.getAttribute( 'disabled' ) ) {
  					value = option.getAttribute( 'value' );
  				}

  				optionWasSelected = true;
  				break;
  			}
  		}

  		// or the first non-disabled option, if none are selected
  		if ( !optionWasSelected ) {
  			while ( ++i < len ) {
  				if ( !options[i].getAttribute( 'disabled' ) ) {
  					value = options[i].getAttribute( 'value' );
  					break;
  				}
  			}
  		}

  		// This is an optimisation (aka hack) that allows us to forgo some
  		// other more expensive work
  		// TODO does it still work? seems at odds with new architecture
  		if ( value !== undefined ) {
  			this.element.attributeByName.value.value = value;
  		}

  		return value;
  	};

  	SingleSelectBinding.prototype.getValue = function getValue () {
  		var options = this.node.options;
  		var len = options.length;

  		var i;
  		for ( i = 0; i < len; i += 1 ) {
  			var option = options[i];

  			if ( options[i].selected && !options[i].disabled ) {
  				return option._ractive ? option._ractive.value : option.value;
  			}
  		}
  	};

  	SingleSelectBinding.prototype.render = function render () {
  		Binding.prototype.render.call(this);
  		this.node.addEventListener( 'change', handleDomEvent, false );
  	};

  	SingleSelectBinding.prototype.setFromNode = function setFromNode ( node ) {
  		var option = getSelectedOptions( node )[0];
  		this.model.set( option._ractive ? option._ractive.value : option.value );
  	};

  	// TODO this method is an anomaly... is it necessary?
  	SingleSelectBinding.prototype.setValue = function setValue ( value ) {
  		this.model.set( value );
  	};

  	SingleSelectBinding.prototype.unrender = function unrender () {
  		this.node.removeEventListener( 'change', handleDomEvent, false );
  	};

  	return SingleSelectBinding;
  }(Binding));

  function isBindable ( attribute ) {
  	return attribute &&
  	       attribute.template.length === 1 &&
  	       attribute.template[0].t === INTERPOLATOR &&
  	       !attribute.template[0].s;
  }

  function selectBinding ( element ) {
  	var attributes = element.attributeByName;

  	// contenteditable - bind if the contenteditable attribute is true
  	// or is bindable and may thus become true...
  	if ( element.getAttribute( 'contenteditable' ) || isBindable( attributes.contenteditable ) ) {
  		// ...and this element also has a value attribute to bind
  		return isBindable( attributes.value ) ? ContentEditableBinding : null;
  	}

  	// <input>
  	if ( element.name === 'input' ) {
  		var type = element.getAttribute( 'type' );

  		if ( type === 'radio' || type === 'checkbox' ) {
  			var bindName = isBindable( attributes.name );
  			var bindChecked = isBindable( attributes.checked );

  			// for radios we can either bind the name attribute, or the checked attribute - not both
  			if ( bindName && bindChecked ) {
  				if ( type === 'radio' ) {
  					warnIfDebug( 'A radio input can have two-way binding on its name attribute, or its checked attribute - not both', { ractive: element.root });
  				} else {
  					// A checkbox with bindings for both name and checked - see https://github.com/ractivejs/ractive/issues/1749
  					return CheckboxBinding;
  				}
  			}

  			if ( bindName ) {
  				return type === 'radio' ? RadioNameBinding : CheckboxNameBinding;
  			}

  			if ( bindChecked ) {
  				return type === 'radio' ? RadioBinding : CheckboxBinding;
  			}
  		}

  		if ( type === 'file' && isBindable( attributes.value ) ) {
  			return Binding;
  		}

  		if ( isBindable( attributes.value ) ) {
  			return ( type === 'number' || type === 'range' ) ? NumericBinding : GenericBinding;
  		}

  		return null;
  	}

  	// <select>
  	if ( element.name === 'select' && isBindable( attributes.value ) ) {
  		return element.getAttribute( 'multiple' ) ? MultipleSelectBinding : SingleSelectBinding;
  	}

  	// <textarea>
  	if ( element.name === 'textarea' && isBindable( attributes.value ) ) {
  		return GenericBinding;
  	}
  }

  function makeDirty$1 ( query ) {
  	query.makeDirty();
  }

  var endsWithSemi = /;\s*$/;

  var Element = (function (Item) {
  	function Element ( options ) {
  		var this$1 = this;

  		Item.call( this, options );

  		this.liveQueries = []; // TODO rare case. can we handle differently?

  		this.name = options.template.e.toLowerCase();
  		this.isVoid = voidElementNames.test( this.name );

  		// find parent element
  		var fragment = this.parentFragment;
  		while ( fragment ) {
  			if ( fragment.owner.type === ELEMENT ) {
  				this$1.parent = fragment.owner;
  				break;
  			}
  			fragment = fragment.parent;
  		}

  		if ( this.parent && this.parent.name === 'option' ) {
  			throw new Error( ("An <option> element cannot contain other elements (encountered <" + (this.name) + ">)") );
  		}

  		// create attributes
  		this.attributeByName = {};
  		this.attributes = [];

  		if ( this.template.a ) {
  			Object.keys( this.template.a ).forEach( function ( name ) {
  				// TODO process this at parse time
  				if ( name === 'twoway' || name === 'lazy' ) return;

  				var attribute = new Attribute({
  					name: name,
  					element: this$1,
  					parentFragment: this$1.parentFragment,
  					template: this$1.template.a[ name ]
  				});

  				this$1.attributeByName[ name ] = attribute;

  				if ( name !== 'value' && name !== 'type' ) this$1.attributes.push( attribute );
  			});

  			if ( this.attributeByName.type ) this.attributes.unshift( this.attributeByName.type );
  			if ( this.attributeByName.value ) this.attributes.push( this.attributeByName.value );
  		}

  		// create conditional attributes
  		this.conditionalAttributes = ( this.template.m || [] ).map( function ( template ) {
  			return new ConditionalAttribute({
  				owner: this$1,
  				parentFragment: this$1.parentFragment,
  				template: template
  			});
  		});

  		// create decorator
  		if ( this.template.o ) {
  			this.decorator = new Decorator( this, this.template.o );
  		}

  		// attach event handlers
  		this.eventHandlers = [];
  		if ( this.template.v ) {
  			Object.keys( this.template.v ).forEach( function ( key ) {
  				var eventNames = key.split( '-' );
  				var template = this$1.template.v[ key ];

  				eventNames.forEach( function ( eventName ) {
  					var fn = findInViewHierarchy( 'events', this$1.ractive, eventName );
  					// we need to pass in "this" in order to get
  					// access to node when it is created.
  					var event = fn ? new CustomEvent( fn, this$1 ) : new DOMEvent( eventName, this$1 );
  					this$1.eventHandlers.push( new EventDirective( this$1, event, template ) );
  				});
  			});
  		}

  		// create children
  		if ( options.template.f && !options.noContent ) {
  			this.fragment = new Fragment({
  				template: options.template.f,
  				owner: this,
  				cssIds: null
  			});
  		}

  		this.binding = null; // filled in later
  	}

  	Element.prototype = Object.create( Item && Item.prototype );
  	Element.prototype.constructor = Element;

  	Element.prototype.bind = function bind$1 () {
  		this.attributes.forEach( bind );
  		this.conditionalAttributes.forEach( bind );
  		this.eventHandlers.forEach( bind );

  		if ( this.decorator ) this.decorator.bind();
  		if ( this.fragment ) this.fragment.bind();

  		// create two-way binding if necessary
  		if ( this.binding = this.createTwowayBinding() ) this.binding.bind();
  	};

  	Element.prototype.createTwowayBinding = function createTwowayBinding () {
  		var attributes = this.template.a;

  		if ( !attributes ) return null;

  		var shouldBind = 'twoway' in attributes ?
  			attributes.twoway === 0 || attributes.twoway === 'true' : // covers `twoway` and `twoway='true'`
  			this.ractive.twoway;

  		if ( !shouldBind ) return null;

  		var Binding = selectBinding( this );

  		if ( !Binding ) return null;

  		var binding = new Binding( this );

  		return binding && binding.model ?
  			binding :
  			null;
  	};

  	Element.prototype.detach = function detach () {
  		if ( this.decorator ) this.decorator.unrender();
  		return detachNode( this.node );
  	};

  	Element.prototype.find = function find ( selector ) {
  		if ( matches( this.node, selector ) ) return this.node;
  		if ( this.fragment ) {
  			return this.fragment.find( selector );
  		}
  	};

  	Element.prototype.findAll = function findAll ( selector, query ) {
  		// Add this node to the query, if applicable, and register the
  		// query on this element
  		var matches = query.test( this.node );
  		if ( matches ) {
  			query.add( this.node );
  			if ( query.live ) this.liveQueries.push( query );
  		}

  		if ( this.fragment ) {
  			this.fragment.findAll( selector, query );
  		}
  	};

  	Element.prototype.findComponent = function findComponent ( name ) {
  		if ( this.fragment ) {
  			return this.fragment.findComponent( name );
  		}
  	};

  	Element.prototype.findAllComponents = function findAllComponents ( name, query ) {
  		if ( this.fragment ) {
  			this.fragment.findAllComponents( name, query );
  		}
  	};

  	Element.prototype.findNextNode = function findNextNode () {
  		return null;
  	};

  	Element.prototype.firstNode = function firstNode () {
  		return this.node;
  	};

  	Element.prototype.getAttribute = function getAttribute ( name ) {
  		var attribute = this.attributeByName[ name ];
  		return attribute ? attribute.getValue() : undefined;
  	};

  	Element.prototype.rebind = function rebind$1 () {
  		this.attributes.forEach( rebind );
  		this.conditionalAttributes.forEach( rebind );
  		this.eventHandlers.forEach( rebind );
  		if ( this.decorator ) this.decorator.rebind();
  		if ( this.fragment ) this.fragment.rebind();
  		if ( this.binding ) this.binding.rebind();

  		this.liveQueries.forEach( makeDirty$1 );
  	};

  	Element.prototype.render = function render$1 ( target, occupants ) {
  		// TODO determine correct namespace
  		var this$1 = this;

  		this.namespace = getNamespace( this );

  		var node;
  		var existing = false;

  		if ( occupants ) {
  			var n;
  			while ( ( n = occupants.shift() ) ) {
  				if ( n.nodeName.toUpperCase() === this$1.template.e.toUpperCase() && n.namespaceURI === this$1.namespace ) {
  					this$1.node = node = n;
  					existing = true;
  					break;
  				} else {
  					detachNode( n );
  				}
  			}
  		}

  		if ( !node ) {
  			node = createElement( this.template.e, this.namespace, this.getAttribute( 'is' ) );
  			this.node = node;
  		}

  		defineProperty( node, '_ractive', {
  			value: {
  				proxy: this
  			}
  		});

  		// Is this a top-level node of a component? If so, we may need to add
  		// a data-ractive-css attribute, for CSS encapsulation
  		if ( this.parentFragment.cssIds ) {
  			node.setAttribute( 'data-ractive-css', this.parentFragment.cssIds.map( function ( x ) { return ("{" + x + "}"); } ).join( ' ' ) );
  		}

  		if ( existing && this.foundNode ) this.foundNode( node );

  		if ( this.fragment ) {
  			var children = existing ? toArray( node.childNodes ) : undefined;
  			this.fragment.render( node, children );

  			// clean up leftover children
  			if ( children ) {
  				children.forEach( detachNode );
  			}
  		}

  		if ( existing ) {
  			// store initial values for two-way binding
  			if ( this.binding && this.binding.wasUndefined ) this.binding.setFromNode( node );

  			// remove unused attributes
  			var i = node.attributes.length;
  			while ( i-- ) {
  				var name = node.attributes[i].name;
  				if ( !this$1.template.a || !( name in this$1.template.a ) ) node.removeAttribute( name );
  			}
  		}

  		this.attributes.forEach( render );
  		this.conditionalAttributes.forEach( render );

  		if ( this.decorator ) runloop.scheduleTask( function () { return this$1.decorator.render(); }, true );
  		if ( this.binding ) this.binding.render();

  		this.eventHandlers.forEach( render );

  		updateLiveQueries$1( this );

  		// store so we can abort if it gets removed
  		this._introTransition = getTransition( this, this.template.t0 || this.template.t1, 'intro' );

  		if ( !existing ) {
  			target.appendChild( node );
  		}

  		this.rendered = true;
  	};

  	Element.prototype.toString = function toString () {
  		var tagName = this.template.e;

  		var attrs = this.attributes.map( stringifyAttribute ).join( '' ) +
  		            this.conditionalAttributes.map( stringifyAttribute ).join( '' );

  		// Special case - selected options
  		if ( this.name === 'option' && this.isSelected() ) {
  			attrs += ' selected';
  		}

  		// Special case - two-way radio name bindings
  		if ( this.name === 'input' && inputIsCheckedRadio( this ) ) {
  			attrs += ' checked';
  		}

  		// Special case style and class attributes and directives
  		var style, cls;
  		this.attributes.forEach( function ( attr ) {
  			if ( attr.name === 'class' ) {
  				cls = ( cls || '' ) + ( cls ? ' ' : '' ) + safeAttributeString( attr.getString() );
  			} else if ( attr.name === 'style' ) {
  				style = ( style || '' ) + ( style ? ' ' : '' ) + safeAttributeString( attr.getString() );
  				if ( style && !endsWithSemi.test( style ) ) style += ';';
  			} else if ( attr.styleName ) {
  				style = ( style || '' ) + ( style ? ' ' : '' ) +  "" + (decamelize( attr.styleName )) + ": " + (safeAttributeString( attr.getString() )) + ";";
  			} else if ( attr.inlineClass && attr.getValue() ) {
  				cls = ( cls || '' ) + ( cls ? ' ' : '' ) + attr.inlineClass;
  			}
  		});
  		// put classes first, then inline style
  		if ( style !== undefined ) attrs = ' style' + ( style ? ("=\"" + style + "\"") : '' ) + attrs;
  		if ( cls !== undefined ) attrs = ' class' + (cls ? ("=\"" + cls + "\"") : '') + attrs;

  		var str = "<" + tagName + "" + attrs + ">";

  		if ( this.isVoid ) return str;

  		// Special case - textarea
  		if ( this.name === 'textarea' && this.getAttribute( 'value' ) !== undefined ) {
  			str += escapeHtml( this.getAttribute( 'value' ) );
  		}

  		// Special case - contenteditable
  		else if ( this.getAttribute( 'contenteditable' ) !== undefined ) {
  			str += ( this.getAttribute( 'value' ) || '' );
  		}

  		if ( this.fragment ) {
  			str += this.fragment.toString( !/^(?:script|style)$/i.test( this.template.e ) ); // escape text unless script/style
  		}

  		str += "</" + tagName + ">";
  		return str;
  	};

  	Element.prototype.unbind = function unbind$1 () {
  		this.attributes.forEach( unbind );
  		this.conditionalAttributes.forEach( unbind );

  		if ( this.decorator ) this.decorator.unbind();
  		if ( this.fragment ) this.fragment.unbind();
  	};

  	Element.prototype.unrender = function unrender$1 ( shouldDestroy ) {
  		if ( !this.rendered ) return;
  		this.rendered = false;

  		// unrendering before intro completed? complete it now
  		// TODO should be an API for aborting transitions
  		var transition = this._introTransition;
  		if ( transition ) transition.complete();

  		// Detach as soon as we can
  		if ( this.name === 'option' ) {
  			// <option> elements detach immediately, so that
  			// their parent <select> element syncs correctly, and
  			// since option elements can't have transitions anyway
  			this.detach();
  		} else if ( shouldDestroy ) {
  			runloop.detachWhenReady( this );
  		}

  		if ( this.fragment ) this.fragment.unrender();

  		this.eventHandlers.forEach( unrender );

  		if ( this.binding ) this.binding.unrender();
  		if ( !shouldDestroy && this.decorator ) this.decorator.unrender();

  		// outro transition
  		getTransition( this, this.template.t0 || this.template.t2, 'outro' );

  		// special case
  		var id = this.attributeByName.id;
  		if ( id  ) {
  			delete this.ractive.nodes[ id.getValue() ];
  		}

  		removeFromLiveQueries( this );
  		// TODO forms are a special case
  	};

  	Element.prototype.update = function update$1 () {
  		if ( this.dirty ) {
  			this.dirty = false;

  			this.attributes.forEach( update );
  			this.conditionalAttributes.forEach( update );
  			this.eventHandlers.forEach( update );

  			if ( this.decorator ) this.decorator.update();
  			if ( this.fragment ) this.fragment.update();
  		}
  	};

  	return Element;
  }(Item));

  function getTransition( owner, template, eventName ) {
  	if ( !template || !owner.ractive.transitionsEnabled ) return;

  	var name = getTransitionName( owner, template );
  	if ( !name ) return;

  	var params = getTransitionParams( owner, template );
  	var transition = new Transition( owner.ractive, owner.node, name, params, eventName );
  	runloop.registerTransition( transition );
  	return transition;
  }

  function getTransitionName ( owner, template ) {
  	var name = template.n || template;

  	if ( typeof name === 'string' ) return name;

  	var fragment = new Fragment({
  		owner: owner,
  		template: name
  	}).bind(); // TODO need a way to capture values without bind()

  	name = fragment.toString();
  	fragment.unbind();

  	return name;
  }

  function getTransitionParams ( owner, template ) {
  	if ( template.a ) return template.a;
  	if ( !template.d )  return;

  	// TODO is there a way to interpret dynamic arguments without all the
  	// 'dependency thrashing'?
  	var fragment = new Fragment({
  		owner: owner,
  		template: template.d
  	}).bind();

  	var params = fragment.getArgsList();
  	fragment.unbind();

  	return params;
  }

  function inputIsCheckedRadio ( element ) {
  	var attributes = element.attributeByName;

  	var typeAttribute  = attributes.type;
  	var valueAttribute = attributes.value;
  	var nameAttribute  = attributes.name;

  	if ( !typeAttribute || ( typeAttribute.value !== 'radio' ) || !valueAttribute || !nameAttribute.interpolator ) {
  		return;
  	}

  	if ( valueAttribute.getValue() === nameAttribute.interpolator.model.get() ) {
  		return true;
  	}
  }

  function stringifyAttribute ( attribute ) {
  	var str = attribute.toString();
  	return str ? ' ' + str : '';
  }

  function removeFromLiveQueries ( element ) {
  	var i = element.liveQueries.length;
  	while ( i-- ) {
  		var query = element.liveQueries[i];
  		query.remove( element.node );
  	}
  }

  function getNamespace ( element ) {
  	// Use specified namespace...
  	var xmlns = element.getAttribute( 'xmlns' );
  	if ( xmlns ) return xmlns;

  	// ...or SVG namespace, if this is an <svg> element
  	if ( element.name === 'svg' ) return svg$1;

  	var parent = element.parent;

  	if ( parent ) {
  		// ...or HTML, if the parent is a <foreignObject>
  		if ( parent.name === 'foreignobject' ) return html;

  		// ...or inherit from the parent node
  		return parent.node.namespaceURI;
  	}

  	return element.ractive.el.namespaceURI;
  }

  var Form = (function (Element) {
  	function Form ( options ) {
  		Element.call( this, options );
  		this.formBindings = [];
  	}

  	Form.prototype = Object.create( Element && Element.prototype );
  	Form.prototype.constructor = Form;

  	Form.prototype.render = function render ( target, occupants ) {
  		Element.prototype.render.call( this, target, occupants );
  		this.node.addEventListener( 'reset', handleReset, false );
  	};

  	Form.prototype.unrender = function unrender ( shouldDestroy ) {
  		this.node.removeEventListener( 'reset', handleReset, false );
  		Element.prototype.unrender.call( this, shouldDestroy );
  	};

  	return Form;
  }(Element));

  function handleReset () {
  	var element = this._ractive.proxy;

  	runloop.start();
  	element.formBindings.forEach( updateModel$1 );
  	runloop.end();
  }

  function updateModel$1 ( binding ) {
  	binding.model.set( binding.resetValue );
  }

  var Mustache = (function (Item) {
  	function Mustache ( options ) {
  		Item.call( this, options );

  		this.parentFragment = options.parentFragment;
  		this.template = options.template;
  		this.index = options.index;

  		this.isStatic = !!options.template.s;

  		this.model = null;
  		this.dirty = false;
  	}

  	Mustache.prototype = Object.create( Item && Item.prototype );
  	Mustache.prototype.constructor = Mustache;

  	Mustache.prototype.bind = function bind () {
  		// try to find a model for this view
  		var this$1 = this;

  		var model = resolve$2( this.parentFragment, this.template );
  		var value = model ? model.get() : undefined;

  		if ( this.isStatic ) {
  			this.model = { get: function () { return value; } };
  			return;
  		}

  		if ( model ) {
  			model.register( this );
  			this.model = model;
  		} else {
  			this.resolver = this.parentFragment.resolve( this.template.r, function ( model ) {
  				this$1.model = model;
  				model.register( this$1 );

  				this$1.handleChange();
  				this$1.resolver = null;
  			});
  		}
  	};

  	Mustache.prototype.handleChange = function handleChange () {
  		this.bubble();
  	};

  	Mustache.prototype.rebind = function rebind () {
  		if ( this.isStatic || !this.model ) return;

  		var model = resolve$2( this.parentFragment, this.template );

  		if ( model === this.model ) return;

  		this.model.unregister( this );

  		this.model = model;

  		if ( model ) {
  			model.register( this );
  			this.handleChange();
  		}
  	};

  	Mustache.prototype.unbind = function unbind () {
  		if ( !this.isStatic ) {
  			this.model && this.model.unregister( this );
  			this.model = undefined;
  			this.resolver && this.resolver.unbind();
  		}
  	};

  	return Mustache;
  }(Item));

  var Interpolator = (function (Mustache) {
  	function Interpolator () {
  		Mustache.apply(this, arguments);
  	}

  	Interpolator.prototype = Object.create( Mustache && Mustache.prototype );
  	Interpolator.prototype.constructor = Interpolator;

  	Interpolator.prototype.detach = function detach () {
  		return detachNode( this.node );
  	};

  	Interpolator.prototype.firstNode = function firstNode () {
  		return this.node;
  	};

  	Interpolator.prototype.getString = function getString () {
  		return this.model ? safeToStringValue( this.model.get() ) : '';
  	};

  	Interpolator.prototype.render = function render ( target, occupants ) {
  		var value = this.getString();

  		this.rendered = true;

  		if ( occupants ) {
  			var n = occupants[0];
  			if ( n && n.nodeType === 3 ) {
  				occupants.shift();
  				if ( n.nodeValue !== value ) {
  					n.nodeValue = value;
  				}
  			} else {
  				n = this.node = doc.createTextNode( value );
  				if ( occupants[0] ) {
  					target.insertBefore( n, occupants[0] );
  				} else {
  					target.appendChild( n );
  				}
  			}

  			this.node = n;
  		} else {
  			this.node = doc.createTextNode( value );
  			target.appendChild( this.node );
  		}
  	};

  	Interpolator.prototype.toString = function toString ( escape ) {
  		var string = this.getString();
  		return escape ? escapeHtml( string ) : string;
  	};

  	Interpolator.prototype.unrender = function unrender ( shouldDestroy ) {
  		if ( shouldDestroy ) this.detach();
  		this.rendered = false;
  	};

  	Interpolator.prototype.update = function update () {
  		if ( this.dirty ) {
  			this.dirty = false;
  			if ( this.rendered ) {
  				this.node.data = this.getString();
  			}
  		}
  	};

  	Interpolator.prototype.valueOf = function valueOf () {
  		return this.model ? this.model.get() : undefined;
  	};

  	return Interpolator;
  }(Mustache));

  var Input = (function (Element) {
  	function Input () {
  		Element.apply(this, arguments);
  	}

  	Input.prototype = Object.create( Element && Element.prototype );
  	Input.prototype.constructor = Input;

  	Input.prototype.render = function render ( target, occupants ) {
  		Element.prototype.render.call( this, target, occupants );
  		this.node.defaultValue = this.node.value;
  	};

  	return Input;
  }(Element));

  function findParentSelect ( element ) {
  	while ( element ) {
  		if ( element.name === 'select' ) return element;
  		element = element.parent;
  	}
  }

  var Option = (function (Element) {
  	function Option ( options ) {
  		var template = options.template;
  		if ( !template.a ) template.a = {};

  		// If the value attribute is missing, use the element's content,
  		// as long as it isn't disabled
  		if ( template.a.value === undefined && !( 'disabled' in template.a ) ) {
  			template.a.value = template.f || '';
  		}

  		Element.call( this, options );

  		this.select = findParentSelect( this.parent );
  	}

  	Option.prototype = Object.create( Element && Element.prototype );
  	Option.prototype.constructor = Option;

  	Option.prototype.bind = function bind () {
  		if ( !this.select ) {
  			Element.prototype.bind.call(this);
  			return;
  		}

  		// If the select has a value, it overrides the `selected` attribute on
  		// this option - so we delete the attribute
  		var selectedAttribute = this.attributeByName.selected;
  		if ( selectedAttribute && this.select.getAttribute( 'value' ) !== undefined ) {
  			var index = this.attributes.indexOf( selectedAttribute );
  			this.attributes.splice( index, 1 );
  			delete this.attributeByName.selected;
  		}

  		Element.prototype.bind.call(this);
  		this.select.options.push( this );
  	};

  	Option.prototype.isSelected = function isSelected () {
  		var optionValue = this.getAttribute( 'value' );

  		if ( optionValue === undefined || !this.select ) {
  			return false;
  		}

  		var selectValue = this.select.getAttribute( 'value' );

  		if ( selectValue == optionValue ) {
  			return true;
  		}

  		if ( this.select.getAttribute( 'multiple' ) && isArray( selectValue ) ) {
  			var i = selectValue.length;
  			while ( i-- ) {
  				if ( selectValue[i] == optionValue ) {
  					return true;
  				}
  			}
  		}
  	};

  	Option.prototype.unbind = function unbind () {
  		Element.prototype.unbind.call(this);

  		if ( this.select ) {
  			removeFromArray( this.select.options, this );
  		}
  	};

  	return Option;
  }(Element));

  function getPartialTemplate ( ractive, name, parentFragment ) {
  	// If the partial in instance or view heirarchy instances, great
  	var partial = getPartialFromRegistry( ractive, name, parentFragment || {} );
  	if ( partial ) return partial;

  	// Does it exist on the page as a script tag?
  	partial = parser.fromId( name, { noThrow: true } );
  	if ( partial ) {
  		// parse and register to this ractive instance
  		var parsed = parser.parseFor( partial, ractive );

  		// register extra partials on the ractive instance if they don't already exist
  		if ( parsed.p ) fillGaps( ractive.partials, parsed.p );

  		// register (and return main partial if there are others in the template)
  		return ractive.partials[ name ] = parsed.t;
  	}
  }

  function getPartialFromRegistry ( ractive, name, parentFragment ) {
  	// if there was an instance up-hierarchy, cool
  	var partial = findParentPartial( name, parentFragment.owner );
  	if ( partial ) return partial;

  	// find first instance in the ractive or view hierarchy that has this partial
  	var instance = findInstance( 'partials', ractive, name );

  	if ( !instance ) { return; }

  	partial = instance.partials[ name ];

  	// partial is a function?
  	var fn;
  	if ( typeof partial === 'function' ) {
  		fn = partial.bind( instance );
  		fn.isOwner = instance.partials.hasOwnProperty(name);
  		partial = fn.call( ractive, parser );
  	}

  	if ( !partial && partial !== '' ) {
  		warnIfDebug( noRegistryFunctionReturn, name, 'partial', 'partial', { ractive: ractive });
  		return;
  	}

  	// If this was added manually to the registry,
  	// but hasn't been parsed, parse it now
  	if ( !parser.isParsed( partial ) ) {
  		// use the parseOptions of the ractive instance on which it was found
  		var parsed = parser.parseFor( partial, instance );

  		// Partials cannot contain nested partials!
  		// TODO add a test for this
  		if ( parsed.p ) {
  			warnIfDebug( 'Partials ({{>%s}}) cannot contain nested inline partials', name, { ractive: ractive });
  		}

  		// if fn, use instance to store result, otherwise needs to go
  		// in the correct point in prototype chain on instance or constructor
  		var target = fn ? instance : findOwner( instance, name );

  		// may be a template with partials, which need to be registered and main template extracted
  		target.partials[ name ] = partial = parsed.t;
  	}

  	// store for reset
  	if ( fn ) partial._fn = fn;

  	return partial.v ? partial.t : partial;
  }

  function findOwner ( ractive, key ) {
  	return ractive.partials.hasOwnProperty( key )
  		? ractive
  		: findConstructor( ractive.constructor, key);
  }

  function findConstructor ( constructor, key ) {
  	if ( !constructor ) { return; }
  	return constructor.partials.hasOwnProperty( key )
  		? constructor
  		: findConstructor( constructor._Parent, key );
  }

  function findParentPartial( name, parent ) {
  	if ( parent ) {
  		if ( parent.template && parent.template.p && parent.template.p[name] ) {
  			return parent.template.p[name];
  		} else if ( parent.parentFragment && parent.parentFragment.owner ) {
  			return findParentPartial( name, parent.parentFragment.owner );
  		}
  	}
  }

  var Partial = (function (Mustache) {
  	function Partial () {
  		Mustache.apply(this, arguments);
  	}

  	Partial.prototype = Object.create( Mustache && Mustache.prototype );
  	Partial.prototype.constructor = Partial;

  	Partial.prototype.bind = function bind () {
  		// keep track of the reference name for future resets
  		this.refName = this.template.r;

  		// name matches take priority over expressions
  		var template = this.refName ? getPartialTemplate( this.ractive, this.refName, this.parentFragment ) || null : null;
  		var templateObj;

  		if ( template ) {
  			this.named = true;
  			this.setTemplate( this.template.r, template );
  		}

  		if ( !template ) {
  			Mustache.prototype.bind.call(this);
  			if ( this.model && ( templateObj = this.model.get() ) && typeof templateObj === 'object' && ( typeof templateObj.template === 'string' || isArray( templateObj.t ) ) ) {
  				if ( templateObj.template ) {
  					templateObj = parsePartial( this.template.r, templateObj.template, this.ractive );
  				}
  				this.setTemplate( this.template.r, templateObj.t );
  			} else if ( ( !this.model || typeof this.model.get() !== 'string' ) && this.refName ) {
  				this.setTemplate( this.refName, template );
  			} else {
  				this.setTemplate( this.model.get() );
  			}
  		}

  		this.fragment = new Fragment({
  			owner: this,
  			template: this.partialTemplate
  		}).bind();
  	};

  	Partial.prototype.detach = function detach () {
  		return this.fragment.detach();
  	};

  	Partial.prototype.find = function find ( selector ) {
  		return this.fragment.find( selector );
  	};

  	Partial.prototype.findAll = function findAll ( selector, query ) {
  		this.fragment.findAll( selector, query );
  	};

  	Partial.prototype.findComponent = function findComponent ( name ) {
  		return this.fragment.findComponent( name );
  	};

  	Partial.prototype.findAllComponents = function findAllComponents ( name, query ) {
  		this.fragment.findAllComponents( name, query );
  	};

  	Partial.prototype.firstNode = function firstNode ( skipParent ) {
  		return this.fragment.firstNode( skipParent );
  	};

  	Partial.prototype.forceResetTemplate = function forceResetTemplate () {
  		this.partialTemplate = undefined;

  		// on reset, check for the reference name first
  		if ( this.refName ) {
  			this.partialTemplate = getPartialTemplate( this.ractive, this.refName, this.parentFragment );
  		}

  		// then look for the resolved name
  		if ( !this.partialTemplate ) {
  			this.partialTemplate = getPartialTemplate( this.ractive, this.name, this.parentFragment );
  		}

  		if ( !this.partialTemplate ) {
  			warnOnceIfDebug( ("Could not find template for partial '" + (this.name) + "'") );
  			this.partialTemplate = [];
  		}

  		this.fragment.resetTemplate( this.partialTemplate );
  		this.bubble();
  	};

  	Partial.prototype.rebind = function rebind () {
  		Mustache.prototype.unbind.call(this);
  		Mustache.prototype.bind.call(this);
  		this.fragment.rebind();
  	};

  	Partial.prototype.render = function render ( target, occupants ) {
  		this.fragment.render( target, occupants );
  	};

  	Partial.prototype.setTemplate = function setTemplate ( name, template ) {
  		this.name = name;

  		if ( !template && template !== null ) template = getPartialTemplate( this.ractive, name, this.parentFragment );

  		if ( !template ) {
  			warnOnceIfDebug( ("Could not find template for partial '" + name + "'") );
  		}

  		this.partialTemplate = template || [];
  	};

  	Partial.prototype.toString = function toString ( escape ) {
  		return this.fragment.toString( escape );
  	};

  	Partial.prototype.unbind = function unbind () {
  		Mustache.prototype.unbind.call(this);
  		this.fragment.unbind();
  	};

  	Partial.prototype.unrender = function unrender ( shouldDestroy ) {
  		this.fragment.unrender( shouldDestroy );
  	};

  	Partial.prototype.update = function update () {
  		var template;

  		if ( this.dirty ) {
  			this.dirty = false;

  			if ( !this.named ) {
  				if ( this.model ) {
  					template = this.model.get();
  				}

  				if ( template && typeof template === 'string' && template !== this.name ) {
  					this.setTemplate( template );
  					this.fragment.resetTemplate( this.partialTemplate );
  				} else if ( template && typeof template === 'object' && ( typeof template.template === 'string' || isArray( template.t ) ) ) {
  					if ( template.template ) {
  						template = parsePartial( this.name, template.template, this.ractive );
  					}
  					this.setTemplate( this.name, template.t );
  					this.fragment.resetTemplate( this.partialTemplate );
  				}
  			}

  			this.fragment.update();
  		}
  	};

  	return Partial;
  }(Mustache));

  function parsePartial( name, partial, ractive ) {
  	var parsed;

  	try {
  		parsed = parser.parse( partial, parser.getParseOptions( ractive ) );
  	} catch (e) {
  		warnIfDebug( ("Could not parse partial from expression '" + name + "'\n" + (e.message)) );
  	}

  	return parsed || { t: [] };
  }

  var RepeatedFragment = function RepeatedFragment ( options ) {
  	this.parent = options.owner.parentFragment;

  	// bit of a hack, so reference resolution works without another
  	// layer of indirection
  	this.parentFragment = this;
  	this.owner = options.owner;
  	this.ractive = this.parent.ractive;

  	// encapsulated styles should be inherited until they get applied by an element
  	this.cssIds = 'cssIds' in options ? options.cssIds : ( this.parent ? this.parent.cssIds : null );

  	this.context = null;
  	this.rendered = false;
  	this.iterations = [];

  	this.template = options.template;

  	this.indexRef = options.indexRef;
  	this.keyRef = options.keyRef;

  	this.pendingNewIndices = null;
  	this.previousIterations = null;

  	// track array versus object so updates of type rest
  	this.isArray = false;
  };

  RepeatedFragment.prototype.bind = function bind ( context ) {
  	var this$1 = this;

  		this.context = context;
  	var value = context.get();

  	// {{#each array}}...
  	if ( this.isArray = isArray( value ) ) {
  		// we can't use map, because of sparse arrays
  		this.iterations = [];
  		for ( var i = 0; i < value.length; i += 1 ) {
  			this$1.iterations[i] = this$1.createIteration( i, i );
  		}
  	}

  	// {{#each object}}...
  	else if ( isObject( value ) ) {
  		this.isArray = false;

  		// TODO this is a dreadful hack. There must be a neater way
  		if ( this.indexRef ) {
  			var refs = this.indexRef.split( ',' );
  			this.keyRef = refs[0];
  			this.indexRef = refs[1];
  		}

  		this.iterations = Object.keys( value ).map( function ( key, index ) {
  			return this$1.createIteration( key, index );
  		});
  	}

  	return this;
  };

  RepeatedFragment.prototype.bubble = function bubble () {
  	this.owner.bubble();
  };

  RepeatedFragment.prototype.createIteration = function createIteration ( key, index ) {
  	var fragment = new Fragment({
  		owner: this,
  		template: this.template
  	});

  	// TODO this is a bit hacky
  	fragment.key = key;
  	fragment.index = index;
  	fragment.isIteration = true;

  	var model = this.context.joinKey( key );

  	// set up an iteration alias if there is one
  	if ( this.owner.template.z ) {
  		fragment.aliases = {};
  		fragment.aliases[ this.owner.template.z[0].n ] = model;
  	}

  	return fragment.bind( model );
  };

  RepeatedFragment.prototype.detach = function detach () {
  	var docFrag = createDocumentFragment();
  	this.iterations.forEach( function ( fragment ) { return docFrag.appendChild( fragment.detach() ); } );
  	return docFrag;
  };

  RepeatedFragment.prototype.find = function find ( selector ) {
  	var this$1 = this;

  		var len = this.iterations.length;
  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		var found = this$1.iterations[i].find( selector );
  		if ( found ) return found;
  	}
  };

  RepeatedFragment.prototype.findAll = function findAll ( selector, query ) {
  	var this$1 = this;

  		var len = this.iterations.length;
  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		this$1.iterations[i].findAll( selector, query );
  	}
  };

  RepeatedFragment.prototype.findComponent = function findComponent ( name ) {
  	var this$1 = this;

  		var len = this.iterations.length;
  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		var found = this$1.iterations[i].findComponent( name );
  		if ( found ) return found;
  	}
  };

  RepeatedFragment.prototype.findAllComponents = function findAllComponents ( name, query ) {
  	var this$1 = this;

  		var len = this.iterations.length;
  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		this$1.iterations[i].findAllComponents( name, query );
  	}
  };

  RepeatedFragment.prototype.findNextNode = function findNextNode ( iteration ) {
  	var this$1 = this;

  		if ( iteration.index < this.iterations.length - 1 ) {
  		for ( var i = iteration.index + 1; i < this$1.iterations.length; i++ ) {
  			var node = this$1.iterations[ i ].firstNode( true );
  			if ( node ) return node;
  		}
  	}

  	return this.owner.findNextNode();
  };

  RepeatedFragment.prototype.firstNode = function firstNode ( skipParent ) {
  	return this.iterations[0] ? this.iterations[0].firstNode( skipParent ) : null;
  };

  RepeatedFragment.prototype.rebind = function rebind ( context ) {
  	var this$1 = this;

  		this.context = context;

  	this.iterations.forEach( function ( fragment ) {
  		var model = context.joinKey( fragment.key || fragment.index );
  		if ( this$1.owner.template.z ) {
  			fragment.aliases = {};
  			fragment.aliases[ this$1.owner.template.z[0].n ] = model;
  		}
  		fragment.rebind( model );
  	});
  };

  RepeatedFragment.prototype.render = function render ( target, occupants ) {
  	// TODO use docFrag.cloneNode...

  	if ( this.iterations ) {
  		this.iterations.forEach( function ( fragment ) { return fragment.render( target, occupants ); } );
  	}

  	this.rendered = true;
  };

  RepeatedFragment.prototype.shuffle = function shuffle ( newIndices ) {
  	var this$1 = this;

  		if ( !this.pendingNewIndices ) this.previousIterations = this.iterations.slice();

  	if ( !this.pendingNewIndices ) this.pendingNewIndices = [];

  	this.pendingNewIndices.push( newIndices );

  	var iterations = [];

  	newIndices.forEach( function ( newIndex, oldIndex ) {
  		if ( newIndex === -1 ) return;

  		var fragment = this$1.iterations[ oldIndex ];
  		iterations[ newIndex ] = fragment;

  		if ( newIndex !== oldIndex && fragment ) fragment.dirty = true;
  	});

  	this.iterations = iterations;

  	this.bubble();
  };

  RepeatedFragment.prototype.toString = function toString$1$$ ( escape ) {
  	return this.iterations ?
  		this.iterations.map( escape ? toEscapedString : toString$1 ).join( '' ) :
  		'';
  };

  RepeatedFragment.prototype.unbind = function unbind$1 () {
  	this.iterations.forEach( unbind );
  	return this;
  };

  RepeatedFragment.prototype.unrender = function unrender$1 ( shouldDestroy ) {
  	this.iterations.forEach( shouldDestroy ? unrenderAndDestroy : unrender );
  	if ( this.pendingNewIndices && this.previousIterations ) {
  		this.previousIterations.forEach( function ( fragment ) {
  			if ( fragment.rendered ) shouldDestroy ? unrenderAndDestroy( fragment ) : unrender( fragment );
  		});
  	}
  	this.rendered = false;
  };

  // TODO smart update
  RepeatedFragment.prototype.update = function update$1 () {
  	// skip dirty check, since this is basically just a facade

  	var this$1 = this;

  		if ( this.pendingNewIndices ) {
  		this.updatePostShuffle();
  		return;
  	}

  	if ( this.updating ) return;
  	this.updating = true;

  	var value = this.context.get(),
  			  wasArray = this.isArray;

  	var toRemove;
  	var oldKeys;
  	var reset = true;
  	var i;

  	if ( this.isArray = isArray( value ) ) {
  		if ( wasArray ) {
  			reset = false;
  			if ( this.iterations.length > value.length ) {
  				toRemove = this.iterations.splice( value.length );
  			}
  		}
  	} else if ( isObject( value ) && !wasArray ) {
  		reset = false;
  		toRemove = [];
  		oldKeys = {};
  		i = this.iterations.length;

  		while ( i-- ) {
  			var fragment$1 = this$1.iterations[i];
  			if ( fragment$1.key in value ) {
  				oldKeys[ fragment$1.key ] = true;
  			} else {
  				this$1.iterations.splice( i, 1 );
  				toRemove.push( fragment$1 );
  			}
  		}
  	}

  	if ( reset ) {
  		toRemove = this.iterations;
  		this.iterations = [];
  	}

  	if ( toRemove ) {
  		toRemove.forEach( function ( fragment ) {
  			fragment.unbind();
  			fragment.unrender( true );
  		});
  	}

  	// update the remaining ones
  	this.iterations.forEach( update );

  	// add new iterations
  	var newLength = isArray( value ) ?
  		value.length :
  		isObject( value ) ?
  			Object.keys( value ).length :
  			0;

  	var docFrag;
  	var fragment;

  	if ( newLength > this.iterations.length ) {
  		docFrag = this.rendered ? createDocumentFragment() : null;
  		i = this.iterations.length;

  		if ( isArray( value ) ) {
  			while ( i < value.length ) {
  				fragment = this$1.createIteration( i, i );

  				this$1.iterations.push( fragment );
  				if ( this$1.rendered ) fragment.render( docFrag );

  				i += 1;
  			}
  		}

  		else if ( isObject( value ) ) {
  			// TODO this is a dreadful hack. There must be a neater way
  			if ( this.indexRef && !this.keyRef ) {
  				var refs = this.indexRef.split( ',' );
  				this.keyRef = refs[0];
  				this.indexRef = refs[1];
  			}

  			Object.keys( value ).forEach( function ( key ) {
  				if ( !oldKeys || !( key in oldKeys ) ) {
  					fragment = this$1.createIteration( key, i );

  					this$1.iterations.push( fragment );
  					if ( this$1.rendered ) fragment.render( docFrag );

  					i += 1;
  				}
  			});
  		}

  		if ( this.rendered ) {
  			var parentNode = this.parent.findParentNode();
  			var anchor = this.parent.findNextNode( this.owner );

  			parentNode.insertBefore( docFrag, anchor );
  		}
  	}

  	this.updating = false;
  };

  RepeatedFragment.prototype.updatePostShuffle = function updatePostShuffle () {
  	var this$1 = this;

  		var newIndices = this.pendingNewIndices[ 0 ];

  	// map first shuffle through
  	this.pendingNewIndices.slice( 1 ).forEach( function ( indices ) {
  		newIndices.forEach( function ( newIndex, oldIndex ) {
  			newIndices[ oldIndex ] = indices[ newIndex ];
  		});
  	});

  	// This algorithm (for detaching incorrectly-ordered fragments from the DOM and
  	// storing them in a document fragment for later reinsertion) seems a bit hokey,
  	// but it seems to work for now
  	var len = this.context.get().length;
  	var i, maxIdx = 0, merged = false;

  	newIndices.forEach( function ( newIndex, oldIndex ) {
  		var fragment = this$1.previousIterations[ oldIndex ];

  		// check for merged shuffles
  		if ( !merged && newIndex !== -1 ) {
  			if ( newIndex < maxIdx ) merged = true;
  			if ( newIndex > maxIdx ) maxIdx = newIndex;
  		}


  		if ( newIndex === -1 ) {
  			fragment.unbind().unrender( true );
  		} else {
  			fragment.index = newIndex;
  			var model = this$1.context.joinKey( newIndex );
  			if ( this$1.owner.template.z ) {
  				fragment.aliases = {};
  				fragment.aliases[ this$1.owner.template.z[0].n ] = model;
  			}
  			fragment.rebind( model );
  		}
  	});

  	// create new iterations
  	var docFrag = this.rendered ? createDocumentFragment() : null;
  	var parentNode = this.rendered ? this.parent.findParentNode() : null;

  	if ( merged ) {
  		for ( i = 0; i < len; i += 1 ) {
  			var frag = this$1.iterations[i];

  			if ( this$1.rendered ) {
  				if ( frag ) {
  					docFrag.appendChild( frag.detach() );
  				} else {
  					this$1.iterations[i] = this$1.createIteration( i, i );
  					this$1.iterations[i].render( docFrag );
  				}
  			}

  			if ( !this$1.rendered ) {
  				if ( !frag ) {
  					this$1.iterations[i] = this$1.createIteration( i, i );
  				}
  			}
  		}
  	} else {
  		for ( i = 0; i < len; i++ ) {
  			var frag$1 = this$1.iterations[i];

  			if ( this$1.rendered ) {
  				if ( frag$1 && docFrag.childNodes.length ) {
  					parentNode.insertBefore( docFrag, frag$1.firstNode() );
  				}

  				if ( !frag$1 ) {
  					frag$1 = this$1.iterations[i] = this$1.createIteration( i, i );
  					frag$1.render( docFrag );
  				}
  			} else if ( !frag$1 ) {
  				this$1.iterations[i] = this$1.createIteration( i, i );
  			}
  		}
  	}

  	if ( this.rendered && docFrag.childNodes.length ) {
  		parentNode.insertBefore( docFrag, this.owner.findNextNode() );
  	}

  	this.iterations.forEach( update );

  	this.pendingNewIndices = null;
  };

  function isEmpty ( value ) {
  	return !value ||
  	       ( isArray( value ) && value.length === 0 ) ||
  		   ( isObject( value ) && Object.keys( value ).length === 0 );
  }

  function getType ( value, hasIndexRef ) {
  	if ( hasIndexRef || isArray( value ) ) return SECTION_EACH;
  	if ( isObject( value ) || typeof value === 'function' ) return SECTION_IF_WITH;
  	if ( value === undefined ) return null;
  	return SECTION_IF;
  }

  var Section = (function (Mustache) {
  	function Section ( options ) {
  		Mustache.call( this, options );

  		this.sectionType = options.template.n || null;
  		this.templateSectionType = this.sectionType;
  		this.fragment = null;
  	}

  	Section.prototype = Object.create( Mustache && Mustache.prototype );
  	Section.prototype.constructor = Section;

  	Section.prototype.bind = function bind () {
  		Mustache.prototype.bind.call(this);

  		// if we managed to bind, we need to create children
  		if ( this.model ) {
  			this.dirty = true;
  			this.update();
  		} else if (this.sectionType && this.sectionType === SECTION_UNLESS) {
  			this.fragment = new Fragment({
  				owner: this,
  				template: this.template.f
  			}).bind();
  		}
  	};

  	Section.prototype.detach = function detach () {
  		return this.fragment ? this.fragment.detach() : createDocumentFragment();
  	};

  	Section.prototype.find = function find ( selector ) {
  		if ( this.fragment ) {
  			return this.fragment.find( selector );
  		}
  	};

  	Section.prototype.findAll = function findAll ( selector, query ) {
  		if ( this.fragment ) {
  			this.fragment.findAll( selector, query );
  		}
  	};

  	Section.prototype.findComponent = function findComponent ( name ) {
  		if ( this.fragment ) {
  			return this.fragment.findComponent( name );
  		}
  	};

  	Section.prototype.findAllComponents = function findAllComponents ( name, query ) {
  		if ( this.fragment ) {
  			this.fragment.findAllComponents( name, query );
  		}
  	};

  	Section.prototype.firstNode = function firstNode ( skipParent ) {
  		return this.fragment && this.fragment.firstNode( skipParent );
  	};

  	Section.prototype.rebind = function rebind () {
  		Mustache.prototype.rebind.call(this);

  		if ( this.fragment ) {
  			this.fragment.rebind( this.sectionType === SECTION_IF || this.sectionType === SECTION_UNLESS ? null : this.model );
  		}
  	};

  	Section.prototype.render = function render ( target, occupants ) {
  		this.rendered = true;
  		if ( this.fragment ) this.fragment.render( target, occupants );
  	};

  	Section.prototype.shuffle = function shuffle ( newIndices ) {
  		if ( this.fragment && this.sectionType === SECTION_EACH ) {
  			this.fragment.shuffle( newIndices );
  		}
  	};

  	Section.prototype.toString = function toString ( escape ) {
  		return this.fragment ? this.fragment.toString( escape ) : '';
  	};

  	Section.prototype.unbind = function unbind () {
  		Mustache.prototype.unbind.call(this);
  		if ( this.fragment ) this.fragment.unbind();
  	};

  	Section.prototype.unrender = function unrender ( shouldDestroy ) {
  		if ( this.rendered && this.fragment ) this.fragment.unrender( shouldDestroy );
  		this.rendered = false;
  	};

  	Section.prototype.update = function update () {
  		if ( !this.dirty ) return;
  		if ( !this.model && this.sectionType !== SECTION_UNLESS ) return;

  		this.dirty = false;

  		var value = !this.model ? undefined : this.model.isRoot ? this.model.value : this.model.get();
  		var lastType = this.sectionType;

  		// watch for switching section types
  		if ( this.sectionType === null || this.templateSectionType === null ) this.sectionType = getType( value, this.template.i );
  		if ( lastType && lastType !== this.sectionType && this.fragment ) {
  			if ( this.rendered ) {
  				this.fragment.unbind().unrender( true );
  			}

  			this.fragment = null;
  		}

  		var newFragment;

  		if ( this.sectionType === SECTION_EACH ) {
  			if ( this.fragment ) {
  				this.fragment.update();
  			} else {
  				// TODO can this happen?
  				newFragment = new RepeatedFragment({
  					owner: this,
  					template: this.template.f,
  					indexRef: this.template.i
  				}).bind( this.model );
  			}
  		}

  		// WITH is now IF_WITH; WITH is only used for {{>partial context}}
  		else if ( this.sectionType === SECTION_WITH ) {
  			if ( this.fragment ) {
  				this.fragment.update();
  			} else {
  				newFragment = new Fragment({
  					owner: this,
  					template: this.template.f
  				}).bind( this.model );
  			}
  		}

  		else if ( this.sectionType === SECTION_IF_WITH ) {
  			if ( this.fragment ) {
  				if ( isEmpty( value ) ) {
  					if ( this.rendered ) {
  						this.fragment.unbind().unrender( true );
  					}

  					this.fragment = null;
  				} else {
  					this.fragment.update();
  				}
  			} else if ( !isEmpty( value ) ) {
  				newFragment = new Fragment({
  					owner: this,
  					template: this.template.f
  				}).bind( this.model );
  			}
  		}

  		else {
  			var fragmentShouldExist = this.sectionType === SECTION_UNLESS ? isEmpty( value ) : !!value && !isEmpty( value );

  			if ( this.fragment ) {
  				if ( fragmentShouldExist ) {
  					this.fragment.update();
  				} else {
  					if ( this.rendered ) {
  						this.fragment.unbind().unrender( true );
  					}

  					this.fragment = null;
  				}
  			} else if ( fragmentShouldExist ) {
  				newFragment = new Fragment({
  					owner: this,
  					template: this.template.f
  				}).bind( null );
  			}
  		}

  		if ( newFragment ) {
  			if ( this.rendered ) {
  				var parentNode = this.parentFragment.findParentNode();
  				var anchor = this.parentFragment.findNextNode( this );

  				if ( anchor ) {
  					var docFrag = createDocumentFragment();
  					newFragment.render( docFrag );

  					// we use anchor.parentNode, not parentNode, because the sibling
  					// may be temporarily detached as a result of a shuffle
  					anchor.parentNode.insertBefore( docFrag, anchor );
  				} else {
  					newFragment.render( parentNode );
  				}
  			}

  			this.fragment = newFragment;
  		}
  	};

  	return Section;
  }(Mustache));

  function valueContains ( selectValue, optionValue ) {
  	var i = selectValue.length;
  	while ( i-- ) {
  		if ( selectValue[i] == optionValue ) return true;
  	}
  }

  var Select = (function (Element) {
  	function Select ( options ) {
  		Element.call( this, options );
  		this.options = [];
  	}

  	Select.prototype = Object.create( Element && Element.prototype );
  	Select.prototype.constructor = Select;

  	Select.prototype.foundNode = function foundNode ( node ) {
  		if ( this.binding ) {
  			var selectedOptions = getSelectedOptions( node );

  			if ( selectedOptions.length > 0 ) {
  				this.selectedOptions = selectedOptions;
  			}
  		}
  	};

  	Select.prototype.render = function render ( target, occupants ) {
  		Element.prototype.render.call( this, target, occupants );
  		this.sync();

  		var node = this.node;

  		var i = node.options.length;
  		while ( i-- ) {
  			node.options[i].defaultSelected = node.options[i].selected;
  		}

  		this.rendered = true;
  	};

  	Select.prototype.sync = function sync () {
  		var this$1 = this;

  		var selectNode = this.node;

  		if ( !selectNode ) return;

  		var options = toArray( selectNode.options );

  		if ( this.selectedOptions ) {
  			options.forEach( function ( o ) {
  				if ( this$1.selectedOptions.indexOf( o ) >= 0 ) o.selected = true;
  				else o.selected = false;
  			});
  			this.binding.setFromNode( selectNode );
  			delete this.selectedOptions;
  			return;
  		}

  		var selectValue = this.getAttribute( 'value' );
  		var isMultiple = this.getAttribute( 'multiple' );

  		// If the <select> has a specified value, that should override
  		// these options
  		if ( selectValue !== undefined ) {
  			var optionWasSelected;

  			options.forEach( function ( o ) {
  				var optionValue = o._ractive ? o._ractive.value : o.value;
  				var shouldSelect = isMultiple ? valueContains( selectValue, optionValue ) : selectValue == optionValue;

  				if ( shouldSelect ) {
  					optionWasSelected = true;
  				}

  				o.selected = shouldSelect;
  			});

  			if ( !optionWasSelected && !isMultiple ) {
  				if ( this.binding ) {
  					this.binding.forceUpdate();
  				}
  			}
  		}

  		// Otherwise the value should be initialised according to which
  		// <option> element is selected, if twoway binding is in effect
  		else if ( this.binding ) {
  			this.binding.forceUpdate();
  		}
  	};

  	Select.prototype.update = function update () {
  		Element.prototype.update.call(this);
  		this.sync();
  	};

  	return Select;
  }(Element));

  var Textarea = (function (Input) {
  	function Textarea( options ) {
  		var template = options.template;

  		// if there is a bindable value, there should be no body
  		if ( template.a && template.a.value && isBindable( { template: template.a.value } ) ) {
  			options.noContent = true;
  		}

  		// otherwise, if there is a single bindable interpolator as content, move it to the value attr
  		else if ( template.f && (!template.a || !template.a.value) && isBindable( { template: template.f } ) ) {
  			if ( !template.a ) template.a = {};
  			template.a.value = template.f;
  			options.noContent = true;
  		}

  		Input.call( this, options );
  	}

  	Textarea.prototype = Object.create( Input && Input.prototype );
  	Textarea.prototype.constructor = Textarea;

  	Textarea.prototype.bubble = function bubble () {
  		var this$1 = this;

  		if ( !this.dirty ) {
  			this.dirty = true;

  			if ( this.rendered && !this.binding && this.fragment ) {
  				runloop.scheduleTask( function () {
  					this$1.dirty = false;
  					this$1.node.value = this$1.fragment.toString();
  				});
  			}

  			this.parentFragment.bubble(); // default behaviour
  		}
  	};

  	return Textarea;
  }(Input));

  var Text = (function (Item) {
  	function Text ( options ) {
  		Item.call( this, options );
  		this.type = TEXT;
  	}

  	Text.prototype = Object.create( Item && Item.prototype );
  	Text.prototype.constructor = Text;

  	Text.prototype.bind = function bind () {
  		// noop
  	};

  	Text.prototype.detach = function detach () {
  		return detachNode( this.node );
  	};

  	Text.prototype.firstNode = function firstNode () {
  		return this.node;
  	};

  	Text.prototype.rebind = function rebind () {
  		// noop
  	};

  	Text.prototype.render = function render ( target, occupants ) {
  		this.rendered = true;

  		if ( occupants ) {
  			var n = occupants[0];
  			if ( n && n.nodeType === 3 ) {
  				occupants.shift();
  				if ( n.nodeValue !== this.template ) {
  					n.nodeValue = this.template;
  				}
  			} else {
  				n = this.node = doc.createTextNode( this.template );
  				if ( occupants[0] ) {
  					target.insertBefore( n, occupants[0] );
  				} else {
  					target.appendChild( n );
  				}
  			}

  			this.node = n;
  		} else {
  			this.node = doc.createTextNode( this.template );
  			target.appendChild( this.node );
  		}
  	};

  	Text.prototype.toString = function toString ( escape ) {
  		return escape ? escapeHtml( this.template ) : this.template;
  	};

  	Text.prototype.unbind = function unbind () {
  		// noop
  	};

  	Text.prototype.unrender = function unrender ( shouldDestroy ) {
  		if ( this.rendered && shouldDestroy ) this.detach();
  		this.rendered = false;
  	};

  	Text.prototype.update = function update () {
  		// noop
  	};

  	Text.prototype.valueOf = function valueOf () {
  		return this.template;
  	};

  	return Text;
  }(Item));

  var elementCache = {};

  var ieBug;
  var ieBlacklist;

  try {
  	createElement( 'table' ).innerHTML = 'foo';
  } catch ( err ) {
  	ieBug = true;

  	ieBlacklist = {
  		TABLE:  [ '<table class="x">', '</table>' ],
  		THEAD:  [ '<table><thead class="x">', '</thead></table>' ],
  		TBODY:  [ '<table><tbody class="x">', '</tbody></table>' ],
  		TR:     [ '<table><tr class="x">', '</tr></table>' ],
  		SELECT: [ '<select class="x">', '</select>' ]
  	};
  }

  function insertHtml ( html, node, docFrag ) {
  	var nodes = [];

  	// render 0 and false
  	if ( html == null || html === '' ) return nodes;

  	var container;
  	var wrapper;
  	var selectedOption;

  	if ( ieBug && ( wrapper = ieBlacklist[ node.tagName ] ) ) {
  		container = element( 'DIV' );
  		container.innerHTML = wrapper[0] + html + wrapper[1];
  		container = container.querySelector( '.x' );

  		if ( container.tagName === 'SELECT' ) {
  			selectedOption = container.options[ container.selectedIndex ];
  		}
  	}

  	else if ( node.namespaceURI === svg$1 ) {
  		container = element( 'DIV' );
  		container.innerHTML = '<svg class="x">' + html + '</svg>';
  		container = container.querySelector( '.x' );
  	}

  	else if ( node.tagName === 'TEXTAREA' ) {
  		container = createElement( 'div' );

  		if ( typeof container.textContent !== 'undefined' ) {
  			container.textContent = html;
  		} else {
  			container.innerHTML = html;
  		}
  	}

  	else {
  		container = element( node.tagName );
  		container.innerHTML = html;

  		if ( container.tagName === 'SELECT' ) {
  			selectedOption = container.options[ container.selectedIndex ];
  		}
  	}

  	var child;
  	while ( child = container.firstChild ) {
  		nodes.push( child );
  		docFrag.appendChild( child );
  	}

  	// This is really annoying. Extracting <option> nodes from the
  	// temporary container <select> causes the remaining ones to
  	// become selected. So now we have to deselect them. IE8, you
  	// amaze me. You really do
  	// ...and now Chrome too
  	var i;
  	if ( node.tagName === 'SELECT' ) {
  		i = nodes.length;
  		while ( i-- ) {
  			if ( nodes[i] !== selectedOption ) {
  				nodes[i].selected = false;
  			}
  		}
  	}

  	return nodes;
  }

  function element ( tagName ) {
  	return elementCache[ tagName ] || ( elementCache[ tagName ] = createElement( tagName ) );
  }

  var Triple = (function (Mustache) {
  	function Triple ( options ) {
  		Mustache.call( this, options );
  	}

  	Triple.prototype = Object.create( Mustache && Mustache.prototype );
  	Triple.prototype.constructor = Triple;

  	Triple.prototype.detach = function detach () {
  		var docFrag = createDocumentFragment();
  		this.nodes.forEach( function ( node ) { return docFrag.appendChild( node ); } );
  		return docFrag;
  	};

  	Triple.prototype.find = function find ( selector ) {
  		var this$1 = this;

  		var len = this.nodes.length;
  		var i;

  		for ( i = 0; i < len; i += 1 ) {
  			var node = this$1.nodes[i];

  			if ( node.nodeType !== 1 ) continue;

  			if ( matches( node, selector ) ) return node;

  			var queryResult = node.querySelector( selector );
  			if ( queryResult ) return queryResult;
  		}

  		return null;
  	};

  	Triple.prototype.findAll = function findAll ( selector, query ) {
  		var this$1 = this;

  		var len = this.nodes.length;
  		var i;

  		for ( i = 0; i < len; i += 1 ) {
  			var node = this$1.nodes[i];

  			if ( node.nodeType !== 1 ) continue;

  			if ( query.test( node ) ) query.add( node );

  			var queryAllResult = node.querySelectorAll( selector );
  			if ( queryAllResult ) {
  				var numNodes = queryAllResult.length;
  				var j;

  				for ( j = 0; j < numNodes; j += 1 ) {
  					query.add( queryAllResult[j] );
  				}
  			}
  		}
  	};

  	Triple.prototype.findComponent = function findComponent () {
  		return null;
  	};

  	Triple.prototype.firstNode = function firstNode () {
  		return this.nodes[0];
  	};

  	Triple.prototype.render = function render ( target ) {
  		var html = this.model ? this.model.get() : '';
  		this.nodes = insertHtml( html, this.parentFragment.findParentNode(), target );
  		this.rendered = true;
  	};

  	Triple.prototype.toString = function toString () {
  		return this.model && this.model.get() != null ? decodeCharacterReferences( '' + this.model.get() ) : '';
  	};

  	Triple.prototype.unrender = function unrender () {
  		if ( this.nodes ) this.nodes.forEach( function ( node ) { return detachNode( node ); } );
  		this.rendered = false;
  	};

  	Triple.prototype.update = function update () {
  		if ( this.rendered && this.dirty ) {
  			this.dirty = false;

  			this.unrender();
  			var docFrag = createDocumentFragment();
  			this.render( docFrag );

  			var parentNode = this.parentFragment.findParentNode();
  			var anchor = this.parentFragment.findNextNode( this );

  			parentNode.insertBefore( docFrag, anchor );
  		}
  	};

  	return Triple;
  }(Mustache));

  var Yielder = (function (Item) {
  	function Yielder ( options ) {
  		Item.call( this, options );

  		this.container = options.parentFragment.ractive;
  		this.component = this.container.component;

  		this.containerFragment = options.parentFragment;
  		this.parentFragment = this.component.parentFragment;

  		// {{yield}} is equivalent to {{yield content}}
  		this.name = options.template.n || '';
  	}

  	Yielder.prototype = Object.create( Item && Item.prototype );
  	Yielder.prototype.constructor = Yielder;

  	Yielder.prototype.bind = function bind () {
  		var name = this.name;

  		( this.component.yielders[ name ] || ( this.component.yielders[ name ] = [] ) ).push( this );

  		// TODO don't parse here
  		var template = this.container._inlinePartials[ name || 'content' ];

  		if ( typeof template === 'string' ) {
  			template = parse( template ).t;
  		}

  		if ( !template ) {
  			warnIfDebug( ("Could not find template for partial \"" + name + "\""), { ractive: this.ractive });
  			template = [];
  		}

  		this.fragment = new Fragment({
  			owner: this,
  			ractive: this.container.parent,
  			template: template
  		}).bind();
  	};

  	Yielder.prototype.bubble = function bubble () {
  		if ( !this.dirty ) {
  			this.containerFragment.bubble();
  			this.dirty = true;
  		}
  	};

  	Yielder.prototype.detach = function detach () {
  		return this.fragment.detach();
  	};

  	Yielder.prototype.find = function find ( selector ) {
  		return this.fragment.find( selector );
  	};

  	Yielder.prototype.findAll = function findAll ( selector, queryResult ) {
  		this.fragment.find( selector, queryResult );
  	};

  	Yielder.prototype.findComponent = function findComponent ( name ) {
  		return this.fragment.findComponent( name );
  	};

  	Yielder.prototype.findAllComponents = function findAllComponents ( name, queryResult ) {
  		this.fragment.findAllComponents( name, queryResult );
  	};

  	Yielder.prototype.findNextNode = function findNextNode() {
  		return this.containerFragment.findNextNode( this );
  	};

  	Yielder.prototype.firstNode = function firstNode ( skipParent ) {
  		return this.fragment.firstNode( skipParent );
  	};

  	Yielder.prototype.rebind = function rebind () {
  		this.fragment.rebind();
  	};

  	Yielder.prototype.render = function render ( target, occupants ) {
  		return this.fragment.render( target, occupants );
  	};

  	Yielder.prototype.setTemplate = function setTemplate ( name ) {
  		var template = this.parentFragment.ractive.partials[ name ];

  		if ( typeof template === 'string' ) {
  			template = parse( template ).t;
  		}

  		this.partialTemplate = template || []; // TODO warn on missing partial
  	};

  	Yielder.prototype.toString = function toString ( escape ) {
  		return this.fragment.toString( escape );
  	};

  	Yielder.prototype.unbind = function unbind () {
  		this.fragment.unbind();
  		removeFromArray( this.component.yielders[ this.name ], this );
  	};

  	Yielder.prototype.unrender = function unrender ( shouldDestroy ) {
  		this.fragment.unrender( shouldDestroy );
  	};

  	Yielder.prototype.update = function update () {
  		this.dirty = false;
  		this.fragment.update();
  	};

  	return Yielder;
  }(Item));

  // finds the component constructor in the registry or view hierarchy registries
  function getComponentConstructor ( ractive, name ) {
  	var instance = findInstance( 'components', ractive, name );
  	var Component;

  	if ( instance ) {
  		Component = instance.components[ name ];

  		// best test we have for not Ractive.extend
  		if ( !Component._Parent ) {
  			// function option, execute and store for reset
  			var fn = Component.bind( instance );
  			fn.isOwner = instance.components.hasOwnProperty( name );
  			Component = fn();

  			if ( !Component ) {
  				warnIfDebug( noRegistryFunctionReturn, name, 'component', 'component', { ractive: ractive });
  				return;
  			}

  			if ( typeof Component === 'string' ) {
  				// allow string lookup
  				Component = getComponentConstructor( ractive, Component );
  			}

  			Component._fn = fn;
  			instance.components[ name ] = Component;
  		}
  	}

  	return Component;
  }

  var constructors = {};
  constructors[ ALIAS ] = Alias;
  constructors[ DOCTYPE ] = Doctype;
  constructors[ INTERPOLATOR ] = Interpolator;
  constructors[ PARTIAL ] = Partial;
  constructors[ SECTION ] = Section;
  constructors[ TRIPLE ] = Triple;
  constructors[ YIELDER ] = Yielder;

  var specialElements = {
  	doctype: Doctype,
  	form: Form,
  	input: Input,
  	option: Option,
  	select: Select,
  	textarea: Textarea
  };

  function createItem ( options ) {
  	if ( typeof options.template === 'string' ) {
  		return new Text( options );
  	}

  	if ( options.template.t === ELEMENT ) {
  		// could be component or element
  		var ComponentConstructor = getComponentConstructor( options.parentFragment.ractive, options.template.e );
  		if ( ComponentConstructor ) {
  			return new Component( options, ComponentConstructor );
  		}

  		var tagName = options.template.e.toLowerCase();

  		var ElementConstructor = specialElements[ tagName ] || Element;
  		return new ElementConstructor( options );
  	}

  	var Item = constructors[ options.template.t ];

  	if ( !Item ) throw new Error( ("Unrecognised item type " + (options.template.t)) );

  	return new Item( options );
  }

  var ReferenceResolver = function ReferenceResolver ( fragment, reference, callback ) {
  	var this$1 = this;

  		this.fragment = fragment;
  	this.reference = normalise( reference );
  	this.callback = callback;

  	this.keys = splitKeypathI( reference );
  	this.resolved = false;

  	// TODO the consumer should take care of addUnresolved
  	// we attach to all the contexts between here and the root
  	// - whenever their values change, they can quickly
  	// check to see if we can resolve
  	while ( fragment ) {
  		if ( fragment.context ) {
  			fragment.context.addUnresolved( this$1.keys[0], this$1 );
  		}

  		fragment = fragment.componentParent || fragment.parent;
  	}
  };

  ReferenceResolver.prototype.attemptResolution = function attemptResolution () {
  	if ( this.resolved ) return;

  	var model = resolveAmbiguousReference( this.fragment, this.reference );

  	if ( model ) {
  		this.resolved = true;
  		this.callback( model );
  	}
  };

  ReferenceResolver.prototype.forceResolution = function forceResolution () {
  	if ( this.resolved ) return;

  	var model = this.fragment.findContext().joinAll( this.keys );
  	this.callback( model );
  	this.resolved = true;
  };

  ReferenceResolver.prototype.unbind = function unbind () {
  	var this$1 = this;

  		removeFromArray( this.fragment.unresolved, this );

  	if ( this.resolved ) return;

  	var fragment = this.fragment;
  	while ( fragment ) {
  		if ( fragment.context ) {
  			fragment.context.removeUnresolved( this$1.keys[0], this$1 );
  		}

  		fragment = fragment.componentParent || fragment.parent;
  	}
  };

  // TODO all this code needs to die
  function processItems ( items, values, guid, counter ) {
  	if ( counter === void 0 ) counter = 0;

  	return items.map( function ( item ) {
  		if ( item.type === TEXT ) {
  			return item.template;
  		}

  		if ( item.fragment ) {
  			if ( item.fragment.iterations ) {
  				return item.fragment.iterations.map( function ( fragment ) {
  					return processItems( fragment.items, values, guid, counter );
  				}).join( '' );
  			} else {
  				return processItems( item.fragment.items, values, guid, counter );
  			}
  		}

  		var placeholderId = "" + guid + "-" + (counter++);

  		values[ placeholderId ] = item.model ?
  			item.model.wrapper ?
  				item.model.wrapper.value :
  				item.model.get() :
  			undefined;

  		return '${' + placeholderId + '}';
  	}).join( '' );
  }

  function unrenderAndDestroy$1 ( item ) {
  	item.unrender( true );
  }

  var Fragment = function Fragment ( options ) {
  	this.owner = options.owner; // The item that owns this fragment - an element, section, partial, or attribute

  	this.isRoot = !options.owner.parentFragment;
  	this.parent = this.isRoot ? null : this.owner.parentFragment;
  	this.ractive = options.ractive || ( this.isRoot ? options.owner : this.parent.ractive );

  	this.componentParent = ( this.isRoot && this.ractive.component ) ? this.ractive.component.parentFragment : null;

  	this.context = null;
  	this.rendered = false;

  	// encapsulated styles should be inherited until they get applied by an element
  	this.cssIds = 'cssIds' in options ? options.cssIds : ( this.parent ? this.parent.cssIds : null );

  	this.resolvers = [];

  	this.dirty = false;
  	this.dirtyArgs = this.dirtyValue = true; // TODO getArgsList is nonsense - should deprecate legacy directives style

  	this.template = options.template || [];
  	this.createItems();
  };

  Fragment.prototype.bind = function bind$1 ( context ) {
  	this.context = context;
  	this.items.forEach( bind );
  	this.bound = true;

  	// in rare cases, a forced resolution (or similar) will cause the
  	// fragment to be dirty before it's even finished binding. In those
  	// cases we update immediately
  	if ( this.dirty ) this.update();

  	return this;
  };

  Fragment.prototype.bubble = function bubble () {
  	this.dirtyArgs = this.dirtyValue = true;

  	if ( !this.dirty ) {
  		this.dirty = true;

  		if ( this.isRoot ) { // TODO encapsulate 'is component root, but not overall root' check?
  			if ( this.ractive.component ) {
  				this.ractive.component.bubble();
  			} else if ( this.bound ) {
  				runloop.addFragment( this );
  			}
  		} else {
  			this.owner.bubble();
  		}
  	}
  };

  Fragment.prototype.createItems = function createItems () {
  	var this$1 = this;

  		this.items = this.template.map( function ( template, index ) {
  		return createItem({ parentFragment: this$1, template: template, index: index });
  	});
  };

  Fragment.prototype.detach = function detach () {
  	var docFrag = createDocumentFragment();
  	this.items.forEach( function ( item ) { return docFrag.appendChild( item.detach() ); } );
  	return docFrag;
  };

  Fragment.prototype.find = function find ( selector ) {
  	var this$1 = this;

  		var len = this.items.length;
  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		var found = this$1.items[i].find( selector );
  		if ( found ) return found;
  	}
  };

  Fragment.prototype.findAll = function findAll ( selector, query ) {
  	var this$1 = this;

  		if ( this.items ) {
  		var len = this.items.length;
  		var i;

  		for ( i = 0; i < len; i += 1 ) {
  			var item = this$1.items[i];

  			if ( item.findAll ) {
  				item.findAll( selector, query );
  			}
  		}
  	}

  	return query;
  };

  Fragment.prototype.findComponent = function findComponent ( name ) {
  	var this$1 = this;

  		var len = this.items.length;
  	var i;

  	for ( i = 0; i < len; i += 1 ) {
  		var found = this$1.items[i].findComponent( name );
  		if ( found ) return found;
  	}
  };

  Fragment.prototype.findAllComponents = function findAllComponents ( name, query ) {
  	var this$1 = this;

  		if ( this.items ) {
  		var len = this.items.length;
  		var i;

  		for ( i = 0; i < len; i += 1 ) {
  			var item = this$1.items[i];

  			if ( item.findAllComponents ) {
  				item.findAllComponents( name, query );
  			}
  		}
  	}

  	return query;
  };

  Fragment.prototype.findContext = function findContext () {
  	var fragment = this;
  	while ( !fragment.context ) fragment = fragment.parent;
  	return fragment.context;
  };

  Fragment.prototype.findNextNode = function findNextNode ( item ) {
  	// search for the next node going forward
  	var this$1 = this;

  		for ( var i = item.index + 1; i < this$1.items.length; i++ ) {
  		if ( !this$1.items[ i ] ) continue;

  		var node = this$1.items[ i ].firstNode( true );
  		if ( node ) return node;
  	}

  	// if this is the root fragment, and there are no more items,
  	// it means we're at the end...
  	if ( this.isRoot ) {
  		if ( this.ractive.component ) {
  			return this.ractive.component.parentFragment.findNextNode( this.ractive.component );
  		}

  		// TODO possible edge case with other content
  		// appended to this.ractive.el?
  		return null;
  	}

  	return this.owner.findNextNode( this ); // the argument is in case the parent is a RepeatedFragment
  };

  Fragment.prototype.findParentNode = function findParentNode () {
  	var fragment = this;

  	do {
  		if ( fragment.owner.type === ELEMENT ) {
  			return fragment.owner.node;
  		}

  		if ( fragment.isRoot && !fragment.ractive.component ) { // TODO encapsulate check
  			return fragment.ractive.el;
  		}

  		if ( fragment.owner.type === YIELDER ) {
  			fragment = fragment.owner.containerFragment;
  		} else {
  			fragment = fragment.componentParent || fragment.parent; // TODO ugh
  		}
  	} while ( fragment );

  	throw new Error( 'Could not find parent node' ); // TODO link to issue tracker
  };

  Fragment.prototype.findRepeatingFragment = function findRepeatingFragment () {
  	var fragment = this;
  	// TODO better check than fragment.parent.iterations
  	while ( fragment.parent && !fragment.isIteration ) {
  		fragment = fragment.parent || fragment.componentParent;
  	}

  	return fragment;
  };

  Fragment.prototype.firstNode = function firstNode ( skipParent ) {
  	var this$1 = this;

  		var node;
  	for ( var i = 0; i < this$1.items.length; i++ ) {
  		node = this$1.items[i].firstNode( true );

  		if ( node ) {
  			return node;
  		}
  	}

  	if ( skipParent ) return null;

  	return this.parent.findNextNode( this.owner );
  };

  // TODO ideally, this would be deprecated in favour of an
  // expression-like approach
  Fragment.prototype.getArgsList = function getArgsList () {
  	if ( this.dirtyArgs ) {
  		var values = {};
  		var source = processItems( this.items, values, this.ractive._guid );
  		var parsed = parseJSON( '[' + source + ']', values );

  		this.argsList = parsed ?
  			parsed.value :
  			[ this.toString() ];

  		this.dirtyArgs = false;
  	}

  	return this.argsList;
  };

  Fragment.prototype.rebind = function rebind$1 ( context ) {
  	this.context = context;

  	this.items.forEach( rebind );
  };

  Fragment.prototype.render = function render ( target, occupants ) {
  	if ( this.rendered ) throw new Error( 'Fragment is already rendered!' );
  	this.rendered = true;

  	this.items.forEach( function ( item ) { return item.render( target, occupants ); } );
  };

  Fragment.prototype.resetTemplate = function resetTemplate ( template ) {
  	var wasBound = this.bound;
  	var wasRendered = this.rendered;

  	// TODO ensure transitions are disabled globally during reset

  	if ( wasBound ) {
  		if ( wasRendered ) this.unrender( true );
  		this.unbind();
  	}

  	this.template = template;
  	this.createItems();

  	if ( wasBound ) {
  		this.bind( this.context );

  		if ( wasRendered ) {
  			var parentNode = this.findParentNode();
  			var anchor = this.parent ? this.parent.findNextNode( this.owner ) : null;

  			if ( anchor ) {
  				var docFrag = createDocumentFragment();
  				this.render( docFrag );
  				parentNode.insertBefore( docFrag, anchor );
  			} else {
  				this.render( parentNode );
  			}
  		}
  	}
  };

  Fragment.prototype.resolve = function resolve ( template, callback ) {
  	if ( !this.context ) {
  		return this.parent.resolve( template, callback );
  	}

  	var resolver = new ReferenceResolver( this, template, callback );
  	this.resolvers.push( resolver );

  	return resolver; // so we can e.g. force resolution
  };

  Fragment.prototype.toHtml = function toHtml () {
  	return this.toString();
  };

  Fragment.prototype.toString = function toString$1$$ ( escape ) {
  	return this.items.map( escape ? toEscapedString : toString$1 ).join( '' );
  };

  Fragment.prototype.unbind = function unbind$1 () {
  	this.items.forEach( unbind );
  	this.bound = false;

  	return this;
  };

  Fragment.prototype.unrender = function unrender$1 ( shouldDestroy ) {
  	this.items.forEach( shouldDestroy ? unrenderAndDestroy$1 : unrender );
  	this.rendered = false;
  };

  Fragment.prototype.update = function update$1 () {
  	if ( this.dirty ) {
  		if ( !this.updating ) {
  			this.dirty = false;
  			this.updating = true;
  			this.items.forEach( update );
  			this.updating = false;
  		} else if ( this.isRoot ) {
  			runloop.addFragmentToRoot( this );
  		}
  	}
  };

  Fragment.prototype.valueOf = function valueOf () {
  	if ( this.items.length === 1 ) {
  		return this.items[0].valueOf();
  	}

  	if ( this.dirtyValue ) {
  		var values = {};
  		var source = processItems( this.items, values, this.ractive._guid );
  		var parsed = parseJSON( source, values );

  		this.value = parsed ?
  			parsed.value :
  			this.toString();

  		this.dirtyValue = false;
  	}

  	return this.value;
  };

  // TODO should resetTemplate be asynchronous? i.e. should it be a case
  // of outro, update template, intro? I reckon probably not, since that
  // could be achieved with unrender-resetTemplate-render. Also, it should
  // conceptually be similar to resetPartial, which couldn't be async

  function Ractive$resetTemplate ( template ) {
  	templateConfigurator.init( null, this, { template: template });

  	var transitionsEnabled = this.transitionsEnabled;
  	this.transitionsEnabled = false;

  	// Is this is a component, we need to set the `shouldDestroy`
  	// flag, otherwise it will assume by default that a parent node
  	// will be detached, and therefore it doesn't need to bother
  	// detaching its own nodes
  	var component = this.component;
  	if ( component ) component.shouldDestroy = true;
  	this.unrender();
  	if ( component ) component.shouldDestroy = false;

  	// remove existing fragment and create new one
  	this.fragment.unbind().unrender( true );

  	this.fragment = new Fragment({
  		template: this.template,
  		root: this,
  		owner: this
  	});

  	var docFrag = createDocumentFragment();
  	this.fragment.bind( this.viewmodel ).render( docFrag );
  	this.el.insertBefore( docFrag, this.anchor );

  	this.transitionsEnabled = transitionsEnabled;
  }

  var reverse = makeArrayMethod( 'reverse' );

  function Ractive$set ( keypath, value ) {
  	var promise = runloop.start( this, true );

  	// Set multiple keypaths in one go
  	if ( isObject( keypath ) ) {
  		var map = keypath;

  		for ( var k in map ) {
  			if ( map.hasOwnProperty( k) ) {
  				set$1( this, k, map[k] );
  			}
  		}
  	}
  	// Set a single keypath
  	else {
  		set$1( this, keypath, value );
  	}

  	runloop.end();

  	return promise;
  }


  function set$1 ( ractive, keypath, value ) {
  	if ( typeof value === 'function' ) value = bind$1( value, ractive );

  	if ( /\*/.test( keypath ) ) {
  		ractive.viewmodel.findMatches( splitKeypathI( keypath ) ).forEach( function ( model ) {
  			model.set( value );
  		});
  	} else {
  		var model = ractive.viewmodel.joinAll( splitKeypathI( keypath ) );
  		model.set( value );
  	}
  }

  var shift$1 = makeArrayMethod( 'shift' );

  var sort = makeArrayMethod( 'sort' );

  var splice$1 = makeArrayMethod( 'splice' );

  function Ractive$subtract ( keypath, d ) {
  	return add( this, keypath, ( d === undefined ? -1 : -d ) );
  }

  var teardownHook$1 = new Hook( 'teardown' );

  // Teardown. This goes through the root fragment and all its children, removing observers
  // and generally cleaning up after itself

  function Ractive$teardown () {
  	var this$1 = this;

  	this.fragment.unbind();
  	this.viewmodel.teardown();

  	this._observers.forEach( cancel );

  	if ( this.fragment.rendered && this.el.__ractive_instances__ ) {
  		removeFromArray( this.el.__ractive_instances__, this );
  	}

  	this.shouldDestroy = true;
  	var promise = ( this.fragment.rendered ? this.unrender() : Promise$1.resolve() );

  	Object.keys( this._links ).forEach( function ( k ) { return this$1._links[k].unlink(); } );

  	teardownHook$1.fire( this );

  	return promise;
  }

  function Ractive$toggle ( keypath ) {
  	if ( typeof keypath !== 'string' ) {
  		throw new TypeError( badArguments );
  	}

  	var changes;

  	if ( /\*/.test( keypath ) ) {
  		changes = {};

  		this.viewmodel.findMatches( splitKeypathI( keypath ) ).forEach( function ( model ) {
  			changes[ model.getKeypath() ] = !model.get();
  		});

  		return this.set( changes );
  	}

  	return this.set( keypath, !this.get( keypath ) );
  }

  function Ractive$toCSS() {
  	var cssIds = [ this.cssId ].concat( this.findAllComponents().map( function ( c ) { return c.cssId; } ) );
  	var uniqueCssIds = Object.keys(cssIds.reduce( function ( ids, id ) { return (ids[id] = true, ids); }, {}));
  	return getCSS( uniqueCssIds );
  }

  function Ractive$toHTML () {
  	return this.fragment.toString( true );
  }

  function Ractive$transition ( name, node, params ) {

  	if ( node instanceof HTMLElement ) {
  		// good to go
  	}
  	else if ( isObject( node ) ) {
  		// omitted, use event node
  		params = node;
  	}

  	// if we allow query selector, then it won't work
  	// simple params like "fast"

  	// else if ( typeof node === 'string' ) {
  	// 	// query selector
  	// 	node = this.find( node )
  	// }

  	node = node || this.event.node;

  	if ( !node ) {
  		fatal( ("No node was supplied for transition " + name) );
  	}

  	var transition = new Transition( this, node, name, params );
  	var promise = runloop.start( this, true );
  	runloop.registerTransition( transition );
  	runloop.end();
  	return promise;
  }

  function unlink$1( here ) {
  	var ln = this._links[ here ];

  	if ( ln ) {
  		ln.unlink();
  		delete this._links[ here ];
  		return this.set( here, ln.intialValue );
  	} else {
  		return Promise$1.resolve( true );
  	}
  }

  var unrenderHook$1 = new Hook( 'unrender' );

  function Ractive$unrender () {
  	if ( !this.fragment.rendered ) {
  		warnIfDebug( 'ractive.unrender() was called on a Ractive instance that was not rendered' );
  		return Promise$1.resolve();
  	}

  	var promise = runloop.start( this, true );

  	// If this is a component, and the component isn't marked for destruction,
  	// don't detach nodes from the DOM unnecessarily
  	var shouldDestroy = !this.component || this.component.shouldDestroy || this.shouldDestroy;
  	this.fragment.unrender( shouldDestroy );

  	removeFromArray( this.el.__ractive_instances__, this );

  	unrenderHook$1.fire( this );

  	runloop.end();
  	return promise;
  }

  var unshift$1 = makeArrayMethod( 'unshift' );

  var updateHook = new Hook( 'update' );

  function Ractive$update ( keypath ) {
  	if ( keypath ) keypath = splitKeypathI( keypath );

  	var model = keypath ?
  		this.viewmodel.joinAll( keypath ) :
  		this.viewmodel;

  	if ( model.parent && model.parent.wrapper ) return this.update( model.parent.getKeypath( this ) );

  	var promise = runloop.start( this, true );

  	model.mark();
  	model.registerChange( model.getKeypath(), model.get() );

  	if ( keypath ) {
  		// there may be unresolved refs that are now resolvable up the context tree
  		var parent = model.parent;
  		while ( keypath.length && parent ) {
  			if ( parent.clearUnresolveds ) parent.clearUnresolveds( keypath.pop() );
  			parent = parent.parent;
  		}
  	}

  	// notify upstream of changes
  	model.notifyUpstream();

  	runloop.end();

  	updateHook.fire( this, model );

  	return promise;
  }

  function Ractive$updateModel ( keypath, cascade ) {
  	var promise = runloop.start( this, true );

  	if ( !keypath ) {
  		this.viewmodel.updateFromBindings( true );
  	} else {
  		this.viewmodel.joinAll( splitKeypathI( keypath ) ).updateFromBindings( cascade !== false );
  	}

  	runloop.end();

  	return promise;
  }

  var proto = {
  	add: Ractive$add,
  	animate: Ractive$animate,
  	detach: Ractive$detach,
  	find: Ractive$find,
  	findAll: Ractive$findAll,
  	findAllComponents: Ractive$findAllComponents,
  	findComponent: Ractive$findComponent,
  	findContainer: Ractive$findContainer,
  	findParent: Ractive$findParent,
  	fire: Ractive$fire,
  	get: Ractive$get,
  	getNodeInfo: getNodeInfo,
  	insert: Ractive$insert,
  	link: link$1,
  	merge: Ractive$merge,
  	observe: observe,
  	observeList: observeList,
  	observeOnce: observeOnce,
  	// TODO reinstate these
  	// observeListOnce,
  	off: Ractive$off,
  	on: Ractive$on,
  	once: Ractive$once,
  	pop: pop$1,
  	push: push$1,
  	render: Ractive$render,
  	reset: Ractive$reset,
  	resetPartial: resetPartial,
  	resetTemplate: Ractive$resetTemplate,
  	reverse: reverse,
  	set: Ractive$set,
  	shift: shift$1,
  	sort: sort,
  	splice: splice$1,
  	subtract: Ractive$subtract,
  	teardown: Ractive$teardown,
  	toggle: Ractive$toggle,
  	toCSS: Ractive$toCSS,
  	toCss: Ractive$toCSS,
  	toHTML: Ractive$toHTML,
  	toHtml: Ractive$toHTML,
  	transition: Ractive$transition,
  	unlink: unlink$1,
  	unrender: Ractive$unrender,
  	unshift: unshift$1,
  	update: Ractive$update,
  	updateModel: Ractive$updateModel
  };

  function wrap$1 ( method, superMethod, force ) {

  	if ( force || needsSuper( method, superMethod ) )  {

  		return function () {

  			var hasSuper = ( '_super' in this ), _super = this._super, result;

  			this._super = superMethod;

  			result = method.apply( this, arguments );

  			if ( hasSuper ) {
  				this._super = _super;
  			}

  			return result;
  		};
  	}

  	else {
  		return method;
  	}
  }

  function needsSuper ( method, superMethod ) {
  	return typeof superMethod === 'function' && /_super/.test( method );
  }

  function unwrap ( Child ) {
  	var options = {};

  	while ( Child ) {
  		addRegistries( Child, options );
  		addOtherOptions( Child, options );

  		if ( Child._Parent !== Ractive ) {
  			Child = Child._Parent;
  		} else {
  			Child = false;
  		}
  	}

  	return options;
  }

  function addRegistries ( Child, options ) {
  	registries.forEach( function ( r ) {
  		addRegistry(
  			r.useDefaults ? Child.prototype : Child,
  			options, r.name );
  	});
  }

  function addRegistry ( target, options, name ) {
  	var registry, keys = Object.keys( target[ name ] );

  	if ( !keys.length ) { return; }

  	if ( !( registry = options[ name ] ) ) {
  		registry = options[ name ] = {};
  	}

  	keys
  		.filter( function ( key ) { return !( key in registry ); } )
  		.forEach( function ( key ) { return registry[ key ] = target[ name ][ key ]; } );
  }

  function addOtherOptions ( Child, options ) {
  	Object.keys( Child.prototype ).forEach( function ( key ) {
  		if ( key === 'computed' ) { return; }

  		var value = Child.prototype[ key ];

  		if ( !( key in options ) ) {
  			options[ key ] = value._method ? value._method : value;
  		}

  		// is it a wrapped function?
  		else if ( typeof options[ key ] === 'function'
  				&& typeof value === 'function'
  				&& options[ key ]._method ) {

  			var result, needsSuper = value._method;

  			if ( needsSuper ) { value = value._method; }

  			// rewrap bound directly to parent fn
  			result = wrap$1( options[ key ]._method, value );

  			if ( needsSuper ) { result._method = result; }

  			options[ key ] = result;
  		}
  	});
  }

  function extend () {
  	var options = [], len = arguments.length;
  	while ( len-- ) options[ len ] = arguments[ len ];

  	if( !options.length ) {
  		return extendOne( this );
  	} else {
  		return options.reduce( extendOne, this );
  	}
  }

  function extendOne ( Parent, options ) {
  	if ( options === void 0 ) options = {};

  	var Child, proto;

  	// if we're extending with another Ractive instance...
  	//
  	//   var Human = Ractive.extend(...), Spider = Ractive.extend(...);
  	//   var Spiderman = Human.extend( Spider );
  	//
  	// ...inherit prototype methods and default options as well
  	if ( options.prototype instanceof Ractive ) {
  		options = unwrap( options );
  	}

  	Child = function ( options ) {
  		if ( !( this instanceof Child ) ) return new Child( options );

  		construct( this, options || {} );
  		initialise( this, options || {}, {} );
  	};

  	proto = create( Parent.prototype );
  	proto.constructor = Child;

  	// Static properties
  	defineProperties( Child, {
  		// alias prototype as defaults
  		defaults: { value: proto },

  		// extendable
  		extend: { value: extend, writable: true, configurable: true },

  		// Parent - for IE8, can't use Object.getPrototypeOf
  		_Parent: { value: Parent }
  	});

  	// extend configuration
  	config.extend( Parent, proto, options );

  	dataConfigurator.extend( Parent, proto, options );

  	if ( options.computed ) {
  		proto.computed = extendObj( create( Parent.prototype.computed ), options.computed );
  	}

  	Child.prototype = proto;

  	return Child;
  }

  function joinKeys () {
  	var keys = [], len = arguments.length;
  	while ( len-- ) keys[ len ] = arguments[ len ];

  	return keys.map( escapeKey ).join( '.' );
  }

  function splitKeypath ( keypath ) {
  	return splitKeypathI( keypath ).map( unescapeKey );
  }

  // Ractive.js makes liberal use of things like Array.prototype.indexOf. In
  // older browsers, these are made available via a shim - here, we do a quick
  // pre-flight check to make sure that either a) we're not in a shit browser,
  // or b) we're using a Ractive-legacy.js build
  var FUNCTION = 'function';

  if (
  	typeof Date.now !== FUNCTION                 ||
  	typeof String.prototype.trim !== FUNCTION    ||
  	typeof Object.keys !== FUNCTION              ||
  	typeof Array.prototype.indexOf !== FUNCTION  ||
  	typeof Array.prototype.forEach !== FUNCTION  ||
  	typeof Array.prototype.map !== FUNCTION      ||
  	typeof Array.prototype.filter !== FUNCTION   ||
  	( win && typeof win.addEventListener !== FUNCTION )
  ) {
  	throw new Error( 'It looks like you\'re attempting to use Ractive.js in an older browser. You\'ll need to use one of the \'legacy builds\' in order to continue - see http://docs.ractivejs.org/latest/legacy-builds for more information.' );
  }

  function Ractive ( options ) {
  	if ( !( this instanceof Ractive ) ) return new Ractive( options );

  	construct( this, options || {} );
  	initialise( this, options || {}, {} );
  }

  extendObj( Ractive.prototype, proto, defaults );
  Ractive.prototype.constructor = Ractive;

  // alias prototype as `defaults`
  Ractive.defaults = Ractive.prototype;

  // static properties
  defineProperties( Ractive, {

  	// debug flag
  	DEBUG:          { writable: true, value: true },
  	DEBUG_PROMISES: { writable: true, value: true },

  	// static methods:
  	extend:         { value: extend },
  	escapeKey:      { value: escapeKey },
  	getNodeInfo:    { value: staticInfo },
  	joinKeys:       { value: joinKeys },
  	parse:          { value: parse },
  	splitKeypath:   { value: splitKeypath },
  	unescapeKey:    { value: unescapeKey },
  	getCSS:         { value: getCSS },

  	// namespaced constructors
  	Promise:        { value: Promise$1 },

  	// support
  	enhance:        { writable: true, value: false },
  	svg:            { value: svg },
  	magic:          { value: magicSupported },

  	// version
  	VERSION:        { value: '0.8.1' },

  	// plugins
  	adaptors:       { writable: true, value: {} },
  	components:     { writable: true, value: {} },
  	decorators:     { writable: true, value: {} },
  	easing:         { writable: true, value: easing },
  	events:         { writable: true, value: {} },
  	interpolators:  { writable: true, value: interpolators },
  	partials:       { writable: true, value: {} },
  	transitions:    { writable: true, value: {} }
  });

  return Ractive;

}));
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{}],206:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  oninit: function oninit() {
    var _this = this;

    this.observe('value', function (newkey, oldkey, keypath) {
      var _get = _this.get();

      var min = _get.min;
      var max = _get.max;

      var value = Math.clamp(min, max, newkey);
      _this.animate('percentage', Math.round((value - min) / (max - min) * 100));
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[13,1,305],"t":7,"e":"div","a":{"class":"bar"},"f":[{"p":[14,3,326],"t":7,"e":"div","a":{"class":["barFill ",{"t":2,"r":"state","p":[14,23,346]}],"style":["width: ",{"t":2,"r":"percentage","p":[14,48,371]},"%"]}}," ",{"p":[15,3,398],"t":7,"e":"span","a":{"class":"barText"},"f":[{"t":16,"p":[15,25,420]}]}]}]};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],207:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var _constants = require('util/constants');

var _byond = require('util/byond');

component.exports = {
  computed: {
    clickable: function clickable() {
      if (this.get('enabled') && !this.get('state')) {
        return true;
      }
      return false;
    },
    enabled: function enabled() {
      if (this.get('config.status') === _constants.UI_INTERACTIVE) {
        return true;
      }
      return false;
    },
    styles: function styles() {
      var extra = '';
      if (this.get('tooltip-side')) extra = ' tooltip-' + this.get('tooltip-side');
      if (this.get('grid')) extra += ' gridable';
      if (this.get('enabled')) {
        var state = this.get('state');
        var style = this.get('style');
        if (!state) {
          return 'active normal ' + style + ' ' + extra;
        } else {
          return 'inactive ' + state + ' ' + extra;
        }
      } else {
        return 'inactive disabled ' + extra;
      }
    }
  },
  oninit: function oninit() {
    var _this = this;

    this.on('press', function (event) {
      var _get = _this.get();

      var action = _get.action;
      var params = _get.params;

      (0, _byond.act)(_this.get('config.ref'), action, params);
      event.node.blur();
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[48,1,1225],"t":7,"e":"span","a":{"class":["button ",{"t":2,"r":"styles","p":[48,21,1245]}],"unselectable":"on","data-tooltip":[{"t":2,"r":"tooltip","p":[51,17,1330]}]},"m":[{"t":4,"f":["tabindex='0'"],"r":"clickable","p":[50,3,1281]}],"v":{"mouseover-mousemove":"hover","mouseleave":"unhover","click-enter":{"n":[{"t":4,"f":["press"],"r":"clickable","p":[54,19,1423]}],"d":[]}},"f":[{"t":4,"f":[{"p":[56,5,1471],"t":7,"e":"i","a":{"class":["fa fa-",{"t":2,"r":"icon","p":[56,21,1487]}]}}],"n":50,"r":"icon","p":[55,3,1453]}," ",{"t":16,"p":[58,3,1516]}]}]};
module.exports = Ractive.extend(component.exports);

},{"ractive":205,"util/byond":270,"util/constants":271}],208:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"div","a":{"class":"display"},"f":[{"t":4,"f":[{"p":[3,5,44],"t":7,"e":"header","f":[{"p":[4,7,60],"t":7,"e":"h3","f":[{"t":2,"r":"title","p":[4,11,64]}]}," ",{"t":4,"f":[{"p":[6,9,110],"t":7,"e":"div","a":{"class":"buttonRight"},"f":[{"t":16,"n":"button","p":[6,34,135]}]}],"n":50,"r":"button","p":[5,7,86]}]}],"n":50,"r":"title","p":[2,3,25]}," ",{"p":[10,3,202],"t":7,"e":"article","f":[{"t":16,"p":[11,5,217]}]}]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],209:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  oninit: function oninit() {
    var _this = this;

    this.on('clear', function () {
      _this.set('value', '');
      _this.find('input').focus();
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[12,1,170],"t":7,"e":"input","a":{"type":"text","value":[{"t":2,"r":"value","p":[12,27,196]}],"placeholder":[{"t":2,"r":"placeholder","p":[12,51,220]}]}}," ",{"p":[13,1,240],"t":7,"e":"ui-button","a":{"icon":"refresh"},"v":{"press":"clear"}}]};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],210:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  data: {
    graph: require('paths-js/smooth-line'),
    xaccessor: function xaccessor(point) {
      return point.x;
    },
    yaccessor: function yaccessor(point) {
      return point.y;
    }
  },
  computed: {
    size: function size() {
      var points = this.get('points');
      return points[0].length;
    },
    scale: function scale() {
      var points = this.get('points');
      return Math.max.apply(Math, Array.map(points, function (a) {
        return Math.max.apply(Math, Array.map(a, function (p) {
          return p.y;
        }));
      }));
    },
    xaxis: function xaxis() {
      var xinc = this.get('xinc');
      var size = this.get('size');
      return Array.from(Array(size).keys()).filter(function (num) {
        return num && num % xinc == 0;
      });
    },
    yaxis: function yaxis() {
      var yinc = this.get('yinc');
      var scale = this.get('scale');
      return Array.from(Array(yinc).keys()).map(function (num) {
        return Math.round(scale * (++num / 100) * 10);
      });
    }
  },
  oninit: function oninit() {
    var _this = this;

    this.on({
      enter: function enter(event) {
        this.set('selected', event.index.count);
      },
      exit: function exit(event) {
        this.set('selected');
      }
    });
    window.addEventListener('resize', function (event) {
      _this.set('width', _this.el.clientWidth);
    });
  },
  onrender: function onrender() {
    this.set('width', this.el.clientWidth);
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[47,1,1269],"t":7,"e":"svg","a":{"class":"linegraph","width":"100%","height":[{"t":2,"x":{"r":["height"],"s":"_0+10"},"p":[47,45,1313]}]},"f":[{"p":[48,3,1334],"t":7,"e":"g","a":{"transform":"translate(0, 5)"},"f":[{"t":4,"f":[{"t":4,"f":[{"p":[51,9,1504],"t":7,"e":"line","a":{"x1":[{"t":2,"x":{"r":["xscale","."],"s":"_0(_1)"},"p":[51,19,1514]}],"x2":[{"t":2,"x":{"r":["xscale","."],"s":"_0(_1)"},"p":[51,38,1533]}],"y1":"0","y2":[{"t":2,"r":"height","p":[51,64,1559]}],"stroke":"darkgray"}}," ",{"t":4,"f":[{"p":[53,11,1635],"t":7,"e":"text","a":{"x":[{"t":2,"x":{"r":["xscale","."],"s":"_0(_1)"},"p":[53,20,1644]}],"y":[{"t":2,"x":{"r":["height"],"s":"_0-5"},"p":[53,38,1662]}],"text-anchor":"middle","fill":"white"},"f":[{"t":2,"x":{"r":["size",".","xfactor"],"s":"(_0-_1)*_2"},"p":[53,88,1712]}," ",{"t":2,"r":"xunit","p":[53,113,1737]}]}],"n":50,"x":{"r":["@index"],"s":"_0%2==0"},"p":[52,9,1600]}],"n":52,"r":"xaxis","p":[50,7,1479]}," ",{"t":4,"f":[{"p":[57,9,1820],"t":7,"e":"line","a":{"x1":"0","x2":[{"t":2,"r":"width","p":[57,26,1837]}],"y1":[{"t":2,"x":{"r":["yscale","."],"s":"_0(_1)"},"p":[57,41,1852]}],"y2":[{"t":2,"x":{"r":["yscale","."],"s":"_0(_1)"},"p":[57,60,1871]}],"stroke":"darkgray"}}," ",{"p":[58,9,1915],"t":7,"e":"text","a":{"x":"0","y":[{"t":2,"x":{"r":["yscale","."],"s":"_0(_1)-5"},"p":[58,24,1930]}],"text-anchor":"begin","fill":"white"},"f":[{"t":2,"x":{"r":[".","yfactor"],"s":"_0*_1"},"p":[58,76,1982]}," ",{"t":2,"r":"yunit","p":[58,92,1998]}]}],"n":52,"r":"yaxis","p":[56,7,1795]}," ",{"t":4,"f":[{"p":[61,9,2071],"t":7,"e":"path","a":{"d":[{"t":2,"x":{"r":["area.path"],"s":"_0.print()"},"p":[61,18,2080]}],"fill":[{"t":2,"rx":{"r":"colors","m":[{"t":30,"n":"curve"}]},"p":[61,47,2109]}],"opacity":"0.1"}}],"n":52,"i":"curve","r":"curves","p":[60,7,2039]}," ",{"t":4,"f":[{"p":[64,9,2200],"t":7,"e":"path","a":{"d":[{"t":2,"x":{"r":["line.path"],"s":"_0.print()"},"p":[64,18,2209]}],"stroke":[{"t":2,"rx":{"r":"colors","m":[{"t":30,"n":"curve"}]},"p":[64,49,2240]}],"fill":"none"}}],"n":52,"i":"curve","r":"curves","p":[63,7,2168]}," ",{"t":4,"f":[{"t":4,"f":[{"p":[68,11,2375],"t":7,"e":"circle","a":{"transform":["translate(",{"t":2,"r":".","p":[68,40,2404]},")"],"r":[{"t":2,"x":{"r":["selected","count"],"s":"_0==_1?10:4"},"p":[68,51,2415]}],"fill":[{"t":2,"rx":{"r":"colors","m":[{"t":30,"n":"curve"}]},"p":[68,89,2453]}]},"v":{"mouseenter":"enter","mouseleave":"exit"}}],"n":52,"i":"count","x":{"r":["line.path"],"s":"_0.points()"},"p":[67,9,2329]}],"n":52,"i":"curve","r":"curves","p":[66,7,2297]}," ",{"t":4,"f":[{"t":4,"f":[{"t":4,"f":[{"p":[74,13,2678],"t":7,"e":"text","a":{"transform":["translate(",{"t":2,"r":".","p":[74,40,2705]},") ",{"t":2,"x":{"r":["count","size"],"s":"_0<=_1/2?\"translate(15, 4)\":\"translate(-15, 4)\""},"p":[74,47,2712]}],"text-anchor":[{"t":2,"x":{"r":["count","size"],"s":"_0<=_1/2?\"start\":\"end\""},"p":[74,126,2791]}],"fill":"white"},"f":[{"t":2,"x":{"r":["count","item","yfactor"],"s":"_1[_0].y*_2"},"p":[75,15,2861]}," ",{"t":2,"r":"yunit","p":[75,43,2889]}," @ ",{"t":2,"x":{"r":["size","count","item","xfactor"],"s":"(_0-_2[_1].x)*_3"},"p":[75,55,2901]}," ",{"t":2,"r":"xunit","p":[75,92,2938]}]}],"n":50,"x":{"r":["selected","count"],"s":"_0==_1"},"p":[73,11,2638]}],"n":52,"i":"count","x":{"r":["line.path"],"s":"_0.points()"},"p":[72,9,2592]}],"n":52,"i":"curve","r":"curves","p":[71,7,2560]}," ",{"t":4,"f":[{"p":[81,9,3063],"t":7,"e":"g","a":{"transform":["translate(",{"t":2,"x":{"r":["width","curves.length","@index"],"s":"(_0/(_1+1))*(_2+1)"},"p":[81,33,3087]},", 10)"]},"f":[{"p":[82,11,3154],"t":7,"e":"circle","a":{"r":"4","fill":[{"t":2,"rx":{"r":"colors","m":[{"t":30,"n":"curve"}]},"p":[82,31,3174]}]}}," ",{"p":[83,11,3206],"t":7,"e":"text","a":{"x":"8","y":"4","fill":"white"},"f":[{"t":2,"rx":{"r":"legend","m":[{"t":30,"n":"curve"}]},"p":[83,42,3237]}]}]}],"n":52,"i":"curve","r":"curves","p":[80,7,3031]}],"x":{"r":["graph","points","xaccessor","yaccessor","width","height"],"s":"_0({data:_1,xaccessor:_2,yaccessor:_3,width:_4,height:_5})"},"p":[49,5,1371]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"paths-js/smooth-line":201,"ractive":205}],211:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"div","a":{"class":"notice"},"f":[{"t":16,"p":[2,3,24]}]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],212:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var _byond = require('util/byond');

var _dragresize = require('util/dragresize');

component.exports = {
  oninit: function oninit() {
    var _this = this;

    var onresize = _dragresize.resize.bind(this);
    var onrelease = function onrelease() {
      return _this.set({ resize: false, x: null, y: null });
    };

    this.observe('config.fancy', function (newkey, oldkey, keypath) {
      (0, _byond.winset)(_this.get('config.window'), 'can-resize', !newkey);

      if (newkey) {
        document.addEventListener('mousemove', onresize);
        document.addEventListener('mouseup', onrelease);
      } else {
        document.removeEventListener('mousemove', onresize);
        document.removeEventListener('mouseup', onrelease);
      }
    });

    this.on('resize', function () {
      return _this.toggle('resize');
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"t":4,"f":[{"p":[28,3,766],"t":7,"e":"div","a":{"class":"resize"},"v":{"mousedown":"resize"}}],"n":50,"r":"config.fancy","p":[27,1,742]}]};
module.exports = Ractive.extend(component.exports);

},{"ractive":205,"util/byond":270,"util/dragresize":272}],213:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"section","a":{"class":[{"t":4,"f":["candystripe"],"r":"candystripe","p":[1,17,16]}]},"f":[{"t":4,"f":[{"p":[3,5,84],"t":7,"e":"span","a":{"class":"label","style":[{"t":4,"f":["color:",{"t":2,"r":"labelcolor","p":[3,53,132]}],"r":"labelcolor","p":[3,32,111]}]},"f":[{"t":2,"r":"label","p":[3,84,163]},":"]}],"n":50,"r":"label","p":[2,3,65]}," ",{"t":4,"f":[{"t":16,"p":[6,5,215]}],"n":50,"r":"nowrap","p":[5,3,195]},{"t":4,"n":51,"f":[{"p":[8,5,242],"t":7,"e":"div","a":{"class":"content","style":[{"t":4,"f":["float:right;"],"r":"right","p":[8,33,270]}]},"f":[{"t":16,"p":[9,7,312]}]}],"r":"nowrap"}]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],214:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"div","a":{"class":"subdisplay"},"f":[{"t":4,"f":[{"p":[3,5,47],"t":7,"e":"header","f":[{"p":[4,7,63],"t":7,"e":"h4","f":[{"t":2,"r":"title","p":[4,11,67]}]}," ",{"t":4,"f":[{"t":16,"n":"button","p":[5,21,103]}],"n":50,"r":"button","p":[5,7,89]}]}],"n":50,"r":"title","p":[2,3,28]}," ",{"p":[8,3,156],"t":7,"e":"article","f":[{"t":16,"p":[9,5,171]}]}]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],215:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  oninit: function oninit() {
    var _this = this;

    this.set('active', this.findComponent('tab').get('name'));
    this.on('switch', function (event) {
      _this.set('active', event.node.textContent.trim()); // Hack but it works...
    });

    this.observe('active', function (newkey, oldkey, path) {
      for (var _iterator = _this.findAllComponents('tab'), _isArray = Array.isArray(_iterator), _i = 0, _iterator = _isArray ? _iterator : _iterator[Symbol.iterator]();;) {
        var _ref;

        if (_isArray) {
          if (_i >= _iterator.length) break;
          _ref = _iterator[_i++];
        } else {
          _i = _iterator.next();
          if (_i.done) break;
          _ref = _i.value;
        }

        var tab = _ref;

        tab.set('shown', tab.get('name') === newkey);
      }
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" "," ",{"p":[20,1,524],"t":7,"e":"header","f":[{"t":4,"f":[{"p":[22,5,556],"t":7,"e":"ui-button","a":{"pane":[{"t":2,"r":".","p":[22,22,573]}]},"v":{"press":"switch"},"f":[{"t":2,"r":".","p":[22,47,598]}]}],"n":52,"r":"tabs","p":[21,3,536]}]}," ",{"p":[25,1,641],"t":7,"e":"ui-display","f":[{"t":8,"r":"content","p":[26,3,657]}]}]};
component.exports.components = component.exports.components || {};
var components = {
  "tab": require("components/tabs/tab.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);

},{"components/tabs/tab.ract":216,"ractive":205}],216:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"t":16,"p":[2,3,17]}],"n":50,"r":"shown","p":[1,1,0]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],217:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var _constants = require('util/constants');

var _byond = require('util/byond');

var _dragresize = require('util/dragresize');

component.exports = {
  computed: {
    visualStatus: function visualStatus() {
      switch (this.get('config.status')) {
        case _constants.UI_INTERACTIVE:
          return 'good';
        case _constants.UI_UPDATE:
          return 'average';
        case _constants.UI_DISABLED:
          return 'bad';
        default:
          return 'bad';
      }
    }
  },
  oninit: function oninit() {
    var _this = this;

    var ondrag = _dragresize.drag.bind(this);
    var onrelease = function onrelease(event) {
      return _this.set({ drag: false, x: null, y: null });
    };

    this.observe('config.fancy', function (newkey, oldkey, keypath) {
      (0, _byond.winset)(_this.get('config.window'), 'titlebar', !newkey);

      if (newkey) {
        document.addEventListener('mousemove', ondrag);
        document.addEventListener('mouseup', onrelease);
      } else {
        document.removeEventListener('mousemove', ondrag);
        document.removeEventListener('mouseup', onrelease);
      }
    });

    this.on({
      drag: function drag() {
        this.toggle('drag');
      },
      close: function close() {
        (0, _byond.winset)(this.get('config.window'), 'is-visible', false);
        window.location.href = (0, _byond.href)({ command: 'uiclose ' + this.get('config.ref') }, 'winset');
      },
      minimize: function minimize() {
        (0, _byond.winset)(this.get('config.window'), 'is-minimized', true);
      }
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[49,1,1382],"t":7,"e":"header","a":{"class":"titlebar"},"v":{"mousedown":"drag"},"f":[{"p":[50,3,1431],"t":7,"e":"i","a":{"class":["statusicon fa fa-eye fa-2x ",{"t":2,"r":"visualStatus","p":[50,40,1468]}]}}," ",{"p":[51,3,1494],"t":7,"e":"span","a":{"class":"title"},"f":[{"t":16,"p":[51,23,1514]}]}," ",{"t":4,"f":[{"p":[53,5,1560],"t":7,"e":"i","a":{"class":"minimize fa fa-minus fa-2x"},"v":{"click":"minimize"}}," ",{"p":[54,5,1628],"t":7,"e":"i","a":{"class":"close fa fa-close fa-2x"},"v":{"click":"close"}}],"n":50,"r":"config.fancy","p":[52,3,1534]}]}]};
module.exports = Ractive.extend(component.exports);

},{"ractive":205,"util/byond":270,"util/constants":271,"util/dragresize":272}],218:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var versions = [11, 10, 9, 8];

component.exports = {
  data: {
    userAgent: navigator.userAgent
  },
  computed: {
    ie: function ie() {
      if (document.documentMode) return document.documentMode;
      for (var version in versions) {
        var div = document.createElement('div');
        div.innerHTML = '<!--[if IE ' + version + ']><span></span><![endif]-->';
        if (div.getElementsByTagName('span').length) return version;
      }
      return undefined;
    }
  },
  oninit: function oninit() {
    var _this = this;

    this.on('debug', function () {
      return _this.toggle('debug');
    });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"t":4,"f":[{"p":[27,3,662],"t":7,"e":"ui-notice","f":[{"p":[28,5,679],"t":7,"e":"span","f":["You have an old (IE",{"t":2,"r":"ie","p":[28,30,704]},"), end-of-life (click 'EOL Info' for more information) version of Internet Explorer installed."]},{"p":[28,137,811],"t":7,"e":"br"}," ",{"p":[29,5,822],"t":7,"e":"span","f":["To upgrade, click 'Upgrade IE' to download IE11 from Microsoft."]},{"p":[29,81,898],"t":7,"e":"br"}," ",{"p":[30,5,909],"t":7,"e":"span","f":["If you are unable to upgrade directly, click 'IE VMs' to download a VM with IE11 or Edge from Microsoft."]},{"p":[30,122,1026],"t":7,"e":"br"}," ",{"p":[31,5,1037],"t":7,"e":"span","f":["Otherwise, click 'No Frills' below to disable potentially incompatible features (and this message)."]}," ",{"p":[32,5,1155],"t":7,"e":"hr"}," ",{"p":[33,5,1166],"t":7,"e":"ui-button","a":{"icon":"close","action":"tgui:nofrills"},"f":["No Frills"]}," ",{"p":[34,5,1240],"t":7,"e":"ui-button","a":{"icon":"internet-explorer","action":"tgui:link","params":"{\"url\": \"http://windows.microsoft.com/en-us/internet-explorer/download-ie\"}"},"f":["Upgrade IE"]}," ",{"p":[36,5,1416],"t":7,"e":"ui-button","a":{"icon":"edge","action":"tgui:link","params":"{\"url\": \"https://dev.windows.com/en-us/microsoft-edge/tools/vms\"}"},"f":["IE VMs"]}," ",{"p":[38,5,1565],"t":7,"e":"ui-button","a":{"icon":"info","action":"tgui:link","params":"{\"url\": \"https://support.microsoft.com/en-us/lifecycle#gp/Microsoft-Internet-Explorer\"}"},"f":["EOL Info"]}," ",{"p":[40,5,1738],"t":7,"e":"ui-button","a":{"icon":"bug"},"v":{"press":"debug"},"f":["Debug Info"]}," ",{"t":4,"f":[{"p":[42,7,1826],"t":7,"e":"hr"}," ",{"p":[43,7,1839],"t":7,"e":"span","f":["Detected: IE",{"t":2,"r":"ie","p":[43,25,1857]}]},{"p":[43,38,1870],"t":7,"e":"br"}," ",{"p":[44,7,1883],"t":7,"e":"span","f":["User Agent: ",{"t":2,"r":"userAgent","p":[44,25,1901]}]}],"n":50,"r":"debug","p":[41,5,1805]}]}],"n":50,"x":{"r":["config.fancy","ie"],"s":"_0&&_1&&_1<11"},"p":[26,1,621]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],219:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[" "," "," "," "," ",{"p":[7,1,267],"t":7,"e":"ui-notice","f":[{"t":4,"f":[{"p":[9,5,312],"t":7,"e":"ui-section","a":{"label":"Interface Lock"},"f":[{"p":[10,7,355],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"lock\":\"unlock\""},"p":[10,24,372]}],"action":"lock"},"f":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[10,75,423]}]}]}],"n":50,"r":"data.siliconUser","p":[8,3,282]},{"t":4,"n":51,"f":[{"p":[13,5,514],"t":7,"e":"span","f":["Swipe an ID card to ",{"t":2,"x":{"r":["data.locked"],"s":"_0?\"unlock\":\"lock\""},"p":[13,31,540]}," this interface."]}],"r":"data.siliconUser"}]}," ",{"p":[16,1,625],"t":7,"e":"status"}," ",{"t":4,"f":[{"t":4,"f":[{"p":[19,7,719],"t":7,"e":"ui-display","a":{"title":"Air Controls"},"f":[{"p":[20,9,762],"t":7,"e":"ui-section","f":[{"p":[21,11,786],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.atmos_alarm"],"s":"_0?\"exclamation-triangle\":\"exclamation\""},"p":[21,28,803]}],"style":[{"t":2,"x":{"r":["data.atmos_alarm"],"s":"_0?\"caution\":null"},"p":[21,98,873]}],"action":[{"t":2,"x":{"r":["data.atmos_alarm"],"s":"_0?\"reset\":\"alarm\""},"p":[22,23,937]}]},"f":["Area Atmosphere Alarm"]}]}," ",{"p":[24,9,1045],"t":7,"e":"ui-section","f":[{"p":[25,11,1069],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.mode"],"s":"_0==3?\"exclamation-triangle\":\"exclamation\""},"p":[25,28,1086]}],"style":[{"t":2,"x":{"r":["data.mode"],"s":"_0==3?\"danger\":null"},"p":[25,96,1154]}],"action":"mode","params":["{\"mode\": ",{"t":2,"x":{"r":["data.mode"],"s":"_0==3?1:3"},"p":[26,44,1236]},"}"]},"f":["Panic Siphon"]}]}," ",{"p":[28,9,1322],"t":7,"e":"br"}," ",{"p":[29,9,1337],"t":7,"e":"ui-section","f":[{"p":[30,11,1361],"t":7,"e":"ui-button","a":{"icon":"sign-out","action":"tgui:view","params":"{\"screen\": \"vents\"}"},"f":["Vent Controls"]}]}," ",{"p":[32,9,1494],"t":7,"e":"ui-section","f":[{"p":[33,11,1518],"t":7,"e":"ui-button","a":{"icon":"filter","action":"tgui:view","params":"{\"screen\": \"scrubbers\"}"},"f":["Scrubber Controls"]}]}," ",{"p":[35,9,1657],"t":7,"e":"ui-section","f":[{"p":[36,11,1681],"t":7,"e":"ui-button","a":{"icon":"cog","action":"tgui:view","params":"{\"screen\": \"modes\"}"},"f":["Operating Mode"]}]}," ",{"p":[38,9,1810],"t":7,"e":"ui-section","f":[{"p":[39,11,1834],"t":7,"e":"ui-button","a":{"icon":"bar-chart","action":"tgui:view","params":"{\"screen\": \"thresholds\"}"},"f":["Alarm Thresholds"]}]}]}],"n":50,"x":{"r":["config.screen"],"s":"_0==\"home\""},"p":[18,3,680]},{"t":4,"n":51,"f":[{"t":4,"n":50,"x":{"r":["config.screen"],"s":"_0==\"vents\""},"f":[{"p":[43,5,2032],"t":7,"e":"vents"}]},{"t":4,"n":50,"x":{"r":["config.screen"],"s":"(!(_0==\"vents\"))&&(_0==\"scrubbers\")"},"f":[" ",{"p":[45,5,2089],"t":7,"e":"scrubbers"}]},{"t":4,"n":50,"x":{"r":["config.screen"],"s":"(!(_0==\"vents\"))&&((!(_0==\"scrubbers\"))&&(_0==\"modes\"))"},"f":[" ",{"p":[47,5,2146],"t":7,"e":"modes"}]},{"t":4,"n":50,"x":{"r":["config.screen"],"s":"(!(_0==\"vents\"))&&((!(_0==\"scrubbers\"))&&((!(_0==\"modes\"))&&(_0==\"thresholds\")))"},"f":[" ",{"p":[49,5,2204],"t":7,"e":"thresholds"}]}],"x":{"r":["config.screen"],"s":"_0==\"home\""}}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"!_0||_1"},"p":[17,1,636]}],"e":{}};
component.exports.components = component.exports.components || {};
var components = {
  "vents": require("./airalarm/vents.ract"),
  "modes": require("./airalarm/modes.ract"),
  "thresholds": require("./airalarm/thresholds.ract"),
  "status": require("./airalarm/status.ract"),
  "scrubbers": require("./airalarm/scrubbers.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);
},{"./airalarm/modes.ract":221,"./airalarm/scrubbers.ract":222,"./airalarm/status.ract":223,"./airalarm/thresholds.ract":224,"./airalarm/vents.ract":225,"ractive":205}],220:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-button","a":{"icon":"arrow-left","action":"tgui:view","params":"{\"screen\": \"home\"}"},"f":["Back"]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],221:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[" ",{"p":{"button":[{"p":[5,5,115],"t":7,"e":"back"}]},"t":7,"e":"ui-display","a":{"title":"Operating Modes","button":0},"f":[" ",{"t":4,"f":[{"p":[8,5,168],"t":7,"e":"ui-section","f":[{"p":[9,7,188],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["selected"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[9,24,205]}],"state":[{"t":2,"x":{"r":["selected","danger"],"s":"_0?_1?\"danger\":\"selected\":null"},"p":[10,16,267]}],"action":"mode","params":["{\"mode\": ",{"t":2,"r":"mode","p":[11,40,361]},"}"]},"f":[{"t":2,"r":"name","p":[11,51,372]}]}]}],"n":52,"r":"data.modes","p":[7,3,142]}]}],"e":{}};
component.exports.components = component.exports.components || {};
var components = {
  "back": require("./back.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);
},{"./back.ract":220,"ractive":205}],222:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[" ",{"p":{"button":[{"p":[5,5,117],"t":7,"e":"back"}]},"t":7,"e":"ui-display","a":{"title":"Scrubber Controls","button":0},"f":[" ",{"t":4,"f":[{"p":[8,5,174],"t":7,"e":"ui-subdisplay","a":{"title":[{"t":2,"r":"long_name","p":[8,27,196]}]},"f":[{"p":[9,7,219],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[10,9,255],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["power"],"s":"_0?\"power-off\":\"close\""},"p":[10,26,272]}],"style":[{"t":2,"x":{"r":["power"],"s":"_0?\"selected\":null"},"p":[10,68,314]}],"action":"power","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[11,46,391]},"\", \"val\": ",{"t":2,"x":{"r":["power"],"s":"+!_0"},"p":[11,66,411]},"}"]},"f":[{"t":2,"x":{"r":["power"],"s":"_0?\"On\":\"Off\""},"p":[11,80,425]}]}]}," ",{"p":[13,7,490],"t":7,"e":"ui-section","a":{"label":"Mode"},"f":[{"p":[14,9,525],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["scrubbing"],"s":"_0?\"filter\":\"sign-in\""},"p":[14,26,542]}],"style":[{"t":2,"x":{"r":["scrubbing"],"s":"_0?null:\"danger\""},"p":[14,71,587]}],"action":"scrubbing","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[15,50,670]},"\", \"val\": ",{"t":2,"x":{"r":["scrubbing"],"s":"+!_0"},"p":[15,70,690]},"}"]},"f":[{"t":2,"x":{"r":["scrubbing"],"s":"_0?\"Scrubbing\":\"Siphoning\""},"p":[15,88,708]}]}]}," ",{"p":[17,7,790],"t":7,"e":"ui-section","a":{"label":"Range"},"f":[{"p":[18,9,826],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["widenet"],"s":"_0?\"expand\":\"compress\""},"p":[18,26,843]}],"style":[{"t":2,"x":{"r":["widenet"],"s":"_0?\"selected\":null"},"p":[18,70,887]}],"action":"widenet","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[19,48,968]},"\", \"val\": ",{"t":2,"x":{"r":["widenet"],"s":"+!_0"},"p":[19,68,988]},"}"]},"f":[{"t":2,"x":{"r":["widenet"],"s":"_0?\"Expanded\":\"Normal\""},"p":[19,84,1004]}]}]}," ",{"p":[21,7,1080],"t":7,"e":"ui-section","a":{"label":"Filters"},"f":[{"p":[22,9,1118],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["filter_co2"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[22,26,1135]}],"style":[{"t":2,"x":{"r":["filter_co2"],"s":"_0?\"selected\":null"},"p":[22,81,1190]}],"action":"co2_scrub","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[23,50,1276]},"\", \"val\": ",{"t":2,"x":{"r":["filter_co2"],"s":"+!_0"},"p":[23,70,1296]},"}"]},"f":["CO2"]}," ",{"p":[24,9,1340],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["filter_n2o"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[24,26,1357]}],"style":[{"t":2,"x":{"r":["filter_n2o"],"s":"_0?\"selected\":null"},"p":[24,81,1412]}],"action":"n2o_scrub","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[25,50,1498]},"\", \"val\": ",{"t":2,"x":{"r":["filter_n2o"],"s":"+!_0"},"p":[25,70,1518]},"}"]},"f":["N2O"]}," ",{"p":[26,9,1562],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["filter_toxins"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[26,26,1579]}],"style":[{"t":2,"x":{"r":["filter_toxins"],"s":"_0?\"selected\":null"},"p":[26,84,1637]}],"action":"tox_scrub","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[27,50,1726]},"\", \"val\": ",{"t":2,"x":{"r":["filter_toxins"],"s":"+!_0"},"p":[27,70,1746]},"}"]},"f":["Plasma"]}," ",{"p":[28,3,1790],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["filter_bz"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[28,20,1807]}],"style":[{"t":2,"x":{"r":["filter_bz"],"s":"_0?\"selected\":null"},"p":[28,74,1861]}],"action":"bz_scrub","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[29,43,1939]},"\", \"val\": ",{"t":2,"x":{"r":["filter_bz"],"s":"+!_0"},"p":[29,63,1959]},"}"]},"f":["BZ"]}]}]}],"n":52,"r":"data.scrubbers","p":[7,3,144]},{"t":4,"n":51,"f":[{"p":[33,5,2052],"t":7,"e":"span","a":{"class":"bad"},"f":["Error: No scrubbers connected."]}],"r":"data.scrubbers"}]}],"e":{}};
component.exports.components = component.exports.components || {};
var components = {
  "back": require("./back.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);
},{"./back.ract":220,"ractive":205}],223:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":"Air Status"},"f":[{"t":4,"f":[{"t":4,"f":[{"p":[4,7,110],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"name","p":[4,26,129]}]},"f":[{"p":[5,6,146],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["danger_level"],"s":"_0==2?\"bad\":_0==1?\"average\":\"good\""},"p":[5,19,159]}]},"f":[{"t":2,"x":{"r":["value"],"s":"Math.fixed(_0,2)"},"p":[6,5,237]},{"t":2,"r":"unit","p":[6,29,261]}]}]}],"n":52,"r":"adata.environment_data","p":[3,5,70]}," ",{"p":[10,5,322],"t":7,"e":"ui-section","a":{"label":"Local Status"},"f":[{"p":[11,7,363],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.danger_level"],"s":"_0==2?\"bad bold\":_0==1?\"average bold\":\"good\""},"p":[11,20,376]}]},"f":[{"t":2,"x":{"r":["data.danger_level"],"s":"_0==2?\"Danger (Internals Required)\":_0==1?\"Caution\":\"Optimal\""},"p":[12,6,475]}]}]}," ",{"p":[15,5,619],"t":7,"e":"ui-section","a":{"label":"Area Status"},"f":[{"p":[16,7,659],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.atmos_alarm","data.fire_alarm"],"s":"_0||_1?\"bad bold\":\"good\""},"p":[16,20,672]}]},"f":[{"t":2,"x":{"r":["data.atmos_alarm","fire_alarm"],"s":"_0?\"Atmosphere Alarm\":_1?\"Fire Alarm\":\"Nominal\""},"p":[17,8,744]}]}]}],"n":50,"r":"data.environment_data","p":[2,3,35]},{"t":4,"n":51,"f":[{"p":[21,5,876],"t":7,"e":"ui-section","a":{"label":"Warning"},"f":[{"p":[22,7,912],"t":7,"e":"span","a":{"class":"bad bold"},"f":["Cannot obtain air sample for analysis."]}]}],"r":"data.environment_data"}," ",{"t":4,"f":[{"p":[26,5,1040],"t":7,"e":"ui-section","a":{"label":"Warning"},"f":[{"p":[27,7,1076],"t":7,"e":"span","a":{"class":"bad bold"},"f":["Safety measures offline. Device may exhibit abnormal behavior."]}]}],"n":50,"r":"data.emagged","p":[25,3,1014]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],224:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.css = "  th, td {\r\n    padding-right: 16px;\r\n    text-align: left;\r\n  }";
component.exports.template = {"v":3,"t":[" ",{"p":{"button":[{"p":[5,5,116],"t":7,"e":"back"}]},"t":7,"e":"ui-display","a":{"title":"Alarm Thresholds","button":0},"f":[" ",{"p":[7,3,143],"t":7,"e":"table","f":[{"p":[8,5,156],"t":7,"e":"thead","f":[{"p":[8,12,163],"t":7,"e":"tr","f":[{"p":[9,7,175],"t":7,"e":"th"}," ",{"p":[10,7,192],"t":7,"e":"th","f":[{"p":[10,11,196],"t":7,"e":"span","a":{"class":"bad"},"f":["min2"]}]}," ",{"p":[11,7,238],"t":7,"e":"th","f":[{"p":[11,11,242],"t":7,"e":"span","a":{"class":"average"},"f":["min1"]}]}," ",{"p":[12,7,288],"t":7,"e":"th","f":[{"p":[12,11,292],"t":7,"e":"span","a":{"class":"average"},"f":["max1"]}]}," ",{"p":[13,7,338],"t":7,"e":"th","f":[{"p":[13,11,342],"t":7,"e":"span","a":{"class":"bad"},"f":["max2"]}]}]}]}," ",{"p":[15,5,401],"t":7,"e":"tbody","f":[{"t":4,"f":[{"p":[16,32,441],"t":7,"e":"tr","f":[{"p":[17,9,455],"t":7,"e":"th","f":[{"t":3,"r":"name","p":[17,13,459]}]}," ",{"t":4,"f":[{"p":[18,27,502],"t":7,"e":"td","f":[{"p":[19,11,518],"t":7,"e":"ui-button","a":{"action":"threshold","params":["{\"env\": \"",{"t":2,"r":"env","p":[19,58,565]},"\", \"var\": \"",{"t":2,"r":"val","p":[19,76,583]},"\"}"]},"f":[{"t":2,"x":{"r":["selected"],"s":"Math.fixed(_0,2)"},"p":[19,87,594]}]}]}],"n":52,"r":"settings","p":[18,9,484]}]}],"n":52,"r":"data.thresholds","p":[16,7,416]}]}," ",{"p":[23,3,697],"t":7,"e":"table","f":[]}]}]}," "],"e":{}};
component.exports.components = component.exports.components || {};
var components = {
  "back": require("./back.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);
},{"./back.ract":220,"ractive":205}],225:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[" ",{"p":{"button":[{"p":[5,5,113],"t":7,"e":"back"}]},"t":7,"e":"ui-display","a":{"title":"Vent Controls","button":0},"f":[" ",{"t":4,"f":[{"p":[8,5,166],"t":7,"e":"ui-subdisplay","a":{"title":[{"t":2,"r":"long_name","p":[8,27,188]}]},"f":[{"p":[9,7,211],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[10,9,247],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["power"],"s":"_0?\"power-off\":\"close\""},"p":[10,26,264]}],"style":[{"t":2,"x":{"r":["power"],"s":"_0?\"selected\":null"},"p":[10,68,306]}],"action":"power","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[11,46,383]},"\", \"val\": ",{"t":2,"x":{"r":["power"],"s":"+!_0"},"p":[11,66,403]},"}"]},"f":[{"t":2,"x":{"r":["power"],"s":"_0?\"On\":\"Off\""},"p":[11,80,417]}]}]}," ",{"p":[13,7,482],"t":7,"e":"ui-section","a":{"label":"Mode"},"f":[{"p":[14,9,517],"t":7,"e":"span","f":[{"t":2,"x":{"r":["direction"],"s":"_0==\"release\"?\"Pressurizing\":\"Siphoning\""},"p":[14,15,523]}]}]}," ",{"p":[16,7,616],"t":7,"e":"ui-section","a":{"label":"Pressure Regulator"},"f":[{"p":[17,9,665],"t":7,"e":"ui-button","a":{"icon":"sign-in","style":[{"t":2,"x":{"r":["incheck"],"s":"_0?\"selected\":null"},"p":[17,42,698]}],"action":"incheck","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[18,48,779]},"\", \"val\": ",{"t":2,"r":"checks","p":[18,68,799]},"}"]},"f":["Internal"]}," ",{"p":[19,9,842],"t":7,"e":"ui-button","a":{"icon":"sign-out","style":[{"t":2,"x":{"r":["excheck"],"s":"_0?\"selected\":null"},"p":[19,43,876]}],"action":"excheck","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[20,48,957]},"\", \"val\": ",{"t":2,"r":"checks","p":[20,68,977]},"}"]},"f":["External"]}]}," ",{"p":[22,7,1039],"t":7,"e":"ui-section","a":{"label":"Target Pressure"},"f":[{"p":[23,9,1085],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"set_external_pressure","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[24,31,1172]},"\"}"]},"f":[{"t":2,"x":{"r":["external"],"s":"Math.fixed(_0)"},"p":[24,45,1186]}]}," ",{"p":[25,9,1232],"t":7,"e":"ui-button","a":{"icon":"refresh","state":[{"t":2,"x":{"r":["extdefault"],"s":"_0?\"disabled\":null"},"p":[25,42,1265]}],"action":"reset_external_pressure","params":["{\"id_tag\": \"",{"t":2,"r":"id_tag","p":[26,31,1365]},"\"}"]},"f":["Reset"]}]}]}],"n":52,"r":"data.vents","p":[7,3,140]},{"t":4,"n":51,"f":[{"p":[30,5,1457],"t":7,"e":"span","a":{"class":"bad"},"f":["Error: No vents connected."]}],"r":"data.vents"}]}],"e":{}};
component.exports.components = component.exports.components || {};
var components = {
  "back": require("./back.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);
},{"./back.ract":220,"ractive":205}],226:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.css = "  table {\r\n    width: 100%;\r\n    border-spacing: 2px;\r\n  }\r\n  th {\r\n    text-align: left;\r\n  }\r\n  td {\r\n    vertical-align: top;\r\n  }\r\n  td .button {\r\n    margin-top: 4px\r\n  }";
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","f":[{"p":[2,3,16],"t":7,"e":"ui-section","f":[{"p":[3,5,34],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.oneAccess"],"s":"_0?\"unlock\":\"lock\""},"p":[3,22,51]}],"action":"one_access"},"f":[{"t":2,"x":{"r":["data.oneAccess"],"s":"_0?\"One\":\"All\""},"p":[3,82,111]}," Required"]}," ",{"p":[4,5,172],"t":7,"e":"ui-button","a":{"icon":"refresh","action":"clear"},"f":["Clear"]}]}," ",{"p":[6,3,251],"t":7,"e":"hr"}," ",{"p":[7,3,260],"t":7,"e":"table","f":[{"p":[8,3,271],"t":7,"e":"thead","f":[{"p":[9,4,283],"t":7,"e":"tr","f":[{"t":4,"f":[{"p":[10,5,315],"t":7,"e":"th","f":[{"p":[10,9,319],"t":7,"e":"span","a":{"class":"highlight bold"},"f":[{"t":2,"r":"name","p":[10,38,348]}]}]}],"n":52,"r":"data.regions","p":[9,8,287]}]}]}," ",{"p":[13,3,403],"t":7,"e":"tbody","f":[{"p":[14,4,415],"t":7,"e":"tr","f":[{"t":4,"f":[{"p":[15,5,447],"t":7,"e":"td","f":[{"t":4,"f":[{"p":[16,11,481],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["req"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[16,28,498]}],"style":[{"t":2,"x":{"r":["req"],"s":"_0?\"selected\":null"},"p":[16,76,546]}],"action":"set","params":["{\"access\": \"",{"t":2,"r":"id","p":[17,46,621]},"\"}"]},"f":[{"t":2,"r":"name","p":[17,56,631]}]}," ",{"p":[18,9,661],"t":7,"e":"br"}],"n":52,"r":"accesses","p":[15,9,451]}]}],"n":52,"r":"data.regions","p":[14,8,419]}]}]}]}]}," "],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],227:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  data: {
    powerState: function powerState(status) {
      switch (status) {
        case 2:
          return 'good';
        case 1:
          return 'average';
        default:
          return 'bad';
      }
    }
  },
  computed: {
    malfAction: function malfAction() {
      switch (this.get('data.malfStatus')) {
        case 1:
          return 'hack';
        case 2:
          return 'occupy';
        case 3:
          return 'deoccupy';
      }
    },
    malfButton: function malfButton() {
      switch (this.get('data.malfStatus')) {
        case 1:
          return 'Override Programming';
        case 2:
        case 4:
          return 'Shunt Core Process';
        case 3:
          return 'Return to Main Core';
      }
    },
    malfIcon: function malfIcon() {
      switch (this.get('data.malfStatus')) {
        case 1:
          return 'terminal';
        case 2:
        case 4:
          return 'caret-square-o-down';
        case 3:
          return 'caret-square-o-left';
      }
    },
    powerCellStatusState: function powerCellStatusState() {
      var status = this.get('data.powerCellStatus');
      if (status > 50) return 'good';else if (status > 25) return 'average';else return 'bad';
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[46,1,1184],"t":7,"e":"ui-notice","f":[{"t":4,"f":[{"p":[48,5,1229],"t":7,"e":"ui-section","a":{"label":"Interface Lock"},"f":[{"p":[49,7,1272],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"lock\":\"unlock\""},"p":[49,24,1289]}],"action":"lock"},"f":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[49,75,1340]}]}]}],"n":50,"r":"data.siliconUser","p":[47,3,1199]},{"t":4,"n":51,"f":[{"p":[52,5,1431],"t":7,"e":"span","f":["Swipe an ID card to ",{"t":2,"x":{"r":["data.locked"],"s":"_0?\"unlock\":\"lock\""},"p":[52,31,1457]}," this interface."]}],"r":"data.siliconUser"}]}," ",{"p":[55,1,1542],"t":7,"e":"ui-display","a":{"title":"Power Status"},"f":[{"p":[56,3,1579],"t":7,"e":"ui-section","a":{"label":"Main Breaker"},"f":[{"t":4,"f":[{"p":[58,7,1666],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"good\":\"bad\""},"p":[58,20,1679]}]},"f":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"On\":\"Off\""},"p":[58,59,1718]}]}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"_0&&!_1"},"p":[57,5,1618]},{"t":4,"n":51,"f":[{"p":[60,7,1782],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"power-off\":\"close\""},"p":[60,24,1799]}],"style":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"selected\":null"},"p":[60,77,1852]}],"action":"breaker"},"f":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"On\":\"Off\""},"p":[61,26,1920]}]}],"x":{"r":["data.locked","data.siliconUser"],"s":"_0&&!_1"}}]}," ",{"p":[64,3,2001],"t":7,"e":"ui-section","a":{"label":"External Power"},"f":[{"p":[65,5,2042],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["powerState","data.externalPower"],"s":"_0(_1)"},"p":[65,18,2055]}]},"f":[{"t":2,"x":{"r":["data.externalPower"],"s":"_0==2?\"Good\":_0==1?\"Low\":\"None\""},"p":[65,54,2091]}]}]}," ",{"p":[67,3,2198],"t":7,"e":"ui-section","a":{"label":"Power Cell"},"f":[{"t":4,"f":[{"p":[69,7,2279],"t":7,"e":"ui-bar","a":{"min":"0","max":"100","value":[{"t":2,"r":"data.powerCellStatus","p":[69,40,2312]}],"state":[{"t":2,"r":"powerCellStatusState","p":[69,73,2345]}]},"f":[{"t":2,"x":{"r":["adata.powerCellStatus"],"s":"Math.fixed(_0)"},"p":[69,99,2371]},"%"]}],"n":50,"x":{"r":["data.powerCellStatus"],"s":"_0!=null"},"p":[68,5,2235]},{"t":4,"n":51,"f":[{"p":[71,7,2440],"t":7,"e":"span","a":{"class":"bad"},"f":["Removed"]}],"x":{"r":["data.powerCellStatus"],"s":"_0!=null"}}]}," ",{"t":4,"f":[{"p":[75,5,2548],"t":7,"e":"ui-section","a":{"label":"Charge Mode"},"f":[{"t":4,"f":[{"p":[77,9,2638],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.chargeMode"],"s":"_0?\"good\":\"bad\""},"p":[77,22,2651]}]},"f":[{"t":2,"x":{"r":["data.chargeMode"],"s":"_0?\"Auto\":\"Off\""},"p":[77,60,2689]}]}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"_0&&!_1"},"p":[76,7,2588]},{"t":4,"n":51,"f":[{"p":[79,9,2758],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.chargeMode"],"s":"_0?\"refresh\":\"close\""},"p":[79,26,2775]}],"style":[{"t":2,"x":{"r":["data.chargeMode"],"s":"_0?\"selected\":null"},"p":[79,76,2825]}],"action":"charge"},"f":[{"t":2,"x":{"r":["data.chargeMode"],"s":"_0?\"Auto\":\"Off\""},"p":[80,27,2893]}]}],"x":{"r":["data.locked","data.siliconUser"],"s":"_0&&!_1"}},"   [",{"p":[83,8,2979],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["powerState","data.chargingStatus"],"s":"_0(_1)"},"p":[83,21,2992]}]},"f":[{"t":2,"x":{"r":["data.chargingStatus"],"s":"_0==2?\"Fully Charged\":_0==1?\"Charging\":\"Not Charging\""},"p":[83,58,3029]}]},"]"]}],"n":50,"x":{"r":["data.powerCellStatus"],"s":"_0!=null"},"p":[74,3,2506]}]}," ",{"p":[87,1,3187],"t":7,"e":"ui-display","a":{"title":"Power Channels"},"f":[{"t":4,"f":[{"p":[89,5,3260],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"title","p":[89,24,3279]}],"nowrap":0},"f":[{"p":[90,7,3305],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"x":{"r":["@index","adata.powerChannels"],"s":"Math.round(_1[_0].powerLoad)"},"p":[90,28,3326]}," W"]}," ",{"p":[91,7,3395],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[91,28,3416],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["status"],"s":"_0>=2?\"good\":\"bad\""},"p":[91,41,3429]}]},"f":[{"t":2,"x":{"r":["status"],"s":"_0>=2?\"On\":\"Off\""},"p":[91,75,3463]}]}]}," ",{"p":[92,7,3514],"t":7,"e":"div","a":{"class":"content"},"f":["[",{"p":[92,29,3536],"t":7,"e":"span","f":[{"t":2,"x":{"r":["status"],"s":"_0==1||_0==3?\"Auto\":\"Manual\""},"p":[92,35,3542]}]},"]"]}," ",{"p":[93,7,3614],"t":7,"e":"div","a":{"class":"content","style":"float:right"},"f":[{"t":4,"f":[{"p":[95,11,3717],"t":7,"e":"ui-button","a":{"icon":"refresh","state":[{"t":2,"x":{"r":["status"],"s":"_0==1||_0==3?\"selected\":null"},"p":[95,44,3750]}],"action":"channel","params":[{"t":2,"r":"topicParams.auto","p":[96,38,3840]}]},"f":["Auto"]}," ",{"p":[97,11,3890],"t":7,"e":"ui-button","a":{"icon":"power-off","state":[{"t":2,"x":{"r":["status"],"s":"_0==2?\"selected\":null"},"p":[97,46,3925]}],"action":"channel","params":[{"t":2,"r":"topicParams.on","p":[98,21,4000]}]},"f":["On"]}," ",{"p":[99,11,4046],"t":7,"e":"ui-button","a":{"icon":"close","state":[{"t":2,"x":{"r":["status"],"s":"_0==0?\"selected\":null"},"p":[99,42,4077]}],"action":"channel","params":[{"t":2,"r":"topicParams.off","p":[100,21,4152]}]},"f":["Off"]}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"!_0||_1"},"p":[94,9,3665]}]}]}],"n":52,"r":"data.powerChannels","p":[88,3,3226]}," ",{"p":[105,3,4255],"t":7,"e":"ui-section","a":{"label":"Total Load"},"f":[{"p":[106,5,4292],"t":7,"e":"span","a":{"class":"bold"},"f":[{"t":2,"x":{"r":["adata.totalLoad"],"s":"Math.round(_0)"},"p":[106,24,4311]}," W"]}]}]}," ",{"t":4,"f":[{"p":[110,3,4413],"t":7,"e":"ui-display","a":{"title":"System Overrides"},"f":[{"p":[111,5,4456],"t":7,"e":"ui-button","a":{"icon":"lightbulb-o","action":"overload"},"f":["Overload"]}," ",{"t":4,"f":[{"p":[113,7,4561],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"r":"malfIcon","p":[113,24,4578]}],"state":[{"t":2,"x":{"r":["data.malfStatus"],"s":"_0==4?\"disabled\":null"},"p":[113,45,4599]}],"action":[{"t":2,"r":"malfAction","p":[113,99,4653]}]},"f":[{"t":2,"r":"malfButton","p":[113,115,4669]}]}],"n":50,"r":"data.malfStatus","p":[112,5,4530]}]}],"n":50,"r":"data.siliconUser","p":[109,1,4385]},{"p":[117,1,4736],"t":7,"e":"ui-notice","f":[{"p":[118,3,4751],"t":7,"e":"ui-section","a":{"label":"Cover Lock"},"f":[{"t":4,"f":[{"p":[120,7,4836],"t":7,"e":"span","f":[{"t":2,"x":{"r":["data.coverLocked"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[120,13,4842]}]}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"_0&&!_1"},"p":[119,5,4788]},{"t":4,"n":51,"f":[{"p":[122,7,4918],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.coverLocked"],"s":"_0?\"lock\":\"unlock\""},"p":[122,24,4935]}],"action":"cover"},"f":[{"t":2,"x":{"r":["data.coverLocked"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[122,81,4992]}]}],"x":{"r":["data.locked","data.siliconUser"],"s":"_0&&!_1"}}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],228:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":"Alarms"},"f":[{"p":[2,3,31],"t":7,"e":"ul","f":[{"t":4,"f":[{"p":[4,7,72],"t":7,"e":"li","f":[{"p":[4,11,76],"t":7,"e":"ui-button","a":{"icon":"close","style":"danger","action":"clear","params":["{\"zone\": \"",{"t":2,"r":".","p":[4,83,148]},"\"}"]},"f":[{"t":2,"r":".","p":[4,92,157]}]}]}],"n":52,"r":"data.priority","p":[3,5,41]},{"t":4,"n":51,"f":[{"p":[6,7,201],"t":7,"e":"li","f":[{"p":[6,11,205],"t":7,"e":"span","a":{"class":"good"},"f":["No Priority Alerts"]}]}],"r":"data.priority"}," ",{"t":4,"f":[{"p":[9,7,303],"t":7,"e":"li","f":[{"p":[9,11,307],"t":7,"e":"ui-button","a":{"icon":"close","style":"caution","action":"clear","params":["{\"zone\": \"",{"t":2,"r":".","p":[9,84,380]},"\"}"]},"f":[{"t":2,"r":".","p":[9,93,389]}]}]}],"n":52,"r":"data.minor","p":[8,5,275]},{"t":4,"n":51,"f":[{"p":[11,7,433],"t":7,"e":"li","f":[{"p":[11,11,437],"t":7,"e":"span","a":{"class":"good"},"f":["No Minor Alerts"]}]}],"r":"data.minor"}]}]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],229:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":[{"t":2,"x":{"r":["data.tank","data.sensors.0.long_name"],"s":"_0?_1:null"},"p":[1,20,19]}]},"f":[{"t":4,"f":[{"p":[3,5,102],"t":7,"e":"ui-subdisplay","a":{"title":[{"t":2,"x":{"r":["data.tank","long_name"],"s":"!_0?_1:null"},"p":[3,27,124]}]},"f":[{"p":[4,7,167],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"p":[5,3,200],"t":7,"e":"span","f":[{"t":2,"x":{"r":["pressure"],"s":"Math.fixed(_0,2)"},"p":[5,9,206]}," kPa"]}]}," ",{"t":4,"f":[{"p":[8,9,302],"t":7,"e":"ui-section","a":{"label":"Temperature"},"f":[{"p":[9,11,346],"t":7,"e":"span","f":[{"t":2,"x":{"r":["temperature"],"s":"Math.fixed(_0,2)"},"p":[9,17,352]}," K"]}]}],"n":50,"r":"temperature","p":[7,7,273]}," ",{"t":4,"f":[{"p":[13,9,462],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"id","p":[13,28,481]}]},"f":[{"p":[14,5,495],"t":7,"e":"span","f":[{"t":2,"x":{"r":["."],"s":"Math.fixed(_0,2)"},"p":[14,11,501]},"%"]}]}],"n":52,"i":"id","r":"gases","p":[12,4,434]}]}],"n":52,"r":"adata.sensors","p":[2,3,73]}]}," ",{"t":4,"f":[{"p":{"button":[{"p":[23,5,704],"t":7,"e":"ui-button","a":{"icon":"refresh","action":"reconnect"},"f":["Reconnect"]}]},"t":7,"e":"ui-display","a":{"title":"Controls","button":0},"f":[" ",{"p":[25,5,792],"t":7,"e":"ui-section","a":{"label":"Input Injector"},"f":[{"p":[26,7,835],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.inputting"],"s":"_0?\"power-off\":\"close\""},"p":[26,24,852]}],"style":[{"t":2,"x":{"r":["data.inputting"],"s":"_0?\"selected\":null"},"p":[26,75,903]}],"action":"input"},"f":[{"t":2,"x":{"r":["data.inputting"],"s":"_0?\"Injecting\":\"Off\""},"p":[27,9,968]}]}]}," ",{"p":[29,5,1044],"t":7,"e":"ui-section","a":{"label":"Input Rate"},"f":[{"p":[30,7,1083],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.inputRate"],"s":"Math.fixed(_0)"},"p":[30,13,1089]}," L/s"]}]}," ",{"p":[32,5,1156],"t":7,"e":"ui-section","a":{"label":"Output Regulator"},"f":[{"p":[33,7,1201],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.outputting"],"s":"_0?\"power-off\":\"close\""},"p":[33,24,1218]}],"style":[{"t":2,"x":{"r":["data.outputting"],"s":"_0?\"selected\":null"},"p":[33,76,1270]}],"action":"output"},"f":[{"t":2,"x":{"r":["data.outputting"],"s":"_0?\"Open\":\"Closed\""},"p":[34,9,1337]}]}]}," ",{"p":[36,5,1412],"t":7,"e":"ui-section","a":{"label":"Output Pressure"},"f":[{"p":[37,7,1456],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure"},"f":[{"t":2,"x":{"r":["adata.outputPressure"],"s":"Math.round(_0)"},"p":[37,50,1499]}," kPa"]}]}]}],"n":50,"r":"data.tank","p":[20,1,618]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],230:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","f":[{"p":[2,3,16],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[3,5,48],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[3,22,65]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":null"},"p":[3,66,109]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[4,22,164]}]}]}," ",{"p":[6,3,223],"t":7,"e":"ui-section","a":{"label":"Output Pressure"},"f":[{"p":[7,5,265],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure","params":"{\"pressure\": \"input\"}"},"f":["Set"]}," ",{"p":[8,5,360],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.pressure","data.max_pressure"],"s":"_0==_1?\"disabled\":null"},"p":[8,35,390]}],"action":"pressure","params":"{\"pressure\": \"max\"}"},"f":["Max"]}," ",{"p":[9,5,518],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.pressure"],"s":"Math.round(_0)"},"p":[9,11,524]}," kPa"]}]}," ",{"p":[11,3,586],"t":7,"e":"ui-section","a":{"label":"Filter"},"f":[{"p":[12,5,619],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"\"?\"selected\":null"},"p":[12,23,637]}],"action":"filter","params":"{\"mode\": \"\"}"},"f":["Nothing"]}," ",{"p":[14,5,755],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"plasma\"?\"selected\":null"},"p":[14,23,773]}],"action":"filter","params":"{\"mode\": \"plasma\"}"},"f":["Plasma"]}," ",{"p":[16,5,902],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"o2\"?\"selected\":null"},"p":[16,23,920]}],"action":"filter","params":"{\"mode\": \"o2\"}"},"f":["O2"]}," ",{"p":[18,5,1037],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"n2\"?\"selected\":null"},"p":[18,23,1055]}],"action":"filter","params":"{\"mode\": \"n2\"}"},"f":["N2"]}," ",{"p":[20,5,1172],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"co2\"?\"selected\":null"},"p":[20,23,1190]}],"action":"filter","params":"{\"mode\": \"co2\"}"},"f":["CO2"]}," ",{"p":[22,5,1310],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"n2o\"?\"selected\":null"},"p":[22,23,1328]}],"action":"filter","params":"{\"mode\": \"n2o\"}"},"f":["N2O"]}," ",{"p":[24,2,1445],"t":7,"e":"ui-button","a":{"state":[{"t":2,"x":{"r":["data.filter_type"],"s":"_0==\"bz\"?\"selected\":null"},"p":[24,20,1463]}],"action":"filter","params":"{\"mode\": \"bz\"}"},"f":["BZ"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],231:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","f":[{"p":[2,3,16],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[3,5,48],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[3,22,65]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":null"},"p":[3,66,109]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[4,22,164]}]}]}," ",{"p":[6,3,223],"t":7,"e":"ui-section","a":{"label":"Output Pressure"},"f":[{"p":[7,5,265],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure","params":"{\"pressure\": \"input\"}"},"f":["Set"]}," ",{"p":[8,5,360],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.set_pressure","data.max_pressure"],"s":"_0==_1?\"disabled\":null"},"p":[8,35,390]}],"action":"pressure","params":"{\"pressure\": \"max\"}"},"f":["Max"]}," ",{"p":[9,5,522],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.set_pressure"],"s":"Math.round(_0)"},"p":[9,11,528]}," kPa"]}]}," ",{"p":[11,3,594],"t":7,"e":"ui-section","a":{"label":"Node 1"},"f":[{"p":[12,5,627],"t":7,"e":"ui-button","a":{"icon":"fast-backward","state":[{"t":2,"x":{"r":["data.node1_concentration"],"s":"_0==0?\"disabled\":null"},"p":[12,44,666]}],"action":"node1","params":"{\"concentration\": -0.1}"}}," ",{"p":[14,5,783],"t":7,"e":"ui-button","a":{"icon":"backward","state":[{"t":2,"x":{"r":["data.node1_concentration"],"s":"_0==0?\"disabled\":null"},"p":[14,39,817]}],"action":"node1","params":"{\"concentration\": -0.01}"}}," ",{"p":[16,5,935],"t":7,"e":"ui-button","a":{"icon":"forward","state":[{"t":2,"x":{"r":["data.node1_concentration"],"s":"_0==100?\"disabled\":null"},"p":[16,38,968]}],"action":"node1","params":"{\"concentration\": 0.01}"}}," ",{"p":[18,5,1087],"t":7,"e":"ui-button","a":{"icon":"fast-forward","state":[{"t":2,"x":{"r":["data.node1_concentration"],"s":"_0==100?\"disabled\":null"},"p":[18,43,1125]}],"action":"node1","params":"{\"concentration\": 0.1}"}}," ",{"p":[20,5,1243],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.node1_concentration"],"s":"Math.round(_0)"},"p":[20,11,1249]},"%"]}]}," ",{"p":[22,3,1319],"t":7,"e":"ui-section","a":{"label":"Node 2"},"f":[{"p":[23,5,1352],"t":7,"e":"ui-button","a":{"icon":"fast-backward","state":[{"t":2,"x":{"r":["data.node2_concentration"],"s":"_0==0?\"disabled\":null"},"p":[23,44,1391]}],"action":"node2","params":"{\"concentration\": -0.1}"}}," ",{"p":[25,5,1508],"t":7,"e":"ui-button","a":{"icon":"backward","state":[{"t":2,"x":{"r":["data.node2_concentration"],"s":"_0==0?\"disabled\":null"},"p":[25,39,1542]}],"action":"node2","params":"{\"concentration\": -0.01}"}}," ",{"p":[27,5,1660],"t":7,"e":"ui-button","a":{"icon":"forward","state":[{"t":2,"x":{"r":["data.node2_concentration"],"s":"_0==100?\"disabled\":null"},"p":[27,38,1693]}],"action":"node2","params":"{\"concentration\": 0.01}"}}," ",{"p":[29,5,1812],"t":7,"e":"ui-button","a":{"icon":"fast-forward","state":[{"t":2,"x":{"r":["data.node2_concentration"],"s":"_0==100?\"disabled\":null"},"p":[29,43,1850]}],"action":"node2","params":"{\"concentration\": 0.1}"}}," ",{"p":[31,5,1968],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.node2_concentration"],"s":"Math.round(_0)"},"p":[31,11,1974]},"%"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],232:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","f":[{"p":[2,3,16],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[3,5,48],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[3,22,65]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":null"},"p":[3,66,109]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[4,22,164]}]}]}," ",{"t":4,"f":[{"p":[7,5,250],"t":7,"e":"ui-section","a":{"label":"Transfer Rate"},"f":[{"p":[8,7,292],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"rate","params":"{\"rate\": \"input\"}"},"f":["Set"]}," ",{"p":[9,7,381],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.rate","data.max_rate"],"s":"_0==_1?\"disabled\":null"},"p":[9,37,411]}],"action":"transfer","params":"{\"rate\": \"max\"}"},"f":["Max"]}," ",{"p":[10,7,529],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.rate"],"s":"Math.round(_0)"},"p":[10,13,535]}," L/s"]}]}],"n":50,"r":"data.max_rate","p":[6,3,223]},{"t":4,"n":51,"f":[{"p":[13,5,609],"t":7,"e":"ui-section","a":{"label":"Output Pressure"},"f":[{"p":[14,7,653],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure","params":"{\"pressure\": \"input\"}"},"f":["Set"]}," ",{"p":[15,7,750],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.pressure","data.max_pressure"],"s":"_0==_1?\"disabled\":null"},"p":[15,37,780]}],"action":"pressure","params":"{\"pressure\": \"max\"}"},"f":["Max"]}," ",{"p":[16,7,910],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.pressure"],"s":"Math.round(_0)"},"p":[16,13,916]}," kPa"]}]}],"r":"data.max_rate"}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],233:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":{"button":[{"p":[3,5,67],"t":7,"e":"ui-button","a":{"icon":"clock-o","style":[{"t":2,"x":{"r":["data.timing"],"s":"_0?\"selected\":null"},"p":[3,38,100]}],"action":[{"t":2,"x":{"r":["data.timing"],"s":"_0?\"stop\":\"start\""},"p":[3,83,145]}]},"f":[{"t":2,"x":{"r":["data.timing"],"s":"_0?\"Stop\":\"Start\""},"p":[3,119,181]}]}," ",{"p":[4,5,233],"t":7,"e":"ui-button","a":{"icon":"lightbulb-o","action":"flash","style":[{"t":2,"x":{"r":["data.flash_charging"],"s":"_0?\"disabled\":null"},"p":[4,57,285]}]},"f":[{"t":2,"x":{"r":["data.flash_charging"],"s":"_0?\"Recharging\":\"Flash\""},"p":[4,102,330]}]}]},"t":7,"e":"ui-display","a":{"title":"Cell Timer","button":0},"f":[" ",{"p":[6,3,410],"t":7,"e":"ui-section","f":[{"p":[7,5,428],"t":7,"e":"ui-button","a":{"icon":"fast-backward","action":"time","params":"{\"adjust\": -600}"}}," ",{"p":[8,5,518],"t":7,"e":"ui-button","a":{"icon":"backward","action":"time","params":"{\"adjust\": -100}"}}," ",{"p":[9,5,603],"t":7,"e":"span","f":[{"t":2,"x":{"r":["text","data.minutes"],"s":"_0.zeroPad(_1,2)"},"p":[9,11,609]},":",{"t":2,"x":{"r":["text","data.seconds"],"s":"_0.zeroPad(_1,2)"},"p":[9,45,643]}]}," ",{"p":[10,5,689],"t":7,"e":"ui-button","a":{"icon":"forward","action":"time","params":"{\"adjust\": 100}"}}," ",{"p":[11,5,772],"t":7,"e":"ui-button","a":{"icon":"fast-forward","action":"time","params":"{\"adjust\": 600}"}}]}," ",{"p":[13,3,875],"t":7,"e":"ui-section","f":[{"p":[14,7,895],"t":7,"e":"ui-button","a":{"icon":"hourglass-start","action":"preset","params":"{\"preset\": \"short\"}"},"f":["Short"]}," ",{"p":[15,7,999],"t":7,"e":"ui-button","a":{"icon":"hourglass-start","action":"preset","params":"{\"preset\": \"medium\"}"},"f":["Medium"]}," ",{"p":[16,7,1105],"t":7,"e":"ui-button","a":{"icon":"hourglass-start","action":"preset","params":"{\"preset\": \"long\"}"},"f":["Long"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],234:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-notice","f":[{"p":[2,3,15],"t":7,"e":"span","f":["The regulator ",{"t":2,"x":{"r":["data.hasHoldingTank"],"s":"_0?\"is\":\"is not\""},"p":[2,23,35]}," connected to a tank."]}]}," ",{"p":{"button":[{"p":[6,5,185],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"relabel"},"f":["Relabel"]}]},"t":7,"e":"ui-display","a":{"title":"Canister","button":0},"f":[" ",{"p":[8,3,266],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"p":[9,5,301],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.tankPressure"],"s":"Math.round(_0)"},"p":[9,11,307]}," kPa"]}]}," ",{"p":[11,3,373],"t":7,"e":"ui-section","a":{"label":"Port"},"f":[{"p":[12,5,404],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.portConnected"],"s":"_0?\"good\":\"average\""},"p":[12,18,417]}]},"f":[{"t":2,"x":{"r":["data.portConnected"],"s":"_0?\"Connected\":\"Not Connected\""},"p":[12,63,462]}]}]}]}," ",{"p":[15,1,557],"t":7,"e":"ui-display","a":{"title":"Valve"},"f":[{"p":[16,3,587],"t":7,"e":"ui-section","a":{"label":"Release Pressure"},"f":[{"p":[17,5,630],"t":7,"e":"ui-bar","a":{"min":[{"t":2,"r":"data.minReleasePressure","p":[17,18,643]}],"max":[{"t":2,"r":"data.maxReleasePressure","p":[17,52,677]}],"value":[{"t":2,"r":"data.releasePressure","p":[18,14,720]}]},"f":[{"t":2,"x":{"r":["adata.releasePressure"],"s":"Math.round(_0)"},"p":[18,40,746]}," kPa"]}]}," ",{"p":[20,3,817],"t":7,"e":"ui-section","a":{"label":"Pressure Regulator"},"f":[{"p":[21,5,862],"t":7,"e":"ui-button","a":{"icon":"refresh","state":[{"t":2,"x":{"r":["data.releasePressure","data.defaultReleasePressure"],"s":"_0!=_1?null:\"disabled\""},"p":[21,38,895]}],"action":"pressure","params":"{\"pressure\": \"reset\"}"},"f":["Reset"]}," ",{"p":[23,5,1051],"t":7,"e":"ui-button","a":{"icon":"minus","state":[{"t":2,"x":{"r":["data.releasePressure","data.minReleasePressure"],"s":"_0>_1?null:\"disabled\""},"p":[23,36,1082]}],"action":"pressure","params":"{\"pressure\": \"min\"}"},"f":["Min"]}," ",{"p":[25,5,1229],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure","params":"{\"pressure\": \"input\"}"},"f":["Set"]}," ",{"p":[26,5,1324],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.releasePressure","data.maxReleasePressure"],"s":"_0<_1?null:\"disabled\""},"p":[26,35,1354]}],"action":"pressure","params":"{\"pressure\": \"max\"}"},"f":["Max"]}]}," ",{"p":[29,3,1516],"t":7,"e":"ui-section","a":{"label":"Valve"},"f":[{"p":[30,5,1548],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.valveOpen"],"s":"_0?\"unlock\":\"lock\""},"p":[30,22,1565]}],"style":[{"t":2,"x":{"r":["data.valveOpen","data.hasHoldingTank"],"s":"_0?_1?\"caution\":\"danger\":null"},"p":[31,14,1619]}],"action":"valve"},"f":[{"t":2,"x":{"r":["data.valveOpen"],"s":"_0?\"Open\":\"Closed\""},"p":[32,22,1713]}]}]}]}," ",{"p":{"button":[{"t":4,"f":[{"p":[38,7,1901],"t":7,"e":"ui-button","a":{"icon":"eject","style":[{"t":2,"x":{"r":["data.valveOpen"],"s":"_0?\"danger\":null"},"p":[38,38,1932]}],"action":"eject"},"f":["Eject"]}],"n":50,"r":"data.hasHoldingTank","p":[37,5,1866]}]},"t":7,"e":"ui-display","a":{"title":"Holding Tank","button":0},"f":[" ",{"t":4,"f":[{"p":[42,3,2066],"t":7,"e":"ui-section","a":{"label":"Label"},"f":[{"t":2,"r":"data.holdingTank.name","p":[43,4,2097]}]}," ",{"p":[45,3,2143],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"t":2,"x":{"r":["adata.holdingTank.tankPressure"],"s":"Math.round(_0)"},"p":[46,4,2177]}," kPa"]}],"n":50,"r":"data.hasHoldingTank","p":[41,3,2035]},{"t":4,"n":51,"f":[{"p":[49,3,2259],"t":7,"e":"ui-section","f":[{"p":[50,4,2276],"t":7,"e":"span","a":{"class":"average"},"f":["No Holding Tank"]}]}],"r":"data.hasHoldingTank"}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],235:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    tabs: function tabs() {
      return Object.keys(this.get('data.supplies'));
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[11,1,158],"t":7,"e":"ui-display","a":{"title":"Cargo"},"f":[{"p":[12,3,188],"t":7,"e":"ui-section","a":{"label":"Shuttle"},"f":[{"t":4,"f":[{"p":[14,7,270],"t":7,"e":"ui-button","a":{"action":"send"},"f":[{"t":2,"r":"data.location","p":[14,32,295]}]}],"n":50,"x":{"r":["data.docked","data.requestonly"],"s":"_0&&!_1"},"p":[13,5,222]},{"t":4,"n":51,"f":[{"p":[16,7,346],"t":7,"e":"span","f":[{"t":2,"r":"data.location","p":[16,13,352]}]}],"x":{"r":["data.docked","data.requestonly"],"s":"_0&&!_1"}}]}," ",{"p":[19,3,410],"t":7,"e":"ui-section","a":{"label":"Credits"},"f":[{"p":[20,5,444],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.points"],"s":"Math.floor(_0)"},"p":[20,11,450]}]}]}," ",{"p":[22,3,506],"t":7,"e":"ui-section","a":{"label":"Centcom Message"},"f":[{"p":[23,7,550],"t":7,"e":"span","f":[{"t":2,"r":"data.message","p":[23,13,556]}]}]}," ",{"t":4,"f":[{"p":[26,5,644],"t":7,"e":"ui-section","a":{"label":"Loan"},"f":[{"t":4,"f":[{"p":[28,9,716],"t":7,"e":"ui-button","a":{"action":"loan"},"f":["Loan Shuttle"]}],"n":50,"x":{"r":["data.loan_dispatched"],"s":"!_0"},"p":[27,7,677]},{"t":4,"n":51,"f":[{"p":[30,9,791],"t":7,"e":"span","a":{"class":"bad"},"f":["Loaned to Centcom"]}],"x":{"r":["data.loan_dispatched"],"s":"!_0"}}]}],"n":50,"x":{"r":["data.loan","data.requestonly"],"s":"_0&&!_1"},"p":[25,3,600]}]}," ",{"t":4,"f":[{"p":{"button":[{"p":[38,7,989],"t":7,"e":"ui-button","a":{"icon":"close","state":[{"t":2,"x":{"r":["data.cart.length"],"s":"_0?null:\"disabled\""},"p":[38,38,1020]}],"action":"clear"},"f":["Clear"]}]},"t":7,"e":"ui-display","a":{"title":"Cart","button":0},"f":[" ",{"t":4,"f":[{"p":[41,7,1145],"t":7,"e":"ui-section","a":{"candystripe":0,"nowrap":0},"f":[{"p":[42,9,1186],"t":7,"e":"div","a":{"class":"content"},"f":["#",{"t":2,"r":"id","p":[42,31,1208]}]}," ",{"p":[43,9,1230],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"r":"object","p":[43,30,1251]}]}," ",{"p":[44,9,1277],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"r":"cost","p":[44,30,1298]}," Credits"]}," ",{"p":[45,9,1330],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[46,11,1363],"t":7,"e":"ui-button","a":{"icon":"minus","action":"remove","params":["{\"id\": \"",{"t":2,"r":"id","p":[46,67,1419]},"\"}"]}}]}]}],"n":52,"r":"data.cart","p":[40,5,1118]},{"t":4,"n":51,"f":[{"p":[50,7,1489],"t":7,"e":"span","f":["Nothing in Cart"]}],"r":"data.cart"}]}],"n":50,"x":{"r":["data.requestonly"],"s":"!_0"},"p":[35,1,895]},{"p":{"button":[{"t":4,"f":[{"p":[57,7,1658],"t":7,"e":"ui-button","a":{"icon":"close","state":[{"t":2,"x":{"r":["data.requests.length"],"s":"_0?null:\"disabled\""},"p":[57,38,1689]}],"action":"denyall"},"f":["Clear"]}],"n":50,"x":{"r":["data.requestonly"],"s":"!_0"},"p":[56,5,1625]}]},"t":7,"e":"ui-display","a":{"title":"Requests","button":0},"f":[" ",{"t":4,"f":[{"p":[61,5,1831],"t":7,"e":"ui-section","a":{"candystripe":0,"nowrap":0},"f":[{"p":[62,7,1870],"t":7,"e":"div","a":{"class":"content"},"f":["#",{"t":2,"r":"id","p":[62,29,1892]}]}," ",{"p":[63,7,1912],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"r":"object","p":[63,28,1933]}]}," ",{"p":[64,7,1957],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"r":"cost","p":[64,28,1978]}," Credits"]}," ",{"p":[65,7,2008],"t":7,"e":"div","a":{"class":"content"},"f":["By ",{"t":2,"r":"orderer","p":[65,31,2032]}]}," ",{"p":[66,7,2057],"t":7,"e":"div","a":{"class":"content"},"f":["Comment: ",{"t":2,"r":"reason","p":[66,37,2087]}]}," ",{"t":4,"f":[{"p":[68,9,2146],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[69,11,2179],"t":7,"e":"ui-button","a":{"icon":"check","action":"approve","params":["{\"id\": \"",{"t":2,"r":"id","p":[69,68,2236]},"\"}"]}}," ",{"p":[70,11,2259],"t":7,"e":"ui-button","a":{"icon":"close","action":"deny","params":["{\"id\": \"",{"t":2,"r":"id","p":[70,65,2313]},"\"}"]}}]}],"n":50,"x":{"r":["data.requestonly"],"s":"!_0"},"p":[67,7,2111]}]}],"n":52,"r":"data.requests","p":[60,3,1802]},{"t":4,"n":51,"f":[{"p":[75,7,2396],"t":7,"e":"span","f":["No Requests"]}],"r":"data.requests"}]}," ",{"p":[78,1,2452],"t":7,"e":"ui-tabs","a":{"tabs":[{"t":2,"r":"tabs","p":[78,16,2467]}]},"f":[{"t":4,"f":[{"p":[80,5,2510],"t":7,"e":"tab","a":{"name":[{"t":2,"r":"name","p":[80,16,2521]}]},"f":[{"t":4,"f":[{"p":[82,9,2564],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"name","p":[82,28,2583]}],"candystripe":0,"right":0},"f":[{"p":[83,11,2623],"t":7,"e":"ui-button","a":{"action":"add","params":["{\"id\": \"",{"t":2,"r":"id","p":[83,51,2663]},"\"}"]},"f":[{"t":2,"r":"cost","p":[83,61,2673]}," Credits"]}]}],"n":52,"r":"packs","p":[81,7,2539]}]}],"n":52,"r":"data.supplies","p":[79,3,2481]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],236:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":"Status"},"f":[{"p":[2,3,31],"t":7,"e":"ui-section","a":{"label":"Energy"},"f":[{"p":[3,5,64],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"data.maxEnergy","p":[3,26,85]}],"value":[{"t":2,"r":"data.energy","p":[3,53,112]}]},"f":[{"t":2,"x":{"r":["adata.energy"],"s":"Math.fixed(_0)"},"p":[3,70,129]}," Units"]}]}]}," ",{"p":{"button":[{"t":4,"f":[{"p":[9,7,315],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.amount","."],"s":"_0==_1?\"selected\":null"},"p":[9,37,345]}],"action":"amount","params":["{\"target\": ",{"t":2,"r":".","p":[9,114,422]},"}"]},"f":[{"t":2,"r":".","p":[9,122,430]}]}],"n":52,"r":"data.beakerTransferAmounts","p":[8,5,271]}]},"t":7,"e":"ui-display","a":{"title":"Dispense","button":0},"f":[" ",{"p":[12,3,482],"t":7,"e":"ui-section","f":[{"t":4,"f":[{"p":[14,7,532],"t":7,"e":"ui-button","a":{"grid":0,"icon":"tint","action":"dispense","params":["{\"reagent\": \"",{"t":2,"r":"id","p":[14,74,599]},"\"}"]},"f":[{"t":2,"r":"title","p":[14,84,609]}]}],"n":52,"r":"data.chemicals","p":[13,5,500]}]}]}," ",{"p":{"button":[{"t":4,"f":[{"p":[21,7,786],"t":7,"e":"ui-button","a":{"icon":"minus","action":"remove","params":["{\"amount\": ",{"t":2,"r":".","p":[21,66,845]},"}"]},"f":[{"t":2,"r":".","p":[21,74,853]}]}],"n":52,"r":"data.beakerTransferAmounts","p":[20,5,742]}," ",{"p":[23,5,891],"t":7,"e":"ui-button","a":{"icon":"eject","state":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?null:\"disabled\""},"p":[23,36,922]}],"action":"eject"},"f":["Eject"]}]},"t":7,"e":"ui-display","a":{"title":"Beaker","button":0},"f":[" ",{"p":[25,3,1019],"t":7,"e":"ui-section","a":{"label":"Contents"},"f":[{"t":4,"f":[{"p":[27,7,1089],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.beakerCurrentVolume"],"s":"Math.round(_0)"},"p":[27,13,1095]},"/",{"t":2,"r":"data.beakerMaxVolume","p":[27,55,1137]}," Units"]}," ",{"p":[28,7,1182],"t":7,"e":"br"}," ",{"t":4,"f":[{"p":[30,9,1235],"t":7,"e":"span","a":{"class":"highlight"},"t0":"fade","f":[{"t":2,"x":{"r":["volume"],"s":"Math.fixed(_0,2)"},"p":[30,52,1278]}," units of ",{"t":2,"r":"name","p":[30,87,1313]}]},{"p":[30,102,1328],"t":7,"e":"br"}],"n":52,"r":"adata.beakerContents","p":[29,7,1195]},{"t":4,"n":51,"f":[{"p":[32,9,1359],"t":7,"e":"span","a":{"class":"bad"},"f":["Beaker Empty"]}],"r":"adata.beakerContents"}],"n":50,"r":"data.isBeakerLoaded","p":[26,5,1054]},{"t":4,"n":51,"f":[{"p":[35,7,1435],"t":7,"e":"span","a":{"class":"average"},"f":["No Beaker"]}],"r":"data.isBeakerLoaded"}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],237:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":"Thermostat"},"f":[{"p":[2,3,35],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[3,5,67],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.isActive"],"s":"_0?\"power-off\":\"close\""},"p":[3,22,84]}],"style":[{"t":2,"x":{"r":["data.isActive"],"s":"_0?\"selected\":null"},"p":[4,10,137]}],"state":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?null:\"disabled\""},"p":[5,10,186]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.isActive"],"s":"_0?\"On\":\"Off\""},"p":[6,18,249]}]}]}," ",{"p":[8,3,314],"t":7,"e":"ui-section","a":{"label":"Target"},"f":[{"p":[9,4,346],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"temperature","params":"{\"target\": \"input\"}"},"f":[{"t":2,"x":{"r":["adata.targetTemp"],"s":"Math.round(_0)"},"p":[9,79,421]}," K"]}]}]}," ",{"p":{"button":[{"p":[14,5,564],"t":7,"e":"ui-button","a":{"icon":"eject","state":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?null:\"disabled\""},"p":[14,36,595]}],"action":"eject"},"f":["Eject"]}]},"t":7,"e":"ui-display","a":{"title":"Beaker","button":0},"f":[" ",{"p":[16,3,692],"t":7,"e":"ui-section","a":{"label":"Contents"},"f":[{"t":4,"f":[{"p":[18,7,762],"t":7,"e":"span","f":["Temperature: ",{"t":2,"x":{"r":["adata.currentTemp"],"s":"Math.round(_0)"},"p":[18,26,781]}," K"]}," ",{"p":[19,7,831],"t":7,"e":"br"}," ",{"t":4,"f":[{"p":[21,9,885],"t":7,"e":"span","a":{"class":"highlight"},"t0":"fade","f":[{"t":2,"x":{"r":["volume"],"s":"Math.fixed(_0,2)"},"p":[21,52,928]}," units of ",{"t":2,"r":"name","p":[21,87,963]}]},{"p":[21,102,978],"t":7,"e":"br"}],"n":52,"r":"adata.beakerContents","p":[20,7,845]},{"t":4,"n":51,"f":[{"p":[23,9,1009],"t":7,"e":"span","a":{"class":"bad"},"f":["Beaker Empty"]}],"r":"adata.beakerContents"}],"n":50,"r":"data.isBeakerLoaded","p":[17,5,727]},{"t":4,"n":51,"f":[{"p":[26,7,1085],"t":7,"e":"span","a":{"class":"average"},"f":["No Beaker"]}],"r":"data.isBeakerLoaded"}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],238:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"p":[2,2,32],"t":7,"e":"ui-display","a":{"title":"Beaker","button":0},"f":[{"p":[3,3,70],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?\"Eject\":\"close\""},"p":[3,20,87]}],"style":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?\"selected\":null"},"p":[4,11,143]}],"state":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?null:\"disabled\""},"p":[5,11,199]}],"action":"eject"},"f":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?\"Eject and Clear Buffer\":\"No beaker\""},"p":[7,5,268]}]}," ",{"p":[10,3,357],"t":7,"e":"ui-section","f":[{"t":4,"f":[{"t":4,"f":[{"p":[13,6,443],"t":7,"e":"ui-section","a":{"label":[{"t":2,"x":{"r":["volume"],"s":"Math.fixed(_0,2)"},"p":[13,25,462]}," units of ",{"t":2,"r":"name","p":[13,60,497]}],"nowrap":0},"f":[{"p":[14,7,522],"t":7,"e":"div","a":{"class":"content","style":"float:right"},"f":[{"p":[15,8,572],"t":7,"e":"ui-button","a":{"action":"transferToBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[15,61,625]},"\", \"amount\": 1}"]},"f":["1"]}," ",{"p":[16,8,670],"t":7,"e":"ui-button","a":{"action":"transferToBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[16,61,723]},"\", \"amount\": 5}"]},"f":["5"]}," ",{"p":[17,8,768],"t":7,"e":"ui-button","a":{"action":"transferToBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[17,61,821]},"\", \"amount\": 10}"]},"f":["10"]}," ",{"p":[18,8,868],"t":7,"e":"ui-button","a":{"action":"transferToBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[18,61,921]},"\", \"amount\": 1000}"]},"f":["All"]}," ",{"p":[19,8,971],"t":7,"e":"ui-button","a":{"action":"transferToBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[19,61,1024]},"\", \"amount\": -1}"]},"f":["Custom"]}," ",{"p":[20,8,1075],"t":7,"e":"ui-button","a":{"action":"analyze","params":["{\"id\": \"",{"t":2,"r":"id","p":[20,52,1119]},"\"}"]},"f":["Analyze"]}]}]}],"n":52,"r":"data.beakerContents","p":[12,5,407]},{"t":4,"n":51,"f":[{"p":[24,5,1201],"t":7,"e":"span","a":{"class":"bad"},"f":["Beaker Empty"]}],"r":"data.beakerContents"}],"n":50,"r":"data.isBeakerLoaded","p":[11,4,374]},{"t":4,"n":51,"f":[{"p":[27,5,1272],"t":7,"e":"span","a":{"class":"average"},"f":["No Beaker"]}],"r":"data.isBeakerLoaded"}]}]}," ",{"p":[32,2,1360],"t":7,"e":"ui-display","a":{"title":"Buffer"},"f":[{"p":[33,3,1391],"t":7,"e":"ui-button","a":{"action":"toggleMode","state":[{"t":2,"x":{"r":["data.mode"],"s":"_0?null:\"selected\""},"p":[33,41,1429]}]},"f":["Destroy"]}," ",{"p":[34,3,1487],"t":7,"e":"ui-button","a":{"action":"toggleMode","state":[{"t":2,"x":{"r":["data.mode"],"s":"_0?\"selected\":null"},"p":[34,41,1525]}]},"f":["Transfer to Beaker"]}," ",{"p":[35,3,1594],"t":7,"e":"ui-section","f":[{"t":4,"f":[{"p":[37,5,1646],"t":7,"e":"ui-section","a":{"label":[{"t":2,"x":{"r":["volume"],"s":"Math.fixed(_0,2)"},"p":[37,24,1665]}," units of ",{"t":2,"r":"name","p":[37,59,1700]}],"nowrap":0},"f":[{"p":[38,6,1724],"t":7,"e":"div","a":{"class":"content","style":"float:right"},"f":[{"p":[39,7,1773],"t":7,"e":"ui-button","a":{"action":"transferFromBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[39,62,1828]},"\", \"amount\": 1}"]},"f":["1"]}," ",{"p":[40,7,1872],"t":7,"e":"ui-button","a":{"action":"transferFromBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[40,62,1927]},"\", \"amount\": 5}"]},"f":["5"]}," ",{"p":[41,7,1971],"t":7,"e":"ui-button","a":{"action":"transferFromBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[41,62,2026]},"\", \"amount\": 10}"]},"f":["10"]}," ",{"p":[42,7,2072],"t":7,"e":"ui-button","a":{"action":"transferFromBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[42,62,2127]},"\", \"amount\": 1000}"]},"f":["All"]}," ",{"p":[43,7,2176],"t":7,"e":"ui-button","a":{"action":"transferFromBuffer","params":["{\"id\": \"",{"t":2,"r":"id","p":[43,62,2231]},"\", \"amount\": -1}"]},"f":["Custom"]}," ",{"p":[44,7,2281],"t":7,"e":"ui-button","a":{"action":"analyze","params":["{\"id\": \"",{"t":2,"r":"id","p":[44,51,2325]},"\"}"]},"f":["Analyze"]}]}]}],"n":52,"r":"data.bufferContents","p":[36,4,1611]}]}]}," ",{"t":4,"f":[{"p":[52,3,2461],"t":7,"e":"ui-display","a":{"title":"Pills, Bottles and Patches"},"f":[{"t":4,"f":[{"p":[54,5,2551],"t":7,"e":"ui-button","a":{"action":"ejectp","state":[{"t":2,"x":{"r":["data.isPillBottleLoaded"],"s":"_0?null:\"disabled\""},"p":[54,39,2585]}]},"f":[{"t":2,"x":{"r":["data.isPillBottleLoaded"],"s":"_0?\"Eject\":\"No Pill bottle loaded\""},"p":[54,88,2634]}]}," ",{"p":[55,5,2715],"t":7,"e":"span","a":{"class":"content"},"f":[{"t":2,"r":"data.pillBotContent","p":[55,27,2737]},"/",{"t":2,"r":"data.pillBotMaxContent","p":[55,51,2761]}]}],"n":50,"r":"data.isPillBottleLoaded","p":[53,4,2514]},{"t":4,"n":51,"f":[{"p":[57,5,2813],"t":7,"e":"span","a":{"class":"average"},"f":["No Pillbottle"]}],"r":"data.isPillBottleLoaded"}," ",{"p":[60,4,2877],"t":7,"e":"br"}," ",{"p":[61,4,2887],"t":7,"e":"br"}," ",{"p":[62,4,2897],"t":7,"e":"ui-button","a":{"action":"createPill","params":"{\"many\": 0}","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[62,63,2956]}]},"f":["Create Pill (max 50µ)"]}," ",{"p":[63,4,3040],"t":7,"e":"br"}," ",{"p":[64,4,3050],"t":7,"e":"ui-button","a":{"action":"createPill","params":"{\"many\": 1}","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[64,63,3109]}]},"f":["Create Multiple Pills"]}," ",{"p":[65,4,3193],"t":7,"e":"br"}," ",{"p":[66,4,3203],"t":7,"e":"br"}," ",{"p":[67,4,3213],"t":7,"e":"ui-button","a":{"action":"createPatch","params":"{\"many\": 0}","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[67,64,3273]}]},"f":["Create Patch (max 50µ)"]}," ",{"p":[68,4,3358],"t":7,"e":"br"}," ",{"p":[69,4,3368],"t":7,"e":"ui-button","a":{"action":"createPatch","params":"{\"many\": 1}","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[69,64,3428]}]},"f":["Create Multiple Patches"]}," ",{"p":[70,4,3514],"t":7,"e":"br"}," ",{"p":[71,4,3524],"t":7,"e":"br"}," ",{"p":[72,4,3534],"t":7,"e":"ui-button","a":{"action":"createBottle","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[72,44,3574]}]},"f":["Create Bottle (max 30µ)"]}]}],"n":50,"x":{"r":["data.condi"],"s":"!_0"},"p":[51,2,2438]},{"t":4,"n":51,"f":[{"p":[76,3,3688],"t":7,"e":"ui-display","a":{"title":"Condiments bottles and packs"},"f":[{"p":[77,4,3743],"t":7,"e":"ui-button","a":{"action":"createPill","params":"{\"many\": 0}","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[77,63,3802]}]},"f":["Create Pack (max 10µ)"]}," ",{"p":[78,4,3886],"t":7,"e":"br"}," ",{"p":[79,4,3896],"t":7,"e":"br"}," ",{"p":[80,4,3906],"t":7,"e":"ui-button","a":{"action":"createBottle","state":[{"t":2,"x":{"r":["data.bufferContents"],"s":"_0?null:\"disabled\""},"p":[80,44,3946]}]},"f":["Create Bottle (max 50µ)"]}]}],"x":{"r":["data.condi"],"s":"!_0"}}],"n":50,"x":{"r":["data.screen"],"s":"_0==\"home\""},"p":[1,1,0]},{"t":4,"n":51,"f":[{"t":4,"n":50,"x":{"r":["data.screen"],"s":"_0==\"analyze\""},"f":[{"p":[84,2,4094],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"data.analyzeVars.name","p":[84,20,4112]}]},"f":[{"p":[85,3,4143],"t":7,"e":"span","a":{"class":"highlight"},"f":["Description:"]}," ",{"p":[86,3,4191],"t":7,"e":"span","a":{"class":"content","style":"float:center"},"f":[{"t":2,"r":"data.analyzeVars.description","p":[86,46,4234]}]}," ",{"p":[87,3,4277],"t":7,"e":"br"}," ",{"p":[88,3,4286],"t":7,"e":"span","a":{"class":"highlight"},"f":["Color:"]}," ",{"p":[89,3,4328],"t":7,"e":"span","a":{"style":["color: ",{"t":2,"r":"data.analyzeVars.color","p":[89,23,4348]},"; background-color: ",{"t":2,"r":"data.analyzeVars.color","p":[89,69,4394]}]},"f":[{"t":2,"r":"data.analyzeVars.color","p":[89,97,4422]}]}," ",{"p":[90,3,4459],"t":7,"e":"br"}," ",{"p":[91,3,4468],"t":7,"e":"span","a":{"class":"highlight"},"f":["State:"]}," ",{"p":[92,3,4510],"t":7,"e":"span","a":{"class":"content"},"f":[{"t":2,"r":"data.analyzeVars.state","p":[92,25,4532]}]}," ",{"p":[93,3,4569],"t":7,"e":"br"}," ",{"p":[94,3,4578],"t":7,"e":"span","a":{"class":"highlight"},"f":["Metabolization Rate:"]}," ",{"p":[95,3,4634],"t":7,"e":"span","a":{"class":"content"},"f":[{"t":2,"r":"data.analyzeVars.metaRate","p":[95,25,4656]},"µ/minute"]}," ",{"p":[96,3,4704],"t":7,"e":"br"}," ",{"p":[97,3,4713],"t":7,"e":"span","a":{"class":"highlight"},"f":["Overdose Threshold:"]}," ",{"p":[98,3,4768],"t":7,"e":"span","a":{"class":"content"},"f":[{"t":2,"r":"data.analyzeVars.overD","p":[98,25,4790]}]}," ",{"p":[99,3,4827],"t":7,"e":"br"}," ",{"p":[100,3,4836],"t":7,"e":"span","a":{"class":"highlight"},"f":["Addiction Threshold:"]}," ",{"p":[101,3,4892],"t":7,"e":"span","a":{"class":"content"},"f":[{"t":2,"r":"data.analyzeVars.addicD","p":[101,25,4914]}]}," ",{"p":[102,3,4952],"t":7,"e":"br"}," ",{"p":[103,3,4961],"t":7,"e":"br"}," ",{"p":[104,3,4970],"t":7,"e":"ui-button","a":{"action":"goScreen","params":"{\"screen\": \"home\"}"},"f":["Back"]}]}]}],"x":{"r":["data.screen"],"s":"_0==\"home\""}}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],239:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"p":[2,1,22],"t":7,"e":"ui-display","f":[{"p":[3,2,37],"t":7,"e":"ui-section","a":{"label":"Cap"},"f":[{"p":[4,3,65],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.is_capped"],"s":"_0?\"power-off\":\"close\""},"p":[4,20,82]}],"style":[{"t":2,"x":{"r":["data.is_capped"],"s":"_0?null:\"selected\""},"p":[4,71,133]}],"action":"toggle_cap"},"f":[{"t":2,"x":{"r":["data.is_capped"],"s":"_0?\"On\":\"Off\""},"p":[6,4,202]}]}]}]}],"n":50,"r":"data.has_cap","p":[1,1,0]},{"p":[10,1,288],"t":7,"e":"ui-display","f":[{"t":4,"f":[{"p":[14,2,419],"t":7,"e":"ui-section","f":[{"p":[15,3,435],"t":7,"e":"ui-button","a":{"action":"select_colour"},"f":["Select New Colour"]}]}],"n":50,"r":"data.can_change_colour","p":[13,1,386]}]}," ",{"p":[19,1,540],"t":7,"e":"ui-display","a":{"title":"Stencil"},"f":[{"t":4,"f":[{"p":[21,2,599],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"name","p":[21,21,618]}]},"f":[{"t":4,"f":[{"p":[23,7,655],"t":7,"e":"ui-button","a":{"action":"select_stencil","params":["{\"item\":\"",{"t":2,"r":"item","p":[23,59,707]},"\"}"],"style":[{"t":2,"x":{"r":["item","data.selected_stencil"],"s":"_0==_1?\"selected\":null"},"p":[24,12,731]}]},"f":[{"t":2,"r":"item","p":[25,4,791]}]}],"n":52,"r":"items","p":[22,3,632]}]}],"n":52,"r":"data.drawables","p":[20,3,572]}]}," ",{"p":[31,1,874],"t":7,"e":"ui-display","a":{"title":"Text Mode"},"f":[{"p":[32,2,907],"t":7,"e":"ui-section","a":{"label":"Current Buffer"},"f":[{"t":2,"r":"text_buffer","p":[32,37,942]}]}," ",{"p":[34,2,976],"t":7,"e":"ui-section","f":[{"p":[34,14,988],"t":7,"e":"ui-button","a":{"action":"enter_text"},"f":["New Text"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],240:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  data: {
    temperatureStatus: function temperatureStatus(temp) {
      if (temp < 225) return 'good';else if (temp < 273.15) return 'average';else return 'bad';
    }
  },
  computed: {
    occupantStatState: function occupantStatState() {
      switch (this.get('data.occupant.stat')) {
        case 0:
          return 'good';
        case 1:
          return 'average';
        default:
          return 'bad';
      }
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[22,1,466],"t":7,"e":"ui-display","a":{"title":"Occupant"},"f":[{"p":[23,3,499],"t":7,"e":"ui-section","a":{"label":"Occupant"},"f":[{"p":[24,3,532],"t":7,"e":"span","f":[{"t":2,"x":{"r":["data.occupant.name"],"s":"_0?_0:\"No Occupant\""},"p":[24,9,538]}]}]}," ",{"t":4,"f":[{"p":[27,5,655],"t":7,"e":"ui-section","a":{"label":"State"},"f":[{"p":[28,7,689],"t":7,"e":"span","a":{"class":[{"t":2,"r":"occupantStatState","p":[28,20,702]}]},"f":[{"t":2,"x":{"r":["data.occupant.stat"],"s":"_0==0?\"Conscious\":_0==1?\"Unconcious\":\"Dead\""},"p":[28,43,725]}]}]}," ",{"p":[30,4,846],"t":7,"e":"ui-section","a":{"label":"Temperature"},"f":[{"p":[31,6,885],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["temperatureStatus","adata.occupant.bodyTemperature"],"s":"_0(_1)"},"p":[31,19,898]}]},"f":[{"t":2,"x":{"r":["adata.occupant.bodyTemperature"],"s":"Math.round(_0)"},"p":[31,74,953]}," K"]}]}," ",{"p":[33,5,1032],"t":7,"e":"ui-section","a":{"label":"Health"},"f":[{"p":[34,7,1067],"t":7,"e":"ui-bar","a":{"min":[{"t":2,"r":"data.occupant.minHealth","p":[34,20,1080]}],"max":[{"t":2,"r":"data.occupant.maxHealth","p":[34,54,1114]}],"value":[{"t":2,"r":"data.occupant.health","p":[34,90,1150]}],"state":[{"t":2,"x":{"r":["data.occupant.health"],"s":"_0>=0?\"good\":\"average\""},"p":[35,16,1192]}]},"f":[{"t":2,"x":{"r":["adata.occupant.health"],"s":"Math.round(_0)"},"p":[35,68,1244]}]}]}," ",{"t":4,"f":[{"p":[38,7,1481],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"label","p":[38,26,1500]}]},"f":[{"p":[39,9,1521],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"data.occupant.maxHealth","p":[39,30,1542]}],"value":[{"t":2,"rx":{"r":"data.occupant","m":[{"t":30,"n":"type"}]},"p":[39,66,1578]}],"state":"bad"},"f":[{"t":2,"x":{"r":["type","adata.occupant"],"s":"Math.round(_1[_0])"},"p":[39,103,1615]}]}]}],"n":52,"x":{"r":[],"s":"[{label:\"Brute\",type:\"bruteLoss\"},{label:\"Respiratory\",type:\"oxyLoss\"},{label:\"Toxin\",type:\"toxLoss\"},{label:\"Burn\",type:\"fireLoss\"}]"},"p":[37,5,1315]}],"n":50,"r":"data.hasOccupant","p":[26,3,625]}]}," ",{"p":[44,1,1724],"t":7,"e":"ui-display","a":{"title":"Cell"},"f":[{"p":[45,3,1753],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[46,5,1785],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"power-off\":\"close\""},"p":[46,22,1802]}],"style":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"selected\":null"},"p":[47,14,1862]}],"state":[{"t":2,"x":{"r":["data.isOpen"],"s":"_0?\"disabled\":null"},"p":[48,14,1918]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.isOperating"],"s":"_0?\"On\":\"Off\""},"p":[49,22,1977]}]}]}," ",{"p":[51,3,2045],"t":7,"e":"ui-section","a":{"label":"Temperature"},"f":[{"p":[52,3,2081],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["temperatureStatus","adata.cellTemperature"],"s":"_0(_1)"},"p":[52,16,2094]}]},"f":[{"t":2,"x":{"r":["adata.cellTemperature"],"s":"Math.round(_0)"},"p":[52,62,2140]}," K"]}]}," ",{"p":[54,2,2205],"t":7,"e":"ui-section","a":{"label":"Door"},"f":[{"p":[55,5,2236],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.isOpen"],"s":"_0?\"unlock\":\"lock\""},"p":[55,22,2253]}],"action":"door"},"f":[{"t":2,"x":{"r":["data.isOpen"],"s":"_0?\"Open\":\"Closed\""},"p":[55,73,2304]}]}," ",{"p":[56,5,2357],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.autoEject"],"s":"_0?\"sign-out\":\"sign-in\""},"p":[56,22,2374]}],"action":"autoeject"},"f":[{"t":2,"x":{"r":["data.autoEject"],"s":"_0?\"Auto\":\"Manual\""},"p":[56,86,2438]}]}]}]}," ",{"p":{"button":[{"p":[61,5,2584],"t":7,"e":"ui-button","a":{"icon":"eject","state":[{"t":2,"x":{"r":["data.isBeakerLoaded"],"s":"_0?null:\"disabled\""},"p":[61,36,2615]}],"action":"ejectbeaker"},"f":["Eject"]}]},"t":7,"e":"ui-display","a":{"title":"Beaker","button":0},"f":[" ",{"p":[63,3,2718],"t":7,"e":"ui-section","a":{"label":"Contents"},"f":[{"t":4,"f":[{"t":4,"f":[{"p":[66,9,2828],"t":7,"e":"span","a":{"class":"highlight"},"t0":"fade","f":[{"t":2,"x":{"r":["volume"],"s":"Math.fixed(_0,2)"},"p":[66,52,2871]}," units of ",{"t":2,"r":"name","p":[66,87,2906]}]},{"p":[66,102,2921],"t":7,"e":"br"}],"n":52,"r":"adata.beakerContents","p":[65,7,2788]},{"t":4,"n":51,"f":[{"p":[68,9,2952],"t":7,"e":"span","a":{"class":"bad"},"f":["Beaker Empty"]}],"r":"adata.beakerContents"}],"n":50,"r":"data.isBeakerLoaded","p":[64,5,2753]},{"t":4,"n":51,"f":[{"p":[71,7,3028],"t":7,"e":"span","a":{"class":"average"},"f":["No Beaker"]}],"r":"data.isBeakerLoaded"}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],241:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-notice","f":[{"p":[2,5,17],"t":7,"e":"span","f":["Time Until Launch: ",{"t":2,"r":"data.timer_str","p":[2,30,42]}]}]}," ",{"p":[4,1,83],"t":7,"e":"ui-notice","f":[{"p":[5,3,98],"t":7,"e":"span","f":["Engines: ",{"t":2,"x":{"r":["data.engines_started"],"s":"_0?\"Online\":\"Idle\""},"p":[5,18,113]}]}]}," ",{"p":[7,1,180],"t":7,"e":"ui-display","a":{"title":"Early Launch"},"f":[{"p":[8,2,216],"t":7,"e":"span","f":["Authorizations Remaining: ",{"t":2,"x":{"r":["data.emagged","data.authorizations_remaining"],"s":"_0?\"ERROR\":_1"},"p":[9,2,250]}]}," ",{"p":[10,2,318],"t":7,"e":"ui-button","a":{"icon":"exclamation-triangle","action":"authorize","style":"danger","state":[{"t":2,"x":{"r":["data.enabled"],"s":"_0?null:\"disabled\""},"p":[12,10,404]}]},"f":["AUTHORIZE"]}," ",{"p":[15,2,473],"t":7,"e":"ui-button","a":{"icon":"minus","action":"repeal","state":[{"t":2,"x":{"r":["data.enabled"],"s":"_0?null:\"disabled\""},"p":[16,10,523]}]},"f":["Repeal"]}," ",{"p":[19,2,589],"t":7,"e":"ui-button","a":{"icon":"close","action":"abort","state":[{"t":2,"x":{"r":["data.enabled"],"s":"_0?null:\"disabled\""},"p":[20,10,638]}]},"f":["Repeal All"]}]}," ",{"p":[24,1,722],"t":7,"e":"ui-display","a":{"title":"Authorizations"},"f":[{"t":4,"f":[{"p":[26,3,793],"t":7,"e":"ui-section","a":{"candystripe":0,"nowrap":0},"f":[{"t":2,"r":"name","p":[26,34,824]}," (",{"t":2,"r":"job","p":[26,44,834]},")"]}],"n":52,"r":"data.authorizations","p":[25,2,760]},{"t":4,"n":51,"f":[{"p":[28,3,870],"t":7,"e":"ui-section","a":{"candystripe":0,"nowrap":0},"f":["No authorizations."]}],"r":"data.authorizations"}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],242:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-notice","f":[{"p":[2,3,15],"t":7,"e":"span","f":["The requested interface (",{"t":2,"r":"config.interface","p":[2,34,46]},") was not found. Does it exist?"]}]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],243:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    seclevelState: function seclevelState() {
      switch (this.get('data.seclevel')) {
        case 'blue':
          return 'average';
        case 'red':
          return 'bad';
        case 'delta':
          return 'bad bold';
        default:
          return 'good';
      }
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[16,1,323],"t":7,"e":"ui-display","f":[{"p":[17,5,341],"t":7,"e":"ui-section","a":{"label":"Alert Level"},"f":[{"p":[18,9,383],"t":7,"e":"span","a":{"class":[{"t":2,"r":"seclevelState","p":[18,22,396]}]},"f":[{"t":2,"x":{"r":["text","data.seclevel"],"s":"_0.titleCase(_1)"},"p":[18,41,415]}]}]}," ",{"p":[20,5,480],"t":7,"e":"ui-section","a":{"label":"Controls"},"f":[{"p":[21,9,519],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.alarm"],"s":"_0?\"close\":\"bell-o\""},"p":[21,26,536]}],"action":[{"t":2,"x":{"r":["data.alarm"],"s":"_0?\"reset\":\"alarm\""},"p":[21,71,581]}]},"f":[{"t":2,"x":{"r":["data.alarm"],"s":"_0?\"Reset\":\"Activate\""},"p":[22,13,631]}]}]}," ",{"t":4,"f":[{"p":[25,7,733],"t":7,"e":"ui-section","a":{"label":"Warning"},"f":[{"p":[26,9,771],"t":7,"e":"span","a":{"class":"bad bold"},"f":["Safety measures offline. Device may exhibit abnormal behavior."]}]}],"n":50,"r":"data.emagged","p":[24,5,705]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],244:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    healthState: function healthState() {
      var health = this.get('data.health');
      if (health > 70) return 'good';else if (health > 50) return 'average';else return 'bad';
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"t":4,"f":[{"p":[15,3,296],"t":7,"e":"ui-notice","f":[{"p":[16,5,313],"t":7,"e":"span","f":["Wipe in progress!"]}]}],"n":50,"r":"data.wiping","p":[14,1,273]},{"p":{"button":[{"t":4,"f":[{"p":[22,7,479],"t":7,"e":"ui-button","a":{"icon":"trash","state":[{"t":2,"x":{"r":["data.wiping","data.isDead"],"s":"_0||_1?\"disabled\":null"},"p":[22,38,510]}],"action":"wipe"},"f":["Wipe AI"]}],"n":50,"r":"data.name","p":[21,5,454]}]},"t":7,"e":"ui-display","a":{"title":[{"t":2,"x":{"r":["data.name"],"s":"_0||\"Empty Card\""},"p":[19,19,388]}],"button":0},"f":[" ",{"t":4,"f":[{"p":[26,5,651],"t":7,"e":"ui-section","a":{"label":"Status"},"f":[{"p":[27,9,688],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.isDead","data.isBraindead"],"s":"_0||_1?\"bad\":\"good\""},"p":[27,22,701]}]},"f":[{"t":2,"x":{"r":["data.isDead","data.isBraindead"],"s":"_0||_1?\"Offline\":\"Operational\""},"p":[27,76,755]}]}]}," ",{"p":[29,5,850],"t":7,"e":"ui-section","a":{"label":"Software Integrity"},"f":[{"p":[30,7,897],"t":7,"e":"ui-bar","a":{"min":"0","max":"100","value":[{"t":2,"r":"data.health","p":[30,40,930]}],"state":[{"t":2,"r":"healthState","p":[30,64,954]}]},"f":[{"t":2,"x":{"r":["adata.health"],"s":"Math.round(_0)"},"p":[30,81,971]},"%"]}]}," ",{"p":[32,5,1034],"t":7,"e":"ui-section","a":{"label":"Laws"},"f":[{"t":4,"f":[{"p":[34,9,1096],"t":7,"e":"span","a":{"class":"highlight"},"f":[{"t":2,"r":".","p":[34,33,1120]}]},{"p":[34,45,1132],"t":7,"e":"br"}],"n":52,"r":"data.laws","p":[33,7,1067]}]}," ",{"p":[37,5,1179],"t":7,"e":"ui-section","a":{"label":"Settings"},"f":[{"p":[38,7,1216],"t":7,"e":"ui-button","a":{"icon":"signal","style":[{"t":2,"x":{"r":["data.wireless"],"s":"_0?\"selected\":null"},"p":[38,39,1248]}],"action":"wireless"},"f":["Wireless Activity"]}," ",{"p":[39,7,1342],"t":7,"e":"ui-button","a":{"icon":"microphone","style":[{"t":2,"x":{"r":["data.radio"],"s":"_0?\"selected\":null"},"p":[39,43,1378]}],"action":"radio"},"f":["Subspace Radio"]}]}],"n":50,"r":"data.name","p":[25,3,628]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],245:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"p":[2,2,23],"t":7,"e":"ui-notice","f":[{"p":[3,3,38],"t":7,"e":"span","f":["Waiting for another device to confirm your request..."]}]}],"n":50,"r":"data.waiting","p":[1,1,0]},{"t":4,"n":51,"f":[{"p":[6,2,132],"t":7,"e":"ui-display","f":[{"p":[7,3,148],"t":7,"e":"ui-section","f":[{"t":4,"f":[{"p":[9,5,197],"t":7,"e":"ui-button","a":{"icon":"check","action":"auth_swipe"},"f":["Authorize ",{"t":2,"r":"data.auth_required","p":[9,59,251]}]}],"n":50,"r":"data.auth_required","p":[8,4,165]},{"t":4,"n":51,"f":[{"p":[11,5,304],"t":7,"e":"ui-button","a":{"icon":"warning","state":[{"t":2,"x":{"r":["data.red_alert"],"s":"_0?\"disabled\":null"},"p":[11,38,337]}],"action":"red_alert"},"f":["Red Alert"]}," ",{"p":[12,5,423],"t":7,"e":"ui-button","a":{"icon":"wrench","state":[{"t":2,"x":{"r":["data.emergency_maint"],"s":"_0?\"disabled\":null"},"p":[12,37,455]}],"action":"emergency_maint"},"f":["Emergency Maintenance Access"]}],"r":"data.auth_required"}]}]}],"r":"data.waiting"}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],246:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
		data: {
				mechChargeState: function mechChargeState(charge) {
						var maxcharge = this.get('data.recharge_port.mech.cell.maxcharge');
						if (charge >= maxcharge / 1.5) return 'good';else if (charge >= maxcharge / 3) return 'average';else return 'bad';
				},
				mechHealthState: function mechHealthState(health) {
						var maxhealth = this.get('data.recharge_port.mech.maxhealth');
						if (health > maxhealth / 1.5) return 'good';else if (health > maxhealth / 3) return 'average';else return 'bad';
				}
		}
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[20,1,545],"t":7,"e":"ui-display","a":{"title":"Mech Status"},"f":[{"t":4,"f":[{"t":4,"f":[{"p":[23,4,646],"t":7,"e":"ui-section","a":{"label":"Integrity"},"f":[{"p":[24,6,683],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"adata.recharge_port.mech.maxhealth","p":[24,27,704]}],"value":[{"t":2,"r":"adata.recharge_port.mech.health","p":[24,74,751]}],"state":[{"t":2,"x":{"r":["mechHealthState","adata.recharge_port.mech.health"],"s":"_0(_1)"},"p":[24,117,794]}]},"f":[{"t":2,"x":{"r":["adata.recharge_port.mech.health"],"s":"Math.round(_0)"},"p":[24,171,848]},"/",{"t":2,"r":"adata.recharge_port.mech.maxhealth","p":[24,219,896]}]}]}," ",{"t":4,"f":[{"t":4,"f":[{"p":[28,5,1061],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[28,31,1087],"t":7,"e":"span","a":{"class":"bad"},"f":["Cell Critical Failure"]}]}],"n":50,"r":"data.recharge_port.mech.cell.critfail","p":[27,3,1010]},{"t":4,"n":51,"f":[{"p":[30,11,1170],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[31,13,1210],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"adata.recharge_port.mech.cell.maxcharge","p":[31,34,1231]}],"value":[{"t":2,"r":"adata.recharge_port.mech.cell.charge","p":[31,86,1283]}],"state":[{"t":2,"x":{"r":["mechChargeState","adata.recharge_port.mech.cell.charge"],"s":"_0(_1)"},"p":[31,134,1331]}]},"f":[{"t":2,"x":{"r":["adata.recharge_port.mech.cell.charge"],"s":"Math.round(_0)"},"p":[31,193,1390]},"/",{"t":2,"x":{"r":["adata.recharge_port.mech.cell.maxcharge"],"s":"Math.round(_0)"},"p":[31,246,1443]}]}]}],"r":"data.recharge_port.mech.cell.critfail"}],"n":50,"r":"data.recharge_port.mech.cell","p":[26,4,970]},{"t":4,"n":51,"f":[{"p":[35,3,1558],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[35,29,1584],"t":7,"e":"span","a":{"class":"bad"},"f":["Cell Missing"]}]}],"r":"data.recharge_port.mech.cell"}],"n":50,"r":"data.recharge_port.mech","p":[22,2,610]},{"t":4,"n":51,"f":[{"p":[38,4,1662],"t":7,"e":"ui-section","f":["Mech Not Found"]}],"r":"data.recharge_port.mech"}],"n":50,"r":"data.recharge_port","p":[21,3,581]},{"t":4,"n":51,"f":[{"p":[41,5,1729],"t":7,"e":"ui-section","f":["Recharging Port Not Found"]}," ",{"p":[42,2,1782],"t":7,"e":"ui-button","a":{"icon":"refresh","action":"reconnect"},"f":["Reconnect"]}],"r":"data.recharge_port"}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],247:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-notice","f":[{"t":4,"f":[{"p":[3,5,45],"t":7,"e":"ui-section","a":{"label":"Interface Lock"},"f":[{"p":[4,7,88],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"lock\":\"unlock\""},"p":[4,24,105]}],"action":"lock"},"f":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[4,75,156]}]}]}],"n":50,"r":"data.siliconUser","p":[2,3,15]},{"t":4,"n":51,"f":[{"p":[7,5,247],"t":7,"e":"span","f":["Swipe an ID card to ",{"t":2,"x":{"r":["data.locked"],"s":"_0?\"unlock\":\"lock\""},"p":[7,31,273]}," this interface."]}],"r":"data.siliconUser"}]}," ",{"p":[10,1,358],"t":7,"e":"ui-display","a":{"title":"Status"},"f":[{"p":[11,3,389],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"t":4,"f":[{"p":[13,7,470],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[13,24,487]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":null"},"p":[13,68,531]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[13,116,579]}]}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"!_0||_1"},"p":[12,5,421]},{"t":4,"n":51,"f":[{"p":[15,7,639],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"good\":\"bad\""},"p":[15,20,652]}],"state":[{"t":2,"x":{"r":["data.cell"],"s":"_0?null:\"disabled\""},"p":[15,57,689]}]},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[15,92,724]}]}],"x":{"r":["data.locked","data.siliconUser"],"s":"!_0||_1"}}]}," ",{"p":[18,3,791],"t":7,"e":"ui-section","a":{"label":"Cell"},"f":[{"p":[19,5,822],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.cell"],"s":"_0?null:\"bad\""},"p":[19,18,835]}]},"f":[{"t":2,"x":{"r":["data.cell","data.cellPercent"],"s":"_0?_1+\"%\":\"No Cell\""},"p":[19,48,865]}]}]}," ",{"p":[21,3,943],"t":7,"e":"ui-section","a":{"label":"Mode"},"f":[{"p":[22,5,974],"t":7,"e":"span","a":{"class":[{"t":2,"r":"data.modeStatus","p":[22,18,987]}]},"f":[{"t":2,"r":"data.mode","p":[22,39,1008]}]}]}," ",{"p":[24,3,1049],"t":7,"e":"ui-section","a":{"label":"Load"},"f":[{"p":[25,5,1080],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.load"],"s":"_0?\"good\":\"average\""},"p":[25,18,1093]}]},"f":[{"t":2,"x":{"r":["data.load"],"s":"_0?_0:\"None\""},"p":[25,54,1129]}]}]}," ",{"p":[27,3,1191],"t":7,"e":"ui-section","a":{"label":"Destination"},"f":[{"p":[28,5,1229],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.destination"],"s":"_0?\"good\":\"average\""},"p":[28,18,1242]}]},"f":[{"t":2,"x":{"r":["data.destination"],"s":"_0?_0:\"None\""},"p":[28,60,1284]}]}]}]}," ",{"t":4,"f":[{"p":{"button":[{"t":4,"f":[{"p":[35,9,1513],"t":7,"e":"ui-button","a":{"icon":"eject","action":"unload"},"f":["Unload"]}],"n":50,"r":"data.load","p":[34,7,1486]}," ",{"t":4,"f":[{"p":[38,9,1623],"t":7,"e":"ui-button","a":{"icon":"eject","action":"ejectpai"},"f":["Eject PAI"]}],"n":50,"r":"data.haspai","p":[37,7,1594]}," ",{"p":[40,7,1709],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"setid"},"f":["Set ID"]}]},"t":7,"e":"ui-display","a":{"title":"Controls","button":0},"f":[" ",{"p":[42,5,1791],"t":7,"e":"ui-section","a":{"label":"Destination"},"f":[{"p":[43,7,1831],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"destination"},"f":["Set Destination"]}," ",{"p":[44,7,1912],"t":7,"e":"ui-button","a":{"icon":"stop","action":"stop"},"f":["Stop"]}," ",{"p":[45,7,1973],"t":7,"e":"ui-button","a":{"icon":"play","action":"go"},"f":["Go"]}]}," ",{"p":[47,5,2047],"t":7,"e":"ui-section","a":{"label":"Home"},"f":[{"p":[48,7,2080],"t":7,"e":"ui-button","a":{"icon":"home","action":"home"},"f":["Go Home"]}," ",{"p":[49,7,2144],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"sethome"},"f":["Set Home"]}]}," ",{"p":[51,5,2231],"t":7,"e":"ui-section","a":{"label":"Settings"},"f":[{"p":[52,7,2268],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.autoReturn"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[52,24,2285]}],"style":[{"t":2,"x":{"r":["data.autoReturn"],"s":"_0?\"selected\":null"},"p":[52,84,2345]}],"action":"autoret"},"f":["Auto-Return Home"]}," ",{"p":[54,7,2449],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.autoPickup"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[54,24,2466]}],"style":[{"t":2,"x":{"r":["data.autoPickup"],"s":"_0?\"selected\":null"},"p":[54,84,2526]}],"action":"autopick"},"f":["Auto-Pickup Crate"]}," ",{"p":[56,7,2632],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.reportDelivery"],"s":"_0?\"check-square-o\":\"square-o\""},"p":[56,24,2649]}],"style":[{"t":2,"x":{"r":["data.reportDelivery"],"s":"_0?\"selected\":null"},"p":[56,88,2713]}],"action":"report"},"f":["Report Deliveries"]}]}]}],"n":50,"x":{"r":["data.locked","data.siliconUser"],"s":"!_0||_1"},"p":[31,1,1373]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],248:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var _filter = require('util/filter');

component.exports = {
  data: {
    filter: ''
  },
  oninit: function oninit() {
    var _this = this;

    this.observe('filter', function (newkey, oldkey, keypath) {
      var categories = _this.findAll('.display:not(:first-child)');
      (0, _filter.filterMulti)(categories, _this.get('filter').toLowerCase());
    }, { init: false });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[16,1,387],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"data.category","p":[16,20,406]}]},"f":[{"t":4,"f":[{"p":[18,5,452],"t":7,"e":"ui-section","f":["Crafting... ",{"p":[19,16,481],"t":7,"e":"i","a":{"class":"fa-spin fa fa-spinner"}}]}],"n":50,"r":"data.busy","p":[17,3,429]},{"t":4,"n":51,"f":[{"p":[22,5,552],"t":7,"e":"ui-section","f":[{"p":[23,7,572],"t":7,"e":"ui-button","a":{"icon":"arrow-left","action":"backwardCat"},"f":[{"t":2,"r":"data.prev_cat","p":[24,6,630]}]}," ",{"p":[26,4,669],"t":7,"e":"ui-button","a":{"icon":"arrow-right","action":"forwardCat"},"f":[{"t":2,"r":"data.next_cat","p":[27,6,726]}]}," ",{"t":4,"f":[{"p":[30,6,810],"t":7,"e":"ui-button","a":{"icon":"lock","action":"toggle_recipes"},"f":["Showing Craftable Recipes"]}],"n":50,"r":"data.display_craftable_only","p":[29,4,768]},{"t":4,"n":51,"f":[{"p":[34,6,924],"t":7,"e":"ui-button","a":{"icon":"unlock","action":"toggle_recipes"},"f":["Showing All Recipes"]}],"r":"data.display_craftable_only"}," ",{"t":4,"f":[{"p":[39,6,1061],"t":7,"e":"ui-input","a":{"value":[{"t":2,"r":"filter","p":[39,23,1078]}],"placeholder":"Filter.."}}],"n":50,"r":"config.fancy","p":[38,7,1034]}]}," ",{"t":4,"f":[{"p":[43,7,1180],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"name","p":[43,26,1199]}]},"f":[{"t":4,"f":[{"p":[45,8,1241],"t":7,"e":"ui-section","a":{"label":"Requirements"},"f":[{"t":2,"r":"req_text","p":[46,10,1285]}]}],"n":50,"r":"req_text","p":[44,6,1216]}," ",{"t":4,"f":[{"p":[50,5,1364],"t":7,"e":"ui-section","a":{"label":"Catalysts"},"f":[{"t":2,"r":"catalyst_text","p":[51,10,1405]}]}],"n":50,"r":"catalyst_text","p":[49,6,1337]}," ",{"t":4,"f":[{"p":[55,5,1485],"t":7,"e":"ui-section","a":{"label":"Tools"},"f":[{"t":2,"r":"tool_text","p":[56,10,1522]}]}],"n":50,"r":"tool_text","p":[54,3,1462]}," ",{"p":[59,6,1575],"t":7,"e":"ui-section","f":[{"p":[60,8,1596],"t":7,"e":"ui-button","a":{"icon":"gears","action":"make","params":["{\"recipe\": \"",{"t":2,"r":"ref","p":[60,66,1654]},"\"}"]},"f":["Craft"]}]}]}],"n":52,"r":"data.can_craft","p":[42,5,1148]}," ",{"t":4,"f":[{"t":4,"f":[{"p":[68,9,1827],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"name","p":[68,28,1846]}]},"f":[{"t":4,"f":[{"p":[70,10,1892],"t":7,"e":"ui-section","a":{"label":"Requirements"},"f":[{"t":2,"r":"req_text","p":[71,12,1938]}]}],"n":50,"r":"req_text","p":[69,8,1865]}," ",{"t":4,"f":[{"p":[75,7,2025],"t":7,"e":"ui-section","a":{"label":"Catalysts"},"f":[{"t":2,"r":"catalyst_text","p":[76,12,2068]}]}],"n":50,"r":"catalyst_text","p":[74,5,1996]}," ",{"t":4,"f":[{"p":[80,7,2156],"t":7,"e":"ui-section","a":{"label":"Tools"},"f":[{"t":2,"r":"tool_text","p":[81,12,2195]}]}],"n":50,"r":"tool_text","p":[79,5,2131]}]}],"n":52,"r":"data.cant_craft","p":[67,7,1792]}],"n":51,"r":"data.display_craftable_only","p":[66,2,1752]}],"r":"data.busy"}]}]};
module.exports = Ractive.extend(component.exports);

},{"ractive":205,"util/filter":273}],249:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-notice","f":[{"p":[2,3,15],"t":7,"e":"span","f":["The regulator ",{"t":2,"x":{"r":["data.holding"],"s":"_0?\"is\":\"is not\""},"p":[2,23,35]}," connected to a tank."]}]}," ",{"p":[4,1,113],"t":7,"e":"ui-display","a":{"title":"Status","button":0},"f":[{"p":[5,3,151],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"p":[6,5,186],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.pressure"],"s":"Math.round(_0)"},"p":[6,11,192]}," kPa"]}]}," ",{"p":[8,3,254],"t":7,"e":"ui-section","a":{"label":"Port"},"f":[{"p":[9,5,285],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.connected"],"s":"_0?\"good\":\"average\""},"p":[9,18,298]}]},"f":[{"t":2,"x":{"r":["data.connected"],"s":"_0?\"Connected\":\"Not Connected\""},"p":[9,59,339]}]}]}]}," ",{"p":[12,1,430],"t":7,"e":"ui-display","a":{"title":"Pump"},"f":[{"p":[13,3,459],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[14,5,491],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[14,22,508]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":\"null\""},"p":[15,14,559]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[16,22,616]}]}]}," ",{"p":[18,3,675],"t":7,"e":"ui-section","a":{"label":"Direction"},"f":[{"p":[19,5,711],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.direction"],"s":"_0==\"out\"?\"sign-out\":\"sign-in\""},"p":[19,22,728]}],"action":"direction"},"f":[{"t":2,"x":{"r":["data.direction"],"s":"_0==\"out\"?\"Out\":\"In\""},"p":[20,26,808]}]}]}," ",{"p":[22,3,883],"t":7,"e":"ui-section","a":{"label":"Target Pressure"},"f":[{"p":[23,5,925],"t":7,"e":"ui-bar","a":{"min":[{"t":2,"r":"data.min_pressure","p":[23,18,938]}],"max":[{"t":2,"r":"data.max_pressure","p":[23,46,966]}],"value":[{"t":2,"r":"data.target_pressure","p":[24,14,1003]}]},"f":[{"t":2,"x":{"r":["adata.target_pressure"],"s":"Math.round(_0)"},"p":[24,40,1029]}," kPa"]}]}," ",{"p":[26,3,1100],"t":7,"e":"ui-section","a":{"label":"Pressure Regulator"},"f":[{"p":[27,5,1145],"t":7,"e":"ui-button","a":{"icon":"refresh","state":[{"t":2,"x":{"r":["data.target_pressure","data.default_pressure"],"s":"_0!=_1?null:\"disabled\""},"p":[27,38,1178]}],"action":"pressure","params":"{\"pressure\": \"reset\"}"},"f":["Reset"]}," ",{"p":[29,5,1328],"t":7,"e":"ui-button","a":{"icon":"minus","state":[{"t":2,"x":{"r":["data.target_pressure","data.min_pressure"],"s":"_0>_1?null:\"disabled\""},"p":[29,36,1359]}],"action":"pressure","params":"{\"pressure\": \"min\"}"},"f":["Min"]}," ",{"p":[31,5,1500],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure","params":"{\"pressure\": \"input\"}"},"f":["Set"]}," ",{"p":[32,5,1595],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.target_pressure","data.max_pressure"],"s":"_0<_1?null:\"disabled\""},"p":[32,35,1625]}],"action":"pressure","params":"{\"pressure\": \"max\"}"},"f":["Max"]}]}]}," ",{"p":{"button":[{"t":4,"f":[{"p":[39,7,1891],"t":7,"e":"ui-button","a":{"icon":"eject","style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"danger\":null"},"p":[39,38,1922]}],"action":"eject"},"f":["Eject"]}],"n":50,"r":"data.holding","p":[38,5,1863]}]},"t":7,"e":"ui-display","a":{"title":"Holding Tank","button":0},"f":[" ",{"t":4,"f":[{"p":[43,3,2042],"t":7,"e":"ui-section","a":{"label":"Label"},"f":[{"t":2,"r":"data.holding.name","p":[44,4,2073]}]}," ",{"p":[46,3,2115],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"t":2,"x":{"r":["adata.holding.pressure"],"s":"Math.round(_0)"},"p":[47,4,2149]}," kPa"]}],"n":50,"r":"data.holding","p":[42,3,2018]},{"t":4,"n":51,"f":[{"p":[50,3,2223],"t":7,"e":"ui-section","f":[{"p":[51,4,2240],"t":7,"e":"span","a":{"class":"average"},"f":["No Holding Tank"]}]}],"r":"data.holding"}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],250:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-notice","f":[{"p":[2,3,15],"t":7,"e":"span","f":["The regulator ",{"t":2,"x":{"r":["data.holding"],"s":"_0?\"is\":\"is not\""},"p":[2,23,35]}," connected to a tank."]}]}," ",{"p":[4,1,113],"t":7,"e":"ui-display","a":{"title":"Status","button":0},"f":[{"p":[5,3,151],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"p":[6,5,186],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.pressure"],"s":"Math.round(_0)"},"p":[6,11,192]}," kPa"]}]}," ",{"p":[8,3,254],"t":7,"e":"ui-section","a":{"label":"Port"},"f":[{"p":[9,5,285],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.connected"],"s":"_0?\"good\":\"average\""},"p":[9,18,298]}]},"f":[{"t":2,"x":{"r":["data.connected"],"s":"_0?\"Connected\":\"Not Connected\""},"p":[9,59,339]}]}]}]}," ",{"p":[12,1,430],"t":7,"e":"ui-display","a":{"title":"Filter"},"f":[{"p":[13,3,461],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[14,5,493],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[14,22,510]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":\"null\""},"p":[15,14,561]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[16,22,618]}]}]}]}," ",{"p":{"button":[{"t":4,"f":[{"p":[22,7,787],"t":7,"e":"ui-button","a":{"icon":"eject","style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"danger\":null"},"p":[22,38,818]}],"action":"eject"},"f":["Eject"]}],"n":50,"r":"data.holding","p":[21,5,759]}]},"t":7,"e":"ui-display","a":{"title":"Holding Tank","button":0},"f":[" ",{"t":4,"f":[{"p":[26,3,938],"t":7,"e":"ui-section","a":{"label":"Label"},"f":[{"t":2,"r":"data.holding.name","p":[27,4,969]}]}," ",{"p":[29,3,1011],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"t":2,"x":{"r":["adata.holding.pressure"],"s":"Math.round(_0)"},"p":[30,4,1045]}," kPa"]}],"n":50,"r":"data.holding","p":[25,3,914]},{"t":4,"n":51,"f":[{"p":[33,3,1119],"t":7,"e":"ui-section","f":[{"p":[34,4,1136],"t":7,"e":"span","a":{"class":"average"},"f":["No Holding Tank"]}]}],"r":"data.holding"}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],251:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  data: {
    chargingState: function chargingState(status) {
      switch (status) {
        case 2:
          return 'good';
        case 1:
          return 'average';
        default:
          return 'bad';
      }
    },
    chargingMode: function chargingMode(status) {
      if (status == 2) return 'Full';else if (status == 1) return 'Charging';else return 'Draining';
    },
    channelState: function channelState(status) {
      if (status >= 2) return 'good';else return 'bad';
    },
    channelPower: function channelPower(status) {
      if (status >= 2) return 'On';else return 'Off';
    },
    channelMode: function channelMode(status) {
      if (status == 1 || status == 3) return 'Auto';else return 'Manual';
    }
  },
  computed: {
    graphData: function graphData() {
      var history = this.get('data.history');
      return Object.keys(history).map(function (key) {
        return history[key].map(function (point, index) {
          return { x: index, y: point };
        });
      });
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[42,1,1035],"t":7,"e":"ui-display","a":{"title":"Network"},"f":[{"t":4,"f":[{"p":[44,5,1093],"t":7,"e":"ui-linegraph","a":{"points":[{"t":2,"r":"graphData","p":[44,27,1115]}],"height":"500","legend":"[\"Available\", \"Load\"]","colors":"[\"rgb(0, 102, 0)\", \"rgb(153, 0, 0)\"]","xunit":"seconds ago","xfactor":[{"t":2,"r":"data.interval","p":[46,38,1267]}],"yunit":"W","yfactor":"1","xinc":[{"t":2,"x":{"r":["data.stored"],"s":"_0/10"},"p":[47,15,1323]}],"yinc":"9"}}],"n":50,"r":"config.fancy","p":[43,3,1067]},{"t":4,"n":51,"f":[{"p":[49,5,1373],"t":7,"e":"ui-section","a":{"label":"Available"},"f":[{"p":[50,7,1411],"t":7,"e":"span","f":[{"t":2,"r":"data.supply","p":[50,13,1417]}," W"]}]}," ",{"p":[52,5,1466],"t":7,"e":"ui-section","a":{"label":"Load"},"f":[{"p":[53,9,1501],"t":7,"e":"span","f":[{"t":2,"r":"data.demand","p":[53,15,1507]}," W"]}]}],"r":"config.fancy"}]}," ",{"p":[57,1,1578],"t":7,"e":"ui-display","a":{"title":"Areas"},"f":[{"p":[58,3,1608],"t":7,"e":"ui-section","a":{"nowrap":0},"f":[{"p":[59,5,1633],"t":7,"e":"div","a":{"class":"content"},"f":["Area"]}," ",{"p":[60,5,1670],"t":7,"e":"div","a":{"class":"content"},"f":["Charge"]}," ",{"p":[61,5,1709],"t":7,"e":"div","a":{"class":"content"},"f":["Load"]}," ",{"p":[62,5,1746],"t":7,"e":"div","a":{"class":"content"},"f":["Status"]}," ",{"p":[63,5,1785],"t":7,"e":"div","a":{"class":"content"},"f":["Equipment"]}," ",{"p":[64,5,1827],"t":7,"e":"div","a":{"class":"content"},"f":["Lighting"]}," ",{"p":[65,5,1868],"t":7,"e":"div","a":{"class":"content"},"f":["Environment"]}]}," ",{"t":4,"f":[{"p":[68,5,1953],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"name","p":[68,24,1972]}],"nowrap":0},"f":[{"p":[69,7,1997],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"x":{"r":["@index","adata.areas"],"s":"Math.round(_1[_0].charge)"},"p":[69,28,2018]}," %"]}," ",{"p":[70,7,2076],"t":7,"e":"div","a":{"class":"content"},"f":[{"t":2,"x":{"r":["@index","adata.areas"],"s":"Math.round(_1[_0].load)"},"p":[70,28,2097]}," W"]}," ",{"p":[71,7,2153],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[71,28,2174],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["chargingState","charging"],"s":"_0(_1)"},"p":[71,41,2187]}]},"f":[{"t":2,"x":{"r":["chargingMode","charging"],"s":"_0(_1)"},"p":[71,70,2216]}]}]}," ",{"p":[72,7,2263],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[72,28,2284],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["channelState","eqp"],"s":"_0(_1)"},"p":[72,41,2297]}]},"f":[{"t":2,"x":{"r":["channelPower","eqp"],"s":"_0(_1)"},"p":[72,64,2320]}," [",{"p":[72,87,2343],"t":7,"e":"span","f":[{"t":2,"x":{"r":["channelMode","eqp"],"s":"_0(_1)"},"p":[72,93,2349]}]},"]"]}]}," ",{"p":[73,7,2398],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[73,28,2419],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["channelState","lgt"],"s":"_0(_1)"},"p":[73,41,2432]}]},"f":[{"t":2,"x":{"r":["channelPower","lgt"],"s":"_0(_1)"},"p":[73,64,2455]}," [",{"p":[73,87,2478],"t":7,"e":"span","f":[{"t":2,"x":{"r":["channelMode","lgt"],"s":"_0(_1)"},"p":[73,93,2484]}]},"]"]}]}," ",{"p":[74,7,2533],"t":7,"e":"div","a":{"class":"content"},"f":[{"p":[74,28,2554],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["channelState","env"],"s":"_0(_1)"},"p":[74,41,2567]}]},"f":[{"t":2,"x":{"r":["channelPower","env"],"s":"_0(_1)"},"p":[74,64,2590]}," [",{"p":[74,87,2613],"t":7,"e":"span","f":[{"t":2,"x":{"r":["channelMode","env"],"s":"_0(_1)"},"p":[74,93,2619]}]},"]"]}]}]}],"n":52,"r":"data.areas","p":[67,3,1927]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],252:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    readableFrequency: function readableFrequency() {
      return Math.round(this.get('adata.frequency')) / 10;
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[11,1,177],"t":7,"e":"ui-display","a":{"title":"Settings"},"f":[{"t":4,"f":[{"p":[13,5,236],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[14,7,270],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.listening"],"s":"_0?\"power-off\":\"close\""},"p":[14,24,287]}],"style":[{"t":2,"x":{"r":["data.listening"],"s":"_0?\"selected\":null"},"p":[14,75,338]}],"action":"listen"},"f":[{"t":2,"x":{"r":["data.listening"],"s":"_0?\"On\":\"Off\""},"p":[16,9,413]}]}]}],"n":50,"r":"data.headset","p":[12,3,210]},{"t":4,"n":51,"f":[{"p":[19,5,494],"t":7,"e":"ui-section","a":{"label":"Microphone"},"f":[{"p":[20,7,533],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.broadcasting"],"s":"_0?\"power-off\":\"close\""},"p":[20,24,550]}],"style":[{"t":2,"x":{"r":["data.broadcasting"],"s":"_0?\"selected\":null"},"p":[20,78,604]}],"action":"broadcast"},"f":[{"t":2,"x":{"r":["data.broadcasting"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[22,9,685]}]}]}," ",{"p":[24,5,769],"t":7,"e":"ui-section","a":{"label":"Speaker"},"f":[{"p":[25,7,805],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.listening"],"s":"_0?\"power-off\":\"close\""},"p":[25,24,822]}],"style":[{"t":2,"x":{"r":["data.listening"],"s":"_0?\"selected\":null"},"p":[25,75,873]}],"action":"listen"},"f":[{"t":2,"x":{"r":["data.listening"],"s":"_0?\"Engaged\":\"Disengaged\""},"p":[27,9,948]}]}]}],"r":"data.headset"}," ",{"t":4,"f":[{"p":[31,5,1064],"t":7,"e":"ui-section","a":{"label":"High Volume"},"f":[{"p":[32,7,1104],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.useCommand"],"s":"_0?\"power-off\":\"close\""},"p":[32,24,1121]}],"style":[{"t":2,"x":{"r":["data.useCommand"],"s":"_0?\"selected\":null"},"p":[32,76,1173]}],"action":"command"},"f":[{"t":2,"x":{"r":["data.useCommand"],"s":"_0?\"On\":\"Off\""},"p":[34,9,1250]}]}]}],"n":50,"r":"data.command","p":[30,3,1038]}]}," ",{"p":[38,1,1342],"t":7,"e":"ui-display","a":{"title":"Channel"},"f":[{"p":[39,3,1374],"t":7,"e":"ui-section","a":{"label":"Frequency"},"f":[{"t":4,"f":[{"p":[41,7,1439],"t":7,"e":"span","f":[{"t":2,"r":"readableFrequency","p":[41,13,1445]}]}],"n":50,"r":"data.freqlock","p":[40,5,1410]},{"t":4,"n":51,"f":[{"p":[43,7,1495],"t":7,"e":"ui-button","a":{"icon":"fast-backward","state":[{"t":2,"x":{"r":["data.frequency","data.minFrequency"],"s":"_0==_1?\"disabled\":null"},"p":[43,46,1534]}],"action":"frequency","params":"{\"adjust\": -1}"}}," ",{"p":[44,7,1646],"t":7,"e":"ui-button","a":{"icon":"backward","state":[{"t":2,"x":{"r":["data.frequency","data.minFrequency"],"s":"_0==_1?\"disabled\":null"},"p":[44,41,1680]}],"action":"frequency","params":"{\"adjust\": -.2}"}}," ",{"p":[45,7,1793],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"frequency","params":"{\"tune\": \"input\"}"},"f":[{"t":2,"r":"readableFrequency","p":[45,78,1864]}]}," ",{"p":[46,7,1905],"t":7,"e":"ui-button","a":{"icon":"forward","state":[{"t":2,"x":{"r":["data.frequency","data.maxFrequency"],"s":"_0==_1?\"disabled\":null"},"p":[46,40,1938]}],"action":"frequency","params":"{\"adjust\": .2}"}}," ",{"p":[47,7,2050],"t":7,"e":"ui-button","a":{"icon":"fast-forward","state":[{"t":2,"x":{"r":["data.frequency","data.maxFrequency"],"s":"_0==_1?\"disabled\":null"},"p":[47,45,2088]}],"action":"frequency","params":"{\"adjust\": 1}"}}],"r":"data.freqlock"}]}," ",{"t":4,"f":[{"p":[51,5,2262],"t":7,"e":"ui-section","a":{"label":"Subspace Transmission"},"f":[{"p":[52,7,2312],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.subspace"],"s":"_0?\"power-off\":\"close\""},"p":[52,24,2329]}],"style":[{"t":2,"x":{"r":["data.subspace"],"s":"_0?\"selected\":null"},"p":[52,74,2379]}],"action":"subspace"},"f":[{"t":2,"x":{"r":["data.subspace"],"s":"_0?\"Active\":\"Inactive\""},"p":[53,29,2447]}]}]}],"n":50,"r":"data.subspaceSwitchable","p":[50,3,2225]}," ",{"t":4,"f":[{"p":[57,5,2578],"t":7,"e":"ui-section","a":{"label":"Channels"},"f":[{"t":4,"f":[{"p":[59,9,2656],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["."],"s":"_0?\"check-square-o\":\"square-o\""},"p":[59,26,2673]}],"style":[{"t":2,"x":{"r":["."],"s":"_0?\"selected\":null"},"p":[60,18,2730]}],"action":"channel","params":["{\"channel\": \"",{"t":2,"r":"channel","p":[61,49,2806]},"\"}"]},"f":[{"t":2,"r":"channel","p":[62,11,2833]}]},{"p":[62,34,2856],"t":7,"e":"br"}],"n":52,"i":"channel","r":"data.channels","p":[58,7,2615]}]}],"n":50,"x":{"r":["data.subspace","data.channels"],"s":"_0&&_1"},"p":[56,3,2534]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],253:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[" "," "," ",{"p":[5,1,200],"t":7,"e":"ui-tabs","a":{"tabs":[{"t":2,"r":"data.tabs","p":[5,16,215]}]},"f":[{"p":[6,2,233],"t":7,"e":"tab","a":{"name":"Status"},"f":[{"p":[7,3,256],"t":7,"e":"status"}]}," ",{"p":[9,2,277],"t":7,"e":"tab","a":{"name":"Templates"},"f":[{"p":[10,3,303],"t":7,"e":"templates"}]}," ",{"p":[12,2,327],"t":7,"e":"tab","a":{"name":"Modification"},"f":[{"t":4,"f":[{"p":[14,3,381],"t":7,"e":"modification"}],"n":50,"r":"data.selected","p":[13,3,356]}," ",{"t":4,"f":[{"p":[17,3,437],"t":7,"e":"span","a":{"class":"bad"},"f":["No shuttle selected."]}],"n":50,"x":{"r":["data.selected"],"s":"!_0"},"p":[16,3,411]}]}]}],"e":{}};
component.exports.components = component.exports.components || {};
var components = {
  "modification": require("./shuttle_manipulator/modification.ract"),
  "templates": require("./shuttle_manipulator/templates.ract"),
  "status": require("./shuttle_manipulator/status.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);
},{"./shuttle_manipulator/modification.ract":254,"./shuttle_manipulator/status.ract":255,"./shuttle_manipulator/templates.ract":256,"ractive":205}],254:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":["Selected: ",{"t":2,"r":"data.selected.name","p":[1,30,29]}]},"f":[{"t":4,"f":[{"p":[3,5,96],"t":7,"e":"ui-section","a":{"label":"Description"},"f":[{"t":2,"r":"data.selected.description","p":[3,37,128]}]}],"n":50,"r":"data.selected.description","p":[2,3,57]}," ",{"t":4,"f":[{"p":[6,5,224],"t":7,"e":"ui-section","a":{"label":"Admin Notes"},"f":[{"t":2,"r":"data.selected.admin_notes","p":[6,37,256]}]}],"n":50,"r":"data.selected.admin_notes","p":[5,3,185]}]}," ",{"t":4,"f":[{"p":[11,3,361],"t":7,"e":"ui-display","a":{"title":["Existing Shuttle: ",{"t":2,"r":"data.existing_shuttle.name","p":[11,40,398]}]},"f":["Status: ",{"t":2,"r":"data.existing_shuttle.status","p":[12,13,444]}," ",{"t":4,"f":["(",{"t":2,"r":"data.existing_shuttle.timeleft","p":[14,8,526]},")"],"n":50,"r":"data.existing_shuttle.timer","p":[13,5,482]}," ",{"p":[16,5,580],"t":7,"e":"ui-button","a":{"action":"jump_to","params":["{\"type\": \"mobile\", \"id\": \"",{"t":2,"r":"data.existing_shuttle.id","p":[17,41,649]},"\"}"]},"f":["Jump To"]}]}],"n":50,"r":"data.existing_shuttle","p":[10,1,328]},{"t":4,"f":[{"p":[24,3,778],"t":7,"e":"ui-display","a":{"title":"Existing Shuttle: None"}}],"n":50,"x":{"r":["data.existing_shuttle"],"s":"!_0"},"p":[23,1,744]},{"p":[27,1,847],"t":7,"e":"ui-button","a":{"action":"preview","params":["{\"shuttle_id\": \"",{"t":2,"r":"data.selected.shuttle_id","p":[28,27,902]},"\"}"]},"f":["Preview"]}," ",{"p":[31,1,961],"t":7,"e":"ui-button","a":{"action":"load","params":["{\"shuttle_id\": \"",{"t":2,"r":"data.selected.shuttle_id","p":[32,27,1013]},"\"}"],"style":"danger"},"f":["Load"]}," ",{"p":[37,1,1089],"t":7,"e":"ui-display","a":{"title":"Status"},"f":[]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],255:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"p":[2,3,27],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"name","p":[2,22,46]}," (",{"t":2,"r":"id","p":[2,32,56]},")"]},"f":[{"t":2,"r":"status","p":[3,5,71]}," ",{"t":4,"f":["(",{"t":2,"r":"timeleft","p":[5,8,109]},")"],"n":50,"r":"timer","p":[4,5,87]}," ",{"p":[7,5,141],"t":7,"e":"ui-button","a":{"action":"jump_to","params":["{\"type\": \"mobile\", \"id\": \"",{"t":2,"r":"id","p":[7,67,203]},"\"}"]},"f":["Jump To"]}," ",{"p":[10,5,252],"t":7,"e":"ui-button","a":{"action":"fast_travel","params":["{\"id\": \"",{"t":2,"r":"id","p":[10,53,300]},"\"}"],"state":[{"t":2,"x":{"r":["can_fast_travel"],"s":"_0?null:\"disabled\""},"p":[10,70,317]}]},"f":["Fast Travel"]}]}],"n":52,"r":"data.shuttles","p":[1,1,0]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],256:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-tabs","a":{"tabs":[{"t":2,"r":"data.templates_tabs","p":[1,16,15]}]},"f":[{"t":4,"f":[{"p":[3,5,74],"t":7,"e":"tab","a":{"name":[{"t":2,"r":"port_id","p":[3,16,85]}]},"f":[{"t":4,"f":[{"p":[5,9,135],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"name","p":[5,28,154]}]},"f":[{"t":4,"f":[{"p":[7,13,209],"t":7,"e":"ui-section","a":{"label":"Description"},"f":[{"t":2,"r":"description","p":[7,45,241]}]}],"n":50,"r":"description","p":[6,11,176]}," ",{"t":4,"f":[{"p":[10,13,333],"t":7,"e":"ui-section","a":{"label":"Admin Notes"},"f":[{"t":2,"r":"admin_notes","p":[10,45,365]}]}],"n":50,"r":"admin_notes","p":[9,11,300]}," ",{"p":[13,11,426],"t":7,"e":"ui-button","a":{"action":"select_template","params":["{\"shuttle_id\": \"",{"t":2,"r":"shuttle_id","p":[14,37,499]},"\"}"],"state":[{"t":2,"x":{"r":["data.selected.shuttle_id","shuttle_id"],"s":"_0==_1?\"selected\":null"},"p":[15,20,537]}]},"f":[{"t":2,"x":{"r":["data.selected.shuttle_id","shuttle_id"],"s":"_0==_1?\"Selected\":\"Select\""},"p":[17,13,630]}]}]}],"n":52,"r":"templates","p":[4,7,106]}]}],"n":52,"r":"data.templates","p":[2,3,44]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],257:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    occupantStatState: function occupantStatState() {
      switch (this.get('data.occupant.stat')) {
        case 0:
          return 'good';
        case 1:
          return 'average';
        default:
          return 'bad';
      }
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[15,1,280],"t":7,"e":"ui-display","a":{"title":"Occupant"},"f":[{"p":[16,3,313],"t":7,"e":"ui-section","a":{"label":"Occupant"},"f":[{"p":[17,3,346],"t":7,"e":"span","f":[{"t":2,"x":{"r":["data.occupant.name"],"s":"_0?_0:\"No Occupant\""},"p":[17,9,352]}]}]}," ",{"t":4,"f":[{"p":[20,5,466],"t":7,"e":"ui-section","a":{"label":"State"},"f":[{"p":[21,7,500],"t":7,"e":"span","a":{"class":[{"t":2,"r":"occupantStatState","p":[21,20,513]}]},"f":[{"t":2,"x":{"r":["data.occupant.stat"],"s":"_0==0?\"Conscious\":_0==1?\"Unconcious\":\"Dead\""},"p":[21,43,536]}]}]}," ",{"p":[23,5,658],"t":7,"e":"ui-section","a":{"label":"Health"},"f":[{"p":[24,7,693],"t":7,"e":"ui-bar","a":{"min":[{"t":2,"r":"data.occupant.minHealth","p":[24,20,706]}],"max":[{"t":2,"r":"data.occupant.maxHealth","p":[24,54,740]}],"value":[{"t":2,"r":"data.occupant.health","p":[24,90,776]}],"state":[{"t":2,"x":{"r":["data.occupant.health"],"s":"_0>=0?\"good\":\"average\""},"p":[25,16,818]}]},"f":[{"t":2,"x":{"r":["adata.occupant.health"],"s":"Math.round(_0)"},"p":[25,68,870]}]}]}," ",{"t":4,"f":[{"p":[28,7,1107],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"label","p":[28,26,1126]}]},"f":[{"p":[29,9,1147],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"data.occupant.maxHealth","p":[29,30,1168]}],"value":[{"t":2,"rx":{"r":"data.occupant","m":[{"t":30,"n":"type"}]},"p":[29,66,1204]}],"state":"bad"},"f":[{"t":2,"x":{"r":["type","adata.occupant"],"s":"Math.round(_1[_0])"},"p":[29,103,1241]}]}]}],"n":52,"x":{"r":[],"s":"[{label:\"Brute\",type:\"bruteLoss\"},{label:\"Respiratory\",type:\"oxyLoss\"},{label:\"Toxin\",type:\"toxLoss\"},{label:\"Burn\",type:\"fireLoss\"}]"},"p":[27,5,941]}," ",{"p":[32,5,1328],"t":7,"e":"ui-section","a":{"label":"Cells"},"f":[{"p":[33,9,1364],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.occupant.cloneLoss"],"s":"_0?\"bad\":\"good\""},"p":[33,22,1377]}]},"f":[{"t":2,"x":{"r":["data.occupant.cloneLoss"],"s":"_0?\"Damaged\":\"Healthy\""},"p":[33,68,1423]}]}]}," ",{"p":[35,5,1506],"t":7,"e":"ui-section","a":{"label":"Brain"},"f":[{"p":[36,9,1542],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.occupant.brainLoss"],"s":"_0?\"bad\":\"good\""},"p":[36,22,1555]}]},"f":[{"t":2,"x":{"r":["data.occupant.brainLoss"],"s":"_0?\"Abnormal\":\"Healthy\""},"p":[36,68,1601]}]}]}," ",{"p":[38,5,1685],"t":7,"e":"ui-section","a":{"label":"Bloodstream"},"f":[{"t":4,"f":[{"p":[40,11,1772],"t":7,"e":"span","a":{"class":"highlight"},"t0":"fade","f":[{"t":2,"x":{"r":["volume"],"s":"Math.fixed(_0,1)"},"p":[40,54,1815]}," units of ",{"t":2,"r":"name","p":[40,89,1850]}]},{"p":[40,104,1865],"t":7,"e":"br"}],"n":52,"r":"adata.occupant.reagents","p":[39,9,1727]},{"t":4,"n":51,"f":[{"p":[42,11,1900],"t":7,"e":"span","a":{"class":"good"},"f":["Pure"]}],"r":"adata.occupant.reagents"}]}],"n":50,"r":"data.occupied","p":[19,3,439]}]}," ",{"p":[47,1,1996],"t":7,"e":"ui-display","a":{"title":"Controls"},"f":[{"p":[48,2,2028],"t":7,"e":"ui-section","a":{"label":"Door"},"f":[{"p":[49,5,2059],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.open"],"s":"_0?\"unlock\":\"lock\""},"p":[49,22,2076]}],"action":"door"},"f":[{"t":2,"x":{"r":["data.open"],"s":"_0?\"Open\":\"Closed\""},"p":[49,71,2125]}]}]}," ",{"p":[51,3,2190],"t":7,"e":"ui-section","a":{"label":"Inject"},"f":[{"t":4,"f":[{"p":[53,7,2251],"t":7,"e":"ui-button","a":{"icon":"flask","state":[{"t":2,"x":{"r":["data.occupied","allowed"],"s":"_0&&_1?null:\"disabled\""},"p":[53,38,2282]}],"action":"inject","params":["{\"chem\": \"",{"t":2,"r":"id","p":[53,122,2366]},"\"}"]},"f":[{"t":2,"r":"name","p":[53,132,2376]}]},{"p":[53,152,2396],"t":7,"e":"br"}],"n":52,"r":"data.chems","p":[52,5,2223]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],258:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    capacityPercentState: function capacityPercentState() {
      var charge = this.get('data.capacityPercent');
      if (charge > 50) return 'good';else if (charge > 15) return 'average';else return 'bad';
    },
    inputState: function inputState() {
      if (this.get('data.capacityPercent') >= 100) return 'good';else if (this.get('data.inputting')) return 'average';else return 'bad';
    },
    outputState: function outputState() {
      if (this.get('data.outputting')) return 'good';else if (this.get('data.charge') > 0) return 'average';else return 'bad';
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[24,1,663],"t":7,"e":"ui-display","a":{"title":"Storage"},"f":[{"p":[25,3,695],"t":7,"e":"ui-section","a":{"label":"Stored Energy"},"f":[{"p":[26,5,735],"t":7,"e":"ui-bar","a":{"min":"0","max":"100","value":[{"t":2,"r":"data.capacityPercent","p":[26,38,768]}],"state":[{"t":2,"r":"capacityPercentState","p":[26,71,801]}]},"f":[{"t":2,"x":{"r":["adata.capacityPercent"],"s":"Math.fixed(_0)"},"p":[26,97,827]},"%"]}]}]}," ",{"p":[29,1,908],"t":7,"e":"ui-display","a":{"title":"Input"},"f":[{"p":[30,3,938],"t":7,"e":"ui-section","a":{"label":"Charge Mode"},"f":[{"p":[31,5,976],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.inputAttempt"],"s":"_0?\"refresh\":\"close\""},"p":[31,22,993]}],"style":[{"t":2,"x":{"r":["data.inputAttempt"],"s":"_0?\"selected\":null"},"p":[31,74,1045]}],"action":"tryinput"},"f":[{"t":2,"x":{"r":["data.inputAttempt"],"s":"_0?\"Auto\":\"Off\""},"p":[32,25,1113]}]},"   [",{"p":[34,6,1182],"t":7,"e":"span","a":{"class":[{"t":2,"r":"inputState","p":[34,19,1195]}]},"f":[{"t":2,"x":{"r":["data.capacityPercent","data.inputting"],"s":"_0>=100?\"Fully Charged\":_1?\"Charging\":\"Not Charging\""},"p":[34,35,1211]}]},"]"]}," ",{"p":[36,3,1335],"t":7,"e":"ui-section","a":{"label":"Target Input"},"f":[{"p":[37,5,1374],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"data.inputLevelMax","p":[37,26,1395]}],"value":[{"t":2,"r":"data.inputLevel","p":[37,57,1426]}]},"f":[{"t":2,"x":{"r":["adata.inputLevel"],"s":"Math.round(_0)"},"p":[37,78,1447]},"W"]}]}," ",{"p":[39,3,1509],"t":7,"e":"ui-section","a":{"label":"Adjust Input"},"f":[{"p":[40,5,1548],"t":7,"e":"ui-button","a":{"icon":"fast-backward","state":[{"t":2,"x":{"r":["data.inputLevel"],"s":"_0==0?\"disabled\":null"},"p":[40,44,1587]}],"action":"input","params":"{\"target\": \"min\"}"}}," ",{"p":[41,5,1682],"t":7,"e":"ui-button","a":{"icon":"backward","state":[{"t":2,"x":{"r":["data.inputLevel"],"s":"_0==0?\"disabled\":null"},"p":[41,39,1716]}],"action":"input","params":"{\"adjust\": -10000}"}}," ",{"p":[42,5,1812],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"input","params":"{\"target\": \"input\"}"},"f":["Set"]}," ",{"p":[43,5,1902],"t":7,"e":"ui-button","a":{"icon":"forward","state":[{"t":2,"x":{"r":["data.inputLevel","data.inputLevelMax"],"s":"_0==_1?\"disabled\":null"},"p":[43,38,1935]}],"action":"input","params":"{\"adjust\": 10000}"}}," ",{"p":[44,5,2047],"t":7,"e":"ui-button","a":{"icon":"fast-forward","state":[{"t":2,"x":{"r":["data.inputLevel","data.inputLevelMax"],"s":"_0==_1?\"disabled\":null"},"p":[44,43,2085]}],"action":"input","params":"{\"target\": \"max\"}"}}]}," ",{"p":[46,3,2212],"t":7,"e":"ui-section","a":{"label":"Available"},"f":[{"p":[47,3,2246],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.inputAvailable"],"s":"Math.round(_0)"},"p":[47,9,2252]},"W"]}]}]}," ",{"p":[50,1,2329],"t":7,"e":"ui-display","a":{"title":"Output"},"f":[{"p":[51,3,2360],"t":7,"e":"ui-section","a":{"label":"Output Mode"},"f":[{"p":[52,5,2398],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.outputAttempt"],"s":"_0?\"power-off\":\"close\""},"p":[52,22,2415]}],"style":[{"t":2,"x":{"r":["data.outputAttempt"],"s":"_0?\"selected\":null"},"p":[52,77,2470]}],"action":"tryoutput"},"f":[{"t":2,"x":{"r":["data.outputAttempt"],"s":"_0?\"On\":\"Off\""},"p":[53,26,2540]}]},"   [",{"p":[55,6,2608],"t":7,"e":"span","a":{"class":[{"t":2,"r":"outputState","p":[55,19,2621]}]},"f":[{"t":2,"x":{"r":["data.outputting","data.charge"],"s":"_0?\"Sending\":_1>0?\"Not Sending\":\"No Charge\""},"p":[55,36,2638]}]},"]"]}," ",{"p":[57,3,2745],"t":7,"e":"ui-section","a":{"label":"Target Output"},"f":[{"p":[58,5,2785],"t":7,"e":"ui-bar","a":{"min":"0","max":[{"t":2,"r":"data.outputLevelMax","p":[58,26,2806]}],"value":[{"t":2,"r":"data.outputLevel","p":[58,58,2838]}]},"f":[{"t":2,"x":{"r":["adata.outputLevel"],"s":"Math.round(_0)"},"p":[58,80,2860]},"W"]}]}," ",{"p":[60,3,2923],"t":7,"e":"ui-section","a":{"label":"Adjust Output"},"f":[{"p":[61,5,2963],"t":7,"e":"ui-button","a":{"icon":"fast-backward","state":[{"t":2,"x":{"r":["data.outputLevel"],"s":"_0==0?\"disabled\":null"},"p":[61,44,3002]}],"action":"output","params":"{\"target\": \"min\"}"}}," ",{"p":[62,5,3099],"t":7,"e":"ui-button","a":{"icon":"backward","state":[{"t":2,"x":{"r":["data.outputLevel"],"s":"_0==0?\"disabled\":null"},"p":[62,39,3133]}],"action":"output","params":"{\"adjust\": -10000}"}}," ",{"p":[63,5,3231],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"output","params":"{\"target\": \"input\"}"},"f":["Set"]}," ",{"p":[64,5,3322],"t":7,"e":"ui-button","a":{"icon":"forward","state":[{"t":2,"x":{"r":["data.outputLevel","data.outputLevelMax"],"s":"_0==_1?\"disabled\":null"},"p":[64,38,3355]}],"action":"output","params":"{\"adjust\": 10000}"}}," ",{"p":[65,5,3470],"t":7,"e":"ui-button","a":{"icon":"fast-forward","state":[{"t":2,"x":{"r":["data.outputLevel","data.outputLevelMax"],"s":"_0==_1?\"disabled\":null"},"p":[65,43,3508]}],"action":"output","params":"{\"target\": \"max\"}"}}]}," ",{"p":[67,3,3638],"t":7,"e":"ui-section","a":{"label":"Outputting"},"f":[{"p":[68,3,3673],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.outputUsed"],"s":"Math.round(_0)"},"p":[68,9,3679]},"W"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],259:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":"Status"},"f":[{"p":[2,3,31],"t":7,"e":"ui-section","a":{"label":"Generated Power"},"f":[{"t":2,"x":{"r":["adata.generated"],"s":"Math.round(_0)"},"p":[3,5,73]},"W"]}," ",{"p":[5,3,126],"t":7,"e":"ui-section","a":{"label":"Orientation"},"f":[{"p":[6,5,164],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.angle"],"s":"Math.round(_0)"},"p":[6,11,170]},"° (",{"t":2,"r":"data.direction","p":[6,45,204]},")"]}]}," ",{"p":[8,3,251],"t":7,"e":"ui-section","a":{"label":"Adjust Angle"},"f":[{"p":[9,5,290],"t":7,"e":"ui-button","a":{"icon":"step-backward","action":"angle","params":"{\"adjust\": -15}"},"f":["15°"]}," ",{"p":[10,5,387],"t":7,"e":"ui-button","a":{"icon":"backward","action":"angle","params":"{\"adjust\": -5}"},"f":["5°"]}," ",{"p":[11,5,477],"t":7,"e":"ui-button","a":{"icon":"forward","action":"angle","params":"{\"adjust\": 5}"},"f":["5°"]}," ",{"p":[12,5,565],"t":7,"e":"ui-button","a":{"icon":"step-forward","action":"angle","params":"{\"adjust\": 15}"},"f":["15°"]}]}]}," ",{"p":[15,1,687],"t":7,"e":"ui-display","a":{"title":"Tracking"},"f":[{"p":[16,3,720],"t":7,"e":"ui-section","a":{"label":"Tracker Mode"},"f":[{"p":[17,5,759],"t":7,"e":"ui-button","a":{"icon":"close","state":[{"t":2,"x":{"r":["data.tracking_state"],"s":"_0==0?\"selected\":null"},"p":[17,36,790]}],"action":"tracking","params":"{\"mode\": 0}"},"f":["Off"]}," ",{"p":[19,5,907],"t":7,"e":"ui-button","a":{"icon":"clock-o","state":[{"t":2,"x":{"r":["data.tracking_state"],"s":"_0==1?\"selected\":null"},"p":[19,38,940]}],"action":"tracking","params":"{\"mode\": 1}"},"f":["Timed"]}," ",{"p":[21,5,1059],"t":7,"e":"ui-button","a":{"icon":"refresh","state":[{"t":2,"x":{"r":["data.connected_tracker","data.tracking_state"],"s":"_0?_1==2?\"selected\":null:\"disabled\""},"p":[21,38,1092]}],"action":"tracking","params":"{\"mode\": 2}"},"f":["Auto"]}]}," ",{"p":[24,3,1262],"t":7,"e":"ui-section","a":{"label":"Tracking Rate"},"f":[{"p":[25,3,1300],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.tracking_rate"],"s":"Math.round(_0)"},"p":[25,9,1306]},"°/h (",{"t":2,"r":"data.rotating_way","p":[25,53,1350]},")"]}]}," ",{"p":[27,3,1399],"t":7,"e":"ui-section","a":{"label":"Adjust Rate"},"f":[{"p":[28,5,1437],"t":7,"e":"ui-button","a":{"icon":"fast-backward","action":"rate","params":"{\"adjust\": -180}"},"f":["180°"]}," ",{"p":[29,5,1535],"t":7,"e":"ui-button","a":{"icon":"step-backward","action":"rate","params":"{\"adjust\": -30}"},"f":["30°"]}," ",{"p":[30,5,1631],"t":7,"e":"ui-button","a":{"icon":"backward","action":"rate","params":"{\"adjust\": -5}"},"f":["5°"]}," ",{"p":[31,5,1720],"t":7,"e":"ui-button","a":{"icon":"forward","action":"rate","params":"{\"adjust\": 5}"},"f":["5°"]}," ",{"p":[32,5,1807],"t":7,"e":"ui-button","a":{"icon":"step-forward","action":"rate","params":"{\"adjust\": 30}"},"f":["30°"]}," ",{"p":[33,5,1901],"t":7,"e":"ui-button","a":{"icon":"fast-forward","action":"rate","params":"{\"adjust\": 180}"},"f":["180°"]}]}]}," ",{"p":{"button":[{"p":[38,5,2088],"t":7,"e":"ui-button","a":{"icon":"refresh","action":"refresh"},"f":["Refresh"]}]},"t":7,"e":"ui-display","a":{"title":"Devices","button":0},"f":[" ",{"p":[40,2,2169],"t":7,"e":"ui-section","a":{"label":"Solar Tracker"},"f":[{"p":[41,5,2209],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.connected_tracker"],"s":"_0?\"good\":\"bad\""},"p":[41,18,2222]}]},"f":[{"t":2,"x":{"r":["data.connected_tracker"],"s":"_0?\"\":\"Not \""},"p":[41,63,2267]},"Found"]}]}," ",{"p":[43,2,2338],"t":7,"e":"ui-section","a":{"label":"Solar Panels"},"f":[{"p":[44,3,2375],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.connected_panels"],"s":"_0?\"good\":\"bad\""},"p":[44,16,2388]}]},"f":[{"t":2,"x":{"r":["adata.connected_panels"],"s":"Math.round(_0)"},"p":[44,60,2432]}," Panels Connected"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],260:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":{"button":[{"t":4,"f":[{"p":[4,7,87],"t":7,"e":"ui-button","a":{"icon":"eject","state":[{"t":2,"x":{"r":["data.hasPowercell"],"s":"_0?null:\"disabled\""},"p":[4,38,118]}],"action":"eject"},"f":["Eject"]}],"n":50,"r":"data.open","p":[3,5,62]}]},"t":7,"e":"ui-display","a":{"title":"Power","button":0},"f":[" ",{"p":[7,3,226],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[8,5,258],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[8,22,275]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":null"},"p":[9,14,326]}],"state":[{"t":2,"x":{"r":["data.hasPowercell"],"s":"_0?null:\"disabled\""},"p":[9,54,366]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[10,22,431]}]}]}," ",{"p":[12,3,490],"t":7,"e":"ui-section","a":{"label":"Cell"},"f":[{"t":4,"f":[{"p":[14,7,554],"t":7,"e":"ui-bar","a":{"min":"0","max":"100","value":[{"t":2,"r":"data.powerLevel","p":[14,40,587]}]},"f":[{"t":2,"x":{"r":["adata.powerLevel"],"s":"Math.fixed(_0)"},"p":[14,61,608]},"%"]}],"n":50,"r":"data.hasPowercell","p":[13,5,521]},{"t":4,"n":51,"f":[{"p":[16,4,667],"t":7,"e":"span","a":{"class":"bad"},"f":["No Cell"]}],"r":"data.hasPowercell"}]}]}," ",{"p":[20,1,744],"t":7,"e":"ui-display","a":{"title":"Thermostat"},"f":[{"p":[21,3,779],"t":7,"e":"ui-section","a":{"label":"Current Temperature"},"f":[{"p":[22,3,823],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.currentTemp"],"s":"Math.round(_0)"},"p":[22,9,829]},"°C"]}]}," ",{"p":[24,2,894],"t":7,"e":"ui-section","a":{"label":"Target Temperature"},"f":[{"p":[25,3,937],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.targetTemp"],"s":"Math.round(_0)"},"p":[25,9,943]},"°C"]}]}," ",{"t":4,"f":[{"p":[28,5,1031],"t":7,"e":"ui-section","a":{"label":"Adjust Target"},"f":[{"p":[29,7,1073],"t":7,"e":"ui-button","a":{"icon":"fast-backward","state":[{"t":2,"x":{"r":["data.targetTemp","data.minTemp"],"s":"_0>_1?null:\"disabled\""},"p":[29,46,1112]}],"action":"target","params":"{\"adjust\": -20}"}}," ",{"p":[30,7,1218],"t":7,"e":"ui-button","a":{"icon":"backward","state":[{"t":2,"x":{"r":["data.targetTemp","data.minTemp"],"s":"_0>_1?null:\"disabled\""},"p":[30,41,1252]}],"action":"target","params":"{\"adjust\": -5}"}}," ",{"p":[31,7,1357],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"target","params":"{\"target\": \"input\"}"},"f":["Set"]}," ",{"p":[32,7,1450],"t":7,"e":"ui-button","a":{"icon":"forward","state":[{"t":2,"x":{"r":["data.targetTemp","data.maxTemp"],"s":"_0<_1?null:\"disabled\""},"p":[32,40,1483]}],"action":"target","params":"{\"adjust\": 5}"}}," ",{"p":[33,7,1587],"t":7,"e":"ui-button","a":{"icon":"fast-forward","state":[{"t":2,"x":{"r":["data.targetTemp","data.maxTemp"],"s":"_0<_1?null:\"disabled\""},"p":[33,45,1625]}],"action":"target","params":"{\"adjust\": 20}"}}]}],"n":50,"r":"data.open","p":[27,3,1008]}," ",{"p":[36,3,1754],"t":7,"e":"ui-section","a":{"label":"Mode"},"f":[{"t":4,"f":[{"p":[38,7,1808],"t":7,"e":"ui-button","a":{"icon":"long-arrow-up","state":[{"t":2,"x":{"r":["data.mode"],"s":"_0==\"heat\"?\"selected\":null"},"p":[38,46,1847]}],"action":"mode","params":"{\"mode\": \"heat\"}"},"f":["Heat"]}," ",{"p":[39,7,1956],"t":7,"e":"ui-button","a":{"icon":"long-arrow-down","state":[{"t":2,"x":{"r":["data.mode"],"s":"_0==\"cool\"?\"selected\":null"},"p":[39,48,1997]}],"action":"mode","params":"{\"mode\": \"cool\"}"},"f":["Cool"]}," ",{"p":[40,7,2106],"t":7,"e":"ui-button","a":{"icon":"arrows-v","state":[{"t":2,"x":{"r":["data.mode"],"s":"_0==\"auto\"?\"selected\":null"},"p":[40,41,2140]}],"action":"mode","params":"{\"mode\": \"auto\"}"},"f":["Auto"]}],"n":50,"r":"data.open","p":[37,3,1783]},{"t":4,"n":51,"f":[{"p":[42,4,2258],"t":7,"e":"span","f":[{"t":2,"x":{"r":["text","data.mode"],"s":"_0.titleCase(_1)"},"p":[42,10,2264]}]}],"r":"data.open"}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],261:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"p":[2,3,31],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"class","p":[2,22,50]}," Alarms"]},"f":[{"p":[3,5,74],"t":7,"e":"ul","f":[{"t":4,"f":[{"p":[5,9,107],"t":7,"e":"li","f":[{"t":2,"r":".","p":[5,13,111]}]}],"n":52,"r":".","p":[4,7,86]},{"t":4,"n":51,"f":[{"p":[7,9,147],"t":7,"e":"li","f":["System Nominal"]}],"r":"."}]}]}],"n":52,"i":"class","r":"data.alarms","p":[1,1,0]}]};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],262:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"t":4,"f":[{"p":[2,3,42],"t":7,"e":"ui-notice","f":[{"p":[3,5,59],"t":7,"e":"span","f":["Biological entity detected in contents. Please remove."]}]}],"n":50,"x":{"r":["data.occupied","data.safeties"],"s":"_0&&_1"},"p":[1,1,0]},{"t":4,"f":[{"p":[7,3,179],"t":7,"e":"ui-notice","f":[{"p":[8,5,196],"t":7,"e":"span","f":["Contents are being disinfected. Please wait."]}]}],"n":50,"r":"data.uv_active","p":[6,1,153]},{"t":4,"n":51,"f":[{"p":{"button":[{"t":4,"f":[{"p":[13,25,369],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"unlock\":\"lock\""},"p":[13,42,386]}],"action":"lock"},"f":[{"t":2,"x":{"r":["data.locked"],"s":"_0?\"Unlock\":\"Lock\""},"p":[13,93,437]}]}],"n":50,"x":{"r":["data.open"],"s":"!_0"},"p":[13,7,351]}," ",{"t":4,"f":[{"p":[14,27,519],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.open"],"s":"_0?\"sign-out\":\"sign-in\""},"p":[14,44,536]}],"action":"door"},"f":[{"t":2,"x":{"r":["data.open"],"s":"_0?\"Close\":\"Open\""},"p":[14,98,590]}]}],"n":50,"x":{"r":["data.locked"],"s":"!_0"},"p":[14,7,499]}]},"t":7,"e":"ui-display","a":{"title":"Storage","button":0},"f":[" ",{"t":4,"f":[{"p":[17,7,692],"t":7,"e":"ui-notice","f":[{"p":[18,9,713],"t":7,"e":"span","f":["Unit Locked"]}]}],"n":50,"r":"data.locked","p":[16,5,665]},{"t":4,"n":51,"f":[{"t":4,"n":50,"x":{"r":["data.open"],"s":"_0"},"f":[{"p":[21,9,793],"t":7,"e":"ui-section","a":{"label":"Helmet"},"f":[{"p":[22,11,832],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.helmet"],"s":"_0?\"square\":\"square-o\""},"p":[22,28,849]}],"state":[{"t":2,"x":{"r":["data.helmet"],"s":"_0?null:\"disabled\""},"p":[22,75,896]}],"action":"dispense","params":"{\"item\": \"helmet\"}"},"f":[{"t":2,"x":{"r":["data.helmet"],"s":"_0||\"Empty\""},"p":[23,59,992]}]}]}," ",{"p":[25,9,1063],"t":7,"e":"ui-section","a":{"label":"Suit"},"f":[{"p":[26,11,1100],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.suit"],"s":"_0?\"square\":\"square-o\""},"p":[26,28,1117]}],"state":[{"t":2,"x":{"r":["data.suit"],"s":"_0?null:\"disabled\""},"p":[26,74,1163]}],"action":"dispense","params":"{\"item\": \"suit\"}"},"f":[{"t":2,"x":{"r":["data.suit"],"s":"_0||\"Empty\""},"p":[27,57,1255]}]}]}," ",{"p":[29,9,1324],"t":7,"e":"ui-section","a":{"label":"Mask"},"f":[{"p":[30,11,1361],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.mask"],"s":"_0?\"square\":\"square-o\""},"p":[30,28,1378]}],"state":[{"t":2,"x":{"r":["data.mask"],"s":"_0?null:\"disabled\""},"p":[30,74,1424]}],"action":"dispense","params":"{\"item\": \"mask\"}"},"f":[{"t":2,"x":{"r":["data.mask"],"s":"_0||\"Empty\""},"p":[31,57,1516]}]}]}," ",{"p":[33,9,1585],"t":7,"e":"ui-section","a":{"label":"Storage"},"f":[{"p":[34,11,1625],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.storage"],"s":"_0?\"square\":\"square-o\""},"p":[34,28,1642]}],"state":[{"t":2,"x":{"r":["data.storage"],"s":"_0?null:\"disabled\""},"p":[34,77,1691]}],"action":"dispense","params":"{\"item\": \"storage\"}"},"f":[{"t":2,"x":{"r":["data.storage"],"s":"_0||\"Empty\""},"p":[35,60,1789]}]}]}]},{"t":4,"n":50,"x":{"r":["data.open"],"s":"!(_0)"},"f":[" ",{"p":[38,7,1873],"t":7,"e":"ui-button","a":{"icon":"recycle","state":[{"t":2,"x":{"r":["data.occupied","data.safeties"],"s":"_0&&_1?\"disabled\":null"},"p":[38,40,1906]}],"action":"uv"},"f":["Disinfect"]}]}],"r":"data.locked"}]}],"r":"data.uv_active"}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],263:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","f":[{"p":[2,5,18],"t":7,"e":"ui-section","a":{"label":"Dispense"},"f":[{"p":[3,9,57],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.plasma"],"s":"_0?\"square\":\"square-o\""},"p":[3,26,74]}],"state":[{"t":2,"x":{"r":["data.plasma"],"s":"_0?null:\"disabled\""},"p":[3,74,122]}],"action":"plasma"},"f":["Plasma (",{"t":2,"x":{"r":["adata.plasma"],"s":"Math.round(_0)"},"p":[4,37,196]},")"]}," ",{"p":[5,9,247],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.oxygen"],"s":"_0?\"square\":\"square-o\""},"p":[5,26,264]}],"state":[{"t":2,"x":{"r":["data.oxygen"],"s":"_0?null:\"disabled\""},"p":[5,74,312]}],"action":"oxygen"},"f":["Oxygen (",{"t":2,"x":{"r":["adata.oxygen"],"s":"Math.round(_0)"},"p":[6,37,386]},")"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],264:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

component.exports = {
  computed: {
    tankPressureState: function tankPressureState() {
      var pressure = this.get('data.tankPressure');
      if (pressure >= 200) return 'good';else if (pressure >= 100) return 'average';else return 'bad';
    }
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":[14,1,295],"t":7,"e":"ui-notice","f":[{"p":[15,3,310],"t":7,"e":"span","f":["The regulator ",{"t":2,"x":{"r":["data.connected"],"s":"_0?\"is\":\"is not\""},"p":[15,23,330]}," connected to a mask."]}]}," ",{"p":[17,1,409],"t":7,"e":"ui-display","f":[{"p":[18,3,425],"t":7,"e":"ui-section","a":{"label":"Tank Pressure"},"f":[{"p":[19,7,467],"t":7,"e":"ui-bar","a":{"min":"0","max":"1013","value":[{"t":2,"r":"data.tankPressure","p":[19,41,501]}],"state":[{"t":2,"r":"tankPressureState","p":[20,16,540]}]},"f":[{"t":2,"x":{"r":["adata.tankPressure"],"s":"Math.round(_0)"},"p":[20,39,563]}," kPa"]}]}," ",{"p":[22,3,631],"t":7,"e":"ui-section","a":{"label":"Release Pressure"},"f":[{"p":[23,5,674],"t":7,"e":"ui-bar","a":{"min":[{"t":2,"r":"data.minReleasePressure","p":[23,18,687]}],"max":[{"t":2,"r":"data.maxReleasePressure","p":[23,52,721]}],"value":[{"t":2,"r":"data.releasePressure","p":[24,14,764]}]},"f":[{"t":2,"x":{"r":["adata.releasePressure"],"s":"Math.round(_0)"},"p":[24,40,790]}," kPa"]}]}," ",{"p":[26,3,861],"t":7,"e":"ui-section","a":{"label":"Pressure Regulator"},"f":[{"p":[27,5,906],"t":7,"e":"ui-button","a":{"icon":"refresh","state":[{"t":2,"x":{"r":["data.releasePressure","data.defaultReleasePressure"],"s":"_0!=_1?null:\"disabled\""},"p":[27,38,939]}],"action":"pressure","params":"{\"pressure\": \"reset\"}"},"f":["Reset"]}," ",{"p":[29,5,1095],"t":7,"e":"ui-button","a":{"icon":"minus","state":[{"t":2,"x":{"r":["data.releasePressure","data.minReleasePressure"],"s":"_0>_1?null:\"disabled\""},"p":[29,36,1126]}],"action":"pressure","params":"{\"pressure\": \"min\"}"},"f":["Min"]}," ",{"p":[31,5,1273],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"pressure","params":"{\"pressure\": \"input\"}"},"f":["Set"]}," ",{"p":[32,5,1368],"t":7,"e":"ui-button","a":{"icon":"plus","state":[{"t":2,"x":{"r":["data.releasePressure","data.maxReleasePressure"],"s":"_0<_1?null:\"disabled\""},"p":[32,35,1398]}],"action":"pressure","params":"{\"pressure\": \"max\"}"},"f":["Max"]}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205}],265:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","a":{"title":"Status"},"f":[{"p":[2,5,33],"t":7,"e":"ui-section","a":{"label":"Temperature"},"f":[{"p":[3,9,75],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.temperature"],"s":"Math.fixed(_0,2)"},"p":[3,15,81]}," K"]}]}," ",{"p":[5,5,151],"t":7,"e":"ui-section","a":{"label":"Pressure"},"f":[{"p":[6,9,190],"t":7,"e":"span","f":[{"t":2,"x":{"r":["adata.pressure"],"s":"Math.fixed(_0,2)"},"p":[6,15,196]}," kPa"]}]}]}," ",{"p":[9,1,276],"t":7,"e":"ui-display","a":{"title":"Controls"},"f":[{"p":[10,5,311],"t":7,"e":"ui-section","a":{"label":"Power"},"f":[{"p":[11,9,347],"t":7,"e":"ui-button","a":{"icon":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"power-off\":\"close\""},"p":[11,26,364]}],"style":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"selected\":null"},"p":[11,70,408]}],"action":"power"},"f":[{"t":2,"x":{"r":["data.on"],"s":"_0?\"On\":\"Off\""},"p":[12,28,469]}]}]}," ",{"p":[14,5,531],"t":7,"e":"ui-section","a":{"label":"Target Temperature"},"f":[{"p":[15,9,580],"t":7,"e":"ui-button","a":{"icon":"fast-backward","style":[{"t":2,"x":{"r":["data.target","data.min"],"s":"_0==_1?\"disabled\":null"},"p":[15,48,619]}],"action":"target","params":"{\"adjust\": -20}"}}," ",{"p":[17,9,733],"t":7,"e":"ui-button","a":{"icon":"backward","style":[{"t":2,"x":{"r":["data.target","data.min"],"s":"_0==_1?\"disabled\":null"},"p":[17,43,767]}],"action":"target","params":"{\"adjust\": -5}"}}," ",{"p":[19,9,880],"t":7,"e":"ui-button","a":{"icon":"pencil","action":"target","params":"{\"target\": \"input\"}"},"f":[{"t":2,"x":{"r":["adata.target"],"s":"Math.fixed(_0,2)"},"p":[19,79,950]}]}," ",{"p":[20,9,1003],"t":7,"e":"ui-button","a":{"icon":"forward","style":[{"t":2,"x":{"r":["data.target","data.max"],"s":"_0==_1?\"disabled\":null"},"p":[20,42,1036]}],"action":"target","params":"{\"adjust\": 5}"}}," ",{"p":[22,9,1148],"t":7,"e":"ui-button","a":{"icon":"fast-forward","style":[{"t":2,"x":{"r":["data.target","data.max"],"s":"_0==_1?\"disabled\":null"},"p":[22,47,1186]}],"action":"target","params":"{\"adjust\": 20}"}}]}]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],266:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var _filter = require('util/filter');

component.exports = {
  data: {
    filter: ''
  },
  oninit: function oninit() {
    var _this = this;

    this.on({
      hover: function hover(event) {
        var uses = this.get('data.telecrystals');
        if (uses >= event.context.params.cost) this.set('hovered', event.context.params);
      },
      unhover: function unhover(event) {
        this.set('hovered');
      }
    });
    this.observe('filter', function (newkey, oldkey, keypath) {
      var categories = _this.findAll('.display:not(:first-child)');
      (0, _filter.filterMulti)(categories, _this.get('filter').toLowerCase());
    }, { init: false });
  }
};
})(component);
component.exports.template = {"v":3,"t":[" ",{"p":{"button":[{"t":4,"f":[{"p":[29,7,770],"t":7,"e":"ui-input","a":{"value":[{"t":2,"r":"filter","p":[29,24,787]}],"placeholder":"Filter..."}}],"n":50,"r":"config.fancy","p":[28,5,742]}," ",{"t":4,"f":[{"p":[32,7,872],"t":7,"e":"ui-button","a":{"icon":"lock","action":"lock"},"f":["Lock"]}],"n":50,"r":"data.lockable","p":[31,5,843]}]},"t":7,"e":"ui-display","a":{"title":"Uplink","button":0},"f":[" ",{"p":[35,3,958],"t":7,"e":"ui-section","a":{"label":"Telecrystals","right":0},"f":[{"p":[36,5,1003],"t":7,"e":"span","a":{"class":[{"t":2,"x":{"r":["data.telecrystals"],"s":"_0>0?\"good\":\"bad\""},"p":[36,18,1016]}]},"f":[{"t":2,"r":"data.telecrystals","p":[36,62,1060]}," TC"]}]}]}," ",{"t":4,"f":[{"p":[40,3,1154],"t":7,"e":"ui-display","a":{"title":[{"t":2,"r":"name","p":[40,22,1173]}]},"f":[{"t":4,"f":[{"p":[42,7,1212],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"name","p":[42,26,1231]}],"candystripe":0,"right":0},"f":[{"p":[43,9,1269],"t":7,"e":"ui-button","a":{"tooltip":[{"t":2,"r":"name","p":[43,29,1289]},": ",{"t":2,"r":"desc","p":[43,39,1299]}],"tooltip-side":"left","state":[{"t":2,"x":{"r":["data.telecrystals","hovered.cost","cost","hovered.item","name"],"s":"_0<_2||(_0-_1<_2&&_3!=_4)?\"disabled\":null"},"p":[44,18,1347]}],"action":"buy","params":["{\"category\": \"",{"t":2,"r":"category","p":[45,46,1512]},"\", \"item\": ",{"t":2,"r":"name","p":[45,69,1535]},", \"cost\": ",{"t":2,"r":"cost","p":[45,87,1553]},"}"]},"v":{"hover":"hover","unhover":"unhover"},"f":[{"t":2,"r":"cost","p":[46,49,1613]}," TC"]}]}],"n":52,"r":"items","p":[41,5,1189]}]}],"n":52,"r":"data.categories","p":[39,1,1125]}],"e":{}};
module.exports = Ractive.extend(component.exports);

},{"ractive":205,"util/filter":273}],267:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
component.exports.template = {"v":3,"t":[{"p":[1,1,0],"t":7,"e":"ui-display","f":[{"t":4,"f":[{"p":[3,5,42],"t":7,"e":"ui-section","a":{"label":[{"t":2,"r":"color","p":[3,24,61]},{"t":2,"x":{"r":["wire"],"s":"_0?\" (\"+_0+\")\":\"\""},"p":[3,33,70]}],"labelcolor":[{"t":2,"r":"color","p":[3,80,117]}],"candystripe":0,"right":0},"f":[{"p":[4,7,154],"t":7,"e":"ui-button","a":{"action":"cut","params":["{\"wire\":\"",{"t":2,"r":"color","p":[4,48,195]},"\"}"]},"f":[{"t":2,"x":{"r":["cut"],"s":"_0?\"Mend\":\"Cut\""},"p":[4,61,208]}]}," ",{"p":[5,7,252],"t":7,"e":"ui-button","a":{"action":"pulse","params":["{\"wire\":\"",{"t":2,"r":"color","p":[5,50,295]},"\"}"]},"f":["Pulse"]}," ",{"p":[6,7,333],"t":7,"e":"ui-button","a":{"action":"attach","params":["{\"wire\":\"",{"t":2,"r":"color","p":[6,51,377]},"\"}"]},"f":[{"t":2,"x":{"r":["attached"],"s":"_0?\"Detach\":\"Attach\""},"p":[6,64,390]}]}]}],"n":52,"r":"data.wires","p":[2,3,16]}]}," ",{"t":4,"f":[{"p":[11,3,508],"t":7,"e":"ui-display","f":[{"t":4,"f":[{"p":[13,7,555],"t":7,"e":"ui-section","f":[{"t":2,"r":".","p":[13,19,567]}]}],"n":52,"r":"data.status","p":[12,5,526]}]}],"n":50,"r":"data.status","p":[10,1,485]}],"e":{}};
module.exports = Ractive.extend(component.exports);
},{"ractive":205}],268:[function(require,module,exports){
(function (babelHelpers){
'use strict';

var _ractive = require('ractive');

var _ractive2 = babelHelpers.interopRequireDefault(_ractive);

require('ie8');

require('babel-polyfill');

require('dom4');

require('html5shiv');

var _tgui = require('tgui.ract');

var _tgui2 = babelHelpers.interopRequireDefault(_tgui);

var _byond = require('util/byond');

var _fgLoadcss = require('fg-loadcss');

var _fontfaceobserver = require('fontfaceobserver');

var _fontfaceobserver2 = babelHelpers.interopRequireDefault(_fontfaceobserver);

_ractive2["default"].DEBUG = /minified/.test(function () {/* minified */}); // Temporarily import Ractive first to keep it from detecting ie8's object.defineProperty shim, which it misuses (ractivejs/ractive#2343).


// Extend the Math builtin with our own utilities.
Object.assign(Math, require('util/math'));

// Set up the initialize function. This is either called below if JSON is provided
// inline, or called by the server if it was not.

window.initialize = function (dataString) {
  if (window.tgui) return; // Don't run twice.
  window.tgui = new _tgui2["default"]({
    el: '#container',
    data: function data() {
      var initial = JSON.parse(dataString);
      return {
        constants: require('util/constants'),
        text: require('util/text'),
        config: initial.config,
        data: initial.data,
        adata: initial.data
      };
    }
  });
};

// Try to find data in the page. If the JSON was inlined, load it.
var holder = document.getElementById('data');
var data = holder.textContent;
var ref = holder.getAttribute('data-ref');
if (data !== '{}') {
  window.initialize(data);
  holder.remove();
}
// Let the server know we're set up. This also sends data if it was not inlined.

(0, _byond.act)(ref, 'tgui:initialize');

// Load fonts.

(0, _fgLoadcss.loadCSS)('https://cdn.jsdelivr.net/fontawesome/4.5.0/css/font-awesome.min.css');
// Handle font loads.

var fontawesome = new _fontfaceobserver2["default"]('FontAwesome');
fontawesome.check('').then(function () {
  return document.body.classList.add('icons');
})["catch"](function () {
  return document.body.classList.add('no-icons');
});

}).call(this,require("babel/external-helpers"))
},{"babel-polyfill":1,"babel/external-helpers":"babel/external-helpers","dom4":190,"fg-loadcss":191,"fontfaceobserver":192,"html5shiv":193,"ie8":194,"ractive":205,"tgui.ract":269,"util/byond":270,"util/constants":271,"util/math":274,"util/text":275}],269:[function(require,module,exports){
var Ractive = require('ractive');
var component = { exports: {} };
(function (component) {
'use strict';

var _byond = require('util/byond');

var _dragresize = require('util/dragresize');

component.exports = {
  components: {
    'ui-bar': require('components/bar'),
    'ui-button': require('components/button'),
    'ui-display': require('components/display'),
    'ui-input': require('components/input'),
    'ui-linegraph': require('components/linegraph'),
    'ui-notice': require('components/notice'),
    'ui-section': require('components/section'),
    'ui-subdisplay': require('components/subdisplay'),
    'ui-tabs': require('components/tabs')
  },
  events: {
    enter: require('ractive-events-keys').enter,
    space: require('ractive-events-keys').space
  },
  transitions: {
    fade: require('ractive-transitions-fade')
  },
  onconfig: function onconfig() {
    var requested = this.get('config.interface');
    var interfaces = {'airalarm': require('interfaces/airalarm.ract'),'airalarm/back': require('interfaces/airalarm/back.ract'),'airalarm/modes': require('interfaces/airalarm/modes.ract'),'airalarm/scrubbers': require('interfaces/airalarm/scrubbers.ract'),'airalarm/status': require('interfaces/airalarm/status.ract'),'airalarm/thresholds': require('interfaces/airalarm/thresholds.ract'),'airalarm/vents': require('interfaces/airalarm/vents.ract'),'airlock_electronics': require('interfaces/airlock_electronics.ract'),'apc': require('interfaces/apc.ract'),'atmos_alert': require('interfaces/atmos_alert.ract'),'atmos_control': require('interfaces/atmos_control.ract'),'atmos_filter': require('interfaces/atmos_filter.ract'),'atmos_mixer': require('interfaces/atmos_mixer.ract'),'atmos_pump': require('interfaces/atmos_pump.ract'),'brig_timer': require('interfaces/brig_timer.ract'),'canister': require('interfaces/canister.ract'),'cargo': require('interfaces/cargo.ract'),'chem_dispenser': require('interfaces/chem_dispenser.ract'),'chem_heater': require('interfaces/chem_heater.ract'),'chem_master': require('interfaces/chem_master.ract'),'crayon': require('interfaces/crayon.ract'),'cryo': require('interfaces/cryo.ract'),'emergency_shuttle_console': require('interfaces/emergency_shuttle_console.ract'),'error': require('interfaces/error.ract'),'firealarm': require('interfaces/firealarm.ract'),'intellicard': require('interfaces/intellicard.ract'),'keycard_auth': require('interfaces/keycard_auth.ract'),'mech_bay_power_console': require('interfaces/mech_bay_power_console.ract'),'mulebot': require('interfaces/mulebot.ract'),'personal_crafting': require('interfaces/personal_crafting.ract'),'portable_pump': require('interfaces/portable_pump.ract'),'portable_scrubber': require('interfaces/portable_scrubber.ract'),'power_monitor': require('interfaces/power_monitor.ract'),'radio': require('interfaces/radio.ract'),'shuttle_manipulator': require('interfaces/shuttle_manipulator.ract'),'shuttle_manipulator/modification': require('interfaces/shuttle_manipulator/modification.ract'),'shuttle_manipulator/status': require('interfaces/shuttle_manipulator/status.ract'),'shuttle_manipulator/templates': require('interfaces/shuttle_manipulator/templates.ract'),'sleeper': require('interfaces/sleeper.ract'),'smes': require('interfaces/smes.ract'),'solar_control': require('interfaces/solar_control.ract'),'space_heater': require('interfaces/space_heater.ract'),'station_alert': require('interfaces/station_alert.ract'),'suit_storage_unit': require('interfaces/suit_storage_unit.ract'),'tank_dispenser': require('interfaces/tank_dispenser.ract'),'tanks': require('interfaces/tanks.ract'),'thermomachine': require('interfaces/thermomachine.ract'),'uplink': require('interfaces/uplink.ract'),'wires': require('interfaces/wires.ract')};
    if (requested in interfaces) {
      this.components["interface"] = interfaces[requested]; // Use the interface specified in the config...
    } else {
        this.components["interface"] = interfaces.error; // ...unless it does not exist.
      }
  },
  oninit: function oninit() {
    this.observe('config.style', function (newkey, oldkey, keypath) {
      if (newkey) document.body.classList.add(newkey);
      if (oldkey) document.body.classList.remove(oldkey);
    });
  },
  oncomplete: function oncomplete() {
    // If the window starts off screen, pull it back.
    if (this.get('config.locked')) {
      var _lock = (0, _dragresize.lock)(window.screenLeft, window.screenTop);

      var x = _lock.x;
      var y = _lock.y;

      (0, _byond.winset)(this.get('config.window'), 'pos', x + ',' + y);
    }

    // Give focus back to the map.
    (0, _byond.winset)('mapwindow.map', 'focus', true);
  }
};
})(component);
component.exports.template = {"v":3,"t":[" "," "," "," ",{"p":[56,1,1874],"t":7,"e":"titlebar","f":[{"t":3,"r":"config.title","p":[56,11,1884]}]}," ",{"p":[57,1,1915],"t":7,"e":"main","f":[{"p":[58,3,1925],"t":7,"e":"warnings"}," ",{"p":[59,3,1940],"t":7,"e":"interface"}]}," ",{"p":[61,1,1963],"t":7,"e":"resize"}]};
component.exports.components = component.exports.components || {};
var components = {
  "warnings": require("components/warnings.ract"),
  "titlebar": require("components/titlebar.ract"),
  "resize": require("components/resize.ract")
};
for (var k in components) {
  if (components.hasOwnProperty(k))
    component.exports.components[k] = components[k];
}
module.exports = Ractive.extend(component.exports);

},{"components/bar":206,"components/button":207,"components/display":208,"components/input":209,"components/linegraph":210,"components/notice":211,"components/resize.ract":212,"components/section":213,"components/subdisplay":214,"components/tabs":215,"components/titlebar.ract":217,"components/warnings.ract":218,"interfaces/airalarm.ract":219,"interfaces/airalarm/back.ract":220,"interfaces/airalarm/modes.ract":221,"interfaces/airalarm/scrubbers.ract":222,"interfaces/airalarm/status.ract":223,"interfaces/airalarm/thresholds.ract":224,"interfaces/airalarm/vents.ract":225,"interfaces/airlock_electronics.ract":226,"interfaces/apc.ract":227,"interfaces/atmos_alert.ract":228,"interfaces/atmos_control.ract":229,"interfaces/atmos_filter.ract":230,"interfaces/atmos_mixer.ract":231,"interfaces/atmos_pump.ract":232,"interfaces/brig_timer.ract":233,"interfaces/canister.ract":234,"interfaces/cargo.ract":235,"interfaces/chem_dispenser.ract":236,"interfaces/chem_heater.ract":237,"interfaces/chem_master.ract":238,"interfaces/crayon.ract":239,"interfaces/cryo.ract":240,"interfaces/emergency_shuttle_console.ract":241,"interfaces/error.ract":242,"interfaces/firealarm.ract":243,"interfaces/intellicard.ract":244,"interfaces/keycard_auth.ract":245,"interfaces/mech_bay_power_console.ract":246,"interfaces/mulebot.ract":247,"interfaces/personal_crafting.ract":248,"interfaces/portable_pump.ract":249,"interfaces/portable_scrubber.ract":250,"interfaces/power_monitor.ract":251,"interfaces/radio.ract":252,"interfaces/shuttle_manipulator.ract":253,"interfaces/shuttle_manipulator/modification.ract":254,"interfaces/shuttle_manipulator/status.ract":255,"interfaces/shuttle_manipulator/templates.ract":256,"interfaces/sleeper.ract":257,"interfaces/smes.ract":258,"interfaces/solar_control.ract":259,"interfaces/space_heater.ract":260,"interfaces/station_alert.ract":261,"interfaces/suit_storage_unit.ract":262,"interfaces/tank_dispenser.ract":263,"interfaces/tanks.ract":264,"interfaces/thermomachine.ract":265,"interfaces/uplink.ract":266,"interfaces/wires.ract":267,"ractive":205,"ractive-events-keys":203,"ractive-transitions-fade":204,"util/byond":270,"util/dragresize":272}],270:[function(require,module,exports){
'use strict';

exports.__esModule = true;
exports.href = href;
exports.act = act;
exports.winset = winset;
var encode = encodeURIComponent;

// Helper to generate a BYOND href given 'params' as an object (with an optional 'url' for eg winset).
function href() {
  var params = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];
  var url = arguments.length <= 1 || arguments[1] === undefined ? '' : arguments[1];

  return 'byond://' + url + '?' + Object.keys(params).map(function (key) {
    return encode(key) + '=' + encode(params[key]);
  }).join('&');
}

// Helper to make a BYOND ui_act() call on the UI 'src' given an 'action' and optional 'params'.
function act(src, action) {
  var params = arguments.length <= 2 || arguments[2] === undefined ? {} : arguments[2];

  window.location.href = href(Object.assign({ src: src, action: action }, params));
}

// Helper to make a BYOND winset() call on 'window', setting 'key' to 'value'
function winset(win, key, value) {
  var _href;

  window.location.href = href((_href = {}, _href[win + '.' + key] = value, _href), 'winset');
}

},{}],271:[function(require,module,exports){
"use strict";

exports.__esModule = true;
// Constants used in tgui; these are mirrored from the BYOND code.
var UI_INTERACTIVE = exports.UI_INTERACTIVE = 2;
var UI_UPDATE = exports.UI_UPDATE = 1;
var UI_DISABLED = exports.UI_DISABLED = 0;
var UI_CLOSE = exports.UI_CLOSE = -1;

},{}],272:[function(require,module,exports){
'use strict';

exports.__esModule = true;
exports.lock = lock;
exports.drag = drag;
exports.sane = sane;
exports.resize = resize;

var _byond = require('./byond');

function lock(x, y) {
  if (x < 0) {
    // Left
    x = 0;
  } else if (x + window.innerWidth > window.screen.availWidth) {
    // Right
    x = window.screen.availWidth - window.innerWidth;
  }

  if (y < 0) {
    // Top
    y = 0;
  } else if (y + window.innerHeight > window.screen.availHeight) {
    // Bottom
    y = window.screen.availHeight - window.innerHeight;
  }

  return { x: x, y: y };
}

function drag(event) {
  event.preventDefault();

  if (!this.get('drag')) return;

  if (this.get('x')) {
    var x = event.screenX - this.get('x') + window.screenLeft;
    var y = event.screenY - this.get('y') + window.screenTop;
    if (this.get('config.locked')) {
      ;
      var _lock = lock(x, y);

      x = _lock.x;
      y = _lock.y;
    } // Lock to primary monitor.
    (0, _byond.winset)(this.get('config.window'), 'pos', x + ',' + y);
  }
  this.set({ x: event.screenX, y: event.screenY });
}

function sane(x, y) {
  x = Math.clamp(100, window.screen.width, x);
  y = Math.clamp(100, window.screen.height, y);
  return { x: x, y: y };
}

function resize(event) {
  event.preventDefault();

  if (!this.get('resize')) return;

  if (this.get('x')) {
    var x = event.screenX - this.get('x') + window.innerWidth;
    var y = event.screenY - this.get('y') + window.innerHeight;
    var _sane = sane(x, y);

    x = _sane.x;
    y = _sane.y;

    (0, _byond.winset)(this.get('config.window'), 'size', x + ',' + y);
  }
  this.set({ x: event.screenX, y: event.screenY });
}

},{"./byond":270}],273:[function(require,module,exports){
'use strict';

exports.__esModule = true;
exports.filterMulti = filterMulti;
exports.filter = filter;
function filterMulti(displays, string) {
  for (var _iterator = displays, _isArray = Array.isArray(_iterator), _i = 0, _iterator = _isArray ? _iterator : _iterator[Symbol.iterator]();;) {
    var _ref;

    if (_isArray) {
      if (_i >= _iterator.length) break;
      _ref = _iterator[_i++];
    } else {
      _i = _iterator.next();
      if (_i.done) break;
      _ref = _i.value;
    }

    var display = _ref;
    // First check if the display includes the search term in the first place.
    if (display.textContent.toLowerCase().includes(string)) {
      display.style.display = '';
      filter(display, string);
    } else {
      display.style.display = 'none';
    }
  }
}

function filter(display, string) {
  var items = display.queryAll('section');
  var titleMatch = display.query('header').textContent.toLowerCase().includes(string);
  for (var _iterator2 = items, _isArray2 = Array.isArray(_iterator2), _i2 = 0, _iterator2 = _isArray2 ? _iterator2 : _iterator2[Symbol.iterator]();;) {
    var _ref2;

    if (_isArray2) {
      if (_i2 >= _iterator2.length) break;
      _ref2 = _iterator2[_i2++];
    } else {
      _i2 = _iterator2.next();
      if (_i2.done) break;
      _ref2 = _i2.value;
    }

    var item = _ref2;
    // Check if the item or its displays title contains the search term.
    if (titleMatch || item.textContent.toLowerCase().includes(string)) {
      item.style.display = '';
    } else {
      item.style.display = 'none';
    }
  }
}

},{}],274:[function(require,module,exports){
'use strict';

exports.__esModule = true;
exports.clamp = clamp;
exports.fixed = fixed;
// Helper to limit a number to be inside 'min' and 'max'.
function clamp(min, max, number) {
  return Math.max(min, Math.min(number, max));
}

// Helper to round a number to 'decimals' decimals.
function fixed(number) {
  var decimals = arguments.length <= 1 || arguments[1] === undefined ? 1 : arguments[1];

  return Number(Math.round(number + 'e' + decimals) + 'e-' + decimals);
}

},{}],275:[function(require,module,exports){
'use strict';

exports.__esModule = true;
exports.upperCaseFirst = upperCaseFirst;
exports.titleCase = titleCase;
exports.zeroPad = zeroPad;
function upperCaseFirst(str) {
  return str[0].toUpperCase() + str.slice(1).toLowerCase();
}

function titleCase(str) {
  return str.replace(/\w\S*/g, upperCaseFirst);
}

function zeroPad(str, pad_size) {
  str = str.toString();
  while (str.length < pad_size) {
    str = '0' + str;
  }return str;
}

},{}],"babel/external-helpers":[function(require,module,exports){
var global = {}; (function (global) {
  var babelHelpers = global.babelHelpers = {};
  babelHelpers["typeof"] = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) {
    return typeof obj;
  } : function (obj) {
    return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj;
  };

  babelHelpers.jsx = function () {
    var REACT_ELEMENT_TYPE = typeof Symbol === "function" && Symbol["for"] && Symbol["for"]("react.element") || 0xeac7;
    return function createRawReactElement(type, props, key, children) {
      var defaultProps = type && type.defaultProps;
      var childrenLength = arguments.length - 3;

      if (!props && childrenLength !== 0) {
        props = {};
      }

      if (props && defaultProps) {
        for (var propName in defaultProps) {
          if (props[propName] === void 0) {
            props[propName] = defaultProps[propName];
          }
        }
      } else if (!props) {
        props = defaultProps || {};
      }

      if (childrenLength === 1) {
        props.children = children;
      } else if (childrenLength > 1) {
        var childArray = Array(childrenLength);

        for (var i = 0; i < childrenLength; i++) {
          childArray[i] = arguments[i + 3];
        }

        props.children = childArray;
      }

      return {
        $$typeof: REACT_ELEMENT_TYPE,
        type: type,
        key: key === undefined ? null : '' + key,
        ref: null,
        props: props,
        _owner: null
      };
    };
  }();

  babelHelpers.asyncToGenerator = function (fn) {
    return function () {
      var gen = fn.apply(this, arguments);
      return new Promise(function (resolve, reject) {
        function step(key, arg) {
          try {
            var info = gen[key](arg);
            var value = info.value;
          } catch (error) {
            reject(error);
            return;
          }

          if (info.done) {
            resolve(value);
          } else {
            return Promise.resolve(value).then(function (value) {
              return step("next", value);
            }, function (err) {
              return step("throw", err);
            });
          }
        }

        return step("next");
      });
    };
  };

  babelHelpers.classCallCheck = function (instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  };

  babelHelpers.createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  babelHelpers.defineEnumerableProperties = function (obj, descs) {
    for (var key in descs) {
      var desc = descs[key];
      desc.configurable = desc.enumerable = true;
      if ("value" in desc) desc.writable = true;
      Object.defineProperty(obj, key, desc);
    }

    return obj;
  };

  babelHelpers.defaults = function (obj, defaults) {
    var keys = Object.getOwnPropertyNames(defaults);

    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      var value = Object.getOwnPropertyDescriptor(defaults, key);

      if (value && value.configurable && obj[key] === undefined) {
        Object.defineProperty(obj, key, value);
      }
    }

    return obj;
  };

  babelHelpers.defineProperty = function (obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, {
        value: value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    } else {
      obj[key] = value;
    }

    return obj;
  };

  babelHelpers["extends"] = Object.assign || function (target) {
    for (var i = 1; i < arguments.length; i++) {
      var source = arguments[i];

      for (var key in source) {
        if (Object.prototype.hasOwnProperty.call(source, key)) {
          target[key] = source[key];
        }
      }
    }

    return target;
  };

  babelHelpers.get = function get(object, property, receiver) {
    if (object === null) object = Function.prototype;
    var desc = Object.getOwnPropertyDescriptor(object, property);

    if (desc === undefined) {
      var parent = Object.getPrototypeOf(object);

      if (parent === null) {
        return undefined;
      } else {
        return get(parent, property, receiver);
      }
    } else if ("value" in desc) {
      return desc.value;
    } else {
      var getter = desc.get;

      if (getter === undefined) {
        return undefined;
      }

      return getter.call(receiver);
    }
  };

  babelHelpers.inherits = function (subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function, not " + typeof superClass);
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
    if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass;
  };

  babelHelpers["instanceof"] = function (left, right) {
    if (right != null && typeof Symbol !== "undefined" && right[Symbol.hasInstance]) {
      return right[Symbol.hasInstance](left);
    } else {
      return left instanceof right;
    }
  };

  babelHelpers.interopRequireDefault = function (obj) {
    return obj && obj.__esModule ? obj : {
      "default": obj
    };
  };

  babelHelpers.interopRequireWildcard = function (obj) {
    if (obj && obj.__esModule) {
      return obj;
    } else {
      var newObj = {};

      if (obj != null) {
        for (var key in obj) {
          if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key];
        }
      }

      newObj["default"] = obj;
      return newObj;
    }
  };

  babelHelpers.newArrowCheck = function (innerThis, boundThis) {
    if (innerThis !== boundThis) {
      throw new TypeError("Cannot instantiate an arrow function");
    }
  };

  babelHelpers.objectDestructuringEmpty = function (obj) {
    if (obj == null) throw new TypeError("Cannot destructure undefined");
  };

  babelHelpers.objectWithoutProperties = function (obj, keys) {
    var target = {};

    for (var i in obj) {
      if (keys.indexOf(i) >= 0) continue;
      if (!Object.prototype.hasOwnProperty.call(obj, i)) continue;
      target[i] = obj[i];
    }

    return target;
  };

  babelHelpers.possibleConstructorReturn = function (self, call) {
    if (!self) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return call && (typeof call === "object" || typeof call === "function") ? call : self;
  };

  babelHelpers.selfGlobal = typeof global === "undefined" ? self : global;

  babelHelpers.set = function set(object, property, value, receiver) {
    var desc = Object.getOwnPropertyDescriptor(object, property);

    if (desc === undefined) {
      var parent = Object.getPrototypeOf(object);

      if (parent !== null) {
        set(parent, property, value, receiver);
      }
    } else if ("value" in desc && desc.writable) {
      desc.value = value;
    } else {
      var setter = desc.set;

      if (setter !== undefined) {
        setter.call(receiver, value);
      }
    }

    return value;
  };

  babelHelpers.slicedToArray = function () {
    function sliceIterator(arr, i) {
      var _arr = [];
      var _n = true;
      var _d = false;
      var _e = undefined;

      try {
        for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) {
          _arr.push(_s.value);

          if (i && _arr.length === i) break;
        }
      } catch (err) {
        _d = true;
        _e = err;
      } finally {
        try {
          if (!_n && _i["return"]) _i["return"]();
        } finally {
          if (_d) throw _e;
        }
      }

      return _arr;
    }

    return function (arr, i) {
      if (Array.isArray(arr)) {
        return arr;
      } else if (Symbol.iterator in Object(arr)) {
        return sliceIterator(arr, i);
      } else {
        throw new TypeError("Invalid attempt to destructure non-iterable instance");
      }
    };
  }();

  babelHelpers.slicedToArrayLoose = function (arr, i) {
    if (Array.isArray(arr)) {
      return arr;
    } else if (Symbol.iterator in Object(arr)) {
      var _arr = [];

      for (var _iterator = arr[Symbol.iterator](), _step; !(_step = _iterator.next()).done;) {
        _arr.push(_step.value);

        if (i && _arr.length === i) break;
      }

      return _arr;
    } else {
      throw new TypeError("Invalid attempt to destructure non-iterable instance");
    }
  };

  babelHelpers.taggedTemplateLiteral = function (strings, raw) {
    return Object.freeze(Object.defineProperties(strings, {
      raw: {
        value: Object.freeze(raw)
      }
    }));
  };

  babelHelpers.taggedTemplateLiteralLoose = function (strings, raw) {
    strings.raw = raw;
    return strings;
  };

  babelHelpers.temporalRef = function (val, name, undef) {
    if (val === undef) {
      throw new ReferenceError(name + " is not defined - temporal dead zone");
    } else {
      return val;
    }
  };

  babelHelpers.temporalUndefined = {};

  babelHelpers.toArray = function (arr) {
    return Array.isArray(arr) ? arr : Array.from(arr);
  };

  babelHelpers.toConsumableArray = function (arr) {
    if (Array.isArray(arr)) {
      for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) arr2[i] = arr[i];

      return arr2;
    } else {
      return Array.from(arr);
    }
  };
})(typeof global === "undefined" ? self : global); module.exports = global.babelHelpers;
},{}]},{},[268]);
