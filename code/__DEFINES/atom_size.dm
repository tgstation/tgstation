// Common item sizes:
/// Usually items smaller then a human hand, (e.g. playing cards, lighter, scalpel, coins/holochips)
#define ITEM_SIZE_TINY 10
/// Pockets can hold small and tiny items, (e.g. flashlight, multitool, grenades, GPS device)
#define ITEM_SIZE_SMALL 500
/// Standard backpacks can carry tiny, small & normal items, (e.g. fire extinguisher, stun baton, gas mask, metal sheets)
#define ITEM_SIZE_NORMAL 8000
/// Items that can be weilded or equipped but not stored in an inventory, (e.g. defibrillator, backpack, space suits)
#define ITEM_SIZE_BULKY 50000
/// Usually represents objects that require two hands to operate, (e.g. shotgun, two-handed melee weapons)
#define ITEM_SIZE_HUGE 125000
/// Essentially means it cannot be picked up or placed in an inventory, (e.g. mech parts, safe)
#define ITEM_SIZE_GIGANTIC 1000000

// Common mob sizes:
/// Most insects and rodents.
#define MOB_SIZE_TINY 100
/// Mobs such as cats and dogs.
#define MOB_SIZE_SMALL 10000
/// The standard size of humans.
#define MOB_SIZE_HUMAN 70000
/// Significantly larger than human mobs.
#define MOB_SIZE_LARGE 100000
/// Megafauna and... well it's pretty much only megafauna. Use this for things you don't want bluespace body-bagged
#define MOB_SIZE_HUGE 10000000

/// The length of one side of a single turf (in cm)
#define TURF_LENGTH 100 // 1m
/// The height of a single turf. (in cm)
#define TURF_HEIGHT 250 // 1m
/// The area of the horizontal cross section of a wall. (in cm^2)
#define TURF_BASE_AREA (TURF_LENGTH * TURF_LENGTH) // 1m^2 | 10000cm^2
/// The area of the vertical cross section of a wall.
#define TURF_SIDE_AREA (TURF_LENGTH * TURF_HEIGHT)
/// The total area of all of the sides of a wall assuming that they are perfectly flat.
#define CLOSED_TURF_SURFACE_AREA ((TURF_BASE_AREA * 2) + (TURF_SIDE_AREA * 4))
/// The size of a wall. In general if its sprite fits within a turf its size should be less than this.
#define TURF_SIZE (TURF_HORIZONTAL_AREA * TURF_HEIGHT) // 2.5m^2 | 2500L | 2500000cm^3
