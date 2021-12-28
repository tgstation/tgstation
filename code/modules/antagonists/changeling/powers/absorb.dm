/datum/action/changeling/absorb_dna
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	///if we're currently absorbing, used for sanity
	var/is_absorbing = FALSE

/datum/action/changeling/absorb_dna/can_sting(mob/living/carbon/owner)
	if(!..())
		return

	if(is_absorbing)
		to_chat(owner, span_warning("We are already absorbing!"))
		return

	if(!owner.pulling || !iscarbon(owner.pulling))
		to_chat(owner, span_warning("We must be grabbing a creature to absorb them!"))
		return
	if(owner.grab_state <= GRAB_NECK)
		to_chat(owner, span_warning("We must have a tighter grip to absorb this creature!"))
		return

	var/mob/living/carbon/target = owner.pulling
	var/datum/antagonist/changeling/changeling = owner.mind.has_antag_datum(/datum/antagonist/changeling)
	return changeling.can_absorb_dna(target)

/datum/action/changeling/absorb_dna/sting_action(mob/owner)
	var/datum/antagonist/changeling/changeling = owner.mind.has_antag_datum(/datum/antagonist/changeling)
	var/mob/living/carbon/human/target = owner.pulling
	is_absorbing = TRUE

	if(!attempt_absorb(target))
		return

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "4"))
	owner.visible_message(span_danger("[owner] sucks the fluids from [target]!"), span_notice("We have absorbed [target]."))
	to_chat(target, span_userdanger("You are absorbed by the changeling!"))

	if(!changeling.has_profile_with_dna(target.dna))
		changeling.add_new_profile(target)
		changeling.trueabsorbs++

	if(owner.nutrition < NUTRITION_LEVEL_WELL_FED)
		owner.set_nutrition(min((owner.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	// Absorb a lizard, speak Draconic.
	owner.copy_languages(target, LANGUAGE_ABSORB)

	if(target.mind && owner.mind)//if the victim and owner have minds
		absorb_memories(target)

	is_absorbing = FALSE

	changeling.adjust_chemicals(10)
	changeling.can_respec = TRUE

	target.death(0)
	target.Drain()
	return TRUE

/datum/action/changeling/absorb_dna/proc/absorb_memories(mob/living/carbon/human/target)
	var/datum/mind/suckedbrain = target.mind

	var/datum/antagonist/changeling/changeling = owner.mind.has_antag_datum(/datum/antagonist/changeling)

	for(var/memory_type in suckedbrain.memories)
		var/datum/memory/stolen_memory = suckedbrain.memories[memory_type]
		changeling.stolen_memories[stolen_memory.name] = stolen_memory.generate_story(STORY_CHANGELING_ABSORB)
	suckedbrain.wipe_memory()

	for(var/datum/antagonist/antagonist_datum as anything in suckedbrain.antag_datums)
		var/list/all_objectives = antagonist_datum.objectives.Copy()
		if(antagonist_datum.antag_memory)
			changeling.antag_memory += "[target]'s antagonist memories: [antagonist_datum.antag_memory]."
		if(!LAZYLEN(all_objectives))
			continue
		changeling.antag_memory += " Objectives:"
		var/obj_count = 1
		for(var/datum/objective/objective as anything in all_objectives)
			if(!objective) //nulls? in my objective list? it's more likely than you think.
				continue
			changeling.antag_memory += " Objective #[obj_count++]: [objective.explanation_text]."
			var/list/datum/mind/other_owners = objective.get_owners() - suckedbrain
			if(!other_owners.len)
				continue
			for(var/datum/mind/conspirator as anything in other_owners)
				changeling.antag_memory += " Objective Conspirator: [conspirator.name]."
	changeling.antag_memory += " That's all [target] had. "

	//Some of target's recent speech, so the changeling can attempt to imitate them better.
	//Recent as opposed to all because rounds tend to have a LOT of text.

	var/list/recent_speech = list()
	var/list/say_log = list()
	var/log_source = target.logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				say_log = reverse_range(reversed.Copy())
				break

	if(LAZYLEN(say_log) > LING_ABSORB_RECENT_SPEECH)
		recent_speech = say_log.Copy(say_log.len-LING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
	else
		for(var/spoken_memory in say_log)
			if(recent_speech.len >= LING_ABSORB_RECENT_SPEECH)
				break
			recent_speech[spoken_memory] = splittext(say_log[spoken_memory], "\"", 1, 0, TRUE)[3]

	if(recent_speech.len)
		changeling.antag_memory += "<B>Some of [target]'s speech patterns, we should study these to better impersonate [target.p_them()]!</B><br>"
		to_chat(owner, span_boldnotice("Some of [target]'s speech patterns, we should study these to better impersonate [target.p_them()]!"))
		for(var/spoken_memory in recent_speech)
			changeling.antag_memory += "\"[recent_speech[spoken_memory]]\"<br>"
			to_chat(owner, span_notice("\"[recent_speech[spoken_memory]]\""))
		changeling.antag_memory += "<B>We have no more knowledge of [target]'s speech patterns.</B><br>"
		to_chat(owner, span_boldnotice("We have no more knowledge of [target]'s speech patterns."))


	var/datum/antagonist/changeling/target_ling = target.mind.has_antag_datum(/datum/antagonist/changeling)
	if(target_ling)//If the target was a changeling, suck out their extra juice and objective points!
		to_chat(owner, span_boldnotice("[target] was one of us. We have absorbed their power."))

		// Gain half of their genetic points.
		var/genetic_points_to_add = round(target_ling.total_genetic_points / 2)
		changeling.genetic_points += genetic_points_to_add
		changeling.total_genetic_points += genetic_points_to_add

		// And half of their chemical charges.
		var/chems_to_add = round(target_ling.total_chem_storage / 2)
		changeling.adjust_chemicals(chems_to_add)
		changeling.total_chem_storage += chems_to_add

		// And of course however many they've absorbed, we've absorbed
		changeling.absorbed_count += target_ling.absorbed_count

		// Lastly, make them not a ling anymore. (But leave their objectives for round-end purposes).
		var/list/copied_objectives = target_ling.objectives.Copy()
		target.mind.remove_antag_datum(/datum/antagonist/changeling)
		var/datum/antagonist/fallen_changeling/fallen = target.mind.add_antag_datum(/datum/antagonist/fallen_changeling)
		fallen.objectives = copied_objectives

/datum/action/changeling/absorb_dna/proc/attempt_absorb(mob/living/carbon/human/target)
	for(var/absorbing_iteration in 1 to 3)
		switch(absorbing_iteration)
			if(1)
				to_chat(owner, span_notice("This creature is compatible. We must hold still..."))
			if(2)
				owner.visible_message(span_warning("[owner] extends a proboscis!"), span_notice("We extend a proboscis."))
			if(3)
				owner.visible_message(span_danger("[owner] stabs [target] with the proboscis!"), span_notice("We stab [target] with the proboscis."))
				to_chat(target, span_userdanger("You feel a sharp stabbing pain!"))
				target.take_overall_damage(40)

		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[absorbing_iteration]"))
		if(!do_mob(owner, target, 15 SECONDS))
			to_chat(owner, span_warning("Our absorption of [target] has been interrupted!"))
			is_absorbing = FALSE
			return FALSE
	return TRUE
