/datum/ai_controller/basic_controller/dog
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/datums/ai/dog/dog.bt.json"

/**
 * Same thing but with make tiny corgis and use access cards.
 */
/datum/ai_controller/basic_controller/dog/corgi
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		// Find nearby mobs ...
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/holding_object,
		// With tongs in hand!
		BB_TARGET_HELD_ITEM = /obj/item/kitchen/tongs,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/pet/dog),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/pet/dog/corgi/puppy),
	)
	behavior_tree_json = "code/datums/ai/dog/dog_corgi.bt.json"

/datum/ai_controller/basic_controller/dog/corgi/get_access()
	var/mob/living/basic/pet/dog/corgi/corgi_pawn = pawn
	if(!istype(corgi_pawn))
		return

	return corgi_pawn.access_card.GetAccess()

/datum/ai_controller/basic_controller/dog/puppy
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/holding_object,
		// With tongs in hand!
		BB_TARGET_HELD_ITEM = /obj/item/kitchen/tongs,
		BB_FUCKS = FALSE, // Puppies don't
	)
	behavior_tree_json = "code/datums/ai/dog/dog_corgi.bt.json"
