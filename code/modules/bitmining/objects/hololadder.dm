/obj/structure/hololadder
	name = "hololadder"

	anchored = TRUE
	desc = "An abstract representation of the means to disconnect from the virtual domain."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	obj_flags = BLOCK_Z_OUT_DOWN
	/// The connected netchair
	var/obj/structure/netchair/connected_netchair
	/// Time req to disconnect properly
	var/travel_time = 3 SECONDS

/obj/structure/hololadder/Initialize(mapload, obj/structure/netchair/connected_netchair)
	. = ..()
	src.connected_netchair = connected_netchair

/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	if(!connected_netchair) // Oh fuck
		balloon_alert(user, "not connected!")
		return

	var/mob/living/carbon/human/avatar/this_avatar = user
	if(!isavatar(this_avatar))
		balloon_alert(user, "improper serial port!")
		return

	var/mob/living/carbon/human/pilot = this_avatar.pilot
	if(!pilot)
		balloon_alert(user, "connection severed!")
		return

	balloon_alert(user, "disconnecting...")
	if(do_after(user, travel_time, src))
		this_avatar.disconnect()
