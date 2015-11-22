/obj/effect/proc_holder/changeling/absorbDNA
	name = "Absorb DNA"
	desc = "Absorb the DNA of our victim."
	chemical_cost = 0
	dna_cost = 0
	req_human = 1
	max_genetic_damage = 100

/obj/effect/proc_holder/changeling/absorbDNA/can_sting(mob/living/carbon/user)
	if(!..())
		return

	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.isabsorbing)
		user << "<span class='warning'>We are already absorbing!</span>"
		return

	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		user << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them!</span>"
		return
	if(G.state <= GRAB_NECK)
		user << "<span class='warning'>We must have a tighter grip to absorb this creature!</span>"
		return

	var/mob/living/carbon/target = G.affecting
	return changeling.can_absorb_dna(user,target)



/obj/effect/proc_holder/changeling/absorbDNA/sting_action(mob/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/human/target = G.affecting
	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user << "<span class='notice'>This creature is compatible. We must hold still...</span>"
			if(2)
				user.visible_message("<span class='warning'>[user] extends a proboscis!</span>", "<span class='notice'>We extend a proboscis.</span>")
			if(3)
				user.visible_message("<span class='danger'>[user] stabs [target] with the proboscis!</span>", "<span class='notice'>We stab [target] with the proboscis.</span>")
				target << "<span class='userdanger'>You feel a sharp pain, followed by an awful draining sensation!</span>"
				target.take_overall_damage(40)

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(user, target, 200))
			user << "<span class='warning'>Our absorption of [target] has been interrupted!</span>"
			changeling.isabsorbing = 0
			return

	user.visible_message("<span class='danger'>[user] sucks the fluids from [target]!</span>", "<span class='notice'>We have absorbed [target].</span>")
	target << "<span class='userdanger'>You have been absorbed by a changeling!</span>"

	if(!changeling.has_dna(target.dna))
		changeling.add_profile(target, user)

	if(user.nutrition < NUTRITION_LEVEL_WELL_FED)
		user.nutrition = min((user.nutrition + target.nutrition), NUTRITION_LEVEL_WELL_FED)

	var/target_is_changeling = FALSE
	if(target.mind)//if the victim has got a mind

		target.mind.show_memory(src, 0) //I can read your mind, kekeke. Output all their notes.

		//Some of target's recent speech, so the changeling can attempt to imitate them better.
		//Recent as opposed to all because rounds tend to have a LOT of text.
		var/list/recent_speech = list()

		if(target.say_log.len > LING_ABSORB_RECENT_SPEECH)
			recent_speech = target.say_log.Copy(target.say_log.len-LING_ABSORB_RECENT_SPEECH+1,0) //0 so len-LING_ARS+1 to end of list
		else
			for(var/spoken_memory in target.say_log)
				if(recent_speech.len >= LING_ABSORB_RECENT_SPEECH)
					break
				recent_speech += spoken_memory

		if(recent_speech.len)
			user.mind.store_memory("<B>Some of [target]'s speech patterns, we should study these to better impersonate them!</B>")
			user << "<span class='boldnotice'>Some of [target]'s speech patterns, we should study these to better impersonate them!</span>"
			for(var/spoken_memory in recent_speech)
				user.mind.store_memory("\"[spoken_memory]\"")
				user << "<span class='notice'>\"[spoken_memory]\"</span>"
			user.mind.store_memory("<B>We have no more knowledge of [target]'s speech patterns.</B>")
			user << "<span class='boldnotice'>We have no more knowledge of [target]'s speech patterns.</span>"

		if(target.mind.changeling)//If the target was a changeling, suck out their extra juice and objective points!
			changeling.chem_charges += min(target.mind.changeling.chem_charges, changeling.chem_storage)
			changeling.absorbedcount += (target.mind.changeling.absorbedcount)
			changeling.geneticpoints += target.mind.changeling.total_genetic_points
			changeling.total_genetic_points += target.mind.changeling.total_genetic_points
			target_is_changeling = TRUE

			target.mind.changeling.stored_profiles.len = 1
			target.mind.changeling.absorbedcount = 0
			user << "<span class='boldnotice'>Our target was a changeling! We have gained all of their evolution points and genomes.</span>"

	if(!target_is_changeling)
		changeling.geneticpoints += 2
		changeling.total_genetic_points += 2
		user << "<span class='boldnotice'>Our absorption of a human has granted us two additional evolution points.</span>"


	changeling.chem_charges=min(changeling.chem_charges+10, changeling.chem_storage)

	changeling.isabsorbing = 0
	changeling.canrespec = 1

	target.death(0)
	target.Drain()
	return 1



//Absorbs the target DNA.
//datum/changeling/proc/absorb_dna(mob/living/carbon/T, mob/user)

//datum/changeling/proc/store_dna(datum/dna/new_dna, mob/user)




/obj/effect/proc_holder/changeling/swap_form
	name = "Swap Forms"
	desc = "We force ourselves into the body of another form, pushing their consciousness into the form we left behind."
	helptext = "We must be aggressively grabbing the creature to do this. We will retain all genetic information sans that of our old form, and the process will be obvious to any observers."
	chemical_cost = 40
	dna_cost = 1
	req_human = 1 //Monkeys can't grab

/obj/effect/proc_holder/changeling/swap_form/can_sting(mob/living/carbon/user)
	if(!..())
		return
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G) || (G.state < GRAB_AGGRESSIVE))
		user << "<span class='warning'>We must have an aggressive grab on creature in our active hand to do this!</span>"
		return
	var/mob/living/carbon/target = G.affecting
	if((target.disabilities & NOCLONE) || (target.disabilities & HUSK))
		user << "<span class='warning'>The DNA of [target] is ruined beyond usability!</span>"
		return
	if(!ishuman(target))
		user << "<span class='warning'>[target] is not compatible with this ability.</span>"
		return
	return 1


/obj/effect/proc_holder/changeling/swap_form/sting_action(mob/living/carbon/user)
	var/obj/item/weapon/grab/G = user.get_active_hand()
	var/mob/living/carbon/target = G.affecting
	var/datum/changeling/changeling = user.mind.changeling

	user << "<span class='notice'>We merge our fingers into [target]'s flesh and begin the consciousness transfer.</span>"
	target << "<span class='userdanger'>[user]'s fingers mold into your flesh as an agonizing sensation invades your body!</span>"
	target.do_jitter_animation(500)
	user.do_jitter_animation(500)

	if(!do_mob(user,target,20))
		user << "<span class='warning'>Your fingers are pulled away with [target], forcing you to regenerate them! The body swap has been interrupted!</span>"
		return

	if(!changeling.has_dna(target.dna))
		changeling.add_profile(target, user)
	changeling.remove_profile(user)

	var/mob/dead/observer/ghost = target.ghostize(0)
	user.mind.transfer_to(target)
	if(ghost && ghost.mind)
		ghost.mind.transfer_to(user)

	user << "<span class='userdanger'>You feel an awful vertigo and are swept into another body!</span>"
	user.Paralyse(2)
	target << "<span class='warning'>We swap our consciousness with [target]'s!</span>"
	target.Paralyse(2) //Metabreaker
