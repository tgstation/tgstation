/obj/effect/landmark/mafia_game_area //locations where mafia will be loaded by the datum
	name = "Mafia Area Spawn"
	var/game_id = "mafia"

/obj/effect/landmark/mafia
	name = "Mafia Player Spawn"
	var/game_id = "mafia"

/obj/effect/landmark/mafia/town_center
	name = "Mafia Town Center"

//for ghosts/admins
/obj/mafia_game_board
	name = "Mafia Game Board"
	icon = 'icons/obj/mafia.dmi'
	icon_state = "board"
	anchored = TRUE
	var/game_id = "mafia"
	var/datum/mafia_controller/MF

/obj/mafia_game_board/attack_ghost(mob/user)
	. = ..()
	if(!MF)
		MF = GLOB.mafia_game
	if(!MF)
		MF = create_mafia_game()
	MF.ui_interact(user)

/area/mafia
	name = "Mafia Minigame"
	icon_state = "mafia"
	static_lighting = FALSE

	base_lighting_alpha = 255
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = BLOCK_SUICIDE | UNIQUE_AREA

/datum/map_template/mafia
	var/description = ""

/datum/map_template/mafia/summerball
	name = "Summerball 2020"
	description = "The original, the OG. The 2020 Summer ball was where mafia came from, with this map."
	mappath = "_maps/map_files/Mafia/mafia_ball.dmm"

/datum/map_template/mafia/syndicate
	name = "Syndicate Megastation"
	description = "Yes, it's a very confusing day at the Megastation. Will the syndicate conflict resolution operatives succeed?"
	mappath = "_maps/map_files/Mafia/mafia_syndie.dmm"

/datum/map_template/mafia/lavaland
	name = "Lavaland Excursion"
	description = "The station has no idea what's going down on lavaland right now, we got changelings... traitors, and worst of all... lawyers roleblocking you every night."
	mappath = "_maps/map_files/Mafia/mafia_lavaland.dmm"

/datum/map_template/mafia/ufo
	name = "Alien Mothership"
	description = "The haunted ghost UFO tour has gone south and now it's up to our fine townies and scare seekers to kill the actual real alien changelings..."
	mappath = "_maps/map_files/Mafia/mafia_ayylmao.dmm"

/datum/map_template/mafia/spider_clan
	name = "Spider Clan Kidnapping"
	description = "New and improved spider clan kidnappings are a lot less boring and have a lot more lynching. Damn westaboos!"
	mappath = "_maps/map_files/Mafia/mafia_spiderclan.dmm"

/datum/map_template/mafia/snowy
	name = "Snowdin"
	description = "Based off of the icey moon map of the same name, the guy who reworked it pretty much did it for nothing since away missions are disabled but at least he'll get this...?"
	mappath = "_maps/map_files/Mafia/mafia_snow.dmm"

/datum/map_template/mafia/gothic
	name = "Vampire's Castle"
	description = "Vampires and changelings clash to find out who's the superior bloodsucking monster in this creepy castle map."
	mappath = "_maps/map_files/Mafia/mafia_gothic.dmm"
