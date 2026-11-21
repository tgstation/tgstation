/// Accepts hydroponics trays that need watering (if pawn holds a watering can) or weeding/dead plant removal.
/// Reads thresholds from the controller blackboard.
/datum/targeting_strategy/treatable_hydro

/datum/targeting_strategy/treatable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/hydroponics/hydro = target
	if(!istype(hydro) || isnull(hydro.myseed))
		return FALSE
	if(!controller)
		return FALSE
	var/waterlevel_threshold = controller.blackboard[BB_WATERLEVEL_THRESHOLD]
	var/weedlevel_threshold = controller.blackboard[BB_WEEDLEVEL_THRESHOLD]
	if(hydro.waterlevel < waterlevel_threshold)
		if(locate(/obj/item/reagent_containers/cup/watering_can) in living_mob)
			return TRUE
	return hydro.weedlevel > weedlevel_threshold || hydro.plant_status == HYDROTRAY_PLANT_DEAD
