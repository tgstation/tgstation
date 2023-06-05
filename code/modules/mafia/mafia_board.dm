/obj/mafia_game_board
	name = "Mafia Game Board"
	desc = "Dead players can orbit this, allowing them to speak to Chaplains during the night."
	icon = 'icons/obj/mafia.dmi'
	icon_state = "board"
	anchored = TRUE
	///The mafia controller board ghosts interacting with us will open.
	var/datum/mafia_controller/mafia_controller_board

/obj/mafia_game_board/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(on_dead_orbit))
	RegisterSignal(src, COMSIG_ATOM_ORBIT_STOP, PROC_REF(on_dead_stop_orbit))

/obj/mafia_game_board/attack_ghost(mob/user)
	. = ..()
	if(!mafia_controller_board)
		mafia_controller_board = GLOB.mafia_game
	if(!mafia_controller_board)
		mafia_controller_board = create_mafia_game()
	mafia_controller_board.ui_interact(user)

/obj/mafia_game_board/proc/on_dead_orbit(atom/source, mob/dead/dead_player)
	SIGNAL_HANDLER
	if(istype(dead_player))
		RegisterSignal(dead_player, COMSIG_MOB_DEADSAY, PROC_REF(on_message))

/obj/mafia_game_board/proc/on_dead_stop_orbit(atom/source, mob/dead/dead_player)
	SIGNAL_HANDLER
	UnregisterSignal(dead_player, COMSIG_MOB_DEADSAY)

/**
 * Sends a message to all mafia roles that can seance, if it's night-time.
 * This includes Ghosts, so they can know eachother's messages are properly sending.
 */
/obj/mafia_game_board/proc/on_message(mob/source, message)
	SIGNAL_HANDLER
	if(mafia_controller_board.phase != MAFIA_PHASE_NIGHT)
		return FALSE
	if(!HAS_TRAIT(source, TRAIT_MAFIA_SEANCE))
		to_chat(source, span_notice("Only players participating in Mafia can speak to the Chaplain!"))
		return FALSE

	for(var/datum/mafia_role/mafia_role as anything in mafia_controller_board.all_roles)
		if(!HAS_TRAIT(mafia_role.body, TRAIT_MAFIA_SEANCE))
			continue
		var/mob/message_receiver = mafia_role.body
		if(!message_receiver.client)
			message_receiver = message_receiver.get_ghost()
		to_chat(message_receiver, span_changeling("<b>DEADCHAT - [source.name]:</b> [message]"))
