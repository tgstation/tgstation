/obj/item/disk/disease
	name = "blank GNA disk"
	desc = "A disk for storing the structure of a pathogen's Glycol Nucleic Acid pertaining to a specific symptom."
	var/datum/symptom/effect = null
	var/stage = 1

/obj/item/disk/disease/premade/New()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/symptom

/obj/item/disk/disease/examine(var/mob/user)
	..()
	if(effect)
		to_chat(user, "<span class='info'>Strength: [effect.multiplier]</span>")
		to_chat(user, "<span class='info'>Occurrence: [effect.chance]</span>")
