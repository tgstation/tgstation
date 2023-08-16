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

	if(istype(attacking_item, /obj/item/food/grown))
		compost(attacking_item)

	if(istype(attacking_item, /obj/item/storage/bag)) // covers any kind of bag that has a compostible item
		var/obj/item/storage/bag/bag = attacking_item
		for(var/obj/item/food/grown/item in bag.contents)
			if(bag.atom_storage.attempt_remove(item, src))
				compost(item)

		for(var/obj/item/seeds/item in bag.contents)
			if(bag.atom_storage.attempt_remove(item, src))
				compost(item)
		to_chat(user, span_info("You empty \the [bag] into \the [src]."))

/obj/machinery/composters/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(biomatter < 40)
		to_chat(user, span_notice("Not enough biomatter to produce Bio-Cube"))
		return
	new /obj/item/bio_cube(get_turf(src))
	biomatter -= 40

/obj/machinery/composters/update_desc()
	. = ..()
	desc = "Just insert your bio degradable materials and it will produce compost."
	desc += "\nBiomatter: [biomatter]"

/obj/machinery/composters/proc/compost(atom/composter)
	if(istype(composter, /obj/item/seeds))
		biomatter++
		qdel(composter)
	if(istype(composter, /obj/item/food/grown))
		biomatter += 4
		qdel(composter)
	update_desc()

/obj/item/seeds/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(istype(over, /obj/machinery/composters))
		var/obj/machinery/composters/dropped = over
		for(var/obj/item/seeds/seed in src_location)
			dropped.compost(seed)

/obj/item/food/grown/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(istype(over, /obj/machinery/composters))
		var/obj/machinery/composters/dropped = over
		for(var/obj/item/food/grown/grown in src_location)
			dropped.compost(grown)


/obj/item/bio_cube
	name = "Bio Cube"
	desc = "A cube made of pure biomatter does wonders on plant trays"
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state = "bio_cube"

	var/total_duration = 60 SECONDS
	var/scale_multiplier = 0.6


/obj/item/bio_cube/update_desc()
	. = ..()
	desc = "A cube made of pure biomatter, it seems to be bigger than normal making it last [total_duration / 600] minutes. Does wonders on plant trays."

/obj/item/bio_cube/attackby(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(istype(attacking_item, /obj/item/bio_cube))
		var/obj/item/bio_cube/attacking_cube = attacking_item
		scale_multiplier += (attacking_cube.scale_multiplier - 0.5)
		total_duration += attacking_cube.total_duration
		to_chat(user, span_notice("You smash the two bio cubes together making a bigger bio cube that lasts longer."))
		update_desc()
		transform = transform.Scale(scale_multiplier, scale_multiplier)
		qdel(attacking_cube)
