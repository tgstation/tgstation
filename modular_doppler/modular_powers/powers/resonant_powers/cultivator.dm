/**
 * Root Powers
 */

/datum/power/astral_dantian
	name = "Astral Dantian"
	desc = "An organ entirely made of Resonance located just behind the navel. It seems to be a battery of some sort. \
	Meditation now requires direct view of the stars to be productive. You can only have one Dantian."
	cost = 5
	root_power = /datum/power/astral_dantian
	blacklist = list(/datum/power/umbral_dantian, /datum/power/paracausal)
	power_type = TRAIT_PATH_SUBTYPE_CULTIVATOR

/obj/item/organ/resonant/astral_dantian
	name = "astral dantian"
	desc = "An organ entirely made of Resonance located just behind the navel. It seems to be a battery of some sort. Meditation now requires direct view of the stars to be productive. You can only have one Dantian."
	icon_state = "tongueplasma"
	w_class = WEIGHT_CLASS_TINY

/datum/power/astral_dantian/add(mob/living/carbon/human/target)
	var/obj/item/organ/resonant/astral_dantian/astrawl = new ()
	astrawl.Insert(target, special = TRUE)

/datum/power/umbral_dantian
	name = "Umbral Dantian"
	desc = "An organ entirely made of Resonance located just behind the navel. It seems to be a battery of some sort, \
	and grants the user night vision at the cost of requiring more food. Meditation requires absolute darkness to be productive. You can only have one Dantian."
	cost = 5
	root_power = /datum/power/umbral_dantian
	blacklist = list(/datum/power/astral_dantian, /datum/power/paracausal)
	power_type = TRAIT_PATH_SUBTYPE_CULTIVATOR

/obj/item/organ/resonant/umbral_dantian
	name = "Umbral dantian"
	desc = "An organ entirely made of Resonance located just behind the navel. It seems to be a battery of some sort, and grants the user night vision at the cost of requiring more food. Meditation requires absolute darkness to be productive. You can only have one Dantian."
	icon_state = "tongueplasma"
	w_class = WEIGHT_CLASS_TINY

/datum/power/umbral_dantian/add(mob/living/carbon/human/target)
	var/obj/item/organ/resonant/umbral_dantian/umbrawl = new ()
	umbrawl.Insert(target, special = TRUE)
