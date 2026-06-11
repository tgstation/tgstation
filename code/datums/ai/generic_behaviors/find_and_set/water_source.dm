/// Finds a nearby sink or reagent dispenser that contains water.
/datum/bt_node/ai_behavior/find_and_set/suitable_water_dispenser

/datum/bt_node/ai_behavior/find_and_set/suitable_water_dispenser/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	for(var/atom/movable/dispenser in oview(search_range, controller.pawn))
		if(!istype(dispenser, /obj/structure/sink) && !istype(dispenser, /obj/structure/reagent_dispensers))
			continue
		if(!dispenser.reagents || !(locate(/datum/reagent/water) in dispenser.reagents.reagent_list))
			continue
		if(can_see(controller.pawn, dispenser, search_range))
			return dispenser
