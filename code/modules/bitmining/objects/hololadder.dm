/obj/structure/hololadder
	name = "hololadder"

	anchored = TRUE
	desc = "An abstract representation of the means to disconnect from the virtual domain."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	obj_flags = BLOCK_Z_OUT_DOWN
	/// The connected netchair
	var/datum/weakref/netchair_ref
	/// Time req to disconnect properly
	var/travel_time = 3 SECONDS

/obj/structure/hololadder/Initialize(mapload, obj/structure/netchair/connected_netchair)
	. = ..()
	src.netchair_ref = WEAKREF(connected_netchair)

/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	var/obj/structure/netchair/hosting_chair = netchair_ref?.resolve()
	if(!hosting_chair) // Oh fuck
		balloon_alert(user, "not connected!")
		return

	balloon_alert(user, "disconnecting...")
	if(do_after(user, travel_time, src))
		hosting_chair.disconnect_occupant(user.mind)
