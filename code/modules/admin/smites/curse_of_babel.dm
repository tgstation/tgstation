/// Strikes the target with a lightning bolt
/datum/smite/curse_of_babel
	name = "Curse of Babel"
	/// How long should the effect last
	var/duration

/datum/smite/curse_of_babel/configure(client/user)
	duration = tgui_input_number(user, "How many minutes would you like this effect to last?", "Time", 1, 60, -1, round_value = FALSE) MINUTES

/datum/smite/curse_of_babel/effect(client/user, mob/living/carbon/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	target.apply_status_effect(/datum/status_effect/tower_of_babel, duration)
	to_chat(target, span_userdanger("The gods have punished you for your sins!"), confidential = TRUE)
