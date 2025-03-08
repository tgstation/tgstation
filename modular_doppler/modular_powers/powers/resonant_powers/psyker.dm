

/datum/power/paracausal
	name = "Paracausal Gland"
	desc = "An organ found only in the central nervous systems of Psykers that doesn't entirely exist on our plane of existence. \
	Technically a Deviancy; however, due to its nature, this gland does not interfere with advanced psychic abilities. Violently interferes with a Dantian."
	cost = 5
	root_power = /datum/power/paracausal
	power_type = TRAIT_PATH_SUBTYPE_PSYKER
	blacklist = list(/datum/power/astral_dantian, /datum/power/umbral_dantian)

/obj/item/organ/resonant/paracausal
	name = "paracausal gland"
	desc = "An organ found only in the central nervous systems of Psykers that doesn't entirely exist on our plane of existence. Technically a Deviancy; however, due to its nature, this gland does not interfere with advanced psychic abilities. Violently interferes with a Dantian."
	icon_state = "tongueplasma"
	w_class = WEIGHT_CLASS_TINY

/datum/power/paracausal/add(mob/living/carbon/human/target)
	var/obj/item/organ/resonant/paracausal/para_organ = new ()
	para_organ.Insert(target, special = TRUE)
