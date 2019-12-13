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

/datum/brain_trauma/psychological/social_anxiety/on_process()
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

/datum/brain_trauma/psychological/schizophrenia
	name = "Paranoid schizophrenia"
	desc = "Mental disorder that is characterized by auditory and visual hallucinations"
	gain_text = "<span class='danger'>You hear whispers behind you.</span>"
	lose_text = "<span class='notice'>Voices stop responding.</span>"
	scan_desc = "Electric impulses detected in brain correspond to some form of schizophrenia"
	var/active = FALSE

/datum/brain_trauma/psychological/schizophrenia/on_process()
	..()
	owner.hallucinations += 6
	if(prob(10))
		var/effect = pick(Jitter,Dizzy,blur_eyes)
		owner.effect(2)
	if(!active && prob(2))
		whispering()

/datum/brain_trauma/psychological/schizophrenia/proc/whispering()
	ADD_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = TRUE
	addtimer(CALLBACK(src, .proc/cease_whispering), rand(50, 300))

/datum/brain_trauma/psychological/schizophrenia/proc/cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SIXTHSENSE, TRAUMA_TRAIT)
	active = FALSE

/datum/brain_trauma/psychological/schizophrenia/on_gain()
	ADD_TRAIT(owner, TRAIT_SOCIAL_ANXIETY, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/schizophrenia/on_lose()
	if(active)
		cease_whispering()
	REMOVE_TRAIT(owner, TRAIT_SOCIAL_ANXIETY, PSYCH_TRAIT)
	..()
