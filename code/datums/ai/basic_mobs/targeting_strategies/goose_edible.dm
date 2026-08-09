/// Accepts items that are edible or made of plastic. Used by goose eating.
/datum/targeting_strategy/goose_edible

/datum/targeting_strategy/goose_edible/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/thing = target
	if(!isitem(thing))
		return FALSE
	return IS_EDIBLE(thing) || thing.has_material_type(/datum/material/plastic)
