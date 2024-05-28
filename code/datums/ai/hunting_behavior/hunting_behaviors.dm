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
	///do we finish planning subtree
	var/finish_planning = TRUE

/datum/ai_planning_subtree/find_and_hunt_target/New()
	. = ..()
	hunt_targets = typecacheof(hunt_targets)

/datum/ai_planning_subtree/find_and_hunt_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(hunt_chance, seconds_per_tick))
		return
	if(controller.blackboard[BB_HUNTING_COOLDOWN] >= world.time)
		return
	var/mob/living/living_pawn = controller.pawn
	// We can't hunt if we're indisposed
	if(HAS_TRAIT(controller.pawn, TRAIT_HANDS_BLOCKED) || living_pawn.stat != CONSCIOUS)
		return

	var/atom/hunted = controller.blackboard[target_key]
	// We're not hunting anything, look around for something
	if(isnull(hunted))
		controller.queue_behavior(finding_behavior, target_key, hunt_targets, hunt_range)
		return

	// We ARE hunting something, execute the hunt.
	// Note that if our AI controller has multiple hunting subtrees set,
	// we may accidentally be executing another tree's hunt - not ideal,
	// try to set a unique target key if you have multiple

	controller.queue_behavior(hunting_behavior, target_key, BB_HUNTING_COOLDOWN)
	if(finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING //If we're hunting we're too busy for anything else

/// Finds a specific atom type to hunt.
/datum/ai_behavior/find_hunt_target

/datum/ai_behavior/find_hunt_target/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	var/mob/living/living_mob = controller.pawn

	for(var/atom/possible_dinner as anything in typecache_filter_list(range(hunt_range, living_mob), types_to_hunt))
		if(!valid_dinner(living_mob, possible_dinner, hunt_range, controller, seconds_per_tick))
			continue
		controller.set_blackboard_key(hunting_target_key, possible_dinner)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/ai_behavior/find_hunt_target/proc/valid_dinner(mob/living/source, atom/dinner, radius, datum/ai_controller/controller, seconds_per_tick)
	if(isliving(dinner))
		var/mob/living/living_target = dinner
		if(living_target.stat == DEAD) //bitch is dead
			return FALSE

	return can_see(source, dinner, radius)

/// Hunts down a specific atom type.
/datum/ai_behavior/hunt_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	/// How long do we have to wait after a successful hunt?
	var/hunt_cooldown = 5 SECONDS
	/// Do we reset the target after attacking something, so we can check for status changes.
	var/always_reset_target = FALSE


/datum/ai_behavior/hunt_target/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/atom/hunt_target = controller.blackboard[hunting_target_key]
	if (isnull(hunt_target))
		return FALSE
	set_movement_target(controller, hunt_target)

/datum/ai_behavior/hunt_target/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	var/mob/living/hunter = controller.pawn
	var/atom/hunted = controller.blackboard[hunting_target_key]

	if(QDELETED(hunted))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	target_caught(hunter, hunted)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/hunt_target/proc/target_caught(mob/living/hunter, atom/hunted)
	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/living_target = hunted
		hunter.manual_emote("chomps [living_target]!")
		living_target.investigate_log("has been killed by [key_name(hunter)].", INVESTIGATE_DEATHS)
		living_target.death()

	else if(IS_EDIBLE(hunted))
		hunted.attack_animal(hunter)

	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		hunter.manual_emote("chomps [hunted]!")
		qdel(hunted)

/datum/ai_behavior/hunt_target/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	if(succeeded)
		controller.set_blackboard_key(hunting_cooldown_key, world.time + hunt_cooldown)
	else if(hunting_target_key)
		controller.clear_blackboard_key(hunting_target_key)
	if(always_reset_target && hunting_target_key)
		controller.clear_blackboard_key(hunting_target_key)

/datum/ai_behavior/hunt_target/unarmed_attack_target
	///do we toggle combat mode before interacting with the object?
	var/switch_combat_mode = FALSE

/datum/ai_behavior/hunt_target/unarmed_attack_target/target_caught(mob/living/hunter, obj/structure/cable/hunted)
	if(switch_combat_mode)
		hunter.combat_mode = !(hunter.combat_mode)
	hunter.UnarmedAttack(hunted, TRUE)

/datum/ai_behavior/hunt_target/unarmed_attack_target/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	if(!switch_combat_mode)
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.combat_mode = initial(living_pawn.combat_mode)

/datum/ai_behavior/hunt_target/unarmed_attack_target/switch_combat_mode
	switch_combat_mode = TRUE

/datum/ai_behavior/hunt_target/unarmed_attack_target/reset_target
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/use_ability_on_target
	always_reset_target = TRUE
	///the ability we will use
	var/ability_key

/datum/ai_behavior/hunt_target/use_ability_on_target/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return ..()

/datum/ai_behavior/hunt_target/use_ability_on_target/target_caught(mob/living/hunter, atom/hunted)
	var/datum/action/cooldown/ability = hunter.ai_controller.blackboard[ability_key]
	ability.InterceptClickOn(hunter, null, hunted)


/datum/ai_behavior/hunt_target/latch_onto

/datum/ai_behavior/hunt_target/latch_onto/setup(datum/ai_controller/controller, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		return FALSE

/datum/ai_behavior/hunt_target/latch_onto/target_caught(mob/living/hunter, obj/hunted)
	if(hunter.buckled)
		return FALSE
	if(!hunted.buckle_mob(hunter, force = TRUE))
		return FALSE
	hunted.visible_message(span_notice("[hunted] has been latched onto by [hunter]!"))
	return TRUE
