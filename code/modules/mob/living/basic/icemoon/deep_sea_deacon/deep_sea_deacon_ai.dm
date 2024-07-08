#define SPECIAL_ATTACK_COUNTER 2
#define DOMAIN_HEALTH_THRESHOLD 0.45
#define CYCLE_STARTED_NOTIFY 2 SECONDS

/datum/ai_controller/basic_controller/deep_sea_deacon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_DEACON_SPECIAL_ATTACK_COUNTER = 0,
		BB_DEACON_NEXT_CYCLE_READY = TRUE,
		BB_DEACON_BOUNCE_MODE = FALSE,
		BB_DEACON_USED_SPECIAL_ATTACKS = list(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/deacon_bounce,
		/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_domain_attack,
		/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_special_attack,
		/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_normal_attack,
		/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_idle_attack,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/deep_sea_deacon/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_MOB_ABILITY_STARTED, PROC_REF(on_ability_used))

/datum/ai_controller/basic_controller/deep_sea_deacon/proc/on_ability_used(datum/source, datum/ability, atom/target)
	SIGNAL_HANDLER
	var/ability_type = ability.type
	if(ability_type == /datum/action/cooldown/mob_cooldown/domain_teleport)
		CancelActions()
		return

	if(ability_type in blackboard[BB_DEACON_CYCLE_RESETERS])
		var/list/used_specials = list()
		if(length(blackboard[BB_DEACON_USED_SPECIAL_ATTACKS]) < length(blackboard[BB_DEACON_CYCLE_RESETERS]))
			used_specials = blackboard[BB_DEACON_USED_SPECIAL_ATTACKS] + ability_type
		CancelActions()
		set_blackboard_key(BB_DEACON_LAST_SPECIAL_ATTACK, ability_type)
		set_blackboard_key(BB_DEACON_SPECIAL_ATTACK_COUNTER, 0)
		override_blackboard_key(BB_DEACON_USED_SPECIAL_ATTACKS, used_specials)
		return

	var/cycle_timer = blackboard[BB_DEACON_CYCLE_TIMERS][ability_type]
	if(!isnull(cycle_timer))
		set_blackboard_key(BB_DEACON_SPECIAL_ATTACK_COUNTER, blackboard[BB_DEACON_SPECIAL_ATTACK_COUNTER] + 1)
		set_blackboard_key(BB_DEACON_NEXT_CYCLE_READY, FALSE)
		addtimer(CALLBACK(src, PROC_REF(set_blackboard_key), BB_DEACON_CYCLE_STARTED, TRUE), CYCLE_STARTED_NOTIFY)
		addtimer(CALLBACK(src, PROC_REF(set_blackboard_key), BB_DEACON_NEXT_CYCLE_READY, TRUE), cycle_timer)
		return

	set_blackboard_key(BB_DEACON_CYCLE_STARTED, FALSE)


/datum/ai_planning_subtree/targeted_mob_ability/deacon
	///list of attacks we choose from
	var/ability_list

/datum/ai_planning_subtree/targeted_mob_ability/deacon/proc/check_conditions(datum/ai_controller/controller)
	return TRUE

/datum/ai_planning_subtree/targeted_mob_ability/deacon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!check_conditions(controller))
		return
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < 3 SECONDS)
		return SUBTREE_RETURN_FINISH_PLANNING
	var/list/blackboard_list = controller.blackboard[ability_list]
	var/list/attacks_list = blackboard_list.Copy()
	shuffle_inplace(attacks_list)
	for(var/ability_key in attacks_list)
		if(!check_availability(controller, ability_key))
			attacks_list -= ability_key
	if(!length(attacks_list))
		return
	ability_key = pick(attacks_list)
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/deacon/proc/check_availability(datum/ai_controller/controller, ability_key)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	return ability.IsAvailable()

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_normal_attack
	ability_list = BB_DEACON_NORMAL_ATTACKS

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_normal_attack/check_conditions(datum/ai_controller/controller)
	return controller.blackboard[BB_DEACON_CYCLE_STARTED]

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_normal_attack/check_availability(datum/ai_controller/controller, ability_key)
	var/mob/living/living_pawn = controller.pawn
	if(ability_key == BB_DEACON_PHANTOM && (living_pawn.health / living_pawn.maxHealth > 0.75))
		return FALSE
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_idle_attack
	ability_list = BB_DEACON_IDLE_ATTACKS

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_idle_attack/check_conditions(datum/ai_controller/controller)
	return controller.blackboard[BB_DEACON_NEXT_CYCLE_READY]

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_special_attack
	ability_list = BB_DEACON_SPECIAL_ATTACKS

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_special_attack/check_conditions(datum/ai_controller/controller)
	return (controller.blackboard[BB_DEACON_SPECIAL_ATTACK_COUNTER] >= SPECIAL_ATTACK_COUNTER && controller.blackboard[BB_DEACON_NEXT_CYCLE_READY])

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_special_attack/check_availability(datum/ai_controller/controller, ability_key)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(ability.type in controller.blackboard[BB_DEACON_USED_SPECIAL_ATTACKS])
		return FALSE
	return ability.IsAvailable() && (controller.blackboard[BB_DEACON_LAST_SPECIAL_ATTACK] != ability.type)

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_domain_attack
	ability_list = BB_DEACON_DOMAIN_ATTACKS

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_domain_attack/check_conditions(datum/ai_controller/controller)
	return controller.blackboard[BB_DEACON_NEXT_CYCLE_READY]

/datum/ai_planning_subtree/targeted_mob_ability/deacon/deacon_domain_attack/check_availability(datum/ai_controller/controller, ability_key)
	. = ..()
	if(!.)
		return FALSE
	var/health_threshold = controller.blackboard[BB_DEACON_DOMAIN_ATTACKS][ability_key]
	var/mob/living/living_pawn = controller.pawn
	return ((living_pawn.health/living_pawn.maxHealth) <= health_threshold)

/datum/ai_planning_subtree/targeted_mob_ability/deacon_bounce
	ability_key = BB_DEACON_BOUNCE

/datum/ai_planning_subtree/targeted_mob_ability/deacon_bounce/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_DEACON_BOUNCE_MODE])
		return
	. = ..()
	return SUBTREE_RETURN_FINISH_PLANNING //always finish planning, we just bouncing around for now

/datum/ai_controller/basic_controller/deacon_phantom
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_DEACON_BOUNCE_MODE = TRUE,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/targeted_mob_ability/deacon_bounce,
	)

/datum/ai_controller/basic_controller/spirit_deacon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
#undef SPECIAL_ATTACK_COUNTER
