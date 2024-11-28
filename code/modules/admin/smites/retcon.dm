/datum/smite/retcon
	name = "Retcon"
	var/timer //how long until the thing attacked by this smite gets deleted
	var/fade_out_timer //the time it takes to actually do the fade out animation, the victim will always have some time still fully visible

/datum/smite/retcon/configure(client/user)
	timer = tgui_input_number(user, "How long should it take before the retcon, in seconds?", "Retcon", 5)
	fade_out_timer = timer*(3/5)

/datum/smite/retcon/effect(client/user, mob/living/target)
	. = ..()
	target.temporary_atom(life_time = timer SECONDS, fade_time = fade_out_timer SECONDS)
