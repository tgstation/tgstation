/datum/ai_controller/basic_controller/cat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_HOSTILE_MEOWS = list("Mawwww", "Mrewwww", "mhhhhng..."),
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/pet/cat),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/pet/cat/kitten),
		BB_FUCKS = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat.bt.json"

/datum/ai_controller/basic_controller/cat/kitten
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_HUNGRY_MEOW = list("mrrp...", "mraw..."),
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_MAX_DISTANCE_TO_FOOD = 2,
	)

	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/kitten.bt.json"

/datum/ai_controller/basic_controller/cat/bread
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_bread.bt.json"

/datum/ai_controller/basic_controller/cat/cake
	behavior_tree_json = "code/modules/mob/living/basic/pets/cat/cat_cake.bt.json"
