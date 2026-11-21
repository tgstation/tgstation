/datum/ai_controller/basic_controller/stoat
	behavior_tree_json = "code/modules/mob/living/basic/stoats/stoat.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/smaller,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_GUILTY_CONSCIOUS_CHANCE = 5,
		BB_STEAL_CHANCE = 25,
		BB_STEAL_TARGET_PRIORITIES = list(
			/obj/item/disk/nuclear = 70,
			/obj/item/card/id = 50,
			/obj/item/gun = 30,
			/obj/item/grenade = 30,
		),
		BB_STEAL_FALLBACK_PRIORITY = 5,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/stoat),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/stoat/kit),
		BB_FUCKS = TRUE
	)
	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/stoat/kit
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/smaller,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_GUILTY_CONSCIOUS_CHANCE = 5,
		BB_STEAL_CHANCE = 2,
		BB_STEAL_TARGET_PRIORITIES = list(
			/obj/item/disk/nuclear = 500,
			/obj/item/card/id = 50,
			/obj/item/gun = 30,
			/obj/item/grenade = 30,
		),
		BB_STEAL_FALLBACK_PRIORITY = 5,
		BB_FUCKS = FALSE
	)
	ai_movement = /datum/ai_movement/basic_avoidance
