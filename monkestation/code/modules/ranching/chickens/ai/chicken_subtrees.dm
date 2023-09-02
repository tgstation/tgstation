/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken
	ability_key = BB_CHICKEN_TARGETED_ABILITY
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range
	target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]
	var/datum/action/cooldown/mob_cooldown/chicken/stored_action = controller.blackboard[ability_key]
	use_ability_behaviour = stored_action.what_range
	if (QDELETED(target))
		return
	return ..()

/datum/ai_planning_subtree/use_mob_ability/chicken
	ability_key = BB_CHICKEN_SELF_ABILITY
	finish_planning = TRUE

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/clown

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/clown/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/mob_cooldown/chicken/stored_action = controller.blackboard[ability_key]
	if(!stored_action.IsAvailable())
		return
	var/mob/living/living_pawn = controller.pawn

	if(istype(living_pawn, /mob/living/basic/chicken/clown_sad))
		var/list/clucking_mad = list()
		for(var/mob/living/carbon/human/unlucky in GLOB.player_list)
			clucking_mad |= unlucky

		if(!length(clucking_mad))
			return
		controller.set_blackboard_key(target_key, pick(clucking_mad))
		clucking_mad = null
	else
		var/list/pick_me = list()
		for(var/mob/living/carbon/human/target in view(living_pawn, CHICKEN_ENEMY_VISION))
			pick_me |= target
		if(!length(pick_me))
			return
		controller.set_blackboard_key(target_key, pick(pick_me))

	return ..()


/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/rev

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/rev/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/mob_cooldown/chicken/stored_action = controller.blackboard[ability_key]
	if(!stored_action.IsAvailable())
		return
	var/mob/living/living_pawn = controller.pawn

	var/list/viable_conversions = list()
	for(var/mob/living/basic/chicken/found_chicken in view(4, living_pawn.loc))
		if(!istype(found_chicken, /mob/living/basic/chicken/rev_raptor) || !istype(found_chicken, /mob/living/basic/chicken/raptor) || !istype(found_chicken, /mob/living/basic/chicken/rev_raptor))
			viable_conversions |= found_chicken
	if(!length(viable_conversions))
		return
	controller.set_blackboard_key(target_key, pick(viable_conversions))

	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/lay_egg
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top
	target_key = BB_CHICKEN_NESTING_BOX
	ability_key = BB_CHICKEN_LAY_EGG

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/lay_egg/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/mob_cooldown/chicken/stored_action = controller.blackboard[ability_key]
	if(!stored_action.IsAvailable())
		return
	var/mob/living/basic/chicken/living_pawn = controller.pawn
	if(living_pawn.eggs_left <= 0)
		return

	var/list/found_spots = list()
	for(var/obj/structure/nestbox/listed_box in view(7, living_pawn.loc))
		found_spots |= listed_box
	if(!length(found_spots))
		return
	controller.set_blackboard_key(target_key, pick(found_spots))
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/feed
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top
	target_key = BB_BASIC_MOB_CURRENT_TARGET
	ability_key = BB_CHICKEN_FEED

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/feed/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/mob_cooldown/chicken/stored_action = controller.blackboard[ability_key]
	if(!stored_action.IsAvailable())
		return
	var/mob/living/living_pawn = controller.pawn

	var/list/found_spots = list()
	for(var/obj/effect/chicken_feed/listed_feed in view(7, living_pawn.loc))
		found_spots |= listed_feed
	if(!length(found_spots))
		return
	controller.set_blackboard_key(target_key, pick(found_spots))
	return ..()
