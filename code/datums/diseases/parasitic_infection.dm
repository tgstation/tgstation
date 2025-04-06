/datum/disease/parasite
	form = "Parasite"
	name = "Parasitic Infection"
	max_stages = 4
	cure_text = "Surgical removal of the liver."
	agent = "Consuming Live Parasites"
	spread_text = "Non-Biological"
	viable_mobtypes = list(/mob/living/carbon/human)
	spreading_modifier = 1
	desc = "If left untreated the subject will passively lose nutrients, and eventually lose their liver."
	severity = DISEASE_SEVERITY_HARMFUL
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = DISEASE_SPREAD_NON_CONTAGIOUS
	required_organ = ORGAN_SLOT_LIVER
	bypasses_immunity = TRUE

/datum/disease/parasite/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.emote("cough")
		if(2)
			if(SPT_PROB(5, seconds_per_tick))
				if(prob(50))
					to_chat(affected_mob, span_notice("You feel the weight loss already!"))
				affected_mob.adjust_nutrition(-3)
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(prob(20))
					to_chat(affected_mob, span_notice("You're... REALLY starting to feel the weight loss."))
				affected_mob.adjust_nutrition(-6)
		if(4)
			if(SPT_PROB(16, seconds_per_tick))
				if(affected_mob.nutrition >= 100)
					if(prob(10))
						to_chat(affected_mob, span_warning("You feel like your body's shedding weight rapidly!"))
					affected_mob.adjust_nutrition(-12)
				else
					to_chat(affected_mob, span_warning("You feel much, MUCH lighter!"))
					affected_mob.vomit(VOMIT_CATEGORY_BLOOD, lost_nutrition = 20)
					// disease code already checks if the liver exists otherwise it is cured
					var/obj/item/organ/liver/affected_liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
					affected_liver.Remove(affected_mob)
					affected_liver.forceMove(get_turf(affected_mob))
					cure()
					return FALSE
