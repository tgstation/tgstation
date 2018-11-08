//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "extensive damage to the brain's speech center"
	gain_text = "<span class='warning'>You forget how to speak!</span>"
	lose_text = "<span class='notice'>You suddenly remember how to speak.</span>"

/datum/brain_trauma/severe/mute/on_gain()
	owner.add_trait(TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/mute/on_lose()
	owner.remove_trait(TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/aphasia
	name = "Aphasia"
	desc = "Patient is unable to speak or understand any language."
	scan_desc = "extensive damage to the brain's language center"
	gain_text = "<span class='warning'>You have trouble forming words in your head...</span>"
	lose_text = "<span class='notice'>You suddenly remember how languages work.</span>"
	var/datum/language_holder/prev_language
	var/datum/language_holder/mob_language

/datum/brain_trauma/severe/aphasia/on_gain()
	mob_language = owner.get_language_holder()
	prev_language = mob_language.copy()
	mob_language.remove_all_languages()
	mob_language.grant_language(/datum/language/aphasia)
	..()

/datum/brain_trauma/severe/aphasia/on_lose()
	mob_language.remove_language(/datum/language/aphasia)
	mob_language.copy_known_languages_from(prev_language) //this will also preserve languages learned during the trauma
	QDEL_NULL(prev_language)
	mob_language = null
	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "extensive damage to the brain's occipital lobe"
	gain_text = "<span class='warning'>You can't see!</span>"
	lose_text = "<span class='notice'>Your vision returns.</span>"

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control its motor functions."
	scan_desc = "cerebral paralysis"
	gain_text = "<span class='warning'>You can't feel your body anymore!</span>"
	lose_text = "<span class='notice'>You can feel your limbs again!</span>"

/datum/brain_trauma/severe/paralysis/on_life()
	owner.Paralyze(200, ignore_canknockdown = TRUE)
	..()

/datum/brain_trauma/severe/paralysis/on_lose()
	owner.SetParalyzed(0)
	..()

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	scan_desc = "traumatic narcolepsy"
	gain_text = "<span class='warning'>You have a constant feeling of drowsiness...</span>"
	lose_text = "<span class='notice'>You feel awake and aware again.</span>"

/datum/brain_trauma/severe/narcolepsy/on_life()
	..()
	if(owner.IsSleeping())
		return
	var/sleep_chance = 1
	if(owner.m_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(owner.drowsyness)
		sleep_chance += 3
	if(prob(sleep_chance))
		to_chat(owner, "<span class='warning'>You fall asleep.</span>")
		owner.Sleeping(60)
	else if(!owner.drowsyness && prob(sleep_chance * 2))
		to_chat(owner, "<span class='warning'>You feel tired...</span>")
		owner.drowsyness += 10

/datum/brain_trauma/severe/monophobia
	name = "Monophobia"
	desc = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."
	scan_desc = "severe monophobia"
	gain_text = ""
	lose_text = "<span class='notice'>You feel like you could be safe on your own.</span>"
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_gain()
	..()
	if(check_alone())
		to_chat(owner, "<span class='warning'>You feel really lonely...</span>")
	else
		to_chat(owner, "<span class='notice'>You feel safe, as long as you have people around you.</span>")

/datum/brain_trauma/severe/monophobia/on_life()
	..()
	if(check_alone())
		stress = min(stress + 0.5, 100)
		if(stress > 10 && (prob(5)))
			stress_reaction()
	else
		stress -= 4

/datum/brain_trauma/severe/monophobia/proc/check_alone()
	if(owner.has_trait(TRAIT_BLIND))
		return TRUE
	for(var/mob/M in oview(owner, 7))
		if(!isliving(M)) //ghosts ain't people
			continue
		if((istype(M, /mob/living/simple_animal/pet)) || M.ckey)
			return FALSE
	return TRUE

/datum/brain_trauma/severe/monophobia/proc/stress_reaction()
	if(owner.stat != CONSCIOUS)
		return

	var/high_stress = (stress > 60) //things get psychosomatic from here on
	switch(rand(1,6))
		if(1)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>You feel sick...</span>")
			else
				to_chat(owner, "<span class='warning'>You feel really sick at the thought of being alone!</span>")
			addtimer(CALLBACK(owner, /mob/living/carbon.proc/vomit, high_stress), 50) //blood vomit if high stress
		if(2)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>You can't stop shaking...</span>")
				owner.dizziness += 20
				owner.confused += 20
				owner.Jitter(20)
			else
				to_chat(owner, "<span class='warning'>You feel weak and scared! If only you weren't alone...</span>")
				owner.dizziness += 20
				owner.confused += 20
				owner.Jitter(20)
				owner.adjustStaminaLoss(50)

		if(3, 4)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>You feel really lonely...</span>")
			else
				to_chat(owner, "<span class='warning'>You're going mad with loneliness!</span>")
				owner.hallucination += 30

		if(5)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>Your heart skips a beat.</span>")
				owner.adjustOxyLoss(8)
			else
				if(prob(15) && ishuman(owner))
					var/mob/living/carbon/human/H = owner
					H.set_heartattack(TRUE)
					to_chat(H, "<span class='userdanger'>You feel a stabbing pain in your heart!</span>")
				else
					to_chat(owner, "<span class='userdanger'>You feel your heart lurching in your chest...</span>")
					owner.adjustOxyLoss(8)

/datum/brain_trauma/severe/discoordination
	name = "Discoordination"
	desc = "Patient is unable to use complex tools or machinery."
	scan_desc = "extreme discoordination"
	gain_text = "<span class='warning'>You can barely control your hands!</span>"
	lose_text = "<span class='notice'>You feel in control of your hands again.</span>"

/datum/brain_trauma/severe/discoordination/on_gain()
	owner.add_trait(TRAIT_MONKEYLIKE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/discoordination/on_lose()
	owner.remove_trait(TRAIT_MONKEYLIKE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/pacifism
	name = "Traumatic Non-Violence"
	desc = "Patient is extremely unwilling to harm others in violent ways."
	scan_desc = "pacific syndrome"
	gain_text = "<span class='notice'>You feel oddly peaceful.</span>"
	lose_text = "<span class='notice'>You no longer feel compelled to not harm.</span>"

/datum/brain_trauma/severe/pacifism/on_gain()
	owner.add_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/pacifism/on_lose()
	owner.remove_trait(TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/hypnotic_stupor
	name = "Hypnotic Stupor"
	desc = "Patient is prone to episodes of extreme stupor that leaves them extremely suggestible."
	scan_desc = "oneiric feedback loop"
	gain_text = "<span class='warning'>You feel somewhat dazed.</span>"
	lose_text = "<span class='notice'>You feel like a fog was lifted from your mind.</span>"

/datum/brain_trauma/severe/hypnotic_stupor/on_lose() //hypnosis must be cleared separately, but brain surgery should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_stupor/on_life()
	..()
	if(prob(1) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)
