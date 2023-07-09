/obj/structure/hololadder
	name = "hololadder"
	desc = "An abstract representation of disconnecting from the virtual domain."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN    //the ladder above this one
	var/crafted = FALSE
	/// The connected netchair
	var/obj/structure/netchair/connection
	/// travel time for ladder in deciseconds
	var/travel_time = 3 SECONDS

/obj/structure/hololadder/Initialize(mapload, obj/structure/netchair/connection)
	. = ..()
	src.connection = connection

	return INITIALIZE_HINT_LATELOAD

/obj/structure/hololadder/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	use(user)

/obj/structure/hololadder/proc/use(mob/user)
	if(!in_range(src, user) || DOING_INTERACTION(user, DOAFTER_SOURCE_CLIMBING_LADDER))
		return

	if(!connection) // Oh fuck
		balloon_alert(user, "This ladder isn't connected to anything!")

	balloon_alert(user, "Disconnecting...")
	var/mob/living/carbon/human/neo = connection.voidrunner.resolve()

	if(!neo)
		balloon_alert(user, "Your mortal connection has been severed!")

	if(do_after(user, travel_time, src))
		user.mind.transfer_to(neo)


