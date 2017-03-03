//used to optimize map expansion
/turf/basic
    var/static/warned

/turf/basic/New()

/turf/basic/ChangeTurf(var/T)
    new T(src)
    if(!warned)
        warned = TRUE
        CRASH("Basic ChangeTurf")