/// Accepts hydroponics trays whose plant health is below the seed's endurance threshold.
/datum/targeting_strategy/beamable_hydro

/datum/targeting_strategy/beamable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/obj/machinery/hydroponics/hydro = target
	if(!istype(hydro) || isnull(hydro.myseed))
		return FALSE
	return hydro.plant_health < hydro.myseed.endurance
