// Papers over incompatibilities with SpacemanDMM.
#ifdef SPACEMAN_DMM

#define call_ext(args...) call(args)

#define nameof(X) "SpacemanDMM incompatibility - nameof()"
#define refcount(X) UNLINT("SpacemanDMM incompatibility - refcount()")

/savefile
	var/byond_version

#endif
