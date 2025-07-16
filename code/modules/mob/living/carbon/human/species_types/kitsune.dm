/datum/species/human/kitsune
	name = "Kitsune"
	id = SPECIES_KITSUNE
	examine_limb_id = SPECIES_HUMAN
	mutantears = /obj/item/organ/ears/fox
	mutant_organs = list(
		/obj/item/organ/tail/fox = "Fox",
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/spinwarder

/datum/species/human/kitsune/get_laugh_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg'
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)


/datum/species/human/kitsune/get_cough_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)


/datum/species/human/kitsune/get_cry_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/human/kitsune/get_sneeze_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/human/kitsune/get_sigh_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/human/kitsune/get_sniff_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/human/kitsune/get_snore_sound(mob/living/carbon/human/kitsune)
	if(kitsune.physique == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/species/human/kitsune/get_physical_attributes()
	return "Kitsunes are very similar to humans in almost all respects, with the main distinction being their pointy ears and fluffy tails."

/datum/species/human/kitsune/get_species_description()
	return "Kitsunes are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common."

/datum/species/human/kitsune/get_species_lore()
	return "Created out of the domestic fox breeding program in the Third Soviet Union. \
		Kitsunes were created directly in response to the development of Felinids. \
		The Soviet geneticists failed to understand the point of Felinids, but they did match their freak."

/datum/species/human/kitsune/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "Grooming",
			SPECIES_PERK_DESC = "kitsunes can lick wounds to reduce bleeding.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "Catlike Grace",
			SPECIES_PERK_DESC = "kitsunes have catlike instincts allowing them to land upright on their feet.  \
				Instead of being knocked down from falling, you only receive a short slowdown. \
				However, they do not have catlike legs, and the fall will deal additional damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Sensitive Hearing",
			SPECIES_PERK_DESC = "kitsunes are more sensitive to loud sounds, such as flashbangs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shower",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "kitsunes don't like getting soaked with water.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_ANGRY,
			SPECIES_PERK_NAME = "'Fight or Flight' Defense Response",
			SPECIES_PERK_DESC = "kitsunes who become mentally unstable (and deprived of food) exhibit an \
				extreme 'fight or flight' response against aggressors. They sometimes bite people. Violently.",
		),
	)
	return to_add
