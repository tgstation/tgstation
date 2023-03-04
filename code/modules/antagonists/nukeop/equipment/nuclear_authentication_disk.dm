/obj/item/disk
	icon = 'icons/obj/module.dmi'
	w_class = WEIGHT_CLASS_TINY
	inhand_icon_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	icon_state = "datadisk0"
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'

// DAT FUKKEN DISK.
/obj/item/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	max_integrity = 250
	armor_type = /datum/armor/disk_nuclear
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Whether we're a real nuke disk or not.
	var/fake = FALSE

/datum/armor/disk_nuclear
	bomb = 30
	fire = 100
	acid = 100

/obj/item/disk/nuclear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bed_tuckable, 6, -6, 0)
	AddComponent(/datum/component/stationloving, !fake)

	if(!fake)
		AddComponent(/datum/component/keep_me_secure, CALLBACK(src, PROC_REF(secured_process)), CALLBACK(src, PROC_REF(unsecured_process)))
		SSpoints_of_interest.make_point_of_interest(src)

/obj/item/disk/nuclear/proc/secured_process(last_move)
	var/turf/new_turf = get_turf(src)
	var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
	if(istype(loneop) && loneop.occurrences < loneop.max_occurrences && prob(loneop.weight))
		loneop.weight = max(loneop.weight - 1, 0)
		if(loneop.weight % 5 == 0 && SSticker.totalPlayers > 1)
			message_admins("[src] is secured (currently in [ADMIN_VERBOSEJMP(new_turf)]). The weight of Lone Operative is now [loneop.weight].")
		log_game("[src] being secured has reduced the weight of the Lone Operative event to [loneop.weight].")

/obj/item/disk/nuclear/proc/unsecured_process(last_move)
	var/turf/new_turf = get_turf(src)
	/// How comfy is our disk?
	var/disk_comfort_level = 0

	//Go through and check for items that make disk comfy
	for(var/obj/comfort_item in loc)
		if(istype(comfort_item, /obj/item/bedsheet) || istype(comfort_item, /obj/structure/bed))
			disk_comfort_level++

	if(last_move < world.time - 500 SECONDS && prob((world.time - 500 SECONDS - last_move)*0.0001))
		var/datum/round_event_control/operative/loneop = locate(/datum/round_event_control/operative) in SSevents.control
		if(istype(loneop) && loneop.occurrences < loneop.max_occurrences)
			loneop.weight += 1
			if(loneop.weight % 5 == 0 && SSticker.totalPlayers > 1)
				if(disk_comfort_level >= 2)
					visible_message(span_notice("[src] sleeps soundly. Sleep tight, disky."))
				message_admins("[src] is unsecured in [ADMIN_VERBOSEJMP(new_turf)]. The weight of Lone Operative is now [loneop.weight].")
			log_game("[src] was left unsecured in [loc_name(new_turf)]. Weight of the Lone Operative event increased to [loneop.weight].")

/obj/item/disk/nuclear/examine(mob/user)
	. = ..()
	if(!fake)
		return

	if(isobserver(user) || HAS_TRAIT(user, TRAIT_DISK_VERIFIER) || (user.mind && HAS_TRAIT(user.mind, TRAIT_DISK_VERIFIER)))
		. += span_warning("The serial numbers on [src] are incorrect.")

/*
 * You can't accidentally eat the nuke disk, bro
 */
/obj/item/disk/nuclear/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	M.visible_message(span_warning("[M] looks like [M.p_theyve()] just bitten into something important."), \
						span_warning("Wait, is this the nuke disk?"))

	return discover_after

/obj/item/disk/nuclear/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/claymore/highlander) && !fake)
		var/obj/item/claymore/highlander/claymore = weapon
		if(claymore.nuke_disk)
			to_chat(user, span_notice("Wait... what?"))
			qdel(claymore.nuke_disk)
			claymore.nuke_disk = null
			return

		user.visible_message(
			span_warning("[user] captures [src]!"),
			span_userdanger("You've got the disk! Defend it with your life!"),
		)
		forceMove(claymore)
		claymore.nuke_disk = src
		return TRUE

	return ..()

/obj/item/disk/nuclear/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is going delta! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/machines/alarm.ogg', 50, -1, TRUE)
	for(var/i in 1 to 100)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, add_atom_colour), (i % 2)? "#00FF00" : "#FF0000", ADMIN_COLOUR_PRIORITY), i)
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 101)
	return MANUAL_SUICIDE

/obj/item/disk/nuclear/proc/manual_suicide(mob/living/user)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
	user.visible_message(span_suicide("[user] is destroyed by the nuclear blast!"))
	user.adjustOxyLoss(200)
	user.death(FALSE)

/obj/item/disk/nuclear/fake
	fake = TRUE

/obj/item/disk/nuclear/fake/obvious
	name = "cheap plastic imitation of the nuclear authentication disk"
	desc = "How anyone could mistake this for the real thing is beyond you."
