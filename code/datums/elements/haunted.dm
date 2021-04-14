///Attaching this element to something will make it float, get a special ai controller, and gives it a spooky outline.
/datum/element/haunted
	element_flags = ELEMENT_DETACH

/datum/element/haunted/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	//Make em look spooky
	var/obj/item/master = target
	master.add_filter("haunt_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))
	master.ai_controller = new /datum/ai_controller/haunted(master)
	master.AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(master, TRAIT_MOVE_FLYING, ELEMENT_TRAIT)

/datum/element/haunted/Detach(datum/source, force)
	. = ..()
	var/atom/movable/master = source
	master.remove_filter("haunt_glow")
	QDEL_NULL(master.ai_controller)
	REMOVE_TRAIT(master, TRAIT_MOVE_FLYING, ELEMENT_TRAIT)
	master.RemoveElement(/datum/element/movetype_handler)
	return ..()


