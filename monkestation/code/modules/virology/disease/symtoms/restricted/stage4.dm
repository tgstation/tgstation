/datum/symptom/heart_failure
	name = "Myocardial Infarction"
	desc = "If left untreated the subject will die!"
	restricted = TRUE
	max_multiplier = 5
	var/sound = FALSE

/datum/symptom/heart_failure/activate(mob/living/carbon/affected_mob)
	. = ..()
	if(ismouse(affected_mob))
		affected_mob.death()
		return FALSE

	if(!affected_mob.can_heartattack())
		affected_mob.death()
		return FALSE

	switch(round(multiplier))
		if(1 to 2)
			if(prob(1))
				to_chat(affected_mob, span_warning("You feel [pick("discomfort", "pressure", "a burning sensation", "pain")] in your chest."))
			if(prob(1))
				to_chat(affected_mob, span_warning("You feel dizzy."))
				affected_mob.adjust_confusion(6 SECONDS)
			if(prob(1.5))
				to_chat(affected_mob, span_warning("You feel [pick("full", "nauseated", "sweaty", "weak", "tired", "short of breath", "uneasy")]."))
		if(3 to 4)
			if(!sound)
				affected_mob.playsound_local(affected_mob, 'sound/health/slowbeat.ogg', 40, FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
				sound = TRUE
			if(prob(1.5))
				to_chat(affected_mob, span_danger("You feel a sharp pain in your chest!"))
				if(prob(25))
					affected_mob.vomit(95)
				affected_mob.emote("cough")
				affected_mob.Paralyze(40)
				affected_mob.losebreath += 4
			if(prob(1.5))
				to_chat(affected_mob, span_danger("You feel very weak and dizzy..."))
				affected_mob.adjust_confusion(8 SECONDS)
				affected_mob.stamina.adjust(-40, FALSE)
				affected_mob.emote("cough")
		if(5)
			affected_mob.stop_sound_channel(CHANNEL_HEARTBEAT)
			affected_mob.playsound_local(affected_mob, 'sound/effects/singlebeat.ogg', 100, FALSE, use_reverb = FALSE)
			if(affected_mob.stat == CONSCIOUS)
				affected_mob.visible_message(span_danger("[affected_mob] clutches at [affected_mob.p_their()] chest as if [affected_mob.p_their()] heart is stopping!"), \
					span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
			affected_mob.stamina.adjust(-60, FALSE)
			affected_mob.set_heartattack(TRUE)
			affected_mob.reagents.add_reagent(/datum/reagent/medicine/c2/penthrite, 3) // To give the victim a final chance to shock their heart before losing consciousness
			return FALSE
