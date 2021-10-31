#define CHANGETURF_DEFER_CHANGE 1
#define CHANGETURF_IGNORE_AIR 2 // This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_FORCEOP 4
#define CHANGETURF_SKIP 8 // A flag for PlaceOnTop to just instance the new turf instead of calling ChangeTurf. Used for uninitialized turfs NOTHING ELSE
#define CHANGETURF_INHERIT_AIR 16 // Inherit air from previous turf. Implies CHANGETURF_IGNORE_AIR
#define CHANGETURF_RECALC_ADJACENT 32 //Immediately recalc adjacent atmos turfs instead of queuing.

#define IS_OPAQUE_TURF(turf) (turf.directional_opacity == ALL_CARDINALS)

//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
///Returns a list of turf in a square
#define RANGE_TURFS(RADIUS, CENTER) \
	RECT_TURFS(RADIUS, RADIUS, CENTER)

#define RECT_TURFS(H_RADIUS, V_RADIUS, CENTER) \
	block( \
	locate(max(CENTER.x-(H_RADIUS),1),          max(CENTER.y-(V_RADIUS),1),          CENTER.z), \
	locate(min(CENTER.x+(H_RADIUS),world.maxx), min(CENTER.y+(V_RADIUS),world.maxy), CENTER.z) \
	)

///Returns all turfs in a zlevel
#define Z_TURFS(ZLEVEL) block(locate(1,1,ZLEVEL), locate(world.maxx, world.maxy, ZLEVEL))

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))

#define UNDERFLOOR_HIDDEN 0
#define UNDERFLOOR_VISIBLE 1
#define UNDERFLOOR_INTERACTABLE 2
