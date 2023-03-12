#define SEE_INVISIBLE_MINIMUM 5

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

//#define SEE_INVISIBLE_LEVEL_ONE 35 //currently unused
//#define INVISIBILITY_LEVEL_ONE 35 //currently unused

//#define SEE_INVISIBLE_LEVEL_TWO 45 //currently unused
//#define INVISIBILITY_LEVEL_TWO 45 //currently unused

#define INVISIBILITY_REVENANT 50

#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100 //the maximum allowed for "real" objects

#define INVISIBILITY_ABSTRACT 101 //only used for abstract objects (e.g. spacevine_controller), things that are not really there.

#define BORGMESON (1<<0)
#define BORGTHERM (1<<1)
#define BORGXRAY (1<<2)
#define BORGMATERIAL (1<<3)

//for clothing visor toggles, these determine which vars to toggle
#define VISOR_FLASHPROTECT (1<<0)
#define VISOR_TINT (1<<1)
#define VISOR_VISIONFLAGS (1<<2) //all following flags only matter for glasses
#define VISOR_INVISVIEW (1<<3)

// BYOND internal values for the sight flags
// See [https://www.byond.com/docs/ref/#/mob/var/sight]
/// can't see anything
//#define BLIND (1<<0)
/// can see all mobs, no matter what
//#define SEE_MOBS (1<<2)
/// can see all objs, no matter what
//#define SEE_OBJS (1<<3)
// can see all turfs (and areas), no matter what
//#define SEE_TURFS (1<<4)
/// can see self, no matter what
//#define SEE_SELF (1<<5)
/// can see infra-red objects (different sort of luminosity, essentially a copy of it, one we do not use)
//#define SEE_INFRA (1<<6)
/// if an object is located on an unlit area, but some of its pixels are
/// in a lit area (via pixel_x,y or smooth movement), can see those pixels
//#define SEE_PIXELS (1<<8)
/// can see through opaque objects
//#define SEE_THRU (1<<9)
/// render dark tiles as blackness (Note, this basically means we draw dark tiles to plane 0)
/// we can then hijack that plane with a plane master, and start drawing it anywhere we want
/// NOTE: this does not function with the SIDE_MAP map format. So we can't. :(
//#define SEE_BLACKNESS (1<<10)

/// Bitfield of sight flags that show THINGS but no lighting
/// Since lighting is an underlay on turfs, this is everything but that
#define SEE_AVOID_TURF_BLACKNESS (SEE_MOBS|SEE_OBJS)
