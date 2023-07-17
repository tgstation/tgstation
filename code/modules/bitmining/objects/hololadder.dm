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
	balloon_alert(user, "disconnecting...")
	if(do_after(user, travel_time, src))
		user.mind.disconnect_avatar()

/obj/structure/hololadder/proc/on_enter(datum/source, atom/movable/arrived as mob|obj, turf/old_loc)
	SIGNAL_HANDLER

	if(!isliving(arrived) || isnull(old_loc))
		return

	var/mob/living/thing = arrived
	if(isnull(thing.mind))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), thing)
