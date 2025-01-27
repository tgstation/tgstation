/datum/disease/weightlessness
	name = "Localized Weightloss Malfunction"
	max_stages = 4
	spread_text = "On Contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Liquid dark matter"
	cures = list(/datum/reagent/liquid_dark_matter)
	agent = "Sub-quantum DNA Repulsion"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	spreading_modifier = 0.5
	cure_chance = 4
	desc = "This disease results in a low level rewrite of the patient's bioelectric signature, causing them to reject the phenomena of \"weight\". Ingestion of liquid dark matter tends to stabilize the field."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC


/datum/disease/weightlessness/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(affected_mob, span_danger("You almost lose your balance for a second."))
		if(2)
			if(SPT_PROB(3, seconds_per_tick) && !HAS_TRAIT_FROM(affected_mob, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT))
				to_chat(affected_mob, span_danger("You feel yourself lift off the ground."))
				affected_mob.reagents.add_reagent(/datum/reagent/gravitum, 1)

		if(4)
			if(SPT_PROB(3, seconds_per_tick) && !affected_mob.has_quirk(/datum/quirk/spacer_born))
				to_chat(affected_mob, span_danger("You feel sick as the world starts moving around you."))
				affected_mob.adjust_confusion(3 SECONDS)
			if(SPT_PROB(8, seconds_per_tick) && !HAS_TRAIT_FROM(affected_mob, TRAIT_MOVE_FLOATING, NO_GRAVITY_TRAIT))
				to_chat(affected_mob, span_danger("You suddenly lift off the ground."))
				affected_mob.reagents.add_reagent(/datum/reagent/gravitum, 5)

/datum/disease/weightlessness/cure(add_resistance)
	. = ..()
	affected_mob.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 95, purge_ratio = 0.4)
	to_chat(affected_mob, span_danger("You fall to the floor as your body stops rejecting gravity."))
