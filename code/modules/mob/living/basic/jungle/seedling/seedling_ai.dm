/datum/ai_controller/basic_controller/seedling
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends,
		BB_WEEDLEVEL_THRESHOLD = 3,
		BB_WATERLEVEL_THRESHOLD = 90,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/watering_can,
		/datum/ai_planning_subtree/treat_hydroplants,
		/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan,
	)

/datum/ai_planning_subtree/find_and_hunt_target/watering_can
	target_key = BB_WATERCAN_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target
	hunt_targets = list(/obj/item/reagent_containers/cup/watering_can)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/watering_can/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(locate(/obj/item/reagent_containers/cup/watering_can) in living_pawn) //we already have what we came for!
		return
	return ..()

/datum/ai_planning_subtree/treat_hydroplants/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/solar_ability = controller.blackboard[BB_SOLARBEAM_ABILITY]
	var/obj/machinery/hydroponics/target_hydro = controller.blackboard[BB_HYDROPLANT_TARGET]

	if(QDELETED(target_hydro))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/treatable_hydro, BB_HYDROPLANT_TARGET, /obj/machinery/hydroponics)
		return

	var/needs_healing = target_hydro.plant_health < target_hydro.myseed?.endurance

	if(!QDELETED(solar_ability) && solar_ability.IsAvailable() && needs_healing)
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target/solarbeam, BB_SOLARBEAM_ABILITY, BB_HYDROPLANT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/treat_hydroplants, BB_HYDROPLANT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/targeted_mob_ability/and_clear_target/solarbeam
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 2
	action_cooldown = 1 MINUTES

/datum/ai_behavior/targeted_mob_ability/and_clear_target/solarbeam/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/targeted_mob_ability/and_clear_target/solarbeam/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	controller.behavior_cooldowns[src] = world.time + action_cooldown //use the action cooldown
	return ..()

/datum/ai_behavior/treat_hydroplants
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 2 SECONDS

/datum/ai_behavior/treat_hydroplants/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/treat_hydroplants/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/mob/living/basic/living_pawn = controller.pawn
	var/obj/machinery/hydroponics/hydro_target = controller.blackboard[target_key]

	if(QDELETED(hydro_target) || QDELETED(hydro_target.myseed))
		finish_action(controller, FALSE, target_key)
		return

	if(hydro_target.plant_status == HYDROTRAY_PLANT_DEAD)
		living_pawn.manual_emote("weeps...") //weep over the dead plants

	living_pawn.melee_attack(hydro_target)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/treat_hydroplants/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_and_set/treatable_hydro

/datum/ai_behavior/find_and_set/treatable_hydro/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/list/possible_trays = list()
	var/mob/living/living_pawn = controller.pawn
	var/waterlevel_threshold = controller.blackboard[BB_WATERLEVEL_THRESHOLD]
	var/weedlevel_threshold = controller.blackboard[BB_WEEDLEVEL_THRESHOLD]
	var/datum/action/cooldown/solar_ability = controller.blackboard[BB_SOLARBEAM_ABILITY]
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
		if(hydro.plant_health < hydro.myseed.endurance && solar_ability.IsAvailable())
			possible_trays += hydro

	if(possible_trays.len)
		return pick(possible_trays)

/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/suitable_dispenser
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/water_source
	hunt_targets = list(/obj/structure/sink, /obj/structure/reagent_dispensers)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/fill_watercan/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(!locate(/obj/item/reagent_containers/cup/watering_can) in living_pawn)
		return
	return ..()

/datum/ai_behavior/find_hunt_target/suitable_dispenser

/datum/ai_behavior/find_hunt_target/suitable_dispenser/valid_dinner(mob/living/source, obj/structure/water_source, radius)
	if(!(locate(/datum/reagent/water) in water_source.reagents.reagent_list))
		return FALSE

	return can_see(source, water_source, radius)

/datum/ai_behavior/hunt_target/unarmed_attack_target/water_source
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	hunt_cooldown = 30 SECONDS

/datum/ai_controller/basic_controller/seedling/meanie
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/not_friends,
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
/datum/pet_command/point_targetting/use_ability/solarbeam
	command_name = "Launch solarbeam"
	command_desc = "Command your pet to launch a solarbeam at your target!"
	radial_icon = 'icons/effects/beam.dmi'
	radial_icon_state = "solar_beam"
	speech_commands = list("beam", "solar")
	pet_ability_key = BB_SOLARBEAM_ABILITY

/datum/pet_command/point_targetting/use_ability/rapidseeds
	command_name = "Rapid seeds"
	command_desc = "Command your pet to launch a volley of seeds at your target!"
	radial_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	radial_icon_state = "seedling"
	speech_commands = list("rapid", "seeds", "volley")
	pet_ability_key = BB_RAPIDSEEDS_ABILITY
