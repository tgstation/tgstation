#define GLOBAL_MANAGED(X)\
\
/world/ReadGlobal(global_name){\
    if(global_name == #X){\
        return X;\
    }\
    return ..();\
}\
/world/WriteGlobal(global_name, value){\
    if(global_name == #X){\
        X = value;\
        return TRUE;\
    }\
    return ..();\
}\
/world/ListGlobals(){\
    . = ..();\
    . += #X;\
}

#define GLOBAL_INIT(X, InitProc)\
GLOBAL_MANAGED(X)\
\
/world/InitGlobals(){\
    ..();\
    testing("IG: [##X] = [#InitProc]()");\
    X = ##InitProc();\
}

#define GLOBAL_RAW(X) var##X;

#define GLOBAL_VAR_INIT(X, InitProc) GLOBAL_RAW(X)\
GLOBAL_INIT(X, InitProc)

#define GLOBAL_LIST_INIT(X, InitProc) GLOBAL_RAW(list/X)\
GLOBAL_INIT(X, InitProc)

#define GLOBAL_DATUM_INIT(X, Typepath, InitProc) GLOBAL_RAW(Typepath/X)\
GLOBAL_INIT(X, InitProc)

#define GLOBAL_VAR(X) GLOBAL_RAW(X)\
GLOBAL_MANAGED(X)

#define GLOBAL_LIST(X) GLOBAL_RAW(list/X)\
GLOBAL_MANAGED(X)

#define GLOBAL_DATUM(X, Typepath) GLOBAL_RAW(Typepath/X)\
GLOBAL_MANAGED(X)

/proc/ReturnsNull()
    return null