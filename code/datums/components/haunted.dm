/datum/component/haunted

/datum/component/haunted/Initialize(_strength=0, _source, _half_life=RAD_HALF_LIFE, _can_contaminate=TRUE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	//Make em look spooky
	var/obj/item/master = parent
	master.add_filter("haunt_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))
	master.ai_controller = new /datum/ai_controller/haunted(master)
	master.float(TRUE)

/datum/component/haunted/Destroy()
	var/atom/movable/master = parent
	master.remove_filter("haunt_glow")
	QDEL_NULL(master.ai_controller)
	master.float(FALSE)
	return ..()


