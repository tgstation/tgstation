/// Finds a nearby hydroponics tray that needs watering or weeding/dead plant removal.
/// Checks BB_WATERLEVEL_THRESHOLD (water below threshold, only if holding a watering can)
/// and BB_WEEDLEVEL_THRESHOLD / dead plants (always). Sets set_key on success.
/datum/bt_node/ai_behavior/find_and_set/treatable_hydro
	time_between_perform = 5 SECONDS
	set_key = BB_HYDROPLANT_TARGET

/datum/bt_node/ai_behavior/find_and_set/treatable_hydro/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/possible_trays = list()
	var/mob/living/living_pawn = controller.pawn
	var/waterlevel_threshold = controller.blackboard[BB_WATERLEVEL_THRESHOLD]
	var/weedlevel_threshold = controller.blackboard[BB_WEEDLEVEL_THRESHOLD]
	var/watering_can = locate(/obj/item/reagent_containers/cup/watering_can) in living_pawn

	for(var/obj/machinery/hydroponics/hydro in oview(search_range, controller.pawn))
		if(isnull(hydro.myseed))
			continue
		if(hydro.waterlevel < waterlevel_threshold && watering_can)
			possible_trays += hydro
			continue
		if(hydro.weedlevel > weedlevel_threshold || hydro.plant_status == HYDROTRAY_PLANT_DEAD)
			possible_trays += hydro
			continue

	if(possible_trays.len)
		return pick(possible_trays)

/// Finds a nearby hydroponics tray whose plant health is below its endurance threshold.
/// Used to pick targets for the solar beam ability.
/datum/bt_node/ai_behavior/find_and_set/beamable_hydroplants
	time_between_perform = 15 SECONDS
	set_key = BB_BEAMABLE_HYDROPLANT_TARGET

/datum/bt_node/ai_behavior/find_and_set/beamable_hydroplants/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/possible_trays = list()

	for(var/obj/machinery/hydroponics/hydro in oview(search_range, controller.pawn))
		if(isnull(hydro.myseed))
			continue
		if(hydro.plant_health < hydro.myseed.endurance)
			possible_trays += hydro

	if(possible_trays.len)
		return pick(possible_trays)
