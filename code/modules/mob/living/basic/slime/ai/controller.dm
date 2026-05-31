/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_SLIME_RABID = FALSE,
		BB_SLIME_HUNGER_DISABLED = FALSE,
		BB_BASIC_MOB_SPEAK_LINES = list(
			BB_EMOTE_SAY = list("Blorble...","Bzzt...",""),
			BB_EMOTE_HEAR = list("blorbles."),
			BB_EMOTE_SEE = list("lights up for a bit, then stops.","bounces in place.", "jiggles!","vibrates!"),
			BB_SPEAK_CHANCE = 1,
		),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/slime/ai/slime.bt.json"

/datum/ai_controller/basic_controller/slime/CancelActions()
	..()
	if(QDELETED(pawn))
		return

	var/mob/living/basic/slime/slime_pawn = pawn
	slime_pawn.stop_feeding()
