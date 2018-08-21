////////////////////////////////////////
//Singularity beacon
////////////////////////////////////////
/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon0"

	anchored = FALSE
	density = TRUE
	layer = BELOW_MOB_LAYER //so people can't hide it and it's REALLY OBVIOUS
	stat = 0
	verb_say = "states"
	var/cooldown = 0

	var/active = 0
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(surplus() < 1500)
		if(user)
			to_chat(user, "<span class='notice'>The connected wire doesn't have enough current.</span>")
		return
	for(var/obj/singularity/singulo in GLOB.singularities)
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	if(user)
		to_chat(user, "<span class='notice'>You activate the beacon.</span>")


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/obj/singularity/singulo in GLOB.singularities)
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	if(user)
		to_chat(user, "<span class='notice'>You deactivate the beacon.</span>")


/obj/machinery/power/singularity_beacon/attack_ai(mob/user)
	return


/obj/machinery/power/singularity_beacon/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(anchored)
		return active ? Deactivate(user) : Activate(user)
	else
		to_chat(user, "<span class='warning'>You need to screw the beacon to the floor first!</span>")

/obj/machinery/power/singularity_beacon/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver))
		if(active)
			to_chat(user, "<span class='warning'>You need to deactivate the beacon first!</span>")
			return

		if(anchored)
			setAnchored(FALSE)
			to_chat(user, "<span class='notice'>You unscrew the beacon from the floor.</span>")
			disconnect_from_network()
			return
		else
			if(!connect_to_network())
				to_chat(user, "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>")
				return
			setAnchored(TRUE)
			to_chat(user, "<span class='notice'>You screw the beacon to the floor and attach the cable.</span>")
			return
	else
		return ..()

/obj/machinery/power/singularity_beacon/Destroy()
	if(active)
		Deactivate()
	return ..()

//stealth direct power usage
/obj/machinery/power/singularity_beacon/process()
	if(!active)
		return

	if(surplus() > 1500)
		add_load(1500)
		if(cooldown <= world.time)
			cooldown = world.time + 80
			for(var/obj/singularity/singulo in GLOB.singularities)
				if(singulo.z == z)
					say("[singulo] is now [get_dist(src,singulo)] standard lengths away to the [dir2text(get_dir(src,singulo))]")
	else
		Deactivate()
		say("Insufficient charge detected - powering down")


/obj/machinery/power/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"

// SINGULO BEACON SPAWNER
/obj/item/sbeacondrop
	name = "suspicious beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	desc = "A label on it reads: <i>Warning: Activating this device will send a special beacon to your location</i>."
	w_class = WEIGHT_CLASS_SMALL
	var/droptype = /obj/machinery/power/singularity_beacon/syndicate


/obj/item/sbeacondrop/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In.</span>")
		new droptype( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/sbeacondrop/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb

/obj/item/sbeacondrop/powersink
	desc = "A label on it reads: <i>Warning: Activating this device will send a power draining device to your location</i>."
	droptype = /obj/item/powersink

/obj/item/sbeacondrop/clownbomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a silly explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb/badmin/clown
