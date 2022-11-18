/**
 * Tells the AI to find a certain target nearby to hunt.
 * If a target has been found, we will start to move towards it, and eventually attack it.
 */
/datum/ai_planning_subtree/find_and_hunt_target
	/// What key in the blacbkboard do we store our hunting target?
	/// If you want to have multiple hunting behaviors on a controller be sure that this is unique
	var/target_key = BB_CURRENT_HUNTING_TARGET
	/// What behavior to execute if we have no target
	var/finding_behavior = /datum/ai_behavior/find_hunt_target
	/// What behavior to execute if we do have a target
	var/hunting_behavior = /datum/ai_behavior/hunt_target
	/// What targets we're hunting for
	var/list/hunt_targets
	/// In what radius will we hunt
	var/hunt_range = 2
	/// What are the chances we hunt something at any given moment
	var/hunt_chance = 100

/datum/ai_planning_subtree/find_and_hunt_target/New()
	. = ..()
	hunt_targets = typecacheof(hunt_targets)

/datum/ai_planning_subtree/find_and_hunt_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!DT_PROB(hunt_chance, delta_time))
		return
	if(controller.blackboard[BB_HUNTING_COOLDOWN] >= world.time)
		return
	var/mob/living/living_pawn = controller.pawn
	// We can't hunt if we're indisposed
	if(HAS_TRAIT(controller.pawn, TRAIT_HANDS_BLOCKED) || living_pawn.stat != CONSCIOUS)
		return

	// We're targeting something else for another reason
	var/datum/weakref/target_weakref = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = target_weakref?.resolve()
	if(!QDELETED(target))
		return

	var/datum/weakref/hunting_weakref = controller.blackboard[target_key]
	var/atom/hunted = hunting_weakref?.resolve()
	// We're not hunting anything, look around for something
	if(QDELETED(hunted))
		controller.queue_behavior(finding_behavior, target_key, hunt_targets, hunt_range)

	// We ARE hunting something, execute the hunt.
	// Note that if our AI controller has multiple hunting subtrees set,
	// we may accidentally be executing another tree's hunt - not ideal,
	// try to set a unique target key if you have multiple
	else
		controller.queue_behavior(hunting_behavior, target_key, BB_HUNTING_COOLDOWN)
		return SUBTREE_RETURN_FINISH_PLANNING //If we're hunting we're too busy for anything else

/// Finds a specific atom type to hunt.
/datum/ai_behavior/find_hunt_target

/datum/ai_behavior/find_hunt_target/perform(delta_time, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	. = ..()

	var/mob/living/living_mob = controller.pawn

	for(var/atom/possible_dinner as anything in typecache_filter_list(range(hunt_range, living_mob), types_to_hunt))
		if(!valid_dinner(living_mob, possible_dinner, hunt_range))
			continue
		controller.blackboard[hunting_target_key] = WEAKREF(possible_dinner)
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/find_hunt_target/proc/valid_dinner(mob/living/source, atom/dinner, radius)
	if(isliving(dinner))
		var/mob/living/living_target = dinner
		if(living_target.stat == DEAD) //bitch is dead
			return FALSE

	return can_see(source, dinner, radius)

/// Hunts down a specific atom type.
/datum/ai_behavior/hunt_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	/// How long do we have to wait after a successful hunt?
	var/hunt_cooldown = 5 SECONDS

/datum/ai_behavior/hunt_target/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/datum/weakref/hunting_weakref = controller.blackboard[hunting_target_key]
	controller.current_movement_target = hunting_weakref?.resolve()

/datum/ai_behavior/hunt_target/perform(delta_time, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/mob/living/hunter = controller.pawn
	var/datum/weakref/hunting_weakref = controller.blackboard[hunting_target_key]
	var/atom/hunted = hunting_weakref?.resolve()

	if(QDELETED(hunted))
		//Target is gone for some reason. forget about this task!
		controller[hunting_target_key] = null
		finish_action(controller, FALSE, hunting_target_key)
	else
		target_caught(hunter, hunted)
		finish_action(controller, TRUE, hunting_target_key, hunting_cooldown_key)

/datum/ai_behavior/hunt_target/proc/target_caught(mob/living/hunter, atom/hunted)
	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/living_target = hunted
		hunter.manual_emote("chomps [living_target]!")
		living_target.death()

	else if(IS_EDIBLE(hunted))
		hunted.attack_animal(hunter)

	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		hunter.manual_emote("chomps [hunted]!")
		qdel(hunted)

/datum/ai_behavior/hunt_target/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	if(succeeded)
		controller.blackboard[hunting_cooldown_key] = world.time + hunt_cooldown
	else if(hunting_target_key)
		controller.blackboard[hunting_target_key] = null

/datum/ai_behavior/hunt_target/unarmed_attack_target

/datum/ai_behavior/hunt_target/unarmed_attack_target/target_caught(mob/living/hunter, obj/structure/cable/hunted)
	hunter.UnarmedAttack(hunted, TRUE)
