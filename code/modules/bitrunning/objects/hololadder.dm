/obj/structure/hololadder
	name = "hololadder"

	anchored = TRUE
	desc = "An abstract representation of the means to disconnect from the virtual domain."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	obj_flags = BLOCK_Z_OUT_DOWN
	/// Time req to disconnect properly
	var/travel_time = 3 SECONDS
	/// Uses this to teleport observers back to the origin server
	var/datum/weakref/server_ref


/obj/structure/hololadder/Initialize(mapload, obj/machinery/quantum_server/origin)
	. = ..()

	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))
	server_ref = WEAKREF(origin)
	register_context()


/obj/structure/hololadder/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_LMB] = "Disconnect"


/obj/structure/hololadder/examine(mob/user)
	. = ..()

	if(isnull(server_ref.resolve()))
		. += span_infoplain("It's not connected to anything.")
		return

	if(isobserver(user))
		. += span_notice("Left click to view the server that this ladder is connected to.")
		return

	. += span_infoplain("This ladder is connected to a server. You can click on it or walk over it to disconnect.")


/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	disconnect(user)


/obj/structure/hololadder/attack_ghost(mob/dead/observer/ghostie)
	var/our_server = server_ref?.resolve()
	if(isnull(our_server))
		return ..()

	ghostie.abstract_move(get_turf(our_server))


/// If there's a pilot ref- send the disconnect signal
/obj/structure/hololadder/proc/disconnect(mob/user)
	if(isnull(user.mind))
		return

	if(!HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		balloon_alert(user, "no connection detected")
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
