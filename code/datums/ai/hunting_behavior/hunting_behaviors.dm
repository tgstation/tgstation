/datum/ai_planning_subtree/find_and_hunt_target
	var/list/hunt_targets = list(/obj/effect/decal/cleanable/ants)

/datum/ai_planning_subtree/find_and_hunt_target/New()
	. = ..()
	hunt_targets = typecacheof(hunt_targets)

/datum/ai_planning_subtree/find_and_hunt_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(controller.blackboard[BB_HUNTING_COOLDOWN] >= world.time)
		return
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_hunt_target, BB_CURRENT_HUNTING_TARGET, hunt_targets)
	else
		controller.queue_behavior(/datum/ai_behavior/hunt_target, BB_CURRENT_HUNTING_TARGET, BB_HUNTING_COOLDOWN)
		return SUBTREE_RETURN_FINISH_PLANNING //If we're hunting we're too busy for anything else


///Literaly for hunting specific mobs.
/datum/ai_behavior/find_hunt_target

/datum/ai_behavior/find_hunt_target/perform(delta_time, datum/ai_controller/controller, hunting_target_key, types_to_hunt)
	. = ..()

	var/mob/living/living_mob = controller.pawn

	for(var/possible_dinner in typecache_filter_list(range(2, living_mob), types_to_hunt))
		if(isliving(possible_dinner))
			var/mob/living/living_target = possible_dinner
			if(living_target.stat == DEAD) //bitch is dead
				continue
		if(can_see(living_mob, possible_dinner, 2))
			controller.blackboard[hunting_target_key] = possible_dinner
			finish_action(controller, TRUE)
			return

	finish_action(controller, FALSE)
/datum/ai_behavior/hunt_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/hunt_target/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	controller.current_movement_target = controller.blackboard[hunting_target_key]

/datum/ai_behavior/hunt_target/perform(delta_time, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()

	if(!controller.blackboard[hunting_target_key]) //Target is gone for some reason. forget about this task!
		controller[hunting_target_key] = null
		finish_action(controller, FALSE, hunting_target_key)
		return

	var/mob/living/hunter = controller.pawn
	var/atom/hunted = controller.blackboard[hunting_target_key]

	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/living_target = hunted
		hunter.manual_emote("chomps [living_target]!")
		living_target.death()

	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		hunter.manual_emote("chomps [hunted]!")
		qdel(hunted)
	finish_action(controller, TRUE, hunting_target_key, hunting_cooldown_key)
	return

/datum/ai_behavior/hunt_target/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	if(succeeded)
		controller.blackboard[hunting_cooldown_key] = world.time + SUCCESFUL_HUNT_COOLDOWN
	else if(hunting_target_key)
		controller.blackboard[hunting_target_key] = null
