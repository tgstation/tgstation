/// Gathers held items matching a fixed typepath.
/datum/target_source/held_items_typed
	abstract_type = /datum/target_source/held_items_typed
	
	var/locate_typepath

/datum/target_source/held_items_typed/collect_candidates(mob/living/pawn, datum/ai_controller/controller, range)
	return pawn.get_held_items_of_type(locate_typepath)

/datum/target_source/held_items_typed/instrument
	locate_typepath = /obj/item/instrument
