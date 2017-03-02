////////////////////////////////////////
//Singularity beacon
////////////////////////////////////////
/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon"

	anchored = 0
	density = 1
	layer = BELOW_MOB_LAYER //so people can't hide it and it's REALLY OBVIOUS
	stat = 0

	var/active = 0
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(surplus() < 1500)
		if(user) user << "<span class='notice'>The connected wire doesn't have enough current.</span>"
		return
	for(var/obj/singularity/singulo in world)
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = 1
	machines |= src
	if(user)
		user << "<span class='notice'>You activate the beacon.</span>"


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/obj/singularity/singulo in world)
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = 0
	if(user)
		user << "<span class='notice'>You deactivate the beacon.</span>"


/obj/machinery/power/singularity_beacon/attack_ai(mob/user)
	return


/obj/machinery/power/singularity_beacon/attack_hand(mob/user)
	if(anchored)
		return active ? Deactivate(user) : Activate(user)
	else
		user << "<span class='warning'>You need to screw the beacon to the floor first!</span>"
		return


/obj/machinery/power/singularity_beacon/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/screwdriver))
		if(active)
			user << "<span class='warning'>You need to deactivate the beacon first!</span>"
			return

		if(anchored)
			anchored = 0
			user << "<span class='notice'>You unscrew the beacon from the floor.</span>"
			disconnect_from_network()
			return
		else
			if(!connect_to_network())
				user << "<span class='warning'>This device must be placed over an exposed, powered cable node!</span>"
				return
			anchored = 1
			user << "<span class='notice'>You screw the beacon to the floor and attach the cable.</span>"
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
		return PROCESS_KILL
	else
		if(surplus() > 1500)
			add_load(1500)
		else
			Deactivate()


/obj/machinery/power/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"

// SINGULO BEACON SPAWNER
/obj/item/device/sbeacondrop
	name = "suspicious beacon"
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a special beacon to your location</i>."
	origin_tech = "bluespace=6;syndicate=5"
	w_class = WEIGHT_CLASS_SMALL
	var/droptype = /obj/machinery/power/singularity_beacon/syndicate


/obj/item/device/sbeacondrop/attack_self(mob/user)
	if(user)
		user << "<span class='notice'>Locked In.</span>"
		new droptype( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/device/sbeacondrop/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb
	origin_tech = "bluespace=5;syndicate=5"

/obj/item/device/sbeacondrop/powersink
	desc = "A label on it reads: <i>Warning: Activating this device will send a power draining device to your location</i>."
	droptype = /obj/item/device/powersink
	origin_tech = "bluespace=4;syndicate=5"
