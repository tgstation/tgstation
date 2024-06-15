/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT | EVENT_PROTECTED | QUIET_LOGS

/area/deathmatch/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/area/deathmatch/teleport //Prevent access to cross-z teleportation in the map itself (no wands of safety/teleportation scrolls). Cordons should prevent same-z teleportations outside of the arena.
	area_flags = UNIQUE_AREA | EVENT_PROTECTED | QUIET_LOGS

// for the illusion of a moving train
/turf/open/chasm/true/no_smooth/fake_motion_sand
	name = "air"
	desc = "Dont jump off, unless you want to fall a really long distance."
	icon_state = "sandmoving"
	base_icon_state = "sandmoving"
	icon = 'icons/turf/floors.dmi'

/turf/open/chasm/true/no_smooth/fake_motion_sand/fast
	icon_state = "sandmovingfast"
	base_icon_state = "sandmovingfast"
