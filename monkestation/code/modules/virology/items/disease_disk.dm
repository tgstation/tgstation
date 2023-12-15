/obj/item/disk/disease
	name = "blank GNA disk"
	desc = "A disk for storing the structure of a pathogen's Glycol Nucleic Acid pertaining to a specific symptom."
	var/datum/symptom/effect = null
	var/stage = 1

/obj/item/disk/disease/premade/New()
	name = "blank GNA disk (stage: [stage])"
	effect = new /datum/symptom

/obj/item/disk/disease/update_desc(updates)
	. = ..()
	desc = "[initial(desc)]\n"
	desc += "Strength: [effect.multiplier]\n"
	desc += "Occurrence: [effect.chance]"
