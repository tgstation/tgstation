/datum/ai_controller/basic_controller/dog
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_dog
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/dog,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/dog_harassment,
	)

/**
 * Same thing but with make tiny corgis and use access cards.
 */
/datum/ai_controller/basic_controller/dog/corgi
	blackboard = list(
		BB_DOG_HARASS_HARM = TRUE,
		BB_VISION_RANGE = AI_DOG_VISION_RANGE,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
		// Find nearby mobs with tongs in hand.
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/holding_object(/obj/item/kitchen/tongs),
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/pet/dog),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/pet/dog/corgi/puppy = 95, /mob/living/basic/pet/dog/corgi/puppy/void = 5),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/dog,
		/datum/ai_planning_subtree/make_babies, // Ian WILL prioritise sex over following your instructions
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/dog_harassment,
		// Find targets to run away from (uses the targetting datum from above)
		/datum/ai_planning_subtree/simple_find_target,
		// Flee from that target
		/datum/ai_planning_subtree/flee_target,
	)

/datum/ai_controller/basic_controller/dog/corgi/get_access()
	var/mob/living/basic/pet/dog/corgi/corgi_pawn = pawn
	if(!istype(corgi_pawn))
		return

	return corgi_pawn.access_card.GetAccess()
