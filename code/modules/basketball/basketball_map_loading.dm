/obj/effect/landmark/basketball
	name = "Basketball Map Spawner"

/obj/effect/landmark/basketball/team_spawn
	name = "Basketball Team Spawner"
	var/game_id = "basketball"

// locations where players for the home team will spawn
/obj/effect/landmark/basketball/team_spawn/home
	name = "Home Team Spawn"

// locations where players for the away team will spawn
/obj/effect/landmark/basaketball/team_spawn/away
	name = "Away Team Spawn"

/area/centcom/basketball
	name = "Basketball Minigame"
	icon_state = "b_ball"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_DEATH_MESSAGE | BLOCK_SUICIDE

/datum/map_template/basketball
	var/description = ""
	/// The basketball teams home stadium uniform
	var/home_team_uniform = null
	/// The sound that plays when players spawn on the stadium
	var/home_team_sound = null

/datum/map_template/basketball/stadium
	name = "Stadium"
	description = "The original homecourt."
	mappath = "_maps/map_files/basketball/stadium.dmm"
	//home_team_uniform defaults to blue or red jerseys for regular stadium

/datum/map_template/basketball/lusty_xenomorphs
	name = "Lusty Xenomorphs Stadium"
	description = "The homecourt of the lusty xenomorphs."
	mappath = "_maps/map_files/basketball/lusty_xenomorphs.dmm"
	home_team_uniform = /datum/outfit/basketball/lusty_xenomorphs

/datum/map_template/basketball/space_surfers
	name = "Space Surfers Stadium"
	description = "The homecourt of the space surfers."
	mappath = "_maps/map_files/basketball/space_surfers.dmm"
	home_team_uniform = /datum/outfit/basketball/space_surfers

/datum/map_template/basketball/greytide_worldwide
	name = "Greytide Worldwide Stadium"
	description = "The homecourt of the greytide worldwide."
	mappath = "_maps/map_files/basketball/greytide_worldwide.dmm"
	home_team_uniform = /datum/outfit/basketball/greytide_worldwide
