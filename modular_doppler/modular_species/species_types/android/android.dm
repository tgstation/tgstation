/datum/species/android
	name = "Android"
	id = SPECIES_ANDROID
	preview_outfit = /datum/outfit/android_preview
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
	exotic_blood = /datum/reagent/synth_blood
	exotic_bloodtype = "R*"

	bodytemp_heat_damage_limit = (BODYTEMP_NORMAL + 146) // 456 K / 183 C
	bodytemp_cold_damage_limit = (BODYTEMP_NORMAL - 80) // 230 K / -43 C

/datum/outfit/android_preview
	name = "Android (Species Preview)"
	uniform = /obj/item/clothing/under/syndicate/skirt

/datum/species/android/prepare_human_for_preview(mob/living/carbon/human/robot_for_preview)
	robot_for_preview.dna.features["frame_list"][BODY_ZONE_HEAD] = /obj/item/bodypart/head/robot/android/e_three_n
	regenerate_organs(robot_for_preview)
	robot_for_preview.update_body(is_creating = TRUE)

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
