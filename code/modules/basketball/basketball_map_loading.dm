/obj/effect/landmark/basketball
	name = "Basketball Map Spawner"

/obj/effect/landmark/basketball/game_area
	name = "Basketball Game Location"

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

/datum/map_template/basketball
	should_place_on_top = FALSE
	var/description = ""
	/// The name of the basketball team
	var/team_name
	/// The basketball teams home stadium uniform
	var/home_team_uniform

/datum/map_template/basketball/stadium
	name = "Stadium"
	description = "The homecourt for the Nanotrasen Basketball Department."
	mappath = "_maps/map_files/basketball/stadium.dmm"
	team_name = "Nanotrasen Basketball Department"
	home_team_uniform = /datum/outfit/basketball/nanotrasen

/datum/map_template/basketball/lusty_xenomorphs
	name = "Lusty Xenomorphs Stadium"
	description = "The homecourt of the Lusty Xenomorphs."
	mappath = "_maps/map_files/basketball/lusty_xenomorphs.dmm"
	team_name = "Lusty Xenomorphs"
	home_team_uniform = /datum/outfit/basketball/lusty_xenomorphs

/datum/map_template/basketball/space_surfers
	name = "Space Surfers Stadium"
	description = "The homecourt of the Space Surfers."
	mappath = "_maps/map_files/basketball/space_surfers.dmm"
	team_name = "Space Surfers"
	home_team_uniform = /datum/outfit/basketball/space_surfers

/datum/map_template/basketball/greytide_worldwide
	name = "Greytide Worldwide Stadium"
	description = "The homecourt of the Greytide Worldwide."
	mappath = "_maps/map_files/basketball/greytide_worldwide.dmm"
	team_name = "Greytide Worldwide"
	home_team_uniform = /datum/outfit/basketball/greytide_worldwide

/datum/map_template/basketball/ass_blast_usa
	name = "Ass Blast USA Stadium"
	description = "The homecourt of the Ass Blast USA."
	mappath = "_maps/map_files/basketball/ass_blast_usa.dmm"
	team_name = "Ass Blast USA"
	home_team_uniform = /datum/outfit/basketball/ass_blast_usa

/datum/map_template/basketball/soviet_bears
	name = "Soviet Bears Stadium"
	description = "The homecourt of the Soviet Bears."
	mappath = "_maps/map_files/basketball/soviet_bears.dmm"
	team_name = "Soviet Bears"
	home_team_uniform = /datum/outfit/basketball/soviet_bears

/datum/map_template/basketball/ash_gladiators
	name = "Ash Gladiators Stadium"
	description = "The homecourt of the Ash Gladiators."
	mappath = "_maps/map_files/basketball/ash_gladiators.dmm"
	team_name = "Ash Gladiators"
	home_team_uniform = /datum/outfit/basketball/ash_gladiators

/datum/map_template/basketball/beach_bums
	name = "Beach Bums Stadium"
	description = "The homecourt of the Beach Bums."
	mappath = "_maps/map_files/basketball/beach_bums.dmm"
	team_name = "Beach Bums"
	home_team_uniform = /datum/outfit/basketball/beach_bums
