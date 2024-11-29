/datum/smite/retcon
	name = "Retcon"
	/// how long until the thing attacked by this smite gets deleted
	var/timer 
	/// the time it takes to actually do the fade out animation, the victim will always have some time still fully visible
	var/fade_out_timer 

/datum/smite/retcon/configure(client/user)
	timer = tgui_input_number(user, "How long should it take before the retcon, in seconds?", "Retcon", 5)
	fade_out_timer = timer*(3/5)

/datum/smite/retcon/effect(client/user, mob/living/target)
	. = ..()
	target.fade_into_nothing(life_time = timer SECONDS, fade_time = fade_out_timer SECONDS)
