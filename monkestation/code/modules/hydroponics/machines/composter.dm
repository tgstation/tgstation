/obj/machinery/composters
	name = "NT-Brand Auto Composter"
	desc = "Just insert your bio degradable materials and it will produce compost."
	icon = 'monkestation/icons/obj/machines/composter.dmi'
	icon_state = "composter"
	density = TRUE

	//current biomatter level
	var/biomatter = 80

/obj/machinery/composters/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(istype(attacking_item, /obj/item/seeds))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/food))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/storage/bag)) // covers any kind of bag that has a compostible item
		var/obj/item/storage/bag/bag = attacking_item
		for(var/obj/item/food/item in bag.contents)
			if(bag.atom_storage.attempt_remove(item, src))
				compost(item)

		for(var/obj/item/seeds/item in bag.contents)
			if(bag.atom_storage.attempt_remove(item, src))
				compost(item)
		to_chat(user, span_info("You empty \the [bag] into \the [src]."))

/obj/machinery/gibber/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/machinery/composters/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(user.pulling && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(!iscarbon(L))
			to_chat(user, span_warning("This item is not suitable for [src]!"))
			return
		var/mob/living/carbon/C = L
		if(C.buckled || C.has_buckled_mobs())
			to_chat(user, span_warning("[C] is attached to something!"))
			return

		for(var/obj/item/I in C.held_items + C.get_equipped_items())
			if(!HAS_TRAIT(I, TRAIT_NODROP))
				to_chat(user, span_warning("Subject may not have abiotic items on!"))
				return

		user.visible_message(span_danger("[user] starts to put [C] into [src]!"))

		add_fingerprint(user)

		if(do_after(user, 80, target = src))
			if(C && user.pulling == C && !C.buckled && !C.has_buckled_mobs() && !occupant)
				user.visible_message(span_danger("[user] stuffs [C] into [src]!"))
				compost(C)

	if(biomatter < 40)
		to_chat(user, span_notice("Not enough biomatter to produce Bio-Cube"))
		return
	new /obj/item/bio_cube(get_turf(src))
	biomatter -= 40
	update_desc()
	update_appearance()

/obj/machinery/composters/update_desc()
	. = ..()
	desc = "Just insert your bio degradable materials and it will produce compost."
	desc += "\nBiomatter: [biomatter]"

/obj/machinery/composters/update_overlays()
	. = ..()
	if(biomatter < 40)
		. += mutable_appearance('monkestation/icons/obj/machines/composter.dmi', "light_off", layer = OBJ_LAYER + 0.01)
	else
		. += mutable_appearance('monkestation/icons/obj/machines/composter.dmi', "light_on", layer = OBJ_LAYER + 0.01)

/obj/machinery/composters/proc/compost(atom/composter)
	if(istype(composter, /obj/item/seeds))
		biomatter++
		qdel(composter)
	if(istype(composter, /obj/item/food))
		biomatter += 4
		qdel(composter)
	if(istype(composter, /mob/living/carbon))
		audible_message(span_hear("You hear a loud squelchy grinding sound."))
		playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)
		biomatter += 40
		qdel(composter)
	update_desc()
	update_appearance()
	flick("composter_animate", src)

/obj/item/seeds/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	// ensure user is next to what we're mouse dropping into
	if (!Adjacent(usr, over))
		return
	// ensure the stuff we're mouse dropping
	if(istype(over, /obj/machinery/composters) && Adjacent(src_location, over_location))
		var/obj/machinery/composters/dropped = over
		for(var/obj/item/seeds/seed in src_location)
			dropped.compost(seed)

/obj/item/food/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	// ensure user is next to what we're mouse dropping into
	if (!Adjacent(usr, over))
		return
	// ensure the stuff we're mouse dropping
	if(istype(over, /obj/machinery/composters) && Adjacent(src_location, over_location))
		var/obj/machinery/composters/dropped = over
		for(var/obj/item/food/food in src_location)
			dropped.compost(food)


/obj/item/bio_cube
	name = "Bio Cube"
	desc = "A cube made of pure biomatter does wonders on plant trays"
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state = "bio_cube"
	var/total_duration = 1 MINUTES

/obj/item/bio_cube/update_desc()
	. = ..()
	desc = "A cube made of pure biomatter, it seems to be denser than normal making it last [DisplayTimeText(total_duration)]. Does wonders on plant trays."

/obj/item/bio_cube/attackby(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(istype(attacking_item, /obj/item/bio_cube))
		var/obj/item/bio_cube/attacking_cube = attacking_item
		total_duration += attacking_cube.total_duration
		to_chat(user, span_notice("You smash the two bio cubes together, making a denser bio cube that lasts longer."))
		update_desc()
		qdel(attacking_cube)
