//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/severe

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "extensive damage to the brain's language center"
	gain_text = "<span class='warning'>You forget how to speak!</span>"
	lose_text = "<span class='notice'>You suddenly remember how to speak.</span>"

/datum/brain_trauma/severe/mute/on_gain()
	owner.disabilities |= MUTE
	..()

//no fiddling with genetics to get out of this one
/datum/brain_trauma/severe/mute/on_life()
	if(!(owner.disabilities & MUTE))
		on_gain()
	..()

/datum/brain_trauma/severe/mute/on_lose()
	owner.disabilities &= ~MUTE
	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "extensive damage to the brain's frontal lobe"
	gain_text = "<span class='warning'>You can't see!</span>"
	lose_text = "<span class='notice'>Your vision returns.</span>"

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind()
	..()

//no fiddling with genetics to get out of this one
/datum/brain_trauma/severe/blindness/on_life()
	if(!(owner.disabilities & BLIND))
		on_gain()
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind()
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control its motor functions."
	scan_desc = "cerebral paralysis"
	gain_text = "<span class='warning'>You can't feel your body anymore!</span>"
	lose_text = "<span class='notice'>You can feel your limbs again!</span>"

/datum/brain_trauma/severe/paralysis/on_life()
	owner.Knockdown(200, ignore_canknockdown = TRUE)
	..()

/datum/brain_trauma/severe/paralysis/on_lose()
	owner.SetKnockdown(0)
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
	if(owner.disabilities & BLIND)
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
				owner.hallucination += 20

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
	owner.disabilities |= MONKEYLIKE
	..()

/datum/brain_trauma/severe/discoordination/on_lose()
	owner.disabilities &= ~MONKEYLIKE
	..()
