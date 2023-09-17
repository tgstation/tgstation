/datum/ai_controller/basic_controller/mega_arachnid
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_BASIC_MOB_FLEEING = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/arachnid_restrain,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/mega_arachnid,
		/datum/ai_planning_subtree/flee_target/mega_arachnid,
		/datum/ai_planning_subtree/climb_trees,
		/datum/ai_planning_subtree/find_and_hunt_target/destroy_surveillance,
	)

///destroy surveillance objects to boost our stealth
/datum/ai_planning_subtree/find_and_hunt_target/destroy_surveillance
	target_key = BB_SURVEILLANCE_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_active_surveillance
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target
	hunt_targets = list(/obj/machinery/camera, /obj/machinery/light)
	hunt_range = 7

/datum/ai_behavior/find_hunt_target/find_active_surveillance

/datum/ai_behavior/find_hunt_target/find_active_camera/valid_dinner(mob/living/source, obj/machinery/dinner, radius)
	if(dinner.machine_stat & BROKEN)
		return FALSE

	return can_see(source, dinner, radius)

///spray slippery acid as we flee!
/datum/ai_planning_subtree/flee_target/mega_arachnid
	flee_behaviour = /datum/ai_behavior/run_away_from_target/mega_arachnid

/datum/ai_planning_subtree/flee_target/mega_arachnid/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	var/datum/action/cooldown/slip_acid = controller.blackboard[BB_ARACHNID_SLIP]

	if(!QDELETED(slip_acid) && slip_acid.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_ARACHNID_SLIP)

	return ..()

/datum/ai_behavior/run_away_from_target/mega_arachnid
	clear_failed_targets = FALSE
	run_distance = 5

///only engage in melee combat against cuffed targets, otherwise keep throwing restraints at them
/datum/ai_planning_subtree/basic_melee_attack_subtree/mega_arachnid
	///minimum health our target must be before we can attack them
	var/minimum_health = 50

/datum/ai_planning_subtree/basic_melee_attack_subtree/mega_arachnid/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!ishuman(target))
		return ..()

	var/mob/living/carbon/human_target = target
	if(!human_target.legcuffed && human_target.health > minimum_health)
		return

	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/arachnid_restrain
	ability_key = BB_ARACHNID_RESTRAIN

/// only fire ability at humans if they are not cuffed
/datum/ai_planning_subtree/targeted_mob_ability/arachnid_restrain/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if(!ishuman(target))
		return
	var/mob/living/carbon/human_target = target
	if(human_target.legcuffed)
		return
	return ..()
