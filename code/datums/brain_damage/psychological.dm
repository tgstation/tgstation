/*TODO:
	PTSD
	Schizophrenia
*/
/datum/brain_trauma/psychological/depression
	name = "Depression"
	desc = "Extensive damage to receptors in brain result in subject's neigh constant bad mood"
	scan_desc = "Extensive damage to serotonin receptors"
	gain_text = "<span class='warning'>You feel emptier inside!</span>"
	lose_text = "<span class='notice'>You feel whole once again.</span>"

/datum/brain_trauma/psychological/depression/on_gain()
	ADD_TRAIT(owner, TRAIT_DEPRESSION, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/depression/on_lose()
	REMOVE_TRAIT(owner, TRAIT_DEPRESSION, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/depression/on_life()
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(prob(5)) //this is much much worse then before!
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)


/datum/brain_trauma/psychological/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel easier about talking again.</span>" //if only it were that easy!
	scan_desc = "Underdeveloped hemisphere to hemisphere connections"
	var/dumb_thing = TRUE

/datum/brain_trauma/psychological/social_anxiety/on_life()
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in oview(3, owner))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = owner
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato(get_turf(H)) //now that's what I call spaghetti code


/datum/brain_trauma/psychological/social_anxiety/on_gain()
	ADD_TRAIT(owner, TRAIT_SOCIAL_ANXIETY, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/social_anxiety/on_lose()
	REMOVE_TRAIT(owner, TRAIT_SOCIAL_ANXIETY, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/schizophrenia/paranoid
	name = "Paranoid schizophrenia"
	desc = "Mental disorder that is characterized by auditory and visual hallucinations"
	gain_text = "<span class='danger'>You hear whispers behind you.</span>"
	lose_text = "<span class='notice'>Voices stop responding.</span>"
	scan_desc = "Electric impulses detected in brain correspond to some form of schizophrenia"
	var/active = FALSE

/datum/brain_trauma/psychological/schizophrenia/paranoid/on_life()
	..()
	owner.hallucination += 20
	if(prob(25))
		owner.Jitter(2)
	if(prob(5))
		owner.Unconscious(80)
	if(!active && prob(2))
		whispering()

/datum/brain_trauma/psychological/schizophrenia/paranoid/proc/whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE, PSYCH_TRAIT)
	active = TRUE
	addtimer(CALLBACK(src, .proc/cease_whispering), rand(50, 300))

/datum/brain_trauma/psychological/schizophrenia/paranoid/proc/cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE, PSYCH_TRAIT)
	active = FALSE

/datum/brain_trauma/psychological/schizophrenia/paranoid/on_gain()
	ADD_TRAIT(owner, TRAIT_PARANOID, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/schizophrenia/paranoid/on_lose()
	if(active)
		cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_PARANOID, PSYCH_TRAIT)
	..()


/datum/brain_trauma/psychological/schizophrenia/catatonia
	name = "Catatonic schizophrenia"
	desc = "Mental disorder that is characterized by auditory and visual hallucinations"
	gain_text = "<span class='danger'>You feel your body not responding</span>"
	lose_text = "<span class='notice'>You feel free once again</span>"
	scan_desc = "Electric impulses detected in brain correspond to some form of schizophrenia"


/datum/brain_trauma/psychological/schizophrenia/catatonia/on_life()
	..()
	if(prob(25))
		owner.Jitter(4)
	addtimer(CALLBACK(src, .proc/roll_bad_effect()), rand(50, 300))


/datum/brain_trauma/psychological/schizophrenia/catatonia/proc/roll_bad_effect()
	clear_bad_effect()
	if(prob(20)) owner.apply_status_effect(STATUS_EFFECT_SPASMS)
	if(prob(20)) ADD_TRAIT(owner, TRAIT_MUTE, PSYCH_TRAIT)
	if(prob(20)) ADD_TRAIT(owner, TRAIT_MONKEYLIKE, PSYCH_TRAIT)
	if(prob(20)) owner.become_blind(PSYCH_TRAIT)
	if(prob(20)) owner.Unconscious(120)

/datum/brain_trauma/psychological/schizophrenia/catatonia/proc/clear_bad_effect()
	REMOVE_TRAIT(owner, TRAIT_MUTE, PSYCH_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_MONKEYLIKE, PSYCH_TRAIT)
	owner.remove_status_effect(STATUS_EFFECT_SPASMS)
	owner.cure_blind(PSYCH_TRAIT)

/datum/brain_trauma/psychological/schizophrenia/catatonia/on_gain()
	ADD_TRAIT(owner, TRAIT_CATATONIA, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/schizophrenia/catatonia/on_lose()
	REMOVE_TRAIT(owner, TRAIT_CATATONIA, PSYCH_TRAIT)
	..()
