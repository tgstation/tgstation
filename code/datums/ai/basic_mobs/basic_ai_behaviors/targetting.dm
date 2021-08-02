///Get all the mobs and potential dangerous machines we can see.
/datum/ai_behavior/basic_get_vision_targets
	var/vision_targets_key = BASIC_MOB_VISION_TARGETS
	var/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))

/datum/ai_behavior/basic_get_vision_targets/perform(delta_time, datum/ai_controller/controller)
	var/list/potential_targets
	var/mob/living/basic/basic_mob = controller.pawn

	potential_targets = basic_mob.hearers(vision_range, controller.pawn) - basic_mob //Remove self, so we don't suicide

	for(var/HM in typecache_filter_list(range(vision_range, basic_mob), hostile_machines)) //Can we see any hostile machines?
		if(can_see(basic_mob, HM, vision_range))
			potential_targets += HM

	controller.blackboard[vision_targets_key] = potential_targets


/datum/ai_behavior/basic_get_vision_targets/select_target
	var/vision_targets_key = BASIC_MOB_VISION_TARGETS
	var/final_target_key = BASIC_MOB_ATTACK_TARGET

	var/mob/living/basic/basic_mob = controller.pawn

