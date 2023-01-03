/obj/structure/fermenting_barrel
	name = "wooden barrel"
	desc = "A large wooden barrel. You can ferment fruits and such inside it, or just use it to hold reagents."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = FALSE
	pressure_resistance = 2 * ONE_ATMOSPHERE
	max_integrity = 300
	var/open = FALSE
	var/can_open = TRUE
	/// The amount of reagents that can be created from the contained products, used for validation
	var/potential_volume = 0
	/// Whether the fermentation is ongoing
	var/fermenting = FALSE
	/// The volume of the barrel sounds
	var/sound_volume = 25
	/// The sound of fermentation
	var/datum/looping_sound/boiling/soundloop
	var/lid_open_sound = 'sound/items/handling/cardboardbox_pickup.ogg'
	var/lid_close_sound = 'sound/effects/footstep/woodclaw2.ogg'

/obj/structure/fermenting_barrel/Initialize(mapload)
	. = ..()
	create_reagents(600, DRAINABLE)
	soundloop = new(src, fermenting)
	soundloop.volume = sound_volume

/obj/structure/fermenting_barrel/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/fermenting_barrel/examine(mob/user)
	. = ..()
	if(open)
		var/fruit_count = contents.len
		if(fruit_count)
			. += span_notice("It contains [fruit_count] fruit\s ready to be fermented.")
		. += span_notice("It is currently open, letting you fill it with fruits or reagents.")
	else
		. += span_notice("It is currently closed, letting it ferment fruits or draw reagents from its tap.")

/obj/structure/fermenting_barrel/attackby(obj/item/object, mob/user, params)
	if(open)
		if(istype(object, /obj/item/food/grown) && insert_fruit(user, object))
			balloon_alert(user, "added fruit")
			return
		if(istype(object, /obj/item/storage/bag/plants))
			var/obj/item/storage/bag/plants/bag = object
			var/inserted_fruits = 0
			for(var/obj/item/food/grown/fruit in bag.contents)
				if(!insert_fruit(user, fruit, bag))
					break
				inserted_fruits++
			if(inserted_fruits)
				balloon_alert(user, "added [inserted_fruits] fruit\s")
	else if(object.is_refillable())
		return //so we can refill them via their afterattack.
	return ..()

/obj/structure/fermenting_barrel/attack_hand(mob/user, list/modifiers)
	if(!can_open)
		return
	if(open)
		open = FALSE
		reagents.flags |= DRAINABLE
		reagents.flags &= ~(REFILLABLE | TRANSPARENT)
		playsound(src, lid_close_sound, sound_volume)
		start_fermentation()
	else
		open = TRUE
		reagents.flags &= ~(DRAINABLE)
		reagents.flags |= REFILLABLE | TRANSPARENT
		playsound(src, lid_open_sound, sound_volume)
		stop_fermentation()
	update_appearance(UPDATE_ICON)

/obj/structure/fermenting_barrel/update_icon_state()
	icon_state = open ? "barrel_open" : "barrel"
	return ..()

/// Adds the fruit to the barrel to queue the fermentation
/obj/structure/fermenting_barrel/proc/insert_fruit(mob/user, obj/item/food/grown/fruit, obj/item/storage/bag/plants/bag = null)
	if(reagents.total_volume + potential_volume > reagents.maximum_volume)
		balloon_alert(user, "it's full!")
		return FALSE
	if(!fruit.can_distill)
		balloon_alert(user, "can't ferment this!")
		return FALSE
	if(bag && !bag.atom_storage.attempt_remove(fruit, src))
		balloon_alert(user, "can't take from bag!")
		return FALSE
	else if (!user.transferItemToLoc(fruit, src))
		balloon_alert(user, "can't take fruit!")
		return FALSE
	potential_volume += fruit.reagents.total_volume
	return TRUE

/// Starts the fermentation process
/obj/structure/fermenting_barrel/proc/start_fermentation()
	if(fermenting)
		return
	if(open)
		return
	if(reagents.total_volume >= reagents.maximum_volume)
		return
	if(!(locate(/obj/item/food) in contents))
		return
	fermenting = TRUE
	soundloop.start()
	START_PROCESSING(SSobj, src)

/// Ferments the next found fruit into wine
/obj/structure/fermenting_barrel/proc/process_fermentation()
	if(!fermenting)
		return
	if(open)
		return stop_fermentation()
	if(reagents.total_volume >= reagents.maximum_volume)
		return stop_fermentation()
	var/obj/item/food/grown/fruit = locate(/obj/item/food/grown) in contents
	if(!fruit)
		return stop_fermentation()
	fruit.ferment()
	potential_volume -= fruit.reagents.total_volume
	fruit.reagents.trans_to(reagents, fruit.reagents.total_volume)
	qdel(fruit)

/// Stops the fermentation process
/obj/structure/fermenting_barrel/proc/stop_fermentation()
	fermenting = FALSE
	soundloop.stop()
	STOP_PROCESSING(SSobj, src)

/obj/structure/fermenting_barrel/process(delta_time)
	process_fermentation()

/// Lil gunpowder barrel fer pirates since it's a nice reagent holder
/obj/structure/fermenting_barrel/gunpowder
	name = "gunpowder barrel"
	desc = "A large wooden barrel for holding gunpowder. You'll need to take from this to load the cannons."
	can_open = FALSE

/obj/structure/fermenting_barrel/gunpowder/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/gunpowder, 500)
