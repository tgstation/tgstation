//used to optimize map expansion
/turf/basic/New()

/turf/basic/ChangeTurf(var/T)
    new T(src)
    CRASH("Basic ChangeTurf")