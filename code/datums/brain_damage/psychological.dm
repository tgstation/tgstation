//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain surgery to solve.

/datum/brain_trauma/psychological

/datum/brain_trauma/psychological/depression
	name = "Depression"
	desc = "Patient lacks serotionin intake"
	scan_desc = "extensive damage to serotonin receptors"
	gain_text = "<span class='warning'>You feel emptier inside!</span>"
	lose_text = "<span class='notice'>You feel whole once again.</span>"
	var/trait = TRAIT_DEPRESSION

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, trait, PSYCH_TRAIT)
	..()

/datum/brain_trauma/severe/mute/on_lose()
	REMOVE_TRAIT(owner, trait, PSYCH_TRAIT)
	..()

/datum/brain_trauma/psychological/depression/on_life()
	..()
	if(HAS_TRAIT(owner, TRAIT_FEARLESS))
		return
	if(prob(0.05))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)
	if(prob(0.1))
		owner.adjust_nutrition(rand(-6,0))
