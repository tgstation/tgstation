/obj/effect/landmark/basketball
	name = "Basketball Map Spawner"

/obj/effect/landmark/basketball/team_spawn
	name = "Basketball Team Spawner"
	var/game_id = "basketball"

// locations where players for the home team will spawn
/obj/effect/landmark/basketball/team_spawn/home
	name = "Home Team Spawn"

/obj/effect/landmark/basketball/team_spawn/home_hoop
	name = "Basketball Home Hoop Spawner"

// locations where players for the away team will spawn
/obj/effect/landmark/basketball/team_spawn/away
	name = "Away Team Spawn"

/obj/effect/landmark/basketball/team_spawn/away_hoop
	name = "Basketball Away Hoop Spawner"

/obj/effect/landmark/basketball/team_spawn/referee
	name = "Referee Spawn"

/area/centcom/basketball
	name = "Basketball Minigame"
	icon_state = "b_ball"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = UNIQUE_AREA | NOTELEPORT | NO_DEATH_MESSAGE | BLOCK_SUICIDE

/datum/lazy_template/basketball
	map_dir = "_maps/minigame/basketball"
	place_on_top = TRUE
	turf_reservation_type = /datum/turf_reservation/turf_not_baseturf
	/// Map UI Name
	var/name
	/// Map Description
	var/description = ""
	/// The name of the basketball team
	var/team_name
	/// The basketball teams home stadium uniform
	var/home_team_uniform

/datum/lazy_template/basketball/stadium
	name = "Stadium"
	description = "The homecourt for the Nanotrasen Basketball Department."
	map_name = "stadium"
	key = "stadium"
	team_name = "Nanotrasen Basketball Department"
	home_team_uniform = /datum/outfit/basketball/nanotrasen

/datum/lazy_template/basketball/lusty_xenomorphs
	name = "Lusty Xenomorphs Stadium"
	description = "The homecourt of the Lusty Xenomorphs."
	map_name = "lusty_xenomorphs"
	key = "lusty_xenomorphs"
	team_name = "Lusty Xenomorphs"
	home_team_uniform = /datum/outfit/basketball/lusty_xenomorphs

/datum/lazy_template/basketball/space_surfers
	name = "Space Surfers Stadium"
	description = "The homecourt of the Space Surfers."
	map_name = "space_surfers"
	key = "space_surfers"
	team_name = "Space Surfers"
	home_team_uniform = /datum/outfit/basketball/space_surfers

/datum/lazy_template/basketball/greytide_worldwide
	name = "Greytide Worldwide Stadium"
	description = "The homecourt of the Greytide Worldwide."
	map_name = "greytide_worldwide"
	key = "greytide_worldwide"
	team_name = "Greytide Worldwide"
	home_team_uniform = /datum/outfit/basketball/greytide_worldwide

/datum/lazy_template/basketball/ass_blast_usa
	name = "Ass Blast USA Stadium"
	description = "The homecourt of the Ass Blast USA."
	map_name = "ass_blast_usa"
	key = "ass_blast_usa"
	team_name = "Ass Blast USA"
	home_team_uniform = /datum/outfit/basketball/ass_blast_usa

/datum/lazy_template/basketball/soviet_bears
	name = "Soviet Bears Stadium"
	description = "The homecourt of the Soviet Bears."
	map_name = "soviet_bear"
	key = "soviet_bear"
	team_name = "Soviet Bears"
	home_team_uniform = /datum/outfit/basketball/soviet_bears

/datum/lazy_template/basketball/ash_gladiators
	name = "Ash Gladiators Stadium"
	description = "The homecourt of the Ash Gladiators."
	map_name = "ash_gladiators"
	key = "ash_gladiators"
	team_name = "Ash Gladiators"
	home_team_uniform = /datum/outfit/basketball/ash_gladiators

/datum/lazy_template/basketball/beach_bums
	name = "Beach Bums Stadium"
	description = "The homecourt of the Beach Bums."
	map_name = "beach_bums"
	key = "beach_bums"
	team_name = "Beach Bums"
	home_team_uniform = /datum/outfit/basketball/beach_bums
