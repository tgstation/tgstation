/// Geese like to eat random objects and kill themselves, and occasionally get pissed off for no reason
/datum/ai_controller/basic_controller/goose
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SEARCH_RANGE = 1,
		BB_EAT_FOOD_COOLDOWN = 10 SECONDS,
		BB_EAT_EMOTES = list()
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/goose

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/random_speech/goose,
		/datum/ai_planning_subtree/capricious_retaliate,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food/goose,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Goose who doesn't randomly retaliate but does still try to die by eating random items
/datum/ai_controller/basic_controller/goose/calm
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_SEARCH_RANGE = 1,
		BB_EAT_FOOD_COOLDOWN = 0.5 SECONDS, // Uh oh
		BB_EAT_EMOTES = list()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/goose,
		/datum/ai_planning_subtree/use_mob_ability/goose_vomit,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food/goose,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Walk more if we're choking or vomiting
/datum/idle_behavior/idle_random_walk/goose

/datum/idle_behavior/idle_random_walk/goose/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	walk_chance = controller.blackboard[BB_GOOSE_PANICKED] ? 100 : 25 // I think this sets it for every goose but that's fine because it'll reset it before using it
	return ..()

/// Only look for things geese will try to eat
/datum/ai_planning_subtree/find_food/goose
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/goose_food

/datum/ai_planning_subtree/find_food/goose/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (controller.blackboard[BB_GOOSE_PANICKED])
		return // Don't look for food while choking or vomiting
	return ..()

/// Only set things geese will try to eat
/datum/ai_behavior/find_and_set/in_list/goose_food

/datum/ai_behavior/find_and_set/in_list/goose_food/search_tactic(datum/ai_controller/controller, locate_paths, search_range)
	var/list/found = typecache_filter_list(oview(search_range, controller.pawn), locate_paths)
	if(!length(found))
		return

	var/list/filtered = list()
	for (var/obj/item/thing as anything in found)
		if (IsEdible(thing) || thing.has_material_type(/datum/material/plastic))
			filtered += thing

	if(length(filtered))
		return pick(filtered)

/// Use this ability only if we roll a dice correctly
/datum/ai_planning_subtree/use_mob_ability/goose_vomit

/datum/ai_planning_subtree/use_mob_ability/goose_vomit/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/trigger_prob = controller.blackboard[BB_GOOSE_VOMIT_CHANCE] || 0
	if (prob(trigger_prob))
		return ..()

/datum/ai_planning_subtree/random_speech/goose
	speech_chance = 3
	emote_hear = list("honks.", "honks loudly.", "honks aggressively.")
	emote_see = list("flaps.", "preens.", "glares around.")
	speak = list("Honk!")
