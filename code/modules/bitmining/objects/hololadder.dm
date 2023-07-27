/**
 * ### Hololadder
 * Provides a way for players to reconnect with their physical bodies.
 */
/obj/structure/hololadder
	name = "hololadder"

	anchored = TRUE
	desc = "An abstract representation of the means to disconnect from the virtual domain."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	obj_flags = BLOCK_Z_OUT_DOWN
	/// Time req to disconnect properly
	var/travel_time = 3 SECONDS

/obj/structure/hololadder/Initialize(mapload)
	. = ..()

	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))

/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	disconnect(user)

/obj/structure/hololadder/proc/disconnect(mob/user)
	if(isnull(user.mind))
		return

	var/datum/mind/mob_mind = user.mind
	if(isnull(mob_mind.pilot_ref))
		balloon_alert(user, "no connection detected.")
		return

	balloon_alert(user, "disconnecting...")
	if(do_after(user, travel_time, src))
		SEND_SIGNAL(mob_mind, COMSIG_BITMINING_SEVER_AVATAR)

/obj/structure/hololadder/proc/on_enter(datum/source, atom/movable/arrived, turf/old_loc)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	var/mob/living/user = arrived
	if(isnull(user.mind))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), user)
