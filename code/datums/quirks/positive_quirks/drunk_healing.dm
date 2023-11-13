/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make you feel on top of the world. Whenever you're drunk, you slowly recover from injuries."
	icon = FA_ICON_WINE_BOTTLE
	value = 8
	gain_text = span_notice("You feel like a drink would do you good.")
	lose_text = span_danger("You no longer feel like drinking would ease your pain.")
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/booze)

/datum/quirk/drunkhealing/process(seconds_per_tick)
	var/need_mob_update = FALSE
	switch(quirk_holder.get_drunk_amount())
		if (6 to 40)
			need_mob_update += quirk_holder.adjustBruteLoss(-0.1 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_holder.adjustFireLoss(-0.05 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		if (41 to 60)
			need_mob_update += quirk_holder.adjustBruteLoss(-0.4 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_holder.adjustFireLoss(-0.2 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		if (61 to INFINITY)
			need_mob_update += quirk_holder.adjustBruteLoss(-0.8 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_holder.adjustFireLoss(-0.4 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	if(need_mob_update)
		quirk_holder.updatehealth()
