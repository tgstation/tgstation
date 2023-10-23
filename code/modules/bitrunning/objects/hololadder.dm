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

/// If there's a pilot ref- send the disconnect signal
/obj/structure/hololadder/proc/disconnect(mob/user)
	if(isnull(user.mind))
		return

	if(!HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		balloon_alert(user, "no connection detected.")
		return

	balloon_alert(user, "disconnecting...")
	if(do_after(user, travel_time, src))
		SEND_SIGNAL(user, COMSIG_BITRUNNER_LADDER_SEVER)

/// Helper for times when you dont have hands (gondola??)
/obj/structure/hololadder/proc/on_enter(datum/source, atom/movable/arrived, turf/old_loc)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	var/mob/living/user = arrived
	if(isnull(user.mind))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), user)
