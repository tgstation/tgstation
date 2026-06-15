/// Accepts sinks or reagent dispensers that contain water and are visible to the pawn.
/datum/targeting_strategy/water_dispenser

/datum/targeting_strategy/water_dispenser/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/atom/movable/dispenser = target
	if(!istype(dispenser, /obj/structure/sink) && !istype(dispenser, /obj/structure/reagent_dispensers))
		return FALSE
	if(!dispenser.reagents || !(locate(/datum/reagent/water) in dispenser.reagents.reagent_list))
		return FALSE
	return can_see(living_mob, dispenser, vision_range)
