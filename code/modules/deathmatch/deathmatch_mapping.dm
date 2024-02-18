/area/deathmatch
	name = "Deathmatch Arena"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED

/area/deathmatch/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/obj/effect/landmark/deathmatch_player_spawn
	name = "Deathmatch Player Spawner"

/obj/effect/landmark/deathmatch_player_spawn/Initialize(mapload)
	. = ..()
	if (isnull(GLOB.deathmatch_game))
		return INITIALIZE_HINT_QDEL
	GLOB.deathmatch_game.spawnpoint_processing += src

/obj/effect/landmark/deathmatch_player_spawn/Destroy()
	. = ..()
	if(isnull(GLOB.deathmatch_game))
		return
	GLOB.deathmatch_game.spawnpoint_processing -= src
