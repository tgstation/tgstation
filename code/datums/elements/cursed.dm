/**
 * # cursed element!
 *
 *Attaching this element to something will make it float, and get a special ai controller!
 */
/datum/element/cursed

/datum/element/cursed/Attach(datum/target, slot)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/master = target
	var/datum/ai_controller/ai = new /datum/ai_controller/cursed(master)
	ai.blackboard[BB_TARGET_SLOT] = slot
	master.ai_controller = ai
	master.AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(master, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))

/datum/element/cursed/Detach(datum/source)
	. = ..()
	var/obj/item/master = source
	QDEL_NULL(master.ai_controller)
	REMOVE_TRAIT(master, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))
	master.RemoveElement(/datum/element/movetype_handler)
