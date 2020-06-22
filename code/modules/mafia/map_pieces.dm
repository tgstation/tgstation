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
	var/game_id = "mafia"

/obj/mafia_game_board/attack_ghost(mob/user)
	. = ..()
	var/datum/mafia_controller/MF = GLOB.mafia_games[game_id]
	if(!MF)
		MF = create_mafia_game(game_id)
	MF.ui_interact(user)

/area/mafia
	name = "Mafia Minigame"
	icon_state = "mafia"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	flags_1 = 0
	hidden = TRUE
