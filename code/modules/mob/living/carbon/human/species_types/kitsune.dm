/datum/species/human/kitsune
	name = "Kitsune"
	id = SPECIES_KITSUNE
	examine_limb_id = SPECIES_HUMAN
	mutanttongue = /obj/item/organ/tongue/fox
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

/datum/species/human/kitsune/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.set_haircolor("#ff9900", update = FALSE) // pink
	human_for_preview.set_hairstyle("Long Bedhead", update = TRUE)

	var/obj/item/organ/ears/cat/cat_ears = human_for_preview.get_organ_by_type(/obj/item/organ/ears/cat)
	if (cat_ears)
		cat_ears.color = human_for_preview.hair_color
		human_for_preview.update_body()

/datum/species/human/kitsune/get_physical_attributes()
	return "Kitsunes are very similar to humans in almost all respects, with their biggest differences being the ability to lick their wounds, \
		and an increased sensitivity to noise, which is often detrimental. They are also rather fond of eating oranges."

/datum/species/human/kitsune/get_species_description()
	return "Kitsunes are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common. Meow?"

/datum/species/human/kitsune/get_species_lore()
	return list(
		"Bio-engineering at its felinest, kitsunes are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, kitsunes are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Kitsunes, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Kitsunes (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

// Kitsunes are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/kitsune/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "grin-tongue",
			SPECIES_PERK_NAME = "It's a perk, alright",
			SPECIES_PERK_DESC = "The UI will bluescreen if I don't have an entry in every one of these.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_PERSON_FALLING,
			SPECIES_PERK_NAME = "It sure is a perk",
			SPECIES_PERK_DESC = "I'm really hoping I can just have one of each.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "You have arrived at the third perk",
			SPECIES_PERK_DESC = "None of these actually do anything.",
		),
	)
	return to_add
