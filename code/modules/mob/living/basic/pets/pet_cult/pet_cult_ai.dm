/datum/ai_controller/basic_controller/pet_cult
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/cultist,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/cultist,
		BB_FRIENDLY_MESSAGE = "eagerly awaits your command...",
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/befriend_cultists,
		/datum/ai_planning_subtree/find_occupied_rune,
		/datum/ai_planning_subtree/find_dead_cultist,
		/datum/ai_planning_subtree/drag_target_to_rune,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

///if target gets pulled away, unset him
/datum/ai_controller/basic_controller/pet_cult/proc/delete_pull_target(datum/source, atom/movable/was_pulling)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_ATOM_NO_LONGER_PULLING)

	if(was_pulling == blackboard[BB_DEAD_CULTIST])
		clear_blackboard_key(BB_DEAD_CULTIST)

///targeting strat to attack non cultists
/datum/targeting_strategy/basic/cultist

/datum/targeting_strategy/basic/cultist/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return IS_CULTIST_OR_CULTIST_MOB(the_target)

///befriend all cultists around us!
/datum/ai_planning_subtree/befriend_cultists

/datum/ai_planning_subtree/befriend_cultists/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_FRIENDLY_CULTIST))
		controller.queue_behavior(/datum/ai_behavior/befriend_target, BB_FRIENDLY_CULTIST)
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/friendly_cultist, BB_FRIENDLY_CULTIST, /mob/living/carbon)

///behavior to find cultists that we befriend
/datum/ai_behavior/find_and_set/friendly_cultist
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_and_set/friendly_cultist/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/carbon/possible_cultist in oview(search_range, controller.pawn))
		if(IS_CULTIST(possible_cultist) && !(living_pawn.faction.Find(REF(possible_cultist))))
			return possible_cultist

	return null

///subtree to find a rune with a viable target on it, so we can go activate it
/datum/ai_planning_subtree/find_occupied_rune

/datum/ai_planning_subtree/find_occupied_rune/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if((LAZYLEN(GLOB.sacrificed) - SOULS_TO_REVIVE - GLOB.sacrifices_used) < 0)
		controller.clear_blackboard_key(BB_OCCUPIED_RUNE)
		return

	if(controller.blackboard_key_exists(BB_OCCUPIED_RUNE))
		controller.queue_behavior(/datum/ai_behavior/activate_rune, BB_OCCUPIED_RUNE)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/occupied_rune, BB_OCCUPIED_RUNE, /obj/effect/rune/raise_dead)

/datum/ai_behavior/find_and_set/occupied_rune

/datum/ai_behavior/find_and_set/occupied_rune/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return null

	for(var/obj/effect/rune/raise_dead/target_rune in oview(search_range, controller.pawn))
		controller.set_blackboard_key(BB_NEARBY_RUNE, target_rune)
		var/mob/living/occupant = locate(/mob/living/carbon/human) in get_turf(target_rune)
		if(isnull(occupant))
			continue
		if(occupant.stat != DEAD || !IS_CULTIST(occupant))
			continue
		return target_rune

	return null

/datum/ai_behavior/activate_rune
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 3 SECONDS

/datum/ai_behavior/activate_rune/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/activate_rune/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	var/mob/living/revive_mob = locate(/mob/living) in get_turf(target)

	if(isnull(revive_mob) || revive_mob.stat != DEAD || !(revive_mob.mind in cult_team.members))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.ai_interact(target = target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/activate_rune/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)


///find targets that we can revive
/datum/ai_planning_subtree/find_dead_cultist

/datum/ai_planning_subtree/find_dead_cultist/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if((LAZYLEN(GLOB.sacrificed) - SOULS_TO_REVIVE - GLOB.sacrifices_used) < 0)
		controller.clear_blackboard_key(BB_DEAD_CULTIST)
		return

	var/mob/living/living_pawn = controller.pawn

	if(!isnull(living_pawn.pulling))
		return

	if(controller.blackboard_key_exists(BB_DEAD_CULTIST))
		controller.queue_behavior(/datum/ai_behavior/pull_target/cult_revive, BB_DEAD_CULTIST)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/dead_cultist, BB_DEAD_CULTIST, /mob/living/carbon/human)

/datum/ai_behavior/find_and_set/dead_cultist

/datum/ai_behavior/find_and_set/dead_cultist/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	var/datum/team/cult/cult_team = controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return null
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(target.stat != DEAD)
			continue
		if(!IS_CULTIST(target))
			continue
		if(target.buckled || target.move_resist > living_pawn.move_force || target.pulledby)
			continue
		if(locate(/obj/effect/rune/raise_dead) in target.loc)
			continue
		return target
	return null

/datum/ai_behavior/pull_target/cult_revive

/datum/ai_behavior/pull_target/cult_revive/finish_action(datum/ai_controller/basic_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		return
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return
	controller.RegisterSignal(controller.pawn, COMSIG_ATOM_NO_LONGER_PULLING, TYPE_PROC_REF(/datum/ai_controller/basic_controller/pet_cult, delete_pull_target), override = TRUE)

/datum/ai_planning_subtree/drag_target_to_rune

/datum/ai_planning_subtree/drag_target_to_rune/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	if(!controller.blackboard_key_exists(BB_DEAD_CULTIST)) //no target, we dont need to do anything
		return

	var/mob/living/our_pawn = controller.pawn

	if(isnull(our_pawn.pulling))
		return

	var/atom/target_rune = controller.blackboard[BB_NEARBY_RUNE]

	if(QDELETED(target_rune))
		controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_RUNE_ABILITY)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!can_see(our_pawn, target_rune, 9))
		controller.clear_blackboard_key(BB_NEARBY_RUNE)
		return

	controller.queue_behavior(/datum/ai_behavior/drag_target_to_rune, BB_NEARBY_RUNE, BB_DEAD_CULTIST)

///behavior to drag the target onto the rune
/datum/ai_behavior/drag_target_to_rune
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/drag_target_to_rune/setup(datum/ai_controller/controller, target_key, cultist_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/drag_target_to_rune/perform(seconds_per_tick, datum/ai_controller/controller, target_key, cultist_key)
	var/mob/living/our_pawn = controller.pawn
	var/atom/cultist_target = controller.blackboard[cultist_key]
	if(isnull(cultist_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/possible_dirs = GLOB.alldirs.Copy()
	possible_dirs -= get_dir(our_pawn, cultist_target)
	for(var/direction in possible_dirs)
		var/turf/possible_turf = get_step(our_pawn, direction)
		if(possible_turf.is_blocked_turf(source_atom = our_pawn))
			possible_dirs -= direction
	step(our_pawn, pick(possible_dirs))
	our_pawn.stop_pulling()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_behavior/drag_target_to_rune/finish_action(datum/ai_controller/controller, success, target_key, cultist_key)
	. = ..()
	if(success)
		var/atom/revival_rune = controller.blackboard[target_key]
		controller.set_blackboard_key(BB_OCCUPIED_RUNE, revival_rune)
	controller.clear_blackboard_key(cultist_key)
	controller.clear_blackboard_key(target_key)

///command ability to draw runes
/datum/pet_command/untargeted_ability/draw_rune
	command_name = "Draw Rune"
	command_desc = "Draw a revival rune."
	radial_icon = 'icons/obj/antags/cult/rune.dmi'
	radial_icon_state = "1"
	speech_commands = list("rune", "revival")
	ability_key = BB_RUNE_ABILITY

/datum/pet_command/untargeted_ability/draw_rune/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to draw a rune!"
