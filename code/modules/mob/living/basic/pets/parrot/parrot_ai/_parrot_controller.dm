/datum/ai_controller/basic_controller/parrot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_HOARD_LOCATION_RANGE = 9,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/parrot

	planning_subtrees = list(
		/datum/ai_planning_subtree/parrot_as_in_repeat, // always get a witty oneliner in when you can
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/perch_on_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/hoard_items,
	)

/datum/idle_behavior/idle_random_walk/parrot
	///chance of us moving while perched
	var/walk_chance_when_perched = 5

/datum/idle_behavior/idle_random_walk/parrot/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	walk_chance = HAS_TRAIT(living_pawn, TRAIT_PARROT_PERCHED) ? walk_chance_when_perched : initial(walk_chance)
	return ..()

/datum/ai_behavior/travel_towards/and_drop

/datum/ai_behavior/travel_towards/and_drop/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	var/mob/living/living_mob = controller.pawn
	if(QDELETED(living_mob)) // pawn can be null at this point
		return
	var/obj/drop_item = locate(/obj/item) in (living_mob.contents - typecache_filter_list(living_mob.contents, controller.blackboard[BB_IGNORE_ITEMS]))
	drop_item?.forceMove(get_turf(living_mob))

/datum/ai_behavior/basic_melee_attack/interact_once/parrot

/datum/ai_behavior/basic_melee_attack/interact_once/parrot/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.set_blackboard_key(BB_ALWAYS_IGNORE_FACTION, FALSE)
