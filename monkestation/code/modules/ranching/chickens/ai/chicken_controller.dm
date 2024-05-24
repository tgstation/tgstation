/datum/ai_controller/chicken
	movement_delay = 0.4 SECONDS
	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/flee_target/low_health,
		)
	idle_behavior = /datum/idle_behavior/chicken
	blackboard = list(
		BB_BASIC_MOB_CURRENT_TARGET = null,
		BB_CHICKEN_TARGETED_ABILITY = null,
		BB_CHICKEN_SELF_ABILITY = null,
		BB_CHICKEN_RECRUIT_COOLDOWN = null,
		BB_CHICKEN_SPECALITY_ABILITY = null,
		BB_CHICKEN_NESTING_BOX = null,
		BB_CHICKEN_FEED = null,

		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	can_idle = FALSE // we want these to be running always

/datum/ai_controller/chicken/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/chicken/living_pawn = new_pawn
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))

	movement_delay = living_pawn.cached_multiplicative_slowdown

	AddComponent(/datum/component/connect_loc_behalf, new_pawn, loc_connections)
	return ..() //Run parent at end

/datum/ai_controller/chicken/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_MOB_MOVESPEED_UPDATED))
	qdel(GetComponent(/datum/component/connect_loc_behalf))
	return ..()//Run parent at end

//HOSTILE
/datum/ai_controller/chicken/hostile
	blackboard = list(
		BB_BASIC_MOB_CURRENT_TARGET = null,
		BB_CHICKEN_TARGETED_ABILITY = null,
		BB_CHICKEN_SELF_ABILITY = null,
		BB_CHICKEN_RECRUIT_COOLDOWN = null,
		BB_CHICKEN_SPECALITY_ABILITY = null,
		BB_CHICKEN_NESTING_BOX = null,
		BB_CHICKEN_FEED = null,

		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/chicken,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		)

/datum/ai_controller/chicken/hostile/TryPossessPawn(atom/new_pawn)
	. = ..()
	new_pawn.AddComponent(/datum/component/ai_target_timer)

//RETALIATE
/datum/ai_controller/chicken/retaliate
	blackboard = list(
		BB_BASIC_MOB_CURRENT_TARGET = null,
		BB_CHICKEN_TARGETED_ABILITY = null,
		BB_CHICKEN_SELF_ABILITY = null,
		BB_CHICKEN_RECRUIT_COOLDOWN = null,
		BB_CHICKEN_SPECALITY_ABILITY = null,
		BB_CHICKEN_NESTING_BOX = null,
		BB_CHICKEN_FEED = null,

		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/flee_target/low_health,
		)

///Start of ai calls

/datum/ai_planning_subtree/basic_melee_attack_subtree/chicken
	operational_datums = list(/datum/component/ai_target_timer)
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/chicken

/// Go for the tentacles if they're available
/datum/ai_behavior/basic_melee_attack/chicken

/datum/ai_behavior/basic_melee_attack/chicken/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < 5 SECONDS)
		return ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(SEND_SIGNAL(controller.pawn, COMSIG_FRIENDSHIP_CHECK_LEVEL, target, FRIENDSHIP_FRIEND))
		controller.clear_blackboard_key(target_key)
		finish_action(controller, succeeded = FALSE)
		return

	// Interrupt attack chain to use tentacles, unless the target is already tentacled
	if (isliving(target))
		var/datum/action/cooldown/using_action = controller.blackboard[BB_CHICKEN_TARGETED_ABILITY]
		if (using_action?.IsAvailable())
			finish_action(controller, succeeded = FALSE)
			return
	return ..()

/datum/ai_planning_subtree/flee_target/low_health/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(!controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	if(living_pawn.health > CHICKEN_FLEE_HEALTH) //Time to skeddadle
		return
	. = ..()

// Stops sentient chickens from being knocked over like weak dunces.
/datum/ai_controller/chicken/on_sentience_gained()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))

/datum/ai_controller/chicken/on_sentience_lost()
	. = ..()
	AddComponent(/datum/component/connect_loc_behalf, pawn, loc_connections)

/datum/ai_controller/chicken/able_to_run()
	. = ..()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE

/datum/ai_controller/chicken/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown

//When idle just kinda fuck around.
/datum/idle_behavior/chicken/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/chicken/living_pawn = controller.pawn

	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	if(SPT_PROB(25, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

/datum/ai_controller/chicken/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && isliving(arrived))
		var/mob/living/in_the_way_mob = arrived
		in_the_way_mob.knockOver(living_pawn)
		return


/datum/ai_controller/basic_controller/chick
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/chicken),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/chick),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)
