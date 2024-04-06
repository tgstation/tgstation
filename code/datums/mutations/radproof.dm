/datum/mutation/human/superradproof
	name = "Superior Radproof"
	desc = "Adapts the host's body to be better suited at preventing cancer caused by radioactivity at no expense to the host. Causes lots of instability and cannot be cured."
	quality = POSITIVE
	text_gain_indication = span_warning("You feel EVERYTHING in your bones!")
	instability = 40
	difficulty = 16
	mutadone_proof = TRUE

/datum/mutation/human/superradproof/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_RADIMMUNE, type)

/datum/mutation/human/superradproof/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, type)
