/obj/structure/hololadder
	name = "hololadder"
	desc = "An abstract representation of disconnecting from the virtual domain."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	obj_flags = BLOCK_Z_OUT_DOWN
	/// The connected netchair
	var/obj/structure/netchair/connection
	/// Travel time to disconnect properly
	var/travel_time = 3 SECONDS

/obj/structure/hololadder/Initialize(mapload, obj/structure/netchair/connection)
	. = ..()
	src.connection = connection

/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	escape(user)

/// Attempts to unplug the user by putting their mind back in their body.
/obj/structure/hololadder/proc/escape(mob/user)
	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	if(!connection) // Oh fuck
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

	var/mob/living/carbon/human/occupant = connection.bitminer_ref?.resolve()
	if(pilot != occupant)
		balloon_alert(user, "mismatched pilot ID!")
		return

	balloon_alert(user, "disconnecting...")
	if(do_after(user, travel_time, src))
		this_avatar.disconnect()

	qdel(src)
