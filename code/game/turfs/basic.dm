//used to optimize map expansion
/turf/basic/New()

/turf/basic/ChangeTurf(var/T)
    new T(src)
    var/static/warned
    if(!warned)
        warned = TRUE
        CRASH("Basic ChangeTurf")