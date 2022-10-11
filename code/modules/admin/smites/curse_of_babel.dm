/// Strikes the target with a lightning bolt
/datum/smite/curse_of_babel
	name = "Curse of Babel"
	/// How long should the effect last
	var/duration

/datum/smite/curse_of_babel/configure(client/user)
	switch(tgui_alert(user, "How long would you like this effect to last?", list("Permanent", "1 MINUTE", "5 MINUTES", "10 MINUTES")))
		if("Permanent")
			duration = INFINITE
		if("1 MINUTE")
			duration = 1 MINUTES
		if("5 MINUTES")
			duration = 5 MINUTES
		if("10 MINUTES")
			duration = 10 MINUTES

/datum/smite/curse_of_babel/effect(client/user, mob/living/carbon/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	target.adjust_timed_status_effect(duration, /datum/status_effect/tower_of_babel/magical)
	to_chat(target, span_userdanger("The gods have punished you for your sins!"), confidential = TRUE)
