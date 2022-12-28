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
