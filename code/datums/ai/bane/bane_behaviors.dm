
/datum/ai_behavior/break_spine/bane/finish_action(datum/ai_controller/controller, succeeded)
	var/list/bane_quotes = strings("bane.json", "bane")
	var/mob/living/bane = controller.pawn
	bane.say(pick(bane_quotes))
	. = ..()
