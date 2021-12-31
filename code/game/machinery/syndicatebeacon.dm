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
	verb_say = "states"
	var/cooldown = 0

	var/active = FALSE
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(surplus() < 1500)
		if(user)
			to_chat(user, span_notice("The connected wire doesn't have enough current."))
		return
	for (var/_singulo in GLOB.singularities)
		var/datum/component/singularity/singulo = _singulo
		var/atom/singulo_atom = singulo.parent
		if(singulo_atom.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = TRUE
	if(user)
		to_chat(user, span_notice("You activate the beacon."))


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/_singulo in GLOB.singularities)
		var/datum/component/singularity/singulo = _singulo
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = FALSE
	if(user)
		to_chat(user, span_notice("You deactivate the beacon."))


/obj/machinery/power/singularity_beacon/attack_ai(mob/user)
	return


/obj/machinery/power/singularity_beacon/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(anchored)
		return active ? Deactivate(user) : Activate(user)
	else
		to_chat(user, span_warning("You need to screw \the [src] to the floor first!"))

/obj/machinery/power/singularity_beacon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		if(active)
			to_chat(user, span_warning("You need to deactivate \the [src] first!"))
			return

		if(anchored)
			set_anchored(FALSE)
			to_chat(user, span_notice("You unbolt \the [src] from the floor and detach it from the cable."))
			disconnect_from_network()
			return
		else
			if(!connect_to_network())
				to_chat(user, span_warning("\The [src] must be placed over an exposed, powered cable node!"))
				return
			set_anchored(TRUE)
			to_chat(user, span_notice("You bolt \the [src] to the floor and attach it to the cable."))
			return
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		user.visible_message( \
			"[user] messes with \the [src] for a bit.", \
			span_notice("You can't fit the screwdriver into \the [src]'s bolts! Try using a wrench."))
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

	if(surplus() >= 1500)
		add_load(1500)
		if(cooldown <= world.time)
			cooldown = world.time + 80
			for(var/_singulo_component in GLOB.singularities)
				var/datum/component/singularity/singulo_component = _singulo_component
				var/atom/singulo = singulo_component.parent
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
	atom_size = ITEM_SIZE_SMALL
	var/droptype = /obj/machinery/power/singularity_beacon/syndicate


/obj/item/sbeacondrop/attack_self(mob/user)
	if(user)
		to_chat(user, span_notice("Locked In."))
		new droptype( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, TRUE)
		qdel(src)
	return

/obj/item/sbeacondrop/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb

/obj/item/sbeacondrop/emp
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-powered electromagnetic device to your location</i>."
	droptype = /obj/machinery/syndicatebomb/emp

/obj/item/sbeacondrop/powersink
	desc = "A label on it reads: <i>Warning: Activating this device will send a power draining device to your location</i>."
	droptype = /obj/item/powersink

/obj/item/sbeacondrop/clownbomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a silly explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb/badmin/clown
