///Attaching this element to something will make it float, get a special ai controller, and gives it a spooky outline.
/datum/element/haunted

/datum/element/haunted/Attach(datum/target, haunt_color = "#f8f8ff")
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/master = target
	if(istype(master.ai_controller, /datum/ai_controller/haunted))
		return ELEMENT_INCOMPATIBLE

	//Make em look spooky
	master.add_filter("haunt_glow", 2, list("type" = "outline", "color" = haunt_color, "size" = 1))
	master.ai_controller = new /datum/ai_controller/haunted(master)
	master.AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(master, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))

/datum/element/haunted/Detach(datum/source)
	. = ..()
	var/atom/movable/master = source
	master.remove_filter("haunt_glow")
	QDEL_NULL(master.ai_controller)
	REMOVE_TRAIT(master, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))
	master.RemoveElement(/datum/element/movetype_handler)
	return ..()

/**
 * Takes a given area and chance, applying the haunted_item component to objects in the area.
 *
 * Takes an epicenter, and within the range around it, runs a haunt_chance percent chance of
 * applying the haunted_item component to nearby objects.
 *
 * * epicenter - The center of the outburst area.
 * * range - The range of the outburst, centered around the epicenter.
 * * haunt_chance - The percent chance that an object caught in the epicenter will be haunted.
 */

/proc/haunt_outburst(epicenter, range, haunt_chance, duration = 1 MINUTES)
	var/effect_area = range(range, epicenter)
	for(var/obj/item/object_to_possess in effect_area)
		if(!prob(haunt_chance))
			continue
		object_to_possess.AddComponent(/datum/component/haunted_item, \
			haunt_color = "#52336e", \
			haunt_duration = duration, \
			aggro_radius = range, \
			spawn_message = span_revenwarning("[object_to_possess] slowly rises upward, hanging menacingly in the air..."), \
			despawn_message = span_revenwarning("[object_to_possess] settles to the floor, lifeless and unmoving."), \
		)
