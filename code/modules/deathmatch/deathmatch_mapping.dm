/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | LOCAL_TELEPORT | EVENT_PROTECTED | QUIET_LOGS | NO_DEATH_MESSAGE | BINARY_JAMMING

/area/deathmatch/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

// for the illusion of a moving train
/turf/open/chasm/true/no_smooth/fake_motion_sand
	name = "air"
	desc = "Don't jump off, unless you want to fall a really long distance."
	icon_state = "sandmoving"
	base_icon_state = "sandmoving"
	icon = 'icons/turf/floors.dmi'

/turf/open/chasm/true/no_smooth/fake_motion_sand/fast
	icon_state = "sandmovingfast"
	base_icon_state = "sandmovingfast"

// fakeout

/turf/open/chasm/true/fakeout
	name = /turf/open/floor/wood::name
	// desc kept the same
	icon_state = /turf/open/floor/wood::icon_state
	base_icon_state = /turf/open/floor/wood::base_icon_state
	icon = /turf/open/floor/wood::icon
	smoothing_flags = NONE
