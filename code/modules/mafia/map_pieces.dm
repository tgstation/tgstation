/obj/effect/landmark/mafia
	name = "Mafia Player Spawn"
	var/game_id = "mafia"

/obj/effect/landmark/mafia/town_center
	name = "Mafia Town Center"

/obj/mafia_game_signup
	name = "Mafia Game Signup"
	desc = "Sign up here."
	icon = 'icons/obj/mafia.dmi'
	icon_state = "joinme"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/game_id = "mafia"

/obj/mafia_game_signup/Initialize()
	. = ..()
	GLOB.minigame_signups.boards[game_id] = src

/obj/mafia_game_signup/attack_hand(mob/user)
	. = ..()
	GLOB.minigame_signups.SignUpFor(user,game_id)

/obj/mafia_game_signup/before_signup()
	var/datum/mafia_controller/MF = GLOB.mafia_games[game_id]
	if(!MF)
		MF = create_mafia_game(game_id)

/obj/proc/before_signup()
	return

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

/obj/mafia_game_signup/debug
	var/datum/mafia_controller/MF
	var/list/debug_setup = list(/datum/mafia_role/md=1,/datum/mafia_role/obsessed=1,/datum/mafia_role/detective=1,/datum/mafia_role/mafia=1)

/obj/mafia_game_signup/debug/Initialize()
	. = ..()
	//new /obj/effect/landmark/mafia(get_step(get_turf(src),EAST))
	//new /obj/effect/landmark/mafia(get_step(get_turf(src),WEST))
	//new /obj/effect/landmark/mafia(get_step(get_turf(src),NORTH))
	//new /obj/effect/landmark/mafia(get_step(get_turf(src),SOUTH))
	MF = create_mafia_game("mafia")
	MF.debug = TRUE
	GLOB.minigame_signups.debug_mode = TRUE
	GLOB.minigame_signups.signed_up["mafia"] = list("debug_guy_key","the_other_guy","third_loser")
	GLOB.mafia_setups = list(debug_setup)

/area/mafia
	name = "Mafia Minigame"
	icon_state = "Prophunt"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	flags_1 = 0
	hidden = TRUE
