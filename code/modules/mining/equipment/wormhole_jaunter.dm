/**********************Jaunter**********************/
/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = SLOT_BELT

/obj/item/device/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
	SSblackbox.add_details("jaunter", "User") // user activated
	activate(user)

/obj/item/device/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf || device_turf.z == ZLEVEL_CENTCOM || device_turf.z == ZLEVEL_TRANSIT)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/device/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	if(isgolem(user))
		for(var/obj/item/device/radio/beacon/B in GLOB.teleportbeacons)
			var/turf/T = get_turf(B)
			if(istype(T.loc, /area/ruin/powered/golem_ship))
				destinations += B

	// In the event golem beacon is destroyed, send to station instead
	if(destinations.len)
		return destinations

	for(var/obj/item/device/radio/beacon/B in GLOB.teleportbeacons)
		var/turf/T = get_turf(B)
		if(T.z in GLOB.station_z_levels)
			destinations += B

	return destinations

/obj/item/device/wormhole_jaunter/proc/activate(mob/user)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		to_chat(user, "<span class='notice'>The [src.name] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/wormhole/jaunt_tunnel/J = new (get_turf(src), src, 100, null, FALSE, get_turf(chosen_beacon))
	try_move_adjacent(J)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/device/wormhole_jaunter/emp_act(power)
	var/triggered = FALSE

	if(usr.get_item_by_slot(slot_belt) == src)
		if(power == 1)
			triggered = TRUE
		else if(power == 2 && prob(50))
			triggered = TRUE

	if(triggered)
		usr.visible_message("<span class='warning'>The [src] overloads and activates!</span>")
		SSblackbox.add_details("jaunter","EMP") // EMP accidental activation
		activate(usr)

/obj/item/device/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(slot_belt) == src)
		to_chat(user, "Your [src] activates, saving you from the chasm!</span>")
		SSblackbox.add_details("jaunter","Chasm") // chasm automatic activation
		activate(user)
	else
		to_chat(user, "The [src] is not attached to your belt, preventing it from saving you from the chasm. RIP.</span>")

//jaunter tunnel
/obj/effect/portal/wormhole/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."
	mech_sized = TRUE //save your ripley

/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(!ismob(M) && !isobj(M))	//No don't teleport lighting and effects!
		return

	if(M.anchored && (!ismob(M) || (istype(M, /obj/mecha) && !mech_sized)))
		return

	if(do_teleport(M, hard_target, 6))
		// KERPLUNK
		playsound(M,'sound/weapons/resonator_blast.ogg',50,1)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			L.Knockdown(60)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, /mob/living/carbon.proc/vomit), 20)
