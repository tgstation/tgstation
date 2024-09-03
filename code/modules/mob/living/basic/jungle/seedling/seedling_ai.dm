/datum/ai_controller/basic_controller/seedling
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_WEEDLEVEL_THRESHOLD = 3,
		BB_WATERLEVEL_THRESHOLD = 90,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/watering_can,
		/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan,
		/datum/ai_planning_subtree/find_and_hunt_target/treat_hydroplants,
		/datum/ai_planning_subtree/find_and_hunt_target/beamable_hydroplants,
	)

/datum/ai_planning_subtree/find_and_hunt_target/watering_can
	target_key = BB_WATERCAN_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target
	hunt_targets = list(/obj/item/reagent_containers/cup/watering_can)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/watering_can/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(locate(/obj/item/reagent_containers/cup/watering_can) in living_pawn) //we already have what we came for!
		return
	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/treat_hydroplants
	target_key = BB_HYDROPLANT_TARGET
	finding_behavior = /datum/ai_behavior/find_and_set/treatable_hydro
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/treat_hydroplant
	hunt_targets = list(/obj/machinery/hydroponics)
	hunt_range = 7

/datum/ai_behavior/find_and_set/treatable_hydro

/datum/ai_behavior/find_and_set/treatable_hydro/search_tactic(datum/ai_controller/controller, locate_path, search_range)
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

/datum/ai_behavior/hunt_target/interact_with_target/treat_hydroplant
	hunt_cooldown = 2 SECONDS
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/interact_with_target/treat_hydroplant/target_caught(mob/living/living_pawn, obj/machinery/hydroponics/hydro_target)
	if(QDELETED(hydro_target) || QDELETED(hydro_target.myseed))
		return

	if(hydro_target.plant_status == HYDROTRAY_PLANT_DEAD)
		living_pawn.manual_emote("weeps...") //weep over the dead plants
	return ..()


/datum/ai_planning_subtree/find_and_hunt_target/beamable_hydroplants
	target_key = BB_BEAMABLE_HYDROPLANT_TARGET
	finding_behavior = /datum/ai_behavior/find_and_set/beamable_hydroplants
	hunting_behavior = /datum/ai_behavior/hunt_target/use_ability_on_target/solarbeam
	hunt_targets = list(/obj/machinery/hydroponics)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/beamable_hydroplants/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/solar_ability = controller.blackboard[BB_SOLARBEAM_ABILITY]
	if(QDELETED(solar_ability) || !solar_ability.IsAvailable())
		return
	return ..()

/datum/ai_behavior/hunt_target/use_ability_on_target/solarbeam
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 2
	action_cooldown = 1 MINUTES
	ability_key = BB_SOLARBEAM_ABILITY

/datum/ai_behavior/hunt_target/use_ability_on_target/solarbeam/setup(datum/ai_controller/controller, target_key, ability_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/find_and_set/beamable_hydroplants/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/possible_trays = list()

	for(var/obj/machinery/hydroponics/hydro in oview(search_range, controller.pawn))
		if(isnull(hydro.myseed))
			continue
		if(hydro.plant_health < hydro.myseed.endurance)
			possible_trays += hydro

	if(possible_trays.len)
		return pick(possible_trays)

/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/suitable_dispenser
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/water_source
	hunt_targets = list(/obj/structure/sink, /obj/structure/reagent_dispensers)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/reagent_containers/can = locate(/obj/item/reagent_containers/cup/watering_can) in living_pawn

	if(isnull(can))
		return
	if(locate(/datum/reagent/water) in can.reagents.reagent_list)
		return

	return ..()

/datum/ai_behavior/find_hunt_target/suitable_dispenser

/datum/ai_behavior/find_hunt_target/suitable_dispenser/valid_dinner(mob/living/source, obj/structure/water_source, radius)
	if(!(locate(/datum/reagent/water) in water_source.reagents.reagent_list))
		return FALSE

	return can_see(source, water_source, radius)

/datum/ai_behavior/hunt_target/interact_with_target/water_source
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	hunt_cooldown = 5 SECONDS

/datum/ai_controller/basic_controller/seedling/meanie
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/seedling_rapid,
		/datum/ai_planning_subtree/targeted_mob_ability/solarbeam,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/targeted_mob_ability/seedling_rapid
	ability_key = BB_RAPIDSEEDS_ABILITY
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/solarbeam
	ability_key = BB_SOLARBEAM_ABILITY
	finish_planning = FALSE

///pet commands
/datum/pet_command/point_targeting/use_ability/solarbeam
	command_name = "Launch solarbeam"
	command_desc = "Command your pet to launch a solarbeam at your target!"
	radial_icon = 'icons/effects/beam.dmi'
	radial_icon_state = "solar_beam"
	speech_commands = list("beam", "solar")
	pet_ability_key = BB_SOLARBEAM_ABILITY

/datum/pet_command/point_targeting/use_ability/rapidseeds
	command_name = "Rapid seeds"
	command_desc = "Command your pet to launch a volley of seeds at your target!"
	radial_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	radial_icon_state = "seedling"
	speech_commands = list("rapid", "seeds", "volley")
	pet_ability_key = BB_RAPIDSEEDS_ABILITY
