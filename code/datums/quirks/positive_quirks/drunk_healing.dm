/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Ничто так не помогает почувствовать себя на вершине мира, как хорошая выпивка. Когда вы пьяны, вы медленно восстанавливаетесь от повреждений."
	icon = FA_ICON_WINE_BOTTLE
	value = 8
	gain_text = span_notice("Вам кажется, что немного выпить не помешает.")
	lose_text = span_danger("Вам больше не хочется пить, чтобы облегчить боль.")
	medical_record_text = "У пациента необычайно эффективный метаболизм печени, и он может медленно регенерировать раны, употребляя алкогольные напитки."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/booze)

/datum/quirk/drunkhealing/process(seconds_per_tick)
	var/need_mob_update = FALSE
	switch(quirk_holder.get_drunk_amount())
		if (6 to 40)
			need_mob_update += quirk_holder.adjust_brute_loss(-0.1 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_holder.adjust_fire_loss(-0.05 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		if (41 to 60)
			need_mob_update += quirk_holder.adjust_brute_loss(-0.4 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_holder.adjust_fire_loss(-0.2 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
		if (61 to INFINITY)
			need_mob_update += quirk_holder.adjust_brute_loss(-0.8 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
			need_mob_update += quirk_holder.adjust_fire_loss(-0.4 * seconds_per_tick, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	if(need_mob_update)
		quirk_holder.updatehealth()
