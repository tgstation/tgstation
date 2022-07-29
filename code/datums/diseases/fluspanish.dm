/datum/disease/fluspanish
	name = "Spanish inquisition Flu"
	max_stages = 3
	spread_text = "Airborne"
	cure_text = "Spaceacillin & Anti-bodies to the common flu"
	cures = list(/datum/reagent/medicine/spaceacillin)
	cure_chance = 5
	agent = "1nqu1s1t10n flu virion"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 0.75
	desc = "If left untreated the subject will burn to death for being a heretic."
	severity = DISEASE_SEVERITY_DANGEROUS


/datum/disease/fluspanish/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			affected_mob.adjust_bodytemperature(5 * delta_time)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(0.5, delta_time))
				to_chat(affected_mob, span_danger("You're burning in your own skin!"))
				affected_mob.take_bodypart_damage(0, 5, updating_health = FALSE)

		if(3)
			affected_mob.adjust_bodytemperature(10 * delta_time)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("sneeze")
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("cough")
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, span_danger("You're burning in your own skin!"))
				affected_mob.take_bodypart_damage(0, 5, updating_health = FALSE)
