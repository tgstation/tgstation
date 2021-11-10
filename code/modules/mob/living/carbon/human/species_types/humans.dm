/datum/species/human
	name = "Human"
	id = SPECIES_HUMAN
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	mutant_bodyparts = list("wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | RAW | CLOTH
	liked_food = JUNKFOOD | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 1

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hairstyle = "Business Hair"
	human.hair_color = "#bb9966" // brown
	human.update_hair()

/datum/species/human/get_scream_sound(mob/living/carbon/human/human)
	if(human.gender == MALE)
		if(prob(1))
			return 'sound/voice/human/wilhelm_scream.ogg'
		return pick('sound/voice/human/malescream_1.ogg',
					'sound/voice/human/malescream_2.ogg',
					'sound/voice/human/malescream_3.ogg',
					'sound/voice/human/malescream_4.ogg',
					'sound/voice/human/malescream_5.ogg',
					'sound/voice/human/malescream_6.ogg')
	return pick('sound/voice/human/femalescream_1.ogg',
				'sound/voice/human/femalescream_2.ogg',
				'sound/voice/human/femalescream_3.ogg',
				'sound/voice/human/femalescream_4.ogg',
				'sound/voice/human/femalescream_5.ogg')
