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
        ##X = value;\
        return TRUE;\
    }\
    return ..();\
}\
/world/ListGlobals(){\
    . = ..();\
    .[#X] = ##X;\
}

#define GLOBAL_INIT(X, InitValue)\
GLOBAL_MANAGED(X)\
\
/world/InitGlobals(){\
    ..();\
    ##X = ##InitValue;\
}

#define GLOBAL_RAW(X) var/global##X;

#define GLOBAL_VAR_INIT(X, InitValue) GLOBAL_RAW(/##X)\
GLOBAL_INIT(X, InitValue)

#define GLOBAL_LIST_INIT(X, InitValue) GLOBAL_RAW(/list/##X)\
GLOBAL_INIT(X, InitValue)

#define GLOBAL_DATUM_INIT(X, Typepath, InitValue) GLOBAL_RAW(Typepath/##X)\
GLOBAL_INIT(X, InitValue)

#define GLOBAL_VAR(X) GLOBAL_RAW(/##X)\
GLOBAL_MANAGED(X)

#define GLOBAL_LIST(X) GLOBAL_RAW(/list/##X)\
GLOBAL_MANAGED(X)

#define GLOBAL_DATUM(X, Typepath) GLOBAL_RAW(Typepath/##X)\
GLOBAL_MANAGED(X)