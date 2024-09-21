//This file is just for the necessary /world definition
//Try looking in /code/game/world.dm, where initialization order is defined

/**
 * The game's world.icon_size is set right here. \
 * Ideally divisible by 16. \
 * Ideally a number. \
 * Can be a string (32x32), so more exotic coders
 * will be sad if you use this in math.
 */
#define ICONSIZE_ALL 32
/// The X dimension of the ICONSIZE. This will more than likely be the bigger one.
#define ICONSIZE_X 32
/// The Y dimension of the ICONSIZE. This will more than likely be the smaller one.
#define ICONSIZE_Y 32

/**
 * # World
 *
 * Two possibilities exist: either we are alone in the Universe or we are not. Both are equally terrifying. ~ Arthur C. Clarke
 *
 * The byond world object stores some basic byond level config, and has a few hub specific procs for managing hub visibility
 */
/world
	mob = /mob/dead/new_player
	turf = /turf/open/space/basic
	area = /area/space
	view = "15x15"
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "/tg/ Station 13"
	fps = 20
	cache_lifespan = 0
	map_format = SIDE_MAP
	icon_size = ICONSIZE_ALL
#ifdef FIND_REF_NO_CHECK_TICK
	loop_checks = FALSE
#endif
