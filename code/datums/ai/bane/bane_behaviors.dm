
/datum/ai_behavior/break_spine/bane/finish_action(datum/ai_controller/controller, succeeded, target_key)
	if(succeeded)
		var/list/bane_quotes = strings("bane.json", "bane")
		var/mob/living/bane = controller.pawn
		if(QDELETED(bane)) // pawn can be null at this point
			return ..()
		bane.say(pick(bane_quotes))
	return ..()
