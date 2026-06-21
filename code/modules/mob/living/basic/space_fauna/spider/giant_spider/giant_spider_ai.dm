/// Attacks people it can see, spins webs if it can't see anything to attack.
/datum/ai_controller/basic_controller/giant_spider
	behavior_tree_json = "giant_spider.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("chitters."), // Space spiders are taxonomically insects not arachnids, don't DM me
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/insect/chitter.ogg'),
			BB_SPEAK_CHANCE = 5,
		),
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/// Giant spider which won't attack structures
/datum/ai_controller/basic_controller/giant_spider/weak
	behavior_tree_json = "giant_spider_weak.bt.json"

/// Used by Araneus, who only attacks those who attack first. He is house-trained and will not web up the HoS office.
/datum/ai_controller/basic_controller/giant_spider/retaliate
	behavior_tree_json = "giant_spider_retaliate.bt.json"

/// Retaliates, hunts other maintenance creatures, runs away from larger attackers, and spins webs.
/datum/ai_controller/basic_controller/giant_spider/pest
	behavior_tree_json = "giant_spider_pest.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/ours_or_smaller, // Hunt mobs our size
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/larger, // Run away from mobs bigger than we are
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_HEAR = list("chitters."),
			BB_EMOTE_SOUND = list('sound/mobs/non-humanoids/insect/chitter.ogg'),
			BB_SPEAK_CHANCE = 5,
		),
	)
