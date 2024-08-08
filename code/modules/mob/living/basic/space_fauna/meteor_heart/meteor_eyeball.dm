#define EYEBALL_BLINK_INTERVAL_MIN 10 SECONDS
#define EYEBALL_BLINK_INTERVAL_MAX 30 SECONDS

/// List of all the meteor eyeballs so we can gib them upon meteor death
GLOBAL_LIST_EMPTY(meteor_eyeballs)

/// Basically just an organic floor light
/obj/structure/meateor_fluff/eyeball
	name = "beady eye"
	desc = "An eyeball growing out of the ground, gross."
	icon_state = "eyeball"
	max_integrity = 15
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE

/obj/structure/meateor_fluff/eyeball/Initialize(mapload)
	. = ..()
	GLOB.meteor_eyeballs += src
	set_light(l_range = 4, l_color = COLOR_VERY_SOFT_YELLOW)
	blink()

/// Play a blinking animation and queue it again
/obj/structure/meateor_fluff/eyeball/proc/blink()
	flick("eyeball_blink", src)
	addtimer(CALLBACK(src, PROC_REF(blink)), rand(EYEBALL_BLINK_INTERVAL_MIN, EYEBALL_BLINK_INTERVAL_MAX), TIMER_DELETE_ME)

/obj/structure/meateor_fluff/eyeball/atom_destruction(damage_flag)
	new /obj/effect/gibspawner/generic(loc)
	return ..()

/obj/structure/meateor_fluff/eyeball/Destroy()
	GLOB.meteor_eyeballs -= src
	return ..()

#undef EYEBALL_BLINK_INTERVAL_MIN
#undef EYEBALL_BLINK_INTERVAL_MAX
