/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	examine_limb_id = SPECIES_HUMAN
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBREATH,
		TRAIT_NOHUNGER,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_OVERDOSEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		/*TG traits we remove
		TRAIT_NOCRITDAMAGE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NOFIRE,
		TRAIT_NOBLOOD,
		TRAIT_NO_UNDERWEAR,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		*/
	)
	mutantheart = /obj/item/organ/internal/heart/cybernetic

//	bodytemp_heat_damage_limit =
//	bodytemp_cold_damage_limit =

/datum/species/android/get_physical_attributes()
	return "Androids are almost, but not quite, identical to fully augmented humans. \
	Unlike those, though, they're completely immune to toxin damage, don't have blood or organs (besides their head), don't get hungry, and can reattach their limbs! \
	That said, an EMP will devastate them and they cannot process any chemicals."

/datum/species/android/get_species_description()
	return "Androids are an entirely synthetic species."

/datum/species/android/get_species_lore()
	return list(
		"Androids are a synthetic species created by Nanotrasen as an intermediary between humans and cyborgs."
	)
