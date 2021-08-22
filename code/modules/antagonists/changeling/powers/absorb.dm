/datum/action/changeling/absorb_dna
	name = "Assimilate DNA"
	desc = "Assimilate the DNA of our victim. Requires us to strangle them."
	button_icon_state = "absorb_dna"
	chemical_cost = 0
	dna_cost = 0
	req_human = 1

/datum/action/changeling/absorb_dna/can_sting(mob/living/carbon/user)
	if(!..())
		return

	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)

	if(changeling.isabsorbing)
		to_chat(user, span_warning("We are already absorbing!"))
		return

	if(!user.pulling || !iscarbon(user.pulling))
		to_chat(user, span_warning("We must be grabbing a creature to absorb them!"))
		return
	if(user.grab_state <= GRAB_NECK)
		to_chat(user, span_warning("We must have a tighter grip to absorb this creature!"))
		return

	var/mob/living/carbon/target = user.pulling
	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(user, span_warning("They are one of us!"))
		return
	return changeling.can_absorb_dna(target)

/datum/action/changeling/absorb_dna/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/mob/living/carbon/human/target = user.pulling
	changeling.isabsorbing = 1
	for(var/i in 1 to 3)
		switch(i)
			if(1)
				to_chat(user, span_notice("This creature is compatible. We must hold still..."))
			if(2)
				user.visible_message(span_warning("[user] extends a proboscis!"), span_notice("We extend a proboscis."))
			if(3)
				user.visible_message(span_danger("[user] stabs [target] with the proboscis!"), span_notice("We stab [target] with the proboscis."))
				to_chat(target, span_userdanger("You feel a sharp stabbing pain!"))
				target.take_overall_damage(40)

		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "[i]"))
		if(!do_mob(user, target, 150))
			to_chat(user, span_warning("Our absorption of [target] has been interrupted!"))
			changeling.isabsorbing = 0
			return

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("Absorb DNA", "4"))
	user.visible_message(span_danger("[user] assimilates [target]!"), span_notice("We have assimilated [target]."))
	to_chat(target, span_userdanger("You are assimilated by the changeling!"))

	if(!changeling.has_dna(target.dna))
		changeling.add_new_profile(target)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.set_nutrition(min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED))

	// Absorb a lizard, speak Draconic.
	owner.copy_languages(target, LANGUAGE_ABSORB)

	if(target.mind && user.mind)
		target.mind.add_antag_datum(/datum/antagonist/changeling)
		target.fully_heal(TRUE)
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)

	changeling.chem_charges=min(changeling.chem_charges+10, changeling.chem_storage)

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	return TRUE
